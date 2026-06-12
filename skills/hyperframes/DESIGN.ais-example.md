# AI Automation Society — Visual Identity

Ground truth extracted from `assets/AIS Brand Guideline Small.jpg` and `assets/AIS Logo PNG.png`. Every composition in this project MUST trace its palette, typography, and motion choices back to this file.

> **This is the worked example for the AIS brand. Write your own `DESIGN.md` for your brand, following this structure.**

## Style Prompt

AI Automation Society is a technical, confident, command-driven brand — "Bloomberg Terminal meets SaaS launch." Compositions should feel like a control room coming online: deep navy canvases, sharp cyan-blue accents, monospaced tickers, clipped motion, and a single warm orange accent used only where contrast matters. Not playful. Not gradient-heavy. Not neon. The mood is precision, urgency, and authority — a community of builders who ship.

## Colors

| Token | Hex | Role |
|---|---|---|
| `--ais-bg` | `#07121c` | Primary background (deep navy) |
| `--ais-surface` | `#0d2031` | Cards, panels, surfaces |
| `--ais-surface-2` | `#195066` | Secondary surface (teal-navy) |
| `--ais-border` | `#252d33` | Borders, dividers, hairlines |
| `--ais-accent` | `#37bdf8` | Primary accent — highlights, numbers, CTAs |
| `--ais-accent-glow` | `#0307ff` | Logo outer glow (75% opacity, 50px blur) |
| `--ais-warn` | `#f09025` | Secondary accent — use sparingly |
| `--ais-text` | `#ffffff` | Primary text on dark |
| `--ais-text-dim` | `#96a2b6` | Secondary/meta text |

## Typography

- **Roboto Mono (Medium 500)** — monospace: UI labels, stats, numbers, terminal lines, CTAs
- **Montserrat (Light 300 / Bold 700)** — display sans: headlines, body copy, taglines

Pair them — never use only one. Roboto Mono labels above Montserrat headlines is the house pattern.

## Logo

- File: `assets/AIS Logo PNG.png` — white italic "AIS" wordmark with blue outer-glow
- CSS glow: `filter: drop-shadow(0 0 50px rgba(3, 7, 255, 0.75));`
- Clearspace: half a logo-height on all sides
- Never recolor, never stretch, never add effects beyond the spec glow

## Motion Rules

- **Entrance only:** every element animates in via `gsap.from()`. Transitions handle exits.
- **Easing palette:** `power3.out`, `expo.out`, `back.out(1.4)`, `power4.out` for entrances; `power2.in` for hand-offs; `sine.inOut` for ambient loops
- **Duration bands:** snaps 0.3–0.5s, headline entrances 0.5–0.8s, ambient drifts 2–4s
- **Text stagger:** 0.04–0.08s per character (display), 0.12–0.18s per word (headlines)
- **Numbers:** `gsap.to(el, { innerText: N, snap: { innerText: 1 } })` for count-up

## Transitions

| Scene change | Transition | Duration | Ease |
|---|---|---|---|
| 1 → 2 | Zoom through | 0.35s | `power4.inOut` |
| 2 → 3 | Push slide left | 0.35s | `power2.inOut` |
| 3 → 4 | Push slide left | 0.35s | `power2.inOut` |
| 4 → 5 | Blur crossfade | 0.5s | `sine.inOut` |

## What NOT to Do

1. No full-screen linear gradients — H.264 banding. Use solid `--ais-bg` + localized radial glow.
2. No neon pinks, purples, or saturated greens outside the palette.
3. No Arial, Helvetica, Roboto (sans), Inter, or system fonts — only Roboto Mono + Montserrat.
4. No `transparent` keyword in gradients — use `rgba(7,18,28,0)`.
5. No `Math.random()` or `Date.now()` — render determinism.
6. No exit animations on any scene except the final — transitions handle exits.
7. No stretching the logo.
