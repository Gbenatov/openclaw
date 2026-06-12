# Transitions — @remotion/transitions

```bash
npm install @remotion/transitions
```

## Available presentations

```tsx
import { fade } from '@remotion/transitions/fade';
import { slide } from '@remotion/transitions/slide';
import { wipe } from '@remotion/transitions/wipe';
import { flip } from '@remotion/transitions/flip';
import { clockWipe } from '@remotion/transitions/clock-wipe';
```

## Timing functions

```tsx
import { linearTiming, springTiming } from '@remotion/transitions';

// Linear
linearTiming({ durationInFrames: 20 })

// Spring-based (smooth, physically natural)
springTiming({
  config: { damping: 200 },
  durationRestThreshold: 0.001,
})
```

## Pattern: full TransitionSeries

```tsx
import { TransitionSeries, linearTiming, springTiming } from '@remotion/transitions';
import { slide } from '@remotion/transitions/slide';
import { fade } from '@remotion/transitions/fade';

<TransitionSeries>
  <TransitionSeries.Sequence durationInFrames={120}>
    <SlideA />
  </TransitionSeries.Sequence>

  <TransitionSeries.Transition
    presentation={slide({ direction: 'from-right' })}
    timing={springTiming({ config: { damping: 200 } })}
  />

  <TransitionSeries.Sequence durationInFrames={120}>
    <SlideB />
  </TransitionSeries.Sequence>

  <TransitionSeries.Transition
    presentation={fade()}
    timing={linearTiming({ durationInFrames: 20 })}
  />

  <TransitionSeries.Sequence durationInFrames={90}>
    <SlideC />
  </TransitionSeries.Sequence>
</TransitionSeries>
```

## Slide directions

```tsx
slide({ direction: 'from-left' })
slide({ direction: 'from-right' })
slide({ direction: 'from-top' })
slide({ direction: 'from-bottom' })
```

## Wipe angle

```tsx
wipe({ direction: 'from-left' })
wipe({ direction: 'from-top-left' })  // diagonal
```

## Custom presentation

A presentation is a component with `presentationProps`:

```tsx
import { TransitionPresentation } from '@remotion/transitions';

const zoomFade = (): TransitionPresentation<Record<string, never>> => ({
  component: ({ children, presentationDirection, presentationProgress }) => {
    const scale = interpolate(
      presentationProgress,
      [0, 1],
      presentationDirection === 'entering' ? [1.1, 1] : [1, 0.9],
    );
    const opacity = interpolate(presentationProgress, [0, 1],
      presentationDirection === 'entering' ? [0, 1] : [1, 0]);
    return <div style={{ transform: `scale(${scale})`, opacity }}>{children}</div>;
  },
  props: {},
});
```
