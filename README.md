<p align="center">
<img src="readme-resources/hero.png" alt="Terminal for iOS">
</p>

<h1 align="center">OpenTerm</h1>

<p align="center">
<a href="https://itunes.apple.com/app/terminal/id1323205755?mt=8&at=1010lII4"><img src="readme-resources/app_store_badge.svg" alt="Download on the App Store"/></a>
<br><span align="center">(Previously called Terminal for iOS)</span>
</p>

<p align="center">
<a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift"/></a>
<img src="https://img.shields.io/badge/Platform-iOS%2018.0+-lightgrey.svg" alt="Platform: iOS">
<a href="https://github.com/NightVibes33/openterm/actions/workflows/ios-unsigned-ipa.yml"><img src="https://github.com/NightVibes33/openterm/actions/workflows/ios-unsigned-ipa.yml/badge.svg" alt="Build Status"/></a>
<br>
<a href="http://twitter.com/NightVibes33"><img src="https://img.shields.io/badge/Twitter-@NightVibes33-blue.svg?style=flat" alt="Twitter"/></a>
</p>

## About
OpenTerm is being refocused from a standalone terminal app into an AI-powered mobile developer workspace for iPhone and iPad.

The design target is closer to "Raycast + Warp + Linear for iOS" than an old-school shell app: clean, modern, glassy, fast, and approachable for developers, VPS users, homelab users, and power users who still want a beginner-friendly surface.

## Current Repo Status

### Implemented in this fork right now
- Legacy OpenTerm terminal core is still present and embedded.
- A new SwiftUI workspace shell is active from `AppDelegate`.
- Workspace sections exist for Home, Terminal, Files, Git, Servers, AI, and Settings.
- The terminal tab uses the legacy `TerminalTabViewController` inside the new shell.
- iOS 18.0 deployment target is configured in the Xcode project and Podfile.
- iOS 26-compatible glass styling hooks are present in the SwiftUI workspace shell.
- Local workspace models exist for sessions, SSH profiles, snippets, premium plans, server snapshots, and Git summaries.
- Local file listing is wired through `DocumentManager.shared.activeDocumentsFolderURL`.
- A Supabase schema foundation exists for users, subscriptions, devices, snippet sync, AI usage, monitors, and audit logs.
- GitHub Actions includes an unsigned IPA workflow for CI artifact generation.
- Vendored dependency compatibility patches have been added for modern Xcode/iOS SDK builds.

### Partially implemented
- SSH manager UI is surfaced, but host connection management is still mostly mock/workspace-model driven.
- Git workspace screens exist, but full in-app clone/pull/commit/push flows are not finished.
- AI assistant surfaces and product affordances exist, but a real provider backend is not wired yet.
- Server monitoring cards exist, but live polling and alert delivery are not connected yet.
- Some premium/account-oriented UI models still exist in the workspace state, but the app direction is temporarily free until the core product is stable. 

### Not implemented yet
- Real encrypted SSH key vault sync.
- Full code editor with syntax highlighting and language tooling.
- Production AI request pipeline, rate limits, and usage billing.
- StoreKit/subscription entitlements and server-side purchase verification.
- Signed TestFlight/App Store distribution workflow.

## Architecture Notes

### App shell
- `OpenTerm/AppDelegate.swift` launches the SwiftUI workspace shell.
- `OpenTerm/Workspace/DeveloperWorkspaceRootView.swift` drives the main multi-surface experience.
- `OpenTerm/Workspace/LegacyTerminalContainerView.swift` wraps the legacy terminal controller.
- `OpenTerm/Workspace/WorkspaceStore.swift` currently powers much of the workspace with local/mock state.

### Backend foundation
- `supabase/migrations/20260506_workspace_foundation.sql` creates the initial hosted-data shape.
- Tables currently defined: `users`, `subscriptions`, `devices`, `ssh_profiles_metadata`, `snippets`, `ai_usage`, `server_monitors`, `audit_logs`.
- Sensitive SSH material should remain end-to-end encrypted before upload. Raw private keys should not be stored server-side in plaintext.

### CI
- `.github/workflows/ios-unsigned-ipa.yml` builds an unsigned archive and packages an IPA artifact.
- The workflow also patches several older vendored dependencies to keep the project compatible with modern Xcode/iOS SDKs.
- Unsigned IPAs are for build verification and sideload-style testing only.

## Product Direction

### Core product goals
- Modernize the UX with SwiftUI while preserving terminal reliability.
- Add a real tabbed workspace for terminal, files, git, servers, and AI.
- Keep the app friendly to both advanced users and newer developers.
- Keep the product extensible for future paid features, but focus current work on quality, reliability, and core workflows.

### Current release direction
- The app is being treated as free until the terminal core, SwiftUI workspace shell, SSH flow, Git tools, AI features, and CI/build reliability are stable.
- Payment and entitlement work is intentionally deferred so product quality can be validated before monetization.
- Any old premium or billing-oriented references in the codebase should be treated as product placeholders, not finished billing behavior.

## Commands Included

|            |            |            |            |
| ---------- | ---------- | ---------- | ---------- |
| awk        | cat        | cd         | chflags    |
| chksum     | clear      | compress   | cp         |
| credits    | cub        | curl       | date       |
| dig        | du         | echo       | egrep      |
| env        | fgrep      | grep       | gunzip     |
| gzip       | help       | host       | link       |
| ln         | ls         | mkdir      | mv         |
| nc         | nslookup   | open-url   | pbcopy     |
| pbpaste    | ping       | printenv   | pwd        |
| readlink   | rlogin     | rm         | rmdir      |
| say        | scp        | sed        | setenv     |
| sftp       | share      | sleep      | ssh        |
| ssh-keygen | stat       | sum        | tar        |
| tee        | telnet     | touch      | tr         |
| uname      | uncompress | unlink     | unsetenv   |
| uptime     | wc         | whoami     |            |

## Local Setup
- Run `bootstrap.sh` if you need to restore local dependencies.
- Open `OpenTerm.xcworkspace`.
- Build the `OpenTerm` scheme.
- If you want to run on a real device locally, you still need your own signing identity/provisioning and any framework resigning required by the legacy stack.

## GitHub Actions
The CI workflow at `.github/workflows/ios-unsigned-ipa.yml` produces an unsigned IPA artifact.

Important:
- Unsigned IPAs do not install on normal real iPhones without signing/provisioning, sideload tooling, or a special device environment.
- A signed workflow for TestFlight/App Store should be added separately with Apple certificate and provisioning profile secrets.

## Roadmap
- [x] Preserve terminal core
- [x] Add SwiftUI workspace shell
- [x] Add unsigned IPA CI pipeline
- [x] Add backend schema foundation
- [ ] Replace mock SSH manager with real connection flow
- [ ] Add code editor and syntax highlighting
- [ ] Finish in-app Git actions
- [ ] Connect AI provider and usage metering
- [ ] Add encrypted vault and sync
- [ ] Add signed beta/TestFlight distribution

## Documentation
- `Documentation/OpenTerm-AI-Workspace-Blueprint.md`
- `Documentation/OpenTerm-Data-And-Monetization.md`
- `Documentation/OpenTerm-Backend-Architecture.md`

## License
OpenTerm is available under the GPLv2 (or later) and the MPLv2 license.

See [COPYING](./COPYING) for more license info.
