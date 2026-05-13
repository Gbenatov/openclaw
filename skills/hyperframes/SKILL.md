---
name: hyperframes
description: HTML-native motion-graphics production — compose animated short-form video via GSAP + HyperFrames, render to MP4 or ProRes MOV with alpha. Use for motion overlays on top of video-use footage.
homepage: https://hyperframes.heygen.com
metadata:
  {
    "openclaw":
      {
        "emoji": "✨",
        "requires": { "bins": ["node", "npx", "ffmpeg"] },
        "install":
          [
            {
              "id": "npm-hyperframes",
              "kind": "shell",
              "cmd": "npm install hyperframes",
              "label": "Install HyperFrames (run from inside project folder)",
            },
          ],
      },
  }
---

# HyperFrames — Motion-Graphics Production

HTML-native video framework from HeyGen. Compose animations as regular HTML files with paused GSAP timelines attached to `window.__timelines`, render to MP4 (or ProRes 4444 MOV with alpha for compositing). Designed for short-form vertical video, product demos, and motion-graphic overlays.

## BEFORE ANY CREATIVE SESSION

1. **Read `{baseDir}/MOTION_PHILOSOPHY.md` in full** — the 11 Laws, the pre-flight checklist, and “What Would Infinite Do?” (Section 5). Never skim. The doc evolves.
2. Re-read **Section 0 (11 Laws)** and **Section 4 (pre-flight checklist)** every time, even on quick iterations.
3. If the brand has a `DESIGN.md`, read it. See `{baseDir}/DESIGN.ais-example.md` for the pattern.
4. Run `npx hyperframes doctor` to verify Node, FFmpeg, and Chrome are available.

## Key Commands

```bash
# Always run from inside the project folder, not the workspace root
npx hyperframes preview           # Live Studio on http://localhost:3002 with hot reload
npx hyperframes lint              # Static HTML validation — always run before rendering
npx hyperframes compositions      # List comp IDs + resolved durations

# Rendering
npx hyperframes render --quality draft    --output renders/draft.mp4    # fast iteration
npx hyperframes render --quality standard --output renders/final.mp4    # visually lossless 1080p
npx hyperframes render --quality high     --docker                      # archival/deterministic
npx hyperframes render --format mov --quality standard --output renders/overlay.mov  # alpha channel

# Catalog
npx hyperframes catalog --type block      # browse 38 blocks
npx hyperframes catalog --type component  # browse 3 components
npx hyperframes add <name>                # install block into compositions/

# Media pipeline
npx hyperframes transcribe <file> --model small.en --json   # word-level timestamps
npx hyperframes tts "text" --voice am_adam --output narration.wav       # on-device TTS

# Diagnostics
npx hyperframes doctor            # env check (Node, FFmpeg, Chrome, Docker)
npx hyperframes benchmark         # find optimal workers/quality
npx hyperframes info --json       # project stats
npx hyperframes docs <topic>      # inline docs
```

### Render Flags

| Flag | Values | Notes |
|---|---|---|
| `--quality` | `draft` / `standard` / `high` | CRF 28 / 18 / 15 |
| `--fps` | `24` / `30` / `60` | Default 30 |
| `--format` | `mp4` / `mov` / `webm` | `mov` = ProRes 4444 with alpha (for compositing) |
| `--workers <n>` | integer | Parallelism |
| `--gpu` | flag | GPU-accelerated render |
| `--crf <n>` | integer | Override CRF directly |

## Authoring Loop (mandatory gates)

1. Read `MOTION_PHILOSOPHY.md` at the start of the session
2. Edit compositions in `index.html` or `compositions/<name>.html`
3. `npx hyperframes lint` — fix all errors, triage warnings
4. **Gate 1 — Live Studio preview** before any render: `npx hyperframes preview` → hand the URL, wait for sign-off
5. `render --quality draft` — extract one frame per scene, call `Read` on every PNG, verify visually
6. **Gate 2 — Rendered MP4 preview** before final: serve via `npx serve . -p 8080 -n`, wait for sign-off
7. `render --quality standard` for final delivery

**Visual verification is mandatory before delivery.** Lint passing ≠ design working.

```bash
# Frame extraction for visual verification
mkdir -p renders/frames
for t in 1 3 5 8 12 18 25; do
  ffmpeg -y -ss $t -i renders/draft.mp4 -frames:v 1 -q:v 2 "renders/frames/t${t}.png"
done
```

## Project Layout

```
my-video/
├── index.html                 ← root composition, chains sub-compositions via <template data-composition-src>
├── compositions/
│   ├── 01-intro.html
│   ├── 02-main.html
│   └── components/            ← shared snippets (npx hyperframes add)
├── assets/                    ← videos, images, audio, transcripts
├── renders/                   ← output MP4s/MOVs (gitignored)
├── hyperframes.json           ← CLI config (relative paths, registry URL)
└── meta.json                  ← project id, name, dimensions, fps
```

## Render Contract (non-negotiable)

1. Root `<div>`: must have `id`, `data-composition-id`, `data-start="0"`, `data-width`, `data-height`
2. Timed visible elements: `class="clip"` — **except** `<video>` and `<audio>` (breaks them)
3. Every timed element: `data-start`, `data-duration`, `data-track-index`
4. `data-start` can reference another clip’s id: `data-start="intro"`, `data-start="intro + 2"`
5. Same-track clips cannot overlap — use different `data-track-index` values
6. Every GSAP timeline: paused, registered as `window.__timelines["<data-composition-id>"]`
7. **Every timeline ends with `tl.to({}, { duration: SLOT_DURATION }, 0)`** — prevents black-frame flashes (Law #11)
8. No `.play()`, `.pause()`, or `.currentTime` on media — the framework owns playback
9. Never animate `width`/`height`/`top`/`left` on `<video>` — wrap in a `<div>`
10. No `Math.random()`, `Date.now()`, unseeded PRNGs — renders must be deterministic
11. Sub-compositions use `<template>` + `data-composition-src` — never `masterTL.add(child)`

## Timeline Pattern

```js
(() => {
  const tl = gsap.timeline({ paused: true });
  const SLOT_DURATION = 5.0; // must match data-duration on the host element

  // ... your tweens ...

  tl.to({}, { duration: SLOT_DURATION }, 0); // Law #11 anchor — non-negotiable
  window.__timelines['my-comp-id'] = tl;
})();
```

## Timeline-Duration Diagnostic

```js
// Run in devtools console while Studio is open
const p = document.querySelector('hyperframes-player');
const iw = p.shadowRoot.querySelector('iframe').contentWindow;
Object.fromEntries(Object.entries(iw.__timelines).map(([k, v]) =>
  [k, +v.duration().toFixed(4)]));
// Any value shorter than its data-duration = black-frame risk
```

## Registry Blocks (38 available)

Install with `npx hyperframes add <name>`:

**Transitions:** `whip-pan`, `cinematic-zoom`, `cross-warp-morph`, `flash-through-white`, `light-leak`, `swirl-vortex`, `glitch`, `chromatic-radial-split`, `domain-warp-dissolve`, `gravitational-lens`, `ripple-waves`, `sdf-iris`, `thermal-distortion`

**CSS Transition Packs:** `transitions-3d`, `transitions-blur`, `transitions-cover`, `transitions-destruction`, `transitions-dissolve`, `transitions-distortion`, `transitions-grid`, `transitions-light`, `transitions-mechanical`, `transitions-other`, `transitions-push`, `transitions-radial`, `transitions-scale`

**Overlays/Textures:** `grain-overlay`, `shimmer-sweep`, `grid-pixelate-wipe`

**Social:** `instagram-follow`, `tiktok-follow`, `yt-lower-third`, `x-post`, `reddit-post`, `spotify-card`, `macos-notification`

**Data/UI:** `data-chart`, `flowchart`, `app-showcase`, `ui-3d-reveal`, `logo-outro`

## Integration with video-use

HyperFrames renders overlays as **ProRes 4444 MOV with alpha channel** (`--format mov`). These feed directly into `video-use`’s EDL `overlays` field and are composited by `render.py`:

```json
{
  "sources": { "footage": "/path/to/footage.mp4" },
  "ranges": [{ "source": "footage", "start": 0, "end": 30 }],
  "grade": "auto",
  "subtitles": "edit/master.srt",
  "overlays": [
    {
      "file": "/path/to/my-video/renders/overlay.mov",
      "start_in_output": 5.0,
      "duration": 8.0
    }
  ]
}
```

**Full pipeline:**

```bash
# 1. Edit and render the motion-graphics overlay
cd my-video
npx hyperframes render --format mov --quality standard --output renders/overlay.mov

# 2. Transcribe footage
python skills/video-use/helpers/transcribe.py footage.mp4

# 3. Render the final composite (grade + overlay + subtitles + loudnorm)
python skills/video-use/helpers/render.py edit/edl.json -o edit/final.mp4 --build-subtitles
```

## Prompting Shorthand

- **Motion easing:** smooth / snappy / bouncy / springy / dramatic / dreamy
- **Caption energy:** hype / corporate / tutorial / storytelling / social
- **Transition energy:** calm (blur) / medium (push) / high (zoom, glitch)
- **Audio reactivity:** bass→scale, treble→glow, amplitude→opacity, mids→shape

## Documentation

- Agent index: https://hyperframes.heygen.com/llms.txt
- Full site: https://hyperframes.heygen.com/introduction
- Inline: `npx hyperframes docs <topic>` — topics: `data-attributes`, `gsap`, `rendering`, `examples`, `troubleshooting`, `compositions`
- Block catalog: `https://hyperframes.heygen.com/catalog/blocks/<slug>`
- Component catalog: `https://hyperframes.heygen.com/catalog/components/<slug>`
