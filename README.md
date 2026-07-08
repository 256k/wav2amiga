# wav2amiga

A small Bash script that batch-converts `.wav` files into Amiga `8SVX` format, using the sample specs expected by ProTracker / OctaMED.

## What it does

`wav_to_8svx.sh` recursively scans the directory it lives in (and all subdirectories) for `.wav` files and converts each one to `8SVX` using [`sox`](http://sox.sourceforge.net/):

- 8-bit signed PCM
- Mono
- 8363 Hz sample rate (the standard Amiga/ProTracker "C-2" reference rate)

Converted files are written to an `amiga-export` folder created next to the script, mirroring the original subfolder structure. The `amiga-export` folder itself is skipped when scanning, so the script can be safely re-run.

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

## Usage

Drop the script at the root of the folder tree containing the `.wav` files you want to convert, then run it:

```bash
./wav_to_8svx.sh
```

No arguments are needed. The script will print progress for each file and a summary (found / converted / failed) when finished.

## Output

For an input file at `ROOT/some/subfolder/kick.wav`, the output will be written to `ROOT/amiga-export/some/subfolder/kick.8svx`.

---

*This script and README were written with the help of an LLM (Claude).*
