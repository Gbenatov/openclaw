# Subtitles — Caption type, SRT loading

## Caption type

```ts
type Caption = {
  text: string;
  startMs: number;
  endMs: number;
};
```

Build an array of captions from a transcript (e.g., from video-use's ElevenLabs Scribe output).

## From SRT

```ts
const parseSRT = (srt: string): Caption[] => {
  return srt
    .trim()
    .split(/\n\n+/)
    .map((block) => {
      const lines = block.split('\n');
      const [start, end] = lines[1].split(' --> ').map(srtTimeToMs);
      return { text: lines.slice(2).join(' '), startMs: start, endMs: end };
    });
};

const srtTimeToMs = (t: string): number => {
  const [h, m, rest] = t.split(':');
  const [s, ms] = rest.split(',');
  return (+h * 3600 + +m * 60 + +s) * 1000 + +ms;
};
```

## Rendering active caption

```tsx
import { useCurrentFrame, useVideoConfig } from 'remotion';

const Subtitles: React.FC<{ captions: Caption[] }> = ({ captions }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const currentMs = (frame / fps) * 1000;

  const active = captions.find(
    (c) => currentMs >= c.startMs && currentMs < c.endMs
  );

  if (!active) return null;

  return (
    <div
      style={{
        position: 'absolute',
        bottom: 90,
        left: '10%',
        right: '10%',
        textAlign: 'center',
        fontSize: 48,
        fontWeight: 700,
        color: 'white',
        textShadow: '0 2px 6px rgba(0,0,0,0.8)',
        fontFamily: 'Helvetica Neue, Arial, sans-serif',
      }}
    >
      {active.text.toUpperCase()}
    </div>
  );
};
```

## Integration with video-use transcripts

video-use writes `edit/<video>/transcript.json` with word-level timing from ElevenLabs Scribe.

Convert to captions:

```ts
import transcript from './edit/clip/transcript.json';

type Word = { text: string; start: number; end: number }; // seconds

const toCaptions = (words: Word[], chunkSize = 2): Caption[] => {
  const caps: Caption[] = [];
  for (let i = 0; i < words.length; i += chunkSize) {
    const chunk = words.slice(i, i + chunkSize);
    caps.push({
      text: chunk.map((w) => w.text).join(' '),
      startMs: chunk[0].start * 1000,
      endMs: chunk[chunk.length - 1].end * 1000,
    });
  }
  return caps;
};

const captions = toCaptions(transcript.words);
```

## @remotion/captions package

```bash
npm install @remotion/captions
```

```tsx
import { createTikTokStyleCaptions } from '@remotion/captions';

// Splits transcript words into display pages automatically
const { pages } = createTikTokStyleCaptions({
  combineTokensWithinMilliseconds: 200,
  transcriptionItems: transcript.words,
});
```
