# Timing — interpolate, spring, easing

## interpolate()

```tsx
import { interpolate } from 'remotion';

// Basic: frame 0-30 → opacity 0-1, clamped outside range
const opacity = interpolate(frame, [0, 30], [0, 1], {
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
});

// Multi-keyframe
const x = interpolate(frame, [0, 20, 50, 80], [0, 100, 100, 0], {
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
});
```

Always pass `extrapolateLeft: 'clamp'` and `extrapolateRight: 'clamp'` unless you intentionally want values outside the output range.

## spring()

```tsx
import { spring } from 'remotion';

// Bouncy enter — starts at 0, settles at 1
const scale = spring({
  frame,
  fps,
  config: { damping: 10, stiffness: 100, mass: 1 },
  // optional: delay
  delay: 10,
});
```

Spring is deterministic by frame — never use it with random seeds.

Common configs:
| Feel | damping | stiffness |
|---|---|---|
| Snappy | 200 | 400 |
| Natural | 15 | 150 |
| Bouncy | 8 | 80 |
| Slow settle | 20 | 60 |

## Easing

```tsx
import { Easing, interpolate } from 'remotion';

// Ease-out quad for enters
const y = interpolate(frame, [0, 20], [40, 0], {
  easing: Easing.out(Easing.quad),
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
});

// Ease-in for exits
const exitOpacity = interpolate(frame, [durationInFrames - 20, durationInFrames], [1, 0], {
  easing: Easing.in(Easing.quad),
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
});

// Custom cubic bezier
const custom = interpolate(frame, [0, 30], [0, 1], {
  easing: Easing.bezier(0.25, 0.1, 0.25, 1),
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
});
```

## Frame math helpers

```tsx
const { fps, durationInFrames } = useVideoConfig();

// Convert seconds to frames
const secondsToFrames = (s: number) => Math.round(s * fps);

// Relative frame within a window
const localFrame = Math.max(0, frame - startFrame);
```
