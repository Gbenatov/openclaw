---
name: video-use
description: Conversation-driven video editor — trim, grade, subtitle, and overlay footage through natural language. Drop raw footage in a folder, describe what you want, receive a finished final.mp4.
homepage: https://github.com/browser-use/video-use
metadata:
  {
    "openclaw":
      {
        "emoji": "🎬",
        "requires": { "bins": ["ffmpeg", "ffprobe", "python3"] },
        "env":
          [
            {
              "key": "ELEVENLABS_API_KEY",
              "label": "ElevenLabs API key (for transcription)",
              "secret": true,
            },
          ],
        "install":
          [
            {
              "id": "brew-ffmpeg",
              "kind": "brew",
              "formula": "ffmpeg",
              "bins": ["ffmpeg", "ffprobe"],
              "label": "Install ffmpeg (brew)",
            },
            {
              "id": "pip-deps",
              "kind": "shell",
              "cmd": "pip install requests librosa matplotlib pillow numpy",
              "label": "Install Python dependencies",
            },
          ],
      },
  }
---

# Video Use: Production-Correctness Editing Framework

Conversation-driven video editor. Drop raw footage in a folder, chat with Claude, receive a finished `final.mp4`. No traditional video editing interface required.

## Core Philosophy

Audio is primary. The system reasons from a phrase-level transcript with word-level timestamps (≈12 KB for a 1-hour video) rather than dumping frames. On-demand filmstrip + waveform visuals are generated only at decision points.

## Workflow

1. **Inventory** — list source files and check for existing transcripts
2. **Pre-scan** — flag obvious problems (silence, retakes, bad audio events)
3. **Conversation** — ask questions shaped by the material
4. **Propose strategy** — describe the edit plan and confirm with the user
5. **Execute** — transcribe → pack → build EDL → render
6. **Self-evaluate** — inspect every cut boundary before showing output
7. **Iterate** — refine based on feedback

## The Six Non-Negotiable Rules

1. **Subtitle order** — captions are applied *last*, after all overlays, so text is never hidden
2. **Per-segment extraction** — extract each range separately, then concat losslessly to avoid double-encoding
3. **Audio fades** — 30 ms fade-in + fade-out at every segment boundary to eliminate pops
4. **Overlay PTS-shift** — use `setpts=PTS-STARTPTS+T/TB` so animation frame 0 lands at the right output time
5. **Subtitle timeline math** — output offset = `word.start − segment_start + segment_offset`
6. **Word-boundary snapping** — never cut mid-word; pad cut edges 30–200 ms inside the nearest word boundary

Additional rules: never re-transcribe an unchanged source (cache hits); spawn overlay sub-agents in parallel, never sequentially; always confirm strategy before executing.

## Helpers

All helpers live in `{baseDir}/helpers/`. Run them with `python {baseDir}/helpers/<script>.py`.

| Script | Purpose |
|---|---|
| `transcribe.py` | Transcribe one video via ElevenLabs Scribe (word-level timestamps, diarization) |
| `transcribe_batch.py` | Parallel batch transcription of a whole directory |
| `pack_transcripts.py` | Convert raw transcript JSON → `takes_packed.md` phrase view |
| `render.py` | Render an `edl.json` → final MP4 (grade, concat, subtitles, loudnorm) |
| `grade.py` | Apply or analyze color grades; auto-grade per clip |
| `timeline_view.py` | Generate filmstrip + waveform PNG for on-demand visual drill-down |

## Key Artifacts

- **`takes_packed.md`** — phrase-level transcript with `[start-end]` timestamps; the primary reading view for cut decisions
- **`edl.json`** — Edit Decision List: sources, cut ranges, grade, overlays, subtitles
- **`project.md`** — session memory; append notes chronologically across sessions

## EDL Format

```json
{
  "sources": {
    "take1": "/path/to/take1.mp4"
  },
  "ranges": [
    { "source": "take1", "start": 12.4, "end": 27.8, "note": "intro" },
    { "source": "take1", "start": 45.0, "end": 61.2, "note": "main point" }
  ],
  "grade": "auto",
  "subtitles": "edit/master.srt",
  "overlays": []
}
```

## Quick Start

```bash
# 1. Transcribe
python {baseDir}/helpers/transcribe.py /path/to/video.mp4

# 2. Pack transcripts into readable view
python {baseDir}/helpers/pack_transcripts.py --edit-dir /path/to/video_parent/edit

# 3. Render from EDL
python {baseDir}/helpers/render.py edit/edl.json -o edit/final.mp4 --build-subtitles

# 4. Visual drill-down on a cut boundary
python {baseDir}/helpers/timeline_view.py /path/to/video.mp4 45.0 65.0
```

## Quality Tiers

| Flag | Resolution | Preset | CRF | Use |
|---|---|---|---|---|
| *(default)* | 1080p | fast | 20 | Final deliverable |
| `--preview` | 1080p | medium | 22 | QC review |
| `--draft` | 720p | ultrafast | 28 | Cut-point check |

## Notes

- Output always lands in `<videos_dir>/edit/`; source files are never modified.
- Audio is normalized to −14 LUFS / −1 dBTP / LRA 11 (social platform standard) by default. Use `--no-loudnorm` to skip.
- HDR sources (PQ/HLG) are automatically tone-mapped to Rec.709 SDR to prevent oversaturation on upload.
- Subtitles default to 2-word UPPERCASE chunks with `MarginV=90` — safe above platform UI on all vertical-video platforms.
