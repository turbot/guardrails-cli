#!/usr/bin/env bash
#
# Generate a versioned Homebrew formula for the Guardrails CLI.
#
# guardrails-cli builds via Node.js SEA (compile-sea.sh), not GoReleaser, so
# there is no `brews:` block to render the formula. This script is the
# equivalent: it reads the sha256 checksums produced by the release job and
# writes a versioned formula file (e.g. Formula/guardrails-cli@1.33.1.rb) whose
# class is GuardrailsCliAT<digits>, matching the convention the homebrew-tap
# promote script (scripts/formula_versioning_guardrails.sh) expects.
#
# Usage:
#   generate-homebrew-formula.sh <version> <checksums-file> <output-file>
#
#   <version>        Release version, with or without a leading 'v' (e.g. 1.33.1).
#   <checksums-file> checksums.txt from the release (sha256sum *.zip output).
#   <output-file>    Path to write the .rb formula to.

set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <version> <checksums-file> <output-file>" >&2
  exit 1
fi

VERSION="${1#v}"
CHECKSUMS="$2"
OUTFILE="$3"

if [ ! -f "$CHECKSUMS" ]; then
  echo "ERROR: checksums file not found: $CHECKSUMS" >&2
  exit 1
fi

# Class name / versioned filename use the base semver (no prerelease suffix),
# mirroring GoReleaser's steampipe@{Major}.{Minor}.{Patch} naming.
BASE_VERSION="${VERSION%%-*}"
CLASS_SUFFIX="$(printf '%s' "$BASE_VERSION" | tr -d '.')"

sha_for() {
  platform="$1"
  line="$(grep "turbot_cli_${VERSION}_${platform}.zip\$" "$CHECKSUMS" || true)"
  if [ -z "$line" ]; then
    echo "ERROR: no checksum for turbot_cli_${VERSION}_${platform}.zip in ${CHECKSUMS}" >&2
    echo "checksums.txt contents:" >&2
    cat "$CHECKSUMS" >&2
    exit 1
  fi
  printf '%s' "$line" | awk '{print $1}'
}

SHA_DARWIN_AMD64="$(sha_for darwin_amd64)"
SHA_DARWIN_ARM64="$(sha_for darwin_arm64)"
SHA_LINUX_AMD64="$(sha_for linux_amd64)"

cat > "$OUTFILE" <<EOF
# typed: false
# frozen_string_literal: true

class GuardrailsCliAT${CLASS_SUFFIX} < Formula
  desc "Command line tooling for Turbot Guardrails - used by developers to write scripts and create mods"
  homepage "https://turbot.com/guardrails/docs/reference/cli"
  version "${VERSION}"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/turbot/guardrails-cli/releases/download/v${VERSION}/turbot_cli_${VERSION}_darwin_amd64.zip"
      sha256 "${SHA_DARWIN_AMD64}"

      def install
        bin.install "turbot"
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/turbot/guardrails-cli/releases/download/v${VERSION}/turbot_cli_${VERSION}_darwin_arm64.zip"
      sha256 "${SHA_DARWIN_ARM64}"

      def install
        bin.install "turbot"
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/turbot/guardrails-cli/releases/download/v${VERSION}/turbot_cli_${VERSION}_linux_amd64.zip"
      sha256 "${SHA_LINUX_AMD64}"
      def install
        bin.install "turbot"
      end
    end
  end
end
EOF

echo "Wrote ${OUTFILE} (class GuardrailsCliAT${CLASS_SUFFIX}, version ${VERSION})"
