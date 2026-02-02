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

## License & Terms

The Turbot Guardrails CLI is closed source, proprietary software. It may be [downloaded
here](https://github.com/turbot/guardrails-cli/releases) and is subject to the [LICENSE](./LICENSE).

Documentation and examples in this repository are available under the [Apache
2.0 License](./LICENSE-DOCS).
