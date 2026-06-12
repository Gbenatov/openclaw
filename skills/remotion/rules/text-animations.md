# Text animations — typewriter, kinetic type

## Typewriter

Slice the string based on frame — never toggle per-character opacity:

```tsx
const Typewriter: React.FC<{ text: string; startFrame: number; charsPerFrame?: number }> = ({
  text,
  startFrame,
  charsPerFrame = 1,
}) => {
  const frame = useCurrentFrame();
  const elapsed = Math.max(0, frame - startFrame);
  const visible = Math.min(text.length, Math.floor(elapsed * charsPerFrame));
  return <span>{text.slice(0, visible)}</span>;
};
```

## Word-by-word reveal

```tsx
const WordReveal: React.FC<{ text: string; framesPerWord?: number }> = ({
  text,
  framesPerWord = 6,
}) => {
  const frame = useCurrentFrame();
  const words = text.split(' ');
  const visibleCount = Math.min(words.length, Math.floor(frame / framesPerWord) + 1);
  return (
    <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
      {words.map((word, i) => {
        const wordFrame = Math.max(0, frame - i * framesPerWord);
        const opacity = interpolate(wordFrame, [0, framesPerWord], [0, 1], {
          extrapolateRight: 'clamp',
        });
        const y = interpolate(wordFrame, [0, framesPerWord], [20, 0], {
          extrapolateRight: 'clamp',
        });
        return (
          <span key={i} style={{ opacity, transform: `translateY(${y}px)` }}>
            {word}
          </span>
        );
      })}
    </div>
  );
};
```

## Kinetic type (scale + fade)

```tsx
const KineticTitle: React.FC<{ text: string }> = ({ text }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const scale = spring({ frame, fps, config: { damping: 12, stiffness: 120 } });
  const opacity = interpolate(frame, [0, 10], [0, 1], { extrapolateRight: 'clamp' });

  return (
    <div
      style={{
        fontSize: 120,
        fontWeight: 900,
        color: 'white',
        opacity,
        transform: `scale(${scale})`,
        textAlign: 'center',
      }}
    >
      {text}
    </div>
  );
};
```

## Easing rules

- **Enters**: `Easing.out(Easing.quad)` or spring with damping 10–15
- **Exits**: `Easing.in(Easing.quad)` — elements should feel intentional leaving
- **Never** linear for text — always ease in/out

## Stroke / outline text (CSS)

```tsx
style={{
  WebkitTextStroke: '2px black',  // outline
  textShadow: '0 2px 8px rgba(0,0,0,0.5)',
}}
```
