#!/bin/sh
# Turbot CLI installer script
# TODO(everyone): Keep this script simple and easily auditable.

set -e

# Configuration
OWNER="turbot"
REPO="guardrails-cli"
BINARY_NAME="turbot"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required commands
check_requirements() {
    if ! command_exists unzip; then
        echo "Error: 'unzip' is required to install Turbot CLI." 1>&2
        exit 1
    fi

    if ! command_exists install; then
        echo "Error: 'install' is required to install Turbot CLI." 1>&2
        exit 1
    fi
}

# Detect OS and architecture
detect_platform() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)

    case "$OS" in
        darwin)
            OS="darwin"
            ;;
        linux)
            OS="linux"
            ;;
        mingw*|msys*|cygwin*)
            OS="windows"
            ;;
        *)
            echo "Error: Unsupported operating system '$OS'." 1>&2
            exit 1
            ;;
    esac

    case "$ARCH" in
        x86_64|amd64)
            ARCH="amd64"
            ;;
        aarch64|arm64)
            # For darwin arm64, use amd64 binary (runs via Rosetta 2)
            if [ "$OS" = "darwin" ]; then
                echo "Note: Apple Silicon detected. Using amd64 binary (runs via Rosetta 2)."
                ARCH="amd64"
            else
                # Linux arm64 not currently supported
                echo "Error: arm64 architecture is not supported on Linux yet." 1>&2
                exit 1
            fi
            ;;
        *)
            echo "Error: Unsupported architecture '$ARCH'." 1>&2
            exit 1
            ;;
    esac
}

# Get the latest release version from GitHub
get_latest_version() {
    if command_exists curl; then
        VERSION=$(curl -sSfL "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" 2>/dev/null | grep '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')
    elif command_exists wget; then
        VERSION=$(wget -qO- "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" 2>/dev/null | grep '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')
    else
        echo "Error: Unable to find curl or wget to check for latest version." 1>&2
        exit 1
    fi

    if [ -z "$VERSION" ]; then
        echo "Error: Unable to determine latest version." 1>&2
        exit 1
    fi

    # Remove 'v' prefix if present for archive naming
    VERSION_NUM=${VERSION#v}
}

# Download the archive
download_archive() {
    local url="$1"
    local dest="$2"

    echo "Downloading from $url"

    if command_exists curl; then
        if ! curl --fail --location --progress-bar --output "$dest" "$url"; then
            echo "Error: Could not download from $url" 1>&2
            exit 1
        fi
    elif command_exists wget; then
        # Check for --show-progress support
        if wget --help 2>&1 | grep -q '\--show-progress'; then
            PROGRESS_OPT="--no-verbose --show-progress"
        else
            PROGRESS_OPT=""
        fi
        if ! wget --prefer-family=IPv4 --progress=bar:force:noscroll $PROGRESS_OPT -O "$dest" "$url"; then
            echo "Error: Could not download from $url" 1>&2
            exit 1
        fi
    else
        echo "Error: Unable to find curl or wget to download." 1>&2
        exit 1
    fi
}

# Main installation function
install_turbot_cli() {
    check_requirements
    detect_platform

    # Parse arguments
    BINDIR="${BINDIR:-/usr/local/bin}"
    VERSION=""

    while [ $# -gt 0 ]; do
        case "$1" in
            -b)
                if [ -z "$2" ] || [ "${2#-}" != "$2" ]; then
                    echo "Error: -b requires a directory argument." 1>&2
                    usage
                fi
                BINDIR="$2"
                shift 2
                ;;
            -h|--help)
                usage
                ;;
            *)
                VERSION="$1"
                shift
                ;;
        esac
    done

    # Get version if not specified
    if [ -z "$VERSION" ]; then
        echo "Checking GitHub for latest version..."
        get_latest_version
    else
        # Ensure version has 'v' prefix for URL
        case "$VERSION" in
            v*) VERSION_NUM=${VERSION#v} ;;
            *)  VERSION_NUM="$VERSION"; VERSION="v$VERSION" ;;
        esac
    fi

    echo "Installing Turbot CLI ${VERSION} for ${OS}/${ARCH}"

    # Determine binary name inside the archive based on OS
    case "$OS" in
        darwin)
            BINARY_INSIDE="turbot-macos-amd64"
            ;;
        linux)
            BINARY_INSIDE="turbot-linux-amd64"
            ;;
        windows)
            BINARY_INSIDE="turbot-windows-amd64.exe"
            ;;
    esac

    # Construct archive name and URL
    ARCHIVE_NAME="turbot_cli_${VERSION_NUM}_${OS}_${ARCH}.zip"
    DOWNLOAD_URL="https://github.com/${OWNER}/${REPO}/releases/download/${VERSION}/${ARCHIVE_NAME}"

    # Create temporary directory
    TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TMP_DIR"' EXIT

    echo "Created temporary directory at $TMP_DIR"

    # Download the archive
    ARCHIVE_PATH="${TMP_DIR}/${ARCHIVE_NAME}"
    download_archive "$DOWNLOAD_URL" "$ARCHIVE_PATH"

    # Extract the archive
    echo "Extracting archive..."
    unzip -q "$ARCHIVE_PATH" -d "$TMP_DIR"

    # Determine the installed binary name (preserve .exe on Windows)
    if [ "$OS" = "windows" ]; then
        INSTALLED_BINARY="${BINARY_NAME}.exe"
    else
        INSTALLED_BINARY="${BINARY_NAME}"
    fi

    # Install the binary
    echo "Installing to ${BINDIR}/${INSTALLED_BINARY}..."
    install -d "$BINDIR"
    install -m 755 "${TMP_DIR}/${BINARY_INSIDE}" "${BINDIR}/${INSTALLED_BINARY}"

    echo ""
    echo "Turbot CLI was installed successfully to ${BINDIR}/${INSTALLED_BINARY}"

    # Verify installation
    if command_exists "${BINDIR}/${INSTALLED_BINARY}"; then
        echo "Run '${INSTALLED_BINARY} --help' to get started."
    else
        echo "Warning: Turbot CLI was installed, but '${BINDIR}/${INSTALLED_BINARY}' is not in your PATH." 1>&2
        echo "Add '${BINDIR}' to your PATH or use the full path to run the CLI." 1>&2
    fi
}

usage() {
    cat <<EOF
Turbot CLI Installer

Usage: $0 [-b bindir] [version]

Options:
  -b DIR      Installation directory (default: /usr/local/bin)
  -h, --help  Show this help message

Arguments:
  version     Specific version to install (e.g., v1.0.0)
              If not specified, installs the latest version.

Examples:
  $0                    Install latest version to /usr/local/bin
  $0 v1.0.0             Install version v1.0.0
  $0 -b ~/.local/bin    Install to ~/.local/bin

EOF
    exit 0
}

# Run the installer
install_turbot_cli "$@"
