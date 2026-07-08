#!/usr/bin/env bash
#
# wav_to_8svx.sh (installed globally as `wav2amiga`)
#
# Recursively converts every .wav file found in the current working
# directory (and all its subdirectories) into Amiga 8SVX format, using the
# standard specs expected by ProTracker / OctaMED:
#
#     - 8-bit signed PCM
#     - Mono
#     - 8363 Hz sample rate (the standard Amiga/ProTracker "C-2" reference rate)
#
# Output is written to a "W2A-8SVX/<root-folder-name>" folder created in
# the current working directory, with the same subfolder structure as the
# source files.
#
# No arguments needed - install once (see README), then cd into any
# folder of .wav files and run:
#
#     wav2amiga
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
MAX_NAME_LEN=30   # AmigaOS OFS/FFS name limit (applies to files and folders alike)

# ---------------------------------------------------------------------------
# Resolve root directory = the directory the command was invoked from
# ---------------------------------------------------------------------------
ROOT_DIR="$(pwd)"
TOP_OUTPUT_DIR="$ROOT_DIR/W2A-8SVX"

root_name="$(basename "$ROOT_DIR")"
root_name_truncated="$root_name"
if (( ${#root_name} > MAX_NAME_LEN )); then
    root_name_truncated="${root_name:0:MAX_NAME_LEN}"
    echo "Note: truncated root folder name to fit Amiga's ${MAX_NAME_LEN}-char limit: '$root_name' -> '$root_name_truncated'"
fi

OUTPUT_DIR="$TOP_OUTPUT_DIR/$root_name_truncated"

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

# Skip the W2A-8SVX folder itself so re-running the script doesn't
# try to re-convert its own previous output.
while IFS= read -r -d '' wav_file; do
    total=$((total + 1))

    rel_path="${wav_file#"$ROOT_DIR"/}"
    rel_dir="$(dirname "$rel_path")"
    base_name="$(basename "$rel_path")"
    base_name_noext="${base_name%.[wW][aA][vV]}"

    max_base_len=$((MAX_NAME_LEN - ${#OUT_EXT} - 1))  # -1 for the dot
    truncated=0
    if (( ${#base_name_noext} > max_base_len )); then
        base_name_noext="${base_name_noext:0:max_base_len}"
        truncated=1
    fi

    dest_dir="$OUTPUT_DIR"
    if [[ "$rel_dir" != "." ]]; then
        dest_dir="$OUTPUT_DIR/$rel_dir"
    fi
    mkdir -p "$dest_dir"

    dest_file="$dest_dir/${base_name_noext}.${OUT_EXT}"

    echo "Converting: $rel_path"
    if (( truncated )); then
        echo "  Note: truncated filename to fit Amiga's ${MAX_NAME_LEN}-char limit -> $(basename "$dest_file")"
    fi
    if sox "$wav_file" -b "$BIT_DEPTH" -c "$CHANNELS" -r "$SAMPLE_RATE" -e "$ENCODING" "$dest_file" 2>/tmp/sox_err.log; then
        converted=$((converted + 1))
    else
        failed=$((failed + 1))
        echo "  FAILED: $(cat /tmp/sox_err.log)" >&2
    fi
done < <(find "$ROOT_DIR" -type f -iname "*.wav" -not -path "$TOP_OUTPUT_DIR/*" -print0)

echo ""
echo "----------------------------------------"
echo "Done. Found: $total  Converted: $converted  Failed: $failed"
echo "Output written to: $OUTPUT_DIR"
