# Videos — Video component, trimming, looping

```tsx
import { Video, staticFile } from 'remotion';

// Full video from frame 0
<Video src={staticFile('footage.mp4')} />

// Trim source
<Video
  src={staticFile('footage.mp4')}
  trimBefore={30}   // skip first 1s (at 30fps)
  trimAfter={120}   // stop at source frame 120
/>

// Delay: wrap in Sequence
<Sequence from={60}>
  <Video src={staticFile('b-roll.mp4')} />
</Sequence>

// Fill frame (cover)
<Video
  src={staticFile('bg.mp4')}
  style={{ width: '100%', height: '100%', objectFit: 'cover' }}
/>
```

## Looping

```tsx
import { Loop } from 'remotion';

// Loop a 30-frame clip for 300 frames total
<Loop durationInFrames={30}>
  <Video src={staticFile('loop.mp4')} />
</Loop>
```

## OffthreadVideo (render-accurate)

For precise frame extraction during rendering (avoids browser decode drift), use `OffthreadVideo`:

```tsx
import { OffthreadVideo } from 'remotion';

<OffthreadVideo src={staticFile('footage.mp4')} />
```

Recommended for: slow-motion, exact frame compositing, any video that must be frame-accurate at render time. In the Studio preview, `Video` is fine.

## Sizing and positioning

```tsx
// Full-frame background
<AbsoluteFill>
  <OffthreadVideo
    src={staticFile('bg.mp4')}
    style={{ width: '100%', height: '100%', objectFit: 'cover' }}
  />
</AbsoluteFill>

// PiP: small inset video
<div style={{ position: 'absolute', bottom: 80, right: 80, width: 320, height: 180 }}>
  <Video src={staticFile('cam.mp4')} style={{ width: '100%', height: '100%' }} />
</div>
```

## AbsoluteFill

Shorthand for `position: absolute; top: 0; left: 0; width: 100%; height: 100%`:

```tsx
import { AbsoluteFill } from 'remotion';
<AbsoluteFill><Video src={staticFile('bg.mp4')} /></AbsoluteFill>
```
