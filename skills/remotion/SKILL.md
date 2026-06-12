---
name: remotion
description: React-based programmatic video creation. Renders compositions frame-by-frame to MP4 or ProRes overlays for video-use compositing.
homepage: https://www.remotion.dev
metadata:
  openclaw:
    emoji: 🎞️
    requires:
      bins:
        - node
        - ffmpeg
    install:
      - npm install -g remotion
      - "# or scaffold a new project:"
      - npx create-video@latest
---

# Remotion

Remotion turns React components into videos. Each component receives `frame` and renders one image; Remotion drives the frame counter and hands the PNG sequence to ffmpeg.

## Core hooks

```tsx
import { useCurrentFrame, useVideoConfig, interpolate, spring } from 'remotion';

const MyComp: React.FC = () => {
  const frame = useCurrentFrame();            // 0-based integer
  const { fps, durationInFrames, width, height } = useVideoConfig();

  // linear interpolate: frame 0→30 maps opacity 0→1
  const opacity = interpolate(frame, [0, 30], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // physics spring (no Math.random — deterministic by frame)
  const scale = spring({ frame, fps, config: { damping: 10, stiffness: 80 } });

  return <div style={{ opacity, transform: `scale(${scale})` }}>Hello</div>;
};
```

**Never** use `Math.random()`, `Date.now()`, or side-effects inside the component body — renders must be deterministic across frames.

## Registering compositions

`src/Root.tsx` is the entry point:

```tsx
import { Composition } from 'remotion';
import { MyComp } from './MyComp';

export const RemotionRoot: React.FC = () => (
  <>
    <Composition
      id="MyComp"
      component={MyComp}
      durationInFrames={90}   // 3 s @ 30 fps
      fps={30}
      width={1920}
      height={1080}
    />
  </>
);
```

## CLI

| Command | Description |
|---|---|
| `npx remotion studio` | Hot-reload preview in browser |
| `npx remotion render <id> --output out.mp4` | Render to MP4 |
| `npx remotion render <id> --codec prores --prores-profile 4444 --output overlay.mov` | ProRes 4444 with alpha (for video-use overlays) |
| `npx remotion still <id> --frame 30 --output frame.png` | Single-frame PNG |
| `npx remotion compositions` | List all registered compositions |

## Integration with video-use

Remotion is the best tool for React-native motion graphics that need precise frame control. Use it to generate overlay files for video-use:

```bash
# 1. Render overlay with alpha
npx remotion render LowerThird \
  --codec prores --prores-profile 4444 \
  --output overlays/lower_third.mov

# 2. Reference in edl.json
```

```json
{
  "overlays": [
    {
      "file": "overlays/lower_third.mov",
      "start_at_output_second": 4.5
    }
  ]
}
```

video-use's `render.py` will PTS-shift the overlay and composite it via `overlay=eof_action=pass`.

## Quick-start

```bash
# Scaffold
npx create-video@latest my-overlays
cd my-overlays

# Dev
npx remotion studio

# Render MP4
npx remotion render MyComp --output out/MyComp.mp4

# Render ProRes overlay for video-use
npx remotion render MyComp \
  --codec prores --prores-profile 4444 \
  --output out/MyComp.mov
```

## Rules

See `rules/` for detailed guidelines:

- `timing.md` — interpolate, spring, easing
- `compositions.md` — registration, sizing, fps
- `sequencing.md` — Sequence, Series, TransitionSeries
- `transitions.md` — @remotion/transitions patterns
- `audio.md` — Audio component, volume, timing
- `videos.md` — Video component, trimming, looping
- `text-animations.md` — typewriter, kinetic type
- `subtitles.md` — Caption type, SRT loading
