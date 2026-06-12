---
name: hyperframes
description: HTML-native motion-graphics video production — author GSAP timelines in plain HTML, preview live, and render to MP4. Primary tool for generating overlay videos for the video-use editing pipeline.
homepage: https://hyperframes.heygen.com
metadata:
  {
    "openclaw":
      {
        "emoji": "✨",
        "requires": { "bins": ["node", "ffmpeg"] },
        "install":
          [
            {
              "id": "hyperframes-doctor",
              "kind": "shell",
              "cmd": "npx hyperframes doctor",
              "label": "Check HyperFrames dependencies",
            },
          ],
      },
  }
---

# HyperFrames — HTML-Native Motion Graphics

HyperFrames is an HTML video framework from HeyGen. Every composition is a **regular HTML file** with a paused GSAP timeline attached to `window.__timelines`. The CLI handles validation, live preview, hot-reload, and rendering to MP4/MOV.

**Not Remotion** — no React, no JSX, no bundler inside compositions. Just HTML + vanilla JS + GSAP.

## Before Any Creative Work

**Always read `{baseDir}/MOTION_PHILOSOPHY.md` before brainstorming or authoring any composition.** It is the gold standard aesthetic for every HyperFrames build. Re-read sections 0 (11 Laws) and 4 (pre-flight checklist) on every session.

For brand identity, read `{baseDir}/DESIGN.ais-example.md` as a worked example — replace with your own `DESIGN.md`.

## Authoring Loop

1. Read `MOTION_PHILOSOPHY.md` (mandatory)
2. Edit HTML in `compositions/<name>.html`
3. `npx hyperframes lint` — fix all errors before rendering
4. `npx hyperframes preview` — live Studio at http://localhost:3002; get sign-off **before any render**
5. `npx hyperframes render --quality draft --output renders/draft.mp4`
6. Extract frames and verify visually — lint passing ≠ design working
7. Run MOTION_PHILOSOPHY.md pre-flight checklist (section 4)
8. `npx hyperframes render --quality standard --output renders/final.mp4`

## Key Commands

```bash
# Authoring
npx hyperframes preview                                          # Studio with hot reload (port 3002)
npx hyperframes lint                                             # static HTML validation
npx hyperframes compositions                                     # list comp IDs + resolved durations

# Rendering
npx hyperframes render --quality draft    --output renders/draft.mp4
npx hyperframes render --quality standard --output renders/final.mp4
npx hyperframes render --quality standard --format mov --output renders/overlay.mov  # ProRes with alpha
npx hyperframes render --quality high --docker --output renders/archive.mp4

# Catalog
npx hyperframes catalog --type block       # browse 38 blocks
npx hyperframes catalog --type component   # browse 3 components
npx hyperframes add <name>                 # install a catalog item

# Media
npx hyperframes transcribe <file> --model small.en --json   # word-level timestamps
npx hyperframes tts "text" --voice am_adam --output narration.wav

# Diagnostics
npx hyperframes doctor                     # check Node/FFmpeg/Chrome/Docker
npx hyperframes docs <topic>               # inline docs: data-attributes, gsap, rendering, examples
npx hyperframes benchmark                  # find optimal workers/quality
```

### Render quality tiers

| Flag | CRF | Use |
|---|---|---|
| `--quality draft` | 28 | Fast iteration — cut-point checking |
| `--quality standard` | 18 | Visually lossless 1080p delivery |
| `--quality high` | 15 | Archival / deterministic output |

`--format mov` = ProRes 4444 **with alpha channel** — use for video-use overlay compositing.

## Project Structure

```
video-projects/<slug>/
├── index.html                 ← root composition (chains sub-compositions)
├── compositions/              ← one .html file per scene/beat
│   └── components/            ← shared snippets (installed via `npx hyperframes add`)
├── assets/                    ← media (MP4, PNG, MP3, SVG, fonts) — copy brand assets here
├── renders/                   ← render outputs (gitignored)
├── hyperframes.json           ← CLI config (registry URL, paths — relative to project folder)
└── meta.json                  ← id, name, dimensions, fps
```

**Always run the CLI from inside the project folder.** Running from the workspace root will fail or scan wrong files.

### Creating a new project

```bash
mkdir video-projects/<new-slug>
cd video-projects/<new-slug>
npx hyperframes init
# or copy from a sibling: cp -r ../may-shorts-19/{hyperframes.json,meta.json} .
```

## Render Contract (Non-Negotiable)

1. Root `<div>` needs `id`, `data-composition-id`, `data-start="0"`, `data-width`, `data-height`
2. Timed visible elements need `class="clip"` — **except** `<video>` and `<audio>` (breaks video)
3. Every timed element needs `data-start`, `data-duration`, `data-track-index`
4. `data-start` can reference another clip's id: `data-start="intro"`, `data-start="intro + 2"`
5. `<video>` must be `muted`; audio belongs in sibling `<audio>` elements
6. Every composition registers exactly one GSAP timeline, paused: `window.__timelines["<comp-id>"]`
7. **Law #11 — Timeline duration anchor:** `tl.to({}, { duration: SLOT_DURATION }, 0)` at end of every timeline — prevents black-frame flash when `timeline.duration() < data-duration`
8. Never call `.play()`, `.pause()`, or set `.currentTime` on media — the framework owns playback
9. Never animate `width/height/top/left` directly on `<video>` — wrap in `<div>` and animate the wrapper
10. Sub-compositions use `<template>` + `data-composition-src` — never `masterTL.add(child)`
11. **Determinism:** no `Math.random()`, `Date.now()`, or render-time network fetches. Use seeded PRNGs.

## Timeline Skeleton

```js
(() => {
  const SLOT_DURATION = 5.0; // must match data-duration of this composition
  const tl = gsap.timeline({ paused: true });

  // ... your tweens ...

  tl.to({}, { duration: SLOT_DURATION }, 0); // Law #11 anchor — non-negotiable
  window.__timelines['my-comp'] = tl;        // key must match data-composition-id exactly
})();
```

### Diagnose black-frame issues

```js
// Run in devtools console with Studio open:
const p = document.querySelector('hyperframes-player');
const iw = p.shadowRoot.querySelector('iframe').contentWindow;
Object.fromEntries(Object.entries(iw.__timelines).map(([k, v]) =>
  [k, +v.duration().toFixed(4)]));
// Any value shorter than its data-duration is a black-frame risk.
```

## Core GSAP Patterns

### Grid background (use everywhere)

```html
<div class="grid-floor clip" data-start="0" data-duration="30" data-track-index="0"></div>
<div class="vignette clip"  data-start="0" data-duration="30" data-track-index="9"></div>
<!-- grain-overlay: npx hyperframes add grain-overlay -->

<style>
.grid-floor {
  position: absolute; inset: 0;
  transform: perspective(900px) rotateX(60deg) translateY(20%);
  background:
    repeating-linear-gradient(0deg,   rgba(255,255,255,.05) 0 1px, transparent 1px 80px),
    repeating-linear-gradient(90deg,  rgba(255,255,255,.05) 0 1px, transparent 1px 80px);
  background-color: #000;
}
.vignette {
  position: absolute; inset: 0; pointer-events: none;
  background: radial-gradient(ellipse at center, transparent 30%, #000 95%);
}
</style>
```

### Chrome-gradient type (all headlines)

```css
.headline {
  background: linear-gradient(180deg, #ffffff 0%, #999999 60%, #cccccc 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  text-shadow: 0 0 20px rgba(255,255,255,0.6), 0 0 40px rgba(255,255,255,0.3);
}
```

### Light-streak whip transition

```js
gsap.fromTo('.whip-streak',
  { xPercent: -100, scaleX: 0.5 },
  { xPercent: 250, scaleX: 1.5, duration: 0.4, ease: 'power3.in' }
);
// Fire AT the cut. Next scene data-start = streak peak (~0.2s into streak).
```

### Color recolor (no cut)

```js
// Same DOM, palette shifts via CSS variables — meaning changes without an edit cut
tl.to('.flowchart', {
  '--edge': '#ffd84a', '--node-glow': 'rgba(255,148,48,0.7)',
  duration: 0.6, ease: 'power2.inOut'
}, 2.5);
```

### GSAP easing quick reference

| Purpose | Ease | Duration |
|---|---|---|
| Word reveal | `expo.out` | 0.20–0.33s |
| Element enter | `power2.out` | 0.2–0.5s |
| Element exit | `power2.in` | 0.2–0.33s |
| Whip exit | `expo.in` | 0.2–0.33s |
| Whip entry | `expo.out` | 0.5–1.0s |
| Camera pan | `power2.inOut` | 1.2–2.3s |
| Bouncy settle | `back.out(1.4)` | 0.3–0.5s |
| Click compress | `power4.in` | 0.07s |
| Click release | `back.out(3)` | 0.30s |
| Breathe/drift | `sine.inOut` yoyo | 2–4s repeat |

## Registry Blocks (38 available)

```bash
# Core texture (install on every project)
npx hyperframes add grain-overlay
npx hyperframes add shimmer-sweep

# Transitions
npx hyperframes add whip-pan
npx hyperframes add cinematic-zoom
npx hyperframes add cross-warp-morph
npx hyperframes add flash-through-white
npx hyperframes add swirl-vortex
npx hyperframes add light-leak
npx hyperframes add glitch
npx hyperframes add chromatic-radial-split
npx hyperframes add domain-warp-dissolve
npx hyperframes add gravitational-lens
npx hyperframes add sdf-iris

# CSS transition packs
npx hyperframes add transitions-3d
npx hyperframes add transitions-blur
npx hyperframes add transitions-cover
npx hyperframes add transitions-push
npx hyperframes add transitions-scale

# UI & product
npx hyperframes add app-showcase
npx hyperframes add ui-3d-reveal
npx hyperframes add flowchart
npx hyperframes add data-chart
npx hyperframes add logo-outro

# Social overlays
npx hyperframes add instagram-follow
npx hyperframes add tiktok-follow
npx hyperframes add yt-lower-third
npx hyperframes add macos-notification
npx hyperframes add x-post
npx hyperframes add reddit-post
npx hyperframes add spotify-card
```

## Integration with video-use Pipeline

HyperFrames generates overlay animations that `render.py` (video-use) composites onto footage:

```bash
# 1. Render overlay with ProRes alpha
cd video-projects/my-overlay
npx hyperframes render --quality standard --format mov --output renders/lower-third.mov

# 2. Wire into video-use EDL
cat edit/edl.json
{
  "sources": { "main": "/footage/interview.mp4" },
  "ranges": [{ "source": "main", "start": 0.0, "end": 45.0 }],
  "overlays": [
    {
      "file": "/video-projects/my-overlay/renders/lower-third.mov",
      "start_in_output": 3.0,
      "duration": 5.0
    }
  ],
  "grade": "auto"
}

# 3. Render final composite
python helpers/render.py edit/edl.json -o edit/final.mp4 --build-subtitles
```

## Visual Verification (Mandatory Before Delivery)

```bash
# Extract frames from draft for inspection
mkdir -p renders/frames
for t in 0.5 1.5 3.0 5.0 8.0; do
  ffmpeg -y -ss $t -i renders/draft.mp4 -frames:v 1 -q:v 2 "renders/frames/t${t}.png"
done
# Then Read each PNG — never ship without having looked at the frames
```

Lint passing ≠ design working. **View the frames every time.**
