#!/bin/sh

set -e

if ! command -v unzip >/dev/null; then
	echo "Error: unzip is required to install turbot." 1>&2
	exit 1
fi

if ! command -v wget >/dev/null; then
    # no wget. check for curl
    if ! command -v curl >/dev/null; then
        echo "Error: either curl or wget is required to install turbot." 1>&2
        exit 1
    fi
fi

if [ "$OS" = "Windows_NT" ]; then
	target="windows"
else
	case $(uname -s) in
	Darwin) target="darwin" ;;
	*) target="linux" ;;
	esac
fi

if [ $# -eq 0 ]; then
	asset_path=$(
		curl -sSf https://github.com/turbot/cli/releases |
			grep -o "/turbot/cli/releases/download/.*/turbot_cli_.*_${target}_amd64\\.zip" |
			head -n 1
	)
	if [ ! "$asset_path" ]; then
		echo "Error: Unable to find latest turbot release on GitHub." 1>&2
		exit 1
	fi
	download_uri="https://github.com${asset_path}"
else
	download_uri="https://github.com/turbot/cli/releases/download/${1}/turbot_cli_${1}_${target}_amd64.zip"
fi

# create a temporary directory to download the zip
tmp_dir="$(mktemp -d)"
mkdir -p "${tmp_dir}"
tmp_dir="${tmp_dir%/}"

# location of the binary
bin_dir=${BINDIR:-/usr/local/bin}

# full path of the resultant binary
exe="$bin_dir/turbot"

# create the bin directory if it doesn't exist
if [ ! -d "$bin_dir" ]; then
	mkdir -p "$bin_dir"
fi

if command -v wget >/dev/null; then
    wget -q --show-progress -O "$tmp_dir/turbot_cli.zip" "$download_uri"
else
    curl --fail --location --progress-bar --output "$tmp_dir/turbot_cli.zip" "$download_uri"
fi

rm -f "$exe"
unzip -d "$tmp_dir" -o "$tmp_dir/turbot_cli.zip"
install "${tmp_dir}/turbot" "${bin_dir}/"
rm -rf "$tmp_dir"

if command -v turbot >/dev/null; then
	echo "Run 'turbot --help' to get started"
else
    echo "Failed"
fi
