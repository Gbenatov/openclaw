# video-use — Installation

## Requirements

- **ffmpeg** and **ffprobe** on `PATH` (hard requirements)
- **Python 3.10+**
- **ElevenLabs API key** stored in `.env` or as `ELEVENLABS_API_KEY` environment variable
- **yt-dlp** (optional — only needed to pull sources from URLs)

## 1. Install ffmpeg

```bash
# macOS
brew install ffmpeg

# Ubuntu / Debian
sudo apt install ffmpeg

# Verify
ffprobe -version
```

## 2. Install Python dependencies

```bash
pip install requests librosa matplotlib pillow numpy
```

Or, from the skill directory:

```bash
pip install -e skills/video-use
```

## 3. Set up ElevenLabs API key

Create a `.env` file in your project root (or set the environment variable):

```
ELEVENLABS_API_KEY=your_key_here
```

The transcription helpers load `.env` automatically. Never echo this key in output.

## 4. (Optional) Install yt-dlp for URL sources

```bash
pip install yt-dlp
# or
brew install yt-dlp
```

## 5. Verify

```bash
python skills/video-use/helpers/transcribe.py --help
python skills/video-use/helpers/render.py --help
ffprobe -version
```

## Animation frameworks (on-demand)

Install only if you need generated overlays:

```bash
# Manim
pip install manim

# Remotion (requires Node.js)
npx create-video@latest
```
