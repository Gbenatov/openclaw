# Compositions — registration, sizing, fps

## Registering in Root.tsx

```tsx
// src/Root.tsx
import { Composition } from 'remotion';
import { Intro } from './Intro';
import { LowerThird } from './LowerThird';
import { Outro } from './Outro';

export const RemotionRoot: React.FC = () => (
  <>
    <Composition
      id="Intro"
      component={Intro}
      durationInFrames={90}
      fps={30}
      width={1920}
      height={1080}
    />
    <Composition
      id="LowerThird"
      component={LowerThird}
      durationInFrames={150}
      fps={30}
      width={1920}
      height={1080}
    />
    <Composition
      id="Outro"
      component={Outro}
      durationInFrames={60}
      fps={30}
      width={1920}
      height={1080}
    />
  </>
);
```

## Standard sizes

| Format | width | height | fps |
|---|---|---|---|
| 1080p landscape | 1920 | 1080 | 30 |
| 4K landscape | 3840 | 2160 | 30 |
| Vertical (Reels/Shorts) | 1080 | 1920 | 30 |
| Square | 1080 | 1080 | 30 |

## Passing props to compositions

```tsx
type LowerThirdProps = {
  name: string;
  title: string;
};

const LowerThird: React.FC<LowerThirdProps> = ({ name, title }) => { ... };

// In Root.tsx:
<Composition
  id="LowerThird"
  component={LowerThird}
  durationInFrames={150}
  fps={30}
  width={1920}
  height={1080}
  defaultProps={{ name: 'John Doe', title: 'CEO' }}
/>
```

Pass runtime props on the CLI:
```bash
npx remotion render LowerThird --props='{"name":"Jane","title":"CTO"}' --output out.mov
```

## calculateMetadata (dynamic duration)

```tsx
import { Composition, calculateMetadata } from 'remotion';

const myCalc = async ({ props }) => {
  return {
    durationInFrames: props.lines.length * 90,
  };
};

<Composition
  id="DynamicComp"
  component={DynamicComp}
  calculateMetadata={myCalc}
  fps={30}
  width={1920}
  height={1080}
  defaultProps={{ lines: [] }}
/>
```
