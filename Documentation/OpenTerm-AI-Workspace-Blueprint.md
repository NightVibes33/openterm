# OpenTerm AI Workspace Blueprint

## Current Reality

OpenTerm is not a native IDE yet. It is currently a legacy UIKit/ios_system terminal wrapped by a newer SwiftUI workspace shell.

Real today:

- terminal execution through `ios_system`
- terminal tabs through `TerminalTabViewController`
- local app document browsing/editing/import/export
- local SSH profile records that queue real `ssh` commands
- terminal-driven Git commands with a `git` preflight
- optional AI request routing after endpoint/provider configuration
- optional Supabase-backed vault sync after backend configuration

Not real yet:

- native Git engine
- embedded Python/Node/Vim/Nano/Tmux/Htop toolchains
- full LSP language tooling
- production hosted AI proxy deployment
- production account/payment/entitlement system
- real multi-device sync validation

## Positioning

The credible positioning is:

"A beautiful SSH + terminal workspace for iPhone and iPad, with optional AI command assistance."

Do not market it as a local unrestricted Linux distro. iOS sandboxing still applies unless the user is in a special/jailbroken environment, and this app does not currently embed full local developer toolchains.

## Product Pillars

### 1. Terminal Core

- keep terminal execution reliable
- improve tab UX
- make terminal settings modern and readable
- keep command availability honest

### 2. Files And Editing

- real iOS Files import/export
- folder navigation
- create/edit/delete/share files
- syntax highlighting and lightweight search
- implemented rename and folder tar export; future move/copy, binary preview, and richer archive formats

### 3. Remote Infrastructure

- real SSH profiles
- real key vault storage
- remote tool audit over SSH
- remote dev setup commands over SSH
- monitor snapshots only after real SSH poll results

### 4. Git

- terminal-driven Git first
- preflight whether `git` exists
- make local-vs-remote command context obvious
- native Git engine later only after a deliberate dependency choice

### 5. AI

- prompt shortcuts can exist without a provider
- live requests must be disabled until provider/proxy config exists
- responses can insert into terminal as drafts
- hosted proxy needs production auth and rate-limit validation before it is called production

## Design Direction

The app should stop looking like a generic AI dashboard. The design should be calmer, more concrete, and more tool-like:

- fewer marketing cards
- more explicit empty states
- fewer huge gradients
- clearer local/remote labels
- status feedback for every action
- honest disabled states when configuration is missing
- terminal readability over decorative glass

## Immediate Engineering Priorities

1. Keep CI green.
2. Finish anti-fake cleanup: remove claims and controls that imply unimplemented behavior.
3. Add capability checks before actions that depend on local/remote binaries.
4. Validate Keychain-backed secret migration and redaction on real devices.
5. Add file move/copy and richer binary preview. File rename and folder tar export are implemented.
6. Add monitor profile validation and remote preflight output.
7. Simplify the Home screen so it shows real state, not product marketing.
