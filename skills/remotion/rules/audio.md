# Audio — Audio component, volume, timing

```tsx
import { Audio, useVideoConfig } from 'remotion';

// Basic usage — plays from output frame 0
<Audio src={staticFile('voice.mp3')} />

// Delay start: wrap in Sequence
<Sequence from={30}>
  <Audio src={staticFile('sfx.mp3')} />
</Sequence>

// Trim source: trimBefore/trimAfter in frames at source fps (default: comp fps)
<Audio
  src={staticFile('music.mp3')}
  trimBefore={0}
  trimAfter={150}   // stop at source frame 150
  volume={0.6}      // 0–1 scalar
/>
```

## Volume animation

```tsx
// Fade in over first 30 frames, fade out over last 30
const { durationInFrames, fps } = useVideoConfig();
const frame = useCurrentFrame();

const volume = interpolate(
  frame,
  [0, 30, durationInFrames - 30, durationInFrames],
  [0, 1, 1, 0],
  { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' },
);

<Audio src={staticFile('bg.mp3')} volume={volume} />
```

## Remote audio

```tsx
// Must be CORS-accessible URL or bundled with staticFile()
<Audio src="https://example.com/voice.mp3" />
```

For production always use `staticFile()` or import the asset directly — remote URLs can fail in offline renders.

## staticFile()

Place assets in `public/` folder:

```
my-project/
  public/
    voice.mp3
    bg-music.mp3
    logo.png
```

```tsx
import { staticFile } from 'remotion';
<Audio src={staticFile('voice.mp3')} />
```
