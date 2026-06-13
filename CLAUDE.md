# OpenClaw — AI Agent Reference

> **Full operational ruleset**: `AGENTS.md` (read it first — this file extends it with structural context).

OpenClaw is a **multi-channel AI gateway**: a CLI tool and runtime that routes messages from Telegram, Discord, Signal, Slack, iMessage, WhatsApp, LINE, and more to AI model providers (Anthropic, OpenAI, Bedrock, Ollama, local LLMs).

- npm package / CLI binary: `openclaw`
- Version scheme: `YYYY.M.D` (e.g. `2026.2.15`)
- Docs: https://docs.openclaw.ai
- License: MIT

## Technology Stack

| Layer | Tool |
|-------|------|
| Runtime | Node ≥22 + Bun (prefer Bun for dev/scripts/tests) |
| Language | TypeScript (ESM, strict) |
| Package manager | pnpm ≥10 |
| Build | tsdown (Rolldown-based bundler) |
| Linter | Oxlint + oxlint-tsgolint |
| Formatter | Oxfmt |
| Tests | Vitest + V8 coverage (70% threshold) |
| iOS / macOS | Swift + SwiftUI (`Observation` framework preferred) |
| Android | Kotlin + Gradle |

## Repository Layout

```
.
├── src/                  Core TypeScript source (see full map below)
├── apps/
│   ├── android/          Android app (Kotlin/Gradle)
│   ├── ios/              iOS app (Swift + XcodeGen)
│   ├── macos/            macOS menubar app (Swift/SwiftUI)
│   └── shared/           Shared Swift package (OpenClawKit)
├── extensions/           Channel/feature plugins (pnpm workspace packages)
├── ui/                   Web UI (served by the gateway)
├── docs/                 Mintlify documentation source
├── packages/             Internal workspace packages
├── skills/               Agent skill definitions (.md files)
├── scripts/              Build, release, and utility scripts
├── test/                 Top-level test fixtures
├── git-hooks/            Pre-commit hooks (installed via prek)
├── .agent/               Per-agent context/config files
├── .agents/              Shared agent skills, PR workflow docs
└── dist/                 Build output (gitignored)
```

## Source Code Directory Reference (`src/`)

| Directory | Purpose |
|-----------|---------|
| `src/acp` | Agent Client Protocol (ACP) SDK adapter and integration |
| `src/agents` | Agent runtime loop, tool dispatch, agent lifecycle |
| `src/auto-reply` | Auto-reply rules, patterns, and scheduler |
| `src/browser` | Playwright-based browser automation and web scraping |
| `src/canvas-host` | A2UI canvas host (Lit web components, bundled via `scripts/bundle-a2ui.sh`) |
| `src/channels` | Channel abstraction layer, base types, channel registry |
| `src/cli` | CLI entry point, argument parsing (`commander`), progress UI (`osc-progress` + `@clack/prompts`) |
| `src/commands` | Individual CLI command implementations (one file per command group) |
| `src/compat` | Backward-compatibility shims and migration helpers |
| `src/config` | Configuration loading, validation, `openclaw config` commands |
| `src/cron` | Cron/scheduled task runner (`croner`) |
| `src/daemon` | Background daemon and process lifecycle management |
| `src/discord` | Discord channel integration (`@buape/carbon`) |
| `src/docs` | In-process documentation server and indexing |
| `src/gateway` | Gateway WebSocket server, HTTP API, protocol handler |
| `src/hooks` | Hook system (pre/post message hooks defined by users) |
| `src/imessage` | iMessage channel integration (macOS only) |
| `src/infra` | Shared infrastructure: filesystem, networking, file locks |
| `src/line` | LINE messaging channel (`@line/bot-sdk`) |
| `src/link-understanding` | URL parsing, link preview, web content extraction (`@mozilla/readability`) |
| `src/logging` | Structured logging (`tslog`) |
| `src/macos` | macOS IPC bridge and menubar app communication protocol |
| `src/markdown` | Markdown rendering (`markdown-it`) |
| `src/media` | Media pipeline: download, transcoding, thumbnail generation (`sharp`) |
| `src/media-understanding` | Media analysis: OCR, image description, PDF extraction (`pdfjs-dist`) |
| `src/memory` | Agent memory store (SQLite + `sqlite-vec` vector search) |
| `src/node-host` | Node.js runtime host for tool/script execution |
| `src/pairing` | Device/channel pairing (QR code flow, `qrcode-terminal`) |
| `src/plugin-sdk` | Plugin SDK public exports (published as `openclaw/plugin-sdk`) |
| `src/plugins` | Plugin loader, sandbox, runtime API |
| `src/process` | Child process management and sandboxing |
| `src/providers` | AI model provider adapters (Anthropic, OpenAI, AWS Bedrock, Ollama, local LLMs) |
| `src/routing` | Message routing rules, allowlists, channel-to-agent mapping |
| `src/scripts` | Source-level build scripts invoked from `package.json` |
| `src/security` | Secret detection, token validation, security utilities |
| `src/sessions` | Session persistence and session log (`.jsonl` format) |
| `src/shared` | Cross-module shared utilities and types |
| `src/signal` | Signal messaging channel |
| `src/slack` | Slack channel integration (`@slack/bolt`) |
| `src/telegram` | Telegram channel integration (`grammy`) |
| `src/terminal` | Terminal UI utilities: colour palette (`palette.ts`), ANSI-safe tables (`table.ts`) |
| `src/test-helpers` | Test helper factories and shared mocks |
| `src/test-utils` | Shared Vitest setup and utility functions |
| `src/tts` | Text-to-speech (`node-edge-tts`) |
| `src/tui` | Terminal UI (TUI) interactive mode |
| `src/types` | Shared TypeScript type definitions |
| `src/utils` | General utility functions |
| `src/web` | WhatsApp Web channel (web-based fallback) |
| `src/whatsapp` | WhatsApp channel via Baileys (`@whiskeysockets/baileys`) |
| `src/wizard` | Setup wizard / onboarding flow |

### Built-in Messaging Channels

| Channel | Source | Library |
|---------|--------|---------|
| Telegram | `src/telegram` | grammy |
| Discord | `src/discord` | @buape/carbon |
| Slack | `src/slack` | @slack/bolt |
| Signal | `src/signal` | — |
| iMessage | `src/imessage` | macOS only |
| WhatsApp (Baileys) | `src/whatsapp` | @whiskeysockets/baileys |
| WhatsApp Web | `src/web` | playwright-core |
| LINE | `src/line` | @line/bot-sdk |

Extension channels live under `extensions/` (workspace packages): MS Teams, Matrix, Zalo, Zalo User, Voice Call, and others.

## Development Commands

```bash
# Setup
pnpm install                  # Install deps (lockfile-defined; also: bun install)
prek install                  # Install pre-commit hooks

# Development
pnpm openclaw ...             # Run CLI in dev (via Bun)
pnpm dev                      # Run gateway in dev mode
pnpm gateway:dev              # Gateway only (skips channel init)

# Build
pnpm build                    # Full build: bundle + plugin-sdk dts + metadata
pnpm tsgo                     # TypeScript type-check (native TS go)

# Quality
pnpm check                    # format:check + tsgo + lint (run before every commit)
pnpm format:fix               # Auto-fix formatting (oxfmt --write)
pnpm lint:fix                 # Auto-fix lint issues

# Tests
pnpm test                     # All unit tests (parallel, vitest.unit.config.ts)
pnpm test:fast                # Unit tests only
pnpm test:coverage            # Unit tests + v8 coverage report
pnpm test:e2e                 # End-to-end tests
pnpm test:live                # Live model/gateway tests (requires OPENCLAW_LIVE_TEST=1)

# Mobile
pnpm ios:run                  # Build + run on iOS Simulator
pnpm ios:gen                  # XcodeGen only
pnpm android:run              # Build + install on Android device
pnpm mac:package              # Package macOS app (current arch)
```

### Test Configurations

| Config | Scope |
|--------|-------|
| `vitest.unit.config.ts` | Unit tests (`*.test.ts`, no e2e/live) |
| `vitest.e2e.config.ts` | E2E tests (`*.e2e.test.ts`) |
| `vitest.live.config.ts` | Live model/gateway tests |
| `vitest.gateway.config.ts` | Gateway integration tests |
| `vitest.extensions.config.ts` | Extension tests |

**Coverage thresholds**: 70% lines / branches / functions / statements.

## Coding Conventions

- **Naming**: product = `OpenClaw`; CLI / packages / paths / config keys = `openclaw`.
- **Files**: aim for ≤500 LOC; extract helpers, never make V2 copies.
- **DI**: follow existing `createDefaultDeps` pattern for dependency injection.
- **CLI progress**: use `src/cli/progress.ts` — never hand-roll spinners/bars.
- **Terminal colours**: use `src/terminal/palette.ts` — no hardcoded ANSI escape codes.
- **Terminal tables**: use `src/terminal/table.ts` for ANSI-safe output.
- **iOS/macOS UI**: prefer `Observation` framework (`@Observable`, `@Bindable`) over `ObservableObject`.
- **Tool schemas**: avoid `Type.Union` / `anyOf` / `oneOf` / `allOf`; use `Type.Unsafe` enum + `Type.Optional`.
- **Commits**: `scripts/committer "<msg>" <file...>` (scopes staging); concise, action-oriented messages.
- **No Carbon updates**: never upgrade the Carbon dependency.
- **Patched deps**: exact versions required; explicit approval needed before adding patches.
- **No streaming to external channels**: WhatsApp/Telegram/etc. receive final replies only.

## Release Channels

| Channel | Tag | npm dist-tag |
|---------|-----|--------------|
| stable | `vYYYY.M.D` | `latest` |
| beta | `vYYYY.M.D-beta.N` | `beta` |
| dev | `main` branch head (untagged) | — |

Never bump versions or publish without explicit operator consent. Read `docs/reference/RELEASING.md` and `docs/platforms/mac/release.md` before any release work.

## Version Locations

Bump ALL of these when bumping version (except `appcast.xml` — only for Sparkle releases):

- `package.json` — CLI version
- `apps/android/app/build.gradle.kts` — `versionName` / `versionCode`
- `apps/ios/Sources/Info.plist` + `apps/ios/Tests/Info.plist` — `CFBundleShortVersionString` / `CFBundleVersion`
- `apps/macos/Sources/OpenClaw/Resources/Info.plist` — `CFBundleShortVersionString` / `CFBundleVersion`
- `docs/install/updating.md` — pinned npm version
- Peekaboo Xcode project Info.plists — `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION`

## Security

- Credentials: `~/.openclaw/credentials/`; Pi sessions: `~/.openclaw/sessions/`.
- Never commit real phone numbers, live tokens, videos, or production config values.
- Use obviously fake placeholders in docs, tests, and examples.
- `detect-secrets` pre-commit hook guards against accidental secret commits.

## Documentation (Mintlify)

- Hosted at https://docs.openclaw.ai
- Internal links: root-relative, no `.md`/`.mdx` extension — e.g. `[Config](/configuration)`
- Anchors: `[Hooks](/configuration#hooks)` — avoid em dashes / apostrophes in headings (break anchors)
- `docs/zh-CN/` is auto-generated — do not hand-edit
- README links: use absolute `https://docs.openclaw.ai/...` URLs

## Multi-Agent Safety

- Do not `git stash` / modify worktrees / switch branches unless explicitly asked.
- Scope commits to your own changes only (`scripts/committer`).
- On "push": `git pull --rebase` first to integrate other agents' work, never discard it.
- When you see unrecognised files, focus on your own changes and note them briefly.

## Key Shorthands

- `sync` — commit dirty tree → `git pull --rebase` → `git push`
- "makeup" → macOS app
- "restart iOS/Android apps" → rebuild + reinstall + relaunch (not just kill/launch)
- "update fly" → SSH to fly.io and pull latest on the flawd-bot instance
