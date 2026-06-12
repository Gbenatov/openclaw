# Sequencing — Sequence, Series, TransitionSeries

## Sequence

`<Sequence>` offsets `useCurrentFrame()` for its children and clips them to a window:

```tsx
import { Sequence } from 'remotion';

// Child sees frame 0 at output frame 30
<Sequence from={30} durationInFrames={60}>
  <MyComp />
</Sequence>

// No duration limit
<Sequence from={30}>
  <MyComp />
</Sequence>
```

Inside `<MyComp>`, `useCurrentFrame()` returns `0` when the output is at frame 30.

## Series

`<Series>` plays children back-to-back automatically:

```tsx
import { Series } from 'remotion';

<Series>
  <Series.Sequence durationInFrames={90}>
    <Intro />
  </Series.Sequence>
  <Series.Sequence durationInFrames={120}>
    <MainContent />
  </Series.Sequence>
  <Series.Sequence durationInFrames={60}>
    <Outro />
  </Series.Sequence>
</Series>
```

## TransitionSeries

Requires `@remotion/transitions`:

```bash
npm install @remotion/transitions
```

```tsx
import { TransitionSeries } from '@remotion/transitions';
import { fade } from '@remotion/transitions/fade';
import { linearTiming } from '@remotion/transitions';

<TransitionSeries>
  <TransitionSeries.Sequence durationInFrames={90}>
    <SceneA />
  </TransitionSeries.Sequence>
  <TransitionSeries.Transition
    presentation={fade()}
    timing={linearTiming({ durationInFrames: 30 })}
  />
  <TransitionSeries.Sequence durationInFrames={90}>
    <SceneB />
  </TransitionSeries.Sequence>
</TransitionSeries>
```

Transitions overlap the adjacent sequences; the total composition duration shrinks by the transition duration for each transition used.

## Nested Sequence pattern

Build reusable animated blocks that reset their own frame counter:

```tsx
const AnimatedCard: React.FC<{ delay: number }> = ({ delay }) => {
  const frame = useCurrentFrame(); // 0-based within this Sequence
  const opacity = interpolate(frame, [0, 20], [0, 1], { extrapolateRight: 'clamp' });
  return <div style={{ opacity }}>Card</div>;
};

// Usage: stagger 3 cards
{[0, 15, 30].map((delay, i) => (
  <Sequence key={i} from={delay}>
    <AnimatedCard delay={delay} />
  </Sequence>
))}
```
