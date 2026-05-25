# Turbot Guardrails CLI

Command line tooling for Turbot Guardrails - used by developers to write scripts and
create mods.

## Documentation

* `turbot --help`
* [CLI in 7 minutes](https://turbot.com/guardrails/docs/7-minute-labs/cli)
* [Command Reference](https://turbot.com/guardrails/docs/reference/cli/commands)
* [Release Notes](https://turbot.com/guardrails/changelog?tag=cli)

## Installation

### Homebrew (macOS & Linux)

```bash
brew install turbot/tap/guardrails-cli
```

### Install Script (macOS & Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/turbot/guardrails-cli/master/install.sh | sh
```

Options:
```bash
# Install to a custom directory
curl -fsSL https://raw.githubusercontent.com/turbot/guardrails-cli/master/install.sh | sh -s -- -b ~/.local/bin

# Install a specific version
curl -fsSL https://raw.githubusercontent.com/turbot/guardrails-cli/master/install.sh | sh -s -- v1.32.0
```

### Manual Download

Download the latest release from the [Releases page](https://github.com/turbot/guardrails-cli/releases) and extract to a directory in your PATH.

### Verify Installation

```bash
turbot --version
```

## Troubleshooting

### `turbot download` fails with `body.on is not a function`

**Affected versions:** v1.32.x, v1.33.x  
**Tracked in:** [#63](https://github.com/turbot/guardrails-cli/issues/63)

`turbot download` exits with `Failed to download mod: re.body.on is not a function` and leaves an empty zip file. This is caused by the CLI calling `.on('data', ...)` on a native `fetch()` response body, which is a Web `ReadableStream` rather than a Node.js `stream.Readable` and does not expose `.on()`.

**Workaround:** Capture the pre-signed S3 URL from the CLI's internal fetch calls and download it directly with `curl`:

```bash
# Step 1: Create a fetch interceptor that logs all URLs
cat > /tmp/log-fetch-url.js << 'PATCH'
const origFetch = globalThis.fetch;
const fs = require('fs');
globalThis.fetch = async function(...args) {
  const url = typeof args[0] === 'string' ? args[0] : (args[0]?.url || '');
  fs.appendFileSync('/tmp/turbot-s3-urls.log', url + '\n');
  return origFetch(...args);
};
PATCH

# Step 2: Run the download command (it will fail, but the URL gets logged)
rm -f /tmp/turbot-s3-urls.log
NODE_OPTIONS='--require /tmp/log-fetch-url.js' turbot download @turbot/aws-lambda --mod-version="5.19.1" 2>/dev/null || true

# Step 3: Download the zip directly from the captured S3 URL
S3_URL=$(grep 's3.amazonaws.com' /tmp/turbot-s3-urls.log | tail -1)
curl -L -o turbot_aws-lambda.zip "$S3_URL"

# Step 4: Upload to your workspace as usual
turbot up --zip-file="turbot_aws-lambda.zip" --profile <your-profile>
```

**Fix (for CLI maintainers):** Replace the Node.js stream event listener pattern in the download implementation with `Readable.fromWeb()`:

```js
// Before (broken with native fetch — Web ReadableStream has no .on()):
const re = await fetch(url);
re.body.on('data', chunk => fileStream.write(chunk));
re.body.on('end', () => fileStream.end());
re.body.on('error', err => fileStream.destroy(err));

// After (works with native fetch):
import { Readable } from 'node:stream';
import { pipeline } from 'node:stream/promises';

const re = await fetch(url);
await pipeline(Readable.fromWeb(re.body), fileStream);
```

`Readable.fromWeb()` is available since Node.js 17.5 / 16.15 — see [Node.js stream docs](https://nodejs.org/api/stream.html#streamreadablefromwebreadablestream-options).

## License & Terms

The Turbot Guardrails CLI is closed source, proprietary software. It may be [downloaded
here](https://github.com/turbot/guardrails-cli/releases) and is subject to the [LICENSE](./LICENSE).

Documentation and examples in this repository are available under the [Apache
2.0 License](./LICENSE-DOCS).
