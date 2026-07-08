#!/usr/bin/env bash
#
# wav_to_8svx.sh
#
# Recursively converts every .wav file found in the same directory as this
# script (and all its subdirectories) into Amiga 8SVX format, using the
# standard specs expected by ProTracker / OctaMED:
#
#     - 8-bit signed PCM
#     - Mono
#     - 8363 Hz sample rate (the standard Amiga/ProTracker "C-2" reference rate)
#
# Output is written to an "amiga-export" folder created next to this script,
# with the same subfolder structure as the source files.
#
# No arguments needed - just drop this script at the root of the folder
# tree you want converted and run it:
#
#     ./wav_to_8svx.sh
#
# Requires: sox
#   WSL/Debian/Ubuntu install:  sudo apt-get install sox
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Fixed Amiga/ProTracker/OctaMED 8SVX specs (not configurable by design)
# ---------------------------------------------------------------------------
SAMPLE_RATE=8363
BIT_DEPTH=8
CHANNELS=1
ENCODING="signed-integer"
OUT_EXT="8svx"

# ---------------------------------------------------------------------------
# Resolve root directory = the directory this script lives in
#
# `readlink -f` is GNU-only; macOS ships BSD readlink without -f support,
# so resolve the script's real path with a portable readlink/pwd loop instead.
# ---------------------------------------------------------------------------
resolve_script_path() {
    local target="$1"
    while [[ -L "$target" ]]; do
        local link
        link="$(readlink "$target")"
        if [[ "$link" == /* ]]; then
            target="$link"
        else
            target="$(dirname "$target")/$link"
        fi
    done
    echo "$target"
}

SCRIPT_PATH="$(cd "$(dirname "$(resolve_script_path "$0")")" && pwd)/$(basename "$(resolve_script_path "$0")")"
ROOT_DIR="$(dirname "$SCRIPT_PATH")"
OUTPUT_DIR="$ROOT_DIR/amiga-export"

# ---------------------------------------------------------------------------
# Sanity checks
# ---------------------------------------------------------------------------
if ! command -v sox >/dev/null 2>&1; then
    echo "Error: 'sox' is not installed or not on PATH." >&2
    echo "On WSL/Debian/Ubuntu, install it with:" >&2
    echo "    sudo apt-get update && sudo apt-get install -y sox" >&2
    echo "On macOS (with Homebrew), install it with:" >&2
    echo "    brew install sox" >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Root directory:    $ROOT_DIR"
echo "Output directory:  $OUTPUT_DIR"
echo "Format:             8SVX, ${BIT_DEPTH}-bit signed, ${CHANNELS}ch, ${SAMPLE_RATE} Hz"
echo ""

# ---------------------------------------------------------------------------
# Conversion
# ---------------------------------------------------------------------------
total=0
converted=0
failed=0

# Skip the amiga-export folder itself so re-running the script doesn't
# try to re-convert its own previous output.
while IFS= read -r -d '' wav_file; do
    total=$((total + 1))

    rel_path="${wav_file#"$ROOT_DIR"/}"
    rel_dir="$(dirname "$rel_path")"
    base_name="$(basename "$rel_path")"
    base_name_noext="${base_name%.[wW][aA][vV]}"

    dest_dir="$OUTPUT_DIR"
    if [[ "$rel_dir" != "." ]]; then
        dest_dir="$OUTPUT_DIR/$rel_dir"
    fi
    mkdir -p "$dest_dir"

    dest_file="$dest_dir/${base_name_noext}.${OUT_EXT}"

    echo "Converting: $rel_path"
    if sox "$wav_file" -b "$BIT_DEPTH" -c "$CHANNELS" -r "$SAMPLE_RATE" -e "$ENCODING" "$dest_file" 2>/tmp/sox_err.log; then
        converted=$((converted + 1))
    else
        failed=$((failed + 1))
        echo "  FAILED: $(cat /tmp/sox_err.log)" >&2
    fi
done < <(find "$ROOT_DIR" -type f -iname "*.wav" -not -path "$OUTPUT_DIR/*" -print0)

echo ""
echo "----------------------------------------"
echo "Done. Found: $total  Converted: $converted  Failed: $failed"
echo "Output written to: $OUTPUT_DIR"
