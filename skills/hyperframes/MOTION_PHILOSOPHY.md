# MOTION PHILOSOPHY — The Gold Standard

> Reference deconstruction of the **Infinite — Global Payments** 30s spot
> (`x-XTeSJ-DKx63uB4.mp4`, 1920×1080, 30fps, 900 frames). This is what every
> Hyperframes motion-graphics build should aspire to. Re-read before starting any
> new composition.

---

## 0 · The 11 Laws (memorize)

1. **One idea per beat. Cut fast.** Average scene length in the reference is **~1.5 seconds**. Each visual lands ONE word/concept and moves on. If a scene says two things, split it.
2. **Black is the canvas.** ~90% of every frame is black or near-black. Negative space is the design. Color earns its place by carrying a message.
3. **Light is the brand, not color.** Chrome gradients on type, soft halos, vignettes, light beams. The piece is *lit*, not *colored*. Light reads as premium.
4. **Camera never sleeps.** Even on "still" frames, the grid recedes, the coin rotates, particles drift, the vignette breathes. Static = death.
5. **Motion blur is a feature.** Every transition uses a streak/blur trail — to convey energy AND to mask the cut. Hard cuts feel cheap; whip-streaks feel expensive.
6. **Object metaphors carry meaning.** Red card = old/broken. Teal coin = new/working. The same coin returns 3 times across the piece. Visual continuity = brand.
7. **Palette is symbolic, not decorative.** Each color owns one concept. Don't drop a color in just because it looks nice — assign it a meaning.
8. **Type is a character.** Words SCALE 8×, MORPH, COMPRESS, GLOW. Typography drives ~60% of the storytelling. A text-only beat can be the strongest beat.
9. **Hold the hero shot.** Logo reveal = ~2s of stillness. Outro card = 5+ seconds. Speed earns space for stillness to land. Kinetic chaos → calm = catharsis.
10. **One unifying texture across everything.** The reference uses a faint perspective grid + crosshair (+) registration marks at intersections. Even when invisible, that grid is the spine of the whole piece.
11. **Timelines must fill their slots.** HyperFrames hides a sub-composition the moment `timeline.duration()` is shorter than `data-duration` → black frame flash. Every GSAP timeline ends with `tl.to({}, { duration: SLOT_DURATION }, 0)` as a no-op duration anchor. Non-negotiable.

---

## 1 · The Reference Timeline (30s)

| Time | Beat | What's on screen | Engine |
|------|------|------------------|--------|
| 0.0–0.5 | Empty stage | Black void, perspective grid floor recedes, 4 crosshair `+` markers at center, soft floor wash | Camera holds; grid hints at depth |
| 0.5–1.5 | "Global payments" | Chrome-gradient type appears center, fades subtly | Word reveal #1 |
| 1.5–2.0 | "are a" | Next word ghosts in while previous fades — overlapping reveals | Continuous read |
| 2.0–3.5 | **"a pain"** | Type GROWS to fill 8× — camera dollies through text, grid tilts sideways | Hero kinetic-type moment |
| 3.5–4.0 | **Whip transition** | Glowing white light-saber streak crosses the grid floor at speed | Hides the cut |
| 4.0–5.5 | Red card lands | 3D credit card materializes on grid with motion blur, slight orbit | Object metaphor: problem |
| 5.5–6.5 | **Morph** | Red card transforms into teal/cyan rounded square mid-flight, big light streak | Solution arrives |
| 6.5–7.5 | Coin rises | Teal cylinder coin, vertical light pillar behind, rotates to face camera | Reveals ∞ symbol |
| 7.5–8.5 | "Meet ∞" → logo | Coin shrinks/locks → "∞ Infinite" wordmark crystallizes | Brand reveal |
| 8.5–9.5 | Logo hold | Pure black, subtle chrome shimmer pass | Stillness lands |
| 9.5–10.5 | **"Fast"** | Magenta lightning comet rips left→right, "Fast" in chrome upper-right | Benefit #1 |
| 10.5–11.5 | Network appears | Flowchart of nodes (white outlines), purple energy pulses through edges | Build-up |
| 11.5–12.0 | "Global" | Word lights up, blue energy pulses fill the nodes | Benefit #2 |
| 12.0–13.0 | **Color flip → "Affordable"** | Same flowchart, palette flips to neon orange/yellow with dashed lines, "Affordable" with halo | Benefit #3 (no scene cut!) |
| 13.0–14.5 | "Sign Up In Seconds" | iPhone slides up from below, Account-linking app screen | Product surface #1 |
| 14.5–16.0 | "Send Funds Anywhere" | Different phone screen, transaction list | Product surface #2 |
| 16.0–17.5 | "Built For Businesses" | Laptop showing "Create Transfer" form | Product surface #3 |
| 17.5–19.0 | **Dash** | Iridescent chrome wheel/dial centered, "Dash — Move money globally" panel slides in left | Product family #1 |
| 19.0–20.5 | **API** | Same wheel rotates, "API — Build your own experience" panel slides in right | Product family #2 |
| 20.5–22.0 | **SDK** | Wheel rotates again, yellow segment lit, "SDK — Integrate in just a few lines" | Product family #3 |
| 22.0–23.5 | Coin returns | Teal coin spinning in cylinder again — callback | Visual rhyme |
| 23.5–25.0 | "Powered by Stablecoins" | Three coins floating in conical light beam, sparkle particles | Foundation reveal |
| 25.0–30.0 | **CTA hold** | App icon + "Infinite — Instant, global payments" + "GET STARTED" | 5s of stillness |

**Three-act structure:**
- **Act 1 (0–9.5s):** Problem → metaphor → brand reveal
- **Act 2 (9.5–22s):** Three benefits → three product surfaces → three product names
- **Act 3 (22–30s):** Foundation → CTA → silence

Notice the **rule of threes** everywhere: 3 benefits, 3 surfaces, 3 product names, 3 floating coins.

---

## 2 · The Visual Vocabulary

### 2.1 Backgrounds (priority order)

| # | Background | How to build in HF |
|---|-----------|---------------------|
| 1 | **Perspective grid floor** | `<div>` with `transform: perspective(800px) rotateX(60deg)` + `repeating-linear-gradient` (×2 axes) + SVG `+` crosshairs. GSAP animates `background-position-y` for parallax. |
| 2 | **Vignette** | Absolute overlay `<div>` with `background: radial-gradient(ellipse at center, transparent 30%, black 100%)`. Always on top of bg, below content. |
| 3 | **Pure black stage** | `body { background: #000 }`. Reset between major sections. |
| 4 | **Horizontal speed lines** | `repeating-linear-gradient` with GSAP scrolling `background-position-x`. |
| 5 | **Film grain** | `npx hyperframes add grain-overlay` |
| 6 | **Liquid-glass card** | 4-stop diagonal gradient + `backdrop-filter: blur(14px) saturate(1.12)` + inner highlight `inset 0 1px 0 rgba(255,255,255,.22)`. |

### 2.2 Type System

- **Single geometric sans-serif throughout** (Inter, Suisse Int'l, or SF Pro)
- **All headline text uses chrome gradient:**
  ```css
  background: linear-gradient(180deg, #ffffff 0%, #999999 60%, #cccccc 100%);
  -webkit-background-clip: text;
  color: transparent;
  ```
- **Halo glow on emphasis words:** `text-shadow: 0 0 20px rgba(255,255,255,0.6), 0 0 40px rgba(255,255,255,0.3)`
- **Word-by-word kinetic reveal** (NOT character-by-character):
  ```js
  tl.from('.word', { y: 30, opacity: 0, scale: 0.85, duration: 0.6, ease: 'power3.out', stagger: 0.35 })
  ```
- **Type SCALES dramatically.** Section labels at 48px. Hero kinetic-type at 480px+.
- **Chrome sweep recipe:**
  ```css
  background: linear-gradient(90deg,
    #14110a 0%, #14110a 15%,
    #5a3215 25%, #c84f1c 40%, #e2b53f 55%, #2a8a7c 70%,
    #14110a 85%, #14110a 100%);
  background-size: 300% 100%;
  background-position: 100% 0; /* resting dark */
  ```
  Tween `backgroundPosition` from `100% 0` → `0% 0` over `0.6s`.
- **Per-beat font discipline:** Use a different Google Font per beat. Contrast sells "different universes". Roster: Instrument Serif · Space Grotesk · Bebas Neue · Inter · EB Garamond · Cormorant Garamond · Azeret Mono · Geist · JetBrains Mono.

### 2.3 Color Story (memorize the meanings)

| Color | Hex | Meaning |
|-------|-----|---------|
| **Black** | `#000` | Canvas / silence |
| **Chrome white→gray** | gradient | Premium / brand voice |
| **Red** | `#e10b1f` | Problem / old / broken |
| **Teal/cyan** | `#33d4c8` | Solution / brand / core |
| **Magenta/purple** | `#a155ff` | Speed / energy / API |
| **Blue** | `#3b82f6` | Connection / global |
| **Neon orange/yellow** | `#ff9430` | Value / affordability |

**Discipline:** when adding a new scene, ask "what's the ONE color carrying this beat?" If you can't name it, you haven't earned it.

### 2.4 Motion Vocabulary

| Move | GSAP recipe |
|------|-------------|
| **Camera dolly through type** | `tl.fromTo(text, { scale: 1, opacity: 1 }, { scale: 8, opacity: 0, duration: 1.5, ease: 'power2.in' })` |
| **Light-streak whip** | `gsap.fromTo(streak, { xPercent: -150 }, { xPercent: 250, duration: 0.4, ease: 'power3.in' })` — fire AT the cut |
| **Word ghost reveal** | `stagger: 0.35` with each word's exit at `+= 0.5`, overlap by 0.15s |
| **Object morph drift** | Two `<div>`s, A scales down + drifts off-axis, B scales up from same vector, light streak hides swap |
| **Coin spin reveal** | `tl.from(coin, { rotateY: 90, duration: 0.8, ease: 'back.out(1.4)' })` — needs `transform-style: preserve-3d` |
| **Energy pulse along path** | SVG `stroke-dasharray + stroke-dashoffset` animated 1→0, node lights up at path end |
| **Color recolor (no cut)** | `tl.to(':root', { '--accent': '#ff9430', duration: 0.6 })` — single tween recolors everything |
| **Floating cluster drift** | `gsap.to(coins, { y: '-=15', duration: 2, repeat: -1, yoyo: true, ease: 'sine.inOut', stagger: 0.4 })` |
| **Cut-the-curve vertical whip** | Exit: `tl.to(wrap, { y: -150, filter: "blur(30px)", duration: 0.33, ease: "power2.in" })` / Entry: `gsap.set(wrap, { y: 150, filter: "blur(30px)" })` then `tl.to(wrap, { y: 0, filter: "blur(0px)", duration: 1.0, ease: "power2.out" })` |
| **Faux-cursor click** | 1. Compress cursor `scale: 0.82, 0.07s` 2. Compress target `scale: 0.96, 0.07s` 3. Ripple `scale: 0→2.5, opacity: 0.9→0` 4. Release `back.out(3)` 5. Overshoot `elastic.out(1, 0.4)` 6. Settle |
| **Vignette breath** | `gsap.to(vignette, { opacity: 0.9, duration: 4, repeat: -1, yoyo: true, ease: 'sine.inOut' })` |

### 2.5 Transition Catalog

| Transition | HF block |
|-----------|----------|
| **Light-streak whip** (default) | custom div + GSAP or `npx hyperframes add whip-pan` |
| **Cinematic zoom-through** | `npx hyperframes add cinematic-zoom` |
| **Cross-warp morph** | `npx hyperframes add cross-warp-morph` |
| **Color recolor (no cut)** | CSS variables + GSAP — no shader needed |
| **Flash-through-white** (act break) | `npx hyperframes add flash-through-white` |
| **Swirl-vortex** | `npx hyperframes add swirl-vortex` |

### 2.6 Pacing Discipline

- **Default scene length:** 1.0–2.0s. Longer = hero moment or outro only.
- **Reveal cadence:** new visual element every 0.3–0.6s. No dead air > 1s mid-piece.
- **Word-reveal stagger:** 0.3–0.4s narrative, 0.5–0.6s dramatic single-word.
- **Whip transition:** 0.3–0.4s. Faster = glitchy; slower = loses energy.
- **Logo hold:** 1.5–2s. **Outro CTA hold:** 4–6s.
- **Breathing rule:** every ~7–8s of density, give 1s rest beat.

### 2.7 Audio Mix Defaults

| Layer | `data-volume` | Role |
|------|---------------|------|
| Voiceover | `1.0` | Primary, drives timing |
| Underscore (warm ambient pad) | `0.15` | Sets mood without competing |
| SFX | `0.2` | Tails can bleed into next beat |

---

## 3 · Building in HyperFrames — Key Recipes

### 3.1 Composition shell

```
my-promo/
├── index.html
├── compositions/
│   ├── 01-intro-type.html
│   ├── 02-card-to-coin.html
│   ├── 03-brand-reveal.html
│   └── 08-cta-outro.html
└── assets/
```

### 3.2 Grid background

```html
<div class="grid-floor clip" data-start="0" data-duration="30" data-track-index="0"></div>
<div class="vignette clip"  data-start="0" data-duration="30" data-track-index="9"></div>

<style>
.grid-floor {
  position: absolute; inset: 0;
  transform: perspective(900px) rotateX(60deg) translateY(20%);
  background:
    repeating-linear-gradient(0deg,  rgba(255,255,255,.05) 0 1px, transparent 1px 80px),
    repeating-linear-gradient(90deg, rgba(255,255,255,.05) 0 1px, transparent 1px 80px);
  background-color: #000;
}
.vignette {
  position: absolute; inset: 0; pointer-events: none;
  background: radial-gradient(ellipse at center, transparent 30%, #000 95%);
}
</style>
```

### 3.3 Kinetic-type opener

```html
<span class="word w1">Global</span>
<span class="word w5">pain</span>

<style>.w5 { font-size: 480px; }</style>

<script>
const tl = gsap.timeline({ paused: true });
tl.from('.w1', { y: 30, opacity: 0, scale: 0.9, duration: 0.5, ease: 'power3.out' }, 0)
  .fromTo('.w5', { scale: 1, opacity: 1 }, { scale: 8, opacity: 0, duration: 1.0, ease: 'power2.in' }, 1.8);
tl.to({}, { duration: SLOT_DURATION }, 0);
window.__timelines['kinetic-opener'] = tl;
</script>
```

### 3.4 The Color Recolor Trick

```js
// No cut — same DOM, meaning shifts
tl.to('.flowchart', {
  '--edge': '#ffd84a', '--node-glow': 'rgba(255,148,48,0.7)',
  duration: 0.6, ease: 'power2.inOut'
}, 2.5);
```

### 3.5 Captions as body-level siblings

```html
<!-- In index.html, OUTSIDE the master composition div -->
<div class="cap clip" data-start="7.29" data-duration="1.86" data-track-index="30">Caption text.</div>
<style>
.cap {
  position: absolute; bottom: 72px; left: 50%; transform: translateX(-50%);
  padding: 12px 22px; border-radius: 14px;
  background: rgba(10,8,5,0.55); backdrop-filter: blur(8px);
  font: 500 28px/1.3 Inter, sans-serif; color: #fff;
}
</style>
```

### 3.6 Video poster + lastframe bracketing

```html
<img  id="beat-poster"    src="assets/beat-poster.jpg">
<video id="beat-video"   src="assets/beat-clip.mp4"
       data-start="7.1" data-duration="8.94" data-track-index="5" muted></video>
<img  id="beat-lastframe" src="assets/beat-lastframe.jpg">
```
```js
tl.set('#beat-poster',    { display: 'none' }, 7.1);
tl.set('#beat-lastframe', { opacity: 1 }, 16.04);
```
```bash
# Generate:
ffmpeg -y -ss 0       -i clip.mp4 -frames:v 1 -q:v 2 poster.jpg
ffmpeg -y -sseof -0.04 -i clip.mp4 -frames:v 1 -q:v 2 lastframe.jpg
```

---

## 4 · Pre-flight Checklist

- [ ] Average scene length ≤ 2s in mid-section
- [ ] No dead air > 1s except deliberate holds
- [ ] Every transition uses motion (whip, morph, slide, recolor — no hard fades)
- [ ] Color palette ≤ 5 active hues, each with a meaning
- [ ] Every text block uses chrome gradient + halo — no flat white
- [ ] Background grid + crosshairs present in ≥ 60% of scenes
- [ ] Vignette layer on every scene
- [ ] Grain overlay on every scene
- [ ] At least one callback (visual element that returns)
- [ ] Outro holds for 4+ seconds
- [ ] Visual verification done — frames extracted and opened
- [ ] Every sub-composition timeline ends with `tl.to({}, { duration: SLOT_DURATION }, 0)`
- [ ] All tween end-times snap to multiples of `1/fps`
- [ ] Timeline-duration diagnostic run in devtools

---

## 5 · The "What Would Infinite Do?" Test

1. Could I cut this scene in half? If yes, do it.
2. Is this color carrying a meaning? If no, kill it.
3. Does the camera move during this beat? If no, add drift.
4. Where's the motion blur? If there's none on the transition, add a streak.
5. Will the viewer see this visual element again? If no, can I make a callback?
6. Does the type SCALE during its reveal, or just fade in? Fading in is the lowest-effort move.
7. What's the negative space doing? If 80%+ isn't black/dark, you're over-designing.
8. Is this beat ONE idea? If you can't summarize in 2 words, you've packed too much in.
9. What's the unifying texture across all scenes? If you don't have one, you have clips not a piece.
10. Where does the viewer rest? Identify the breathing moments. If none, build them in.

---

## 6 · Anti-patterns

- ❌ Centered, axis-aligned, motionless text fades
- ❌ Hard cuts between scenes — every cut needs a transition element
- ❌ Flat white text on flat black — use chrome gradient and halo glow
- ❌ 6+ colors — you're decorating, not communicating
- ❌ No callbacks — setups that never pay off
- ❌ Outro that ends on the last beat — always hold 4+s
- ❌ Scenes that say two things — split them
- ❌ Static backgrounds — every bg needs one slow-moving element
- ❌ `Math.random()` / `Date.now()` in render loops — use seeded PRNGs
- ❌ Skipping visual frame verification — lint passing ≠ design working

---

## 7 · TL;DR

> **One idea per beat, lit not colored, kinetic not still, callbacks not novelty, hold the hero, breathe the outro — the grid is always under everything, every timeline fills its slot, every exit snaps to a frame boundary, and every cut hides inside a motion-blurred whip.**
