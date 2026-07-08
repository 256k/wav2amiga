# wav2amiga

A small Bash script that batch-converts `.wav` files into Amiga `8SVX` format, using the sample specs expected by ProTracker / OctaMED.

## What it does

`wav_to_8svx.sh` (installed as the `wav2amiga` command) recursively scans the current working directory (and all subdirectories) for `.wav` files and converts each one to `8SVX` using [`sox`](http://sox.sourceforge.net/):

- 8-bit signed PCM
- Mono
- 8363 Hz sample rate (the standard Amiga/ProTracker "C-2" reference rate)

Converted files are written to a `W2A-8SVX-8363hz/<root-folder-name>` folder created in the current working directory, mirroring the original subfolder structure (the sample rate in the folder name reflects the fixed 8363 Hz output rate above). `<root-folder-name>` is the name of the folder you ran the command from, truncated if needed to fit AmigaOS's 30-character name limit. The `W2A-8SVX-8363hz` folder itself is skipped when scanning, so the command can be safely re-run.

Individual output filenames are also truncated to fit the same 30-character limit (including the `.8svx` extension), since classic AmigaOS filesystems (OFS/FFS) reject or mangle longer names.

Works on both Linux and macOS.

## Requirements

- `sox`

Install on WSL/Debian/Ubuntu:

```bash
sudo apt-get update && sudo apt-get install -y sox
```

Install on macOS (via [Homebrew](https://brew.sh/)):

```bash
brew install sox
```

## Installation

Symlink the script into a directory that's already on your `PATH`, under the name `wav2amiga`. A symlink (rather than a shell alias) is used so the command works from any shell and any context — interactive, scripted, or otherwise — without per-shell config:

```bash
chmod +x wav_to_8svx.sh
ln -s "$(pwd)/wav_to_8svx.sh" ~/.local/bin/wav2amiga
```

(`~/.local/bin` is a common personal-bin location; use whichever directory is already on your `PATH`, e.g. `~/bin` or `/opt/homebrew/bin`. Check with `echo $PATH`.)

## Usage

`cd` into any folder of `.wav` files you want to convert, then run:

```bash
wav2amiga
```

No arguments are needed. The command will print progress for each file and a summary (found / converted / failed) when finished.

## Output

If you run `wav2amiga` inside a folder named `mysamples`, an input file at `mysamples/some/subfolder/kick.wav` will be written to `mysamples/W2A-8SVX-8363hz/mysamples/some/subfolder/kick.8svx`.

If either the root folder name or a converted filename (including its `.8svx` extension) would exceed 30 characters, it's truncated to fit, and the script prints a note when this happens.

---

*This script and README were written with the help of an LLM (Claude).*
