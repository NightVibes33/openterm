# OpenTerm AI Workspace Blueprint

## Positioning

OpenTerm should evolve from a sandboxed terminal app into a modern mobile developer workspace for iPhone and iPad:

"The modern AI-powered terminal for iPhone and iPad."

The app should feel closer to Linear, Raycast, and modern IDE surfaces than to an old-school hacker novelty app. That means:

- calm information density
- strong typography
- generous spacing
- layered depth and motion
- clear onboarding for non-expert users
- advanced power for expert users without making the first-run experience hostile

## Verified Current State

The current repo is a legacy UIKit app built around:

- `AppDelegate` + storyboard-instantiated panels
- `TabView` for tabs
- `PanelKit` for side panels
- `ios_system` for terminal execution
- `libssh2-for-iOS` legacy dependencies
- deployment target `iOS 11.0`
- Swift `4.0`
- CocoaPods-based dependency management

This means the modernization should preserve the terminal engine where useful, while replacing almost all app shell/UI architecture.

## Product Pillars

### 1. Terminal Workspace

- tabbed terminal sessions
- pinned/favorite sessions
- split context model: local, SSH, container, git repo
- session restore
- reusable command snippets

### 2. Remote Infrastructure

- SSH profiles
- quick connect
- key management
- connection health
- server monitoring dashboard
- alert summaries

### 3. Coding Workspace

- local file manager
- code editor with syntax highlighting
- command palette
- git status / branch / commit / diff / stash
- project-aware AI actions

### 4. AI Copilot

- explain terminal errors
- generate shell commands
- fix shell scripts
- explain Linux commands
- convert bash to zsh
- SSH troubleshooting
- Docker helper
- regex generation
- code assistant

### 5. Premium Personalization

- visual themes
- layout customization
- saved workspaces
- widgets
- sync and vault features

## Recommended Technical Direction

## Platform Baseline

- minimum iOS: `18.0`
- design target: latest iOS with Liquid Glass polish
- architecture: SwiftUI-first
- persistence: SwiftData
- purchase stack: StoreKit 2
- networking: `URLSession`, `NWPathMonitor`, structured async/await APIs

## App Shell

Replace the current UIKit-first shell with:

- `OpenTermApp` SwiftUI app entry
- `NavigationSplitView` for iPad workspace layout
- `TabView` or custom workspace switcher for high-level sections
- feature modules for:
  - Workspace
  - Sessions
  - Files
  - Editor
  - Git
  - Servers
  - AI
  - Settings

The existing terminal core can be bridged into SwiftUI initially through `UIViewControllerRepresentable` or `UIViewRepresentable`.

## Liquid Glass on iOS 26.x

Adopt Liquid Glass selectively:

- command palette
- floating action surfaces
- session switcher
- server detail overlays
- AI composer
- inspector panels

Avoid using glass everywhere. The terminal output surface itself should prioritize readability and low distraction.

## Information Architecture

Top-level sections should become:

- Home
- Sessions
- Files
- Git
- Servers
- AI
- Settings

The current app mixes terminal actions, scripts, bookmarks, and settings around one terminal screen. The new app should separate browse, edit, run, and assist flows more clearly.

## Roadmap

### Phase 1: Foundation

- move target baseline to iOS 18+
- upgrade Swift / Xcode project settings
- remove iOS 11 era assumptions like `armv7`
- add unsigned IPA CI
- define SwiftData schema
- define StoreKit product model

### Phase 2: Modern Shell

- build new SwiftUI app shell
- wrap existing terminal engine
- add modern tab/session model
- add theme system and design tokens

### Phase 3: Developer Workspace

- SSH profile manager
- local file browser
- code editor
- git dashboard
- server monitor cards

### Phase 4: AI Layer

- inline AI chat
- terminal-aware assistant actions
- error explanation pipeline
- command generation
- repo-aware code help

### Phase 5: Premium Layer

- subscriptions
- entitlement-gated features
- sync
- vault
- widgets
- alerts

## First Buildable Milestones

The fastest path to a credible vNext is:

1. keep terminal execution working
2. replace the outer app shell
3. add session persistence
4. add SSH profiles
5. add AI actions
6. add git/files
7. add premium tier

## Design Direction

The design should not market itself as "dark terminal for hackers only".

The visual direction should be:

- editorial
- modern
- tactile
- premium
- approachable

Practical design rules:

- use a neutral foundation with one strong accent family
- reserve monospaced text for terminal, code, diffs, and structured values
- prefer cards, sidebars, and layered panes over crowded toolbar-heavy UI
- keep onboarding narrative and visual
- let power features reveal progressively
