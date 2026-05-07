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
- Legacy OpenTerm terminal core is still present and embedded inside the SwiftUI workspace.
- `AppDelegate` launches the modern workspace shell with Home, Files, Terminal, Servers, and a custom More hub on iPhone, plus full workspace navigation on iPad.
- iOS 18.0 is the deployment floor, with iOS 26 Liquid Glass-style SwiftUI surfaces enabled when the SDK/runtime supports them.
- Terminal commands can now be queued or executed from workspace actions, so SSH, Git, snippets, and generated commands can jump into the active terminal tab.
- Terminal appearance has a modernized canvas with live font, cursor, keyboard, text color, background color, and app accent controls.
- SSH profiles persist locally with label, host, username, port, auth type, key path, startup path, notes, and last-used timestamps.
- SSH quick connect now builds and runs real `ssh` commands through the terminal instead of only switching screens.
- A local SSH key vault foundation exists with protected on-device key files, metadata, import/delete actions, and attach-to-profile flow.
- Local files are scanned from `DocumentManager.shared.activeDocumentsFolderURL`; UTF-8 files can open in an in-app syntax-highlighted editor and save back to disk.
- Command snippets persist locally and can run directly in the terminal.
- Git repositories are detected by scanning for `.git` folders, and clone/status/pull/commit/push actions are terminal-driven.
- Server monitors persist locally and can poll Linux CPU, memory, disk, and load snapshots over noninteractive SSH.
- The AI assistant can call a configurable OpenAI-compatible chat endpoint, records local usage history, includes prompt shortcuts, and can insert assistant output back into the terminal.
- The iPhone More tab is custom now, not Apple's automatic overflow list, and contains real AI, Git, settings, theme, and terminal controls.
- Settings are free-preview focused with real AI/provider controls and live appearance controls instead of placeholder billing screens.
- A Supabase schema foundation exists for users, subscriptions, devices, snippet sync, AI usage, monitors, and audit logs.
- GitHub Actions includes a green unsigned IPA workflow for CI artifact generation.
- Vendored dependency compatibility patches have been added for modern Xcode/iOS SDK builds.

### Partially implemented
- SSH profile and key-vault storage are local only. Encrypted cloud vault sync is not connected yet.
- Server monitoring works for noninteractive SSH profiles; password-based profiles still require manual terminal sessions.
- Git actions are terminal-driven because this fork does not currently bundle a native Git engine.
- The editor has lightweight syntax highlighting and language detection, but full language-server tooling, completions, and diff views are not finished.
- The AI assistant supports a configurable provider endpoint, prompt shortcuts, terminal handoff, and local usage history, but production auth, rate limits, hosted usage enforcement, and billing are deferred.

### Not implemented yet
- End-to-end encrypted SSH key vault sync across devices.
- Full language-server tooling, completions, and diff views in the code editor.
- Native Git engine integration with structured conflict handling.
- Production AI request proxy, rate limits, and server-side usage controls.
- StoreKit/subscription entitlements and server-side purchase verification.
- Signed App Store distribution workflow.

## Architecture Notes

### App shell
- `OpenTerm/AppDelegate.swift` launches the SwiftUI workspace shell.
- `OpenTerm/Workspace/DeveloperWorkspaceRootView.swift` drives the main multi-surface experience.
- `OpenTerm/Workspace/LegacyTerminalContainerView.swift` wraps the legacy terminal controller.
- `OpenTerm/Workspace/WorkspaceStore.swift` owns local workspace state, persistence, terminal actions, SSH profile commands, monitor refresh, Git command queuing, file editing, snippets, app accent state, and AI provider configuration. The SwiftUI workspace owns the lightweight highlighted editor surface.

### Backend foundation
- `supabase/migrations/20260506_workspace_foundation.sql` creates the initial hosted-data shape.
- Tables currently defined: `users`, `subscriptions`, `devices`, `ssh_profiles_metadata`, `snippets`, `ai_usage`, `server_monitors`, `audit_logs`.
- Sensitive SSH material should remain end-to-end encrypted before upload. Raw private keys should not be stored server-side in plaintext.
- The active app direction is free until the core SSH, Git, editor, AI, and monitoring workflows are stable.

### CI
- `.github/workflows/ios-unsigned-ipa.yml` builds an unsigned archive and packages an IPA artifact.
- The workflow raises stale vendored deployment targets, patches several older dependencies for modern Swift/iOS SDKs, and builds with an iOS 18.0 floor to avoid `libarclite` failures on current Xcode.
- Unsigned IPAs are for build verification and sideload-style testing only.

## Product Direction

### Core product goals
- Modernize the UX with SwiftUI while preserving terminal reliability.
- Build a tabbed mobile workspace for terminal, files, Git, servers, SSH, snippets, and AI.
- Keep the app friendly to both advanced users and newer developers.
- Keep future paid features possible, but keep the current release free until product quality is stable.

### Current release direction
- Payment and entitlement work is intentionally deferred.
- Buy Me a Coffee, Stripe, StoreKit, and hosted subscription checks should be revisited only after the core workflows are reliable.
- No device serial-number scheme should be used for entitlement checks. Future verification should be account-based and privacy-preserving.

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
- Run `bootstrap.sh` if you need to restore local dependencies, Apple OSS sources, frameworks, and pods in one pass.
- Open `OpenTerm.xcworkspace`.
- Build the `OpenTerm` scheme.
- If you want to run on a real device locally, you still need your own signing identity/provisioning. `resign-frameworks.sh` now uses the signing identity you provide instead of an old hard-coded developer certificate.

## GitHub Actions
The CI workflow at `.github/workflows/ios-unsigned-ipa.yml` produces an unsigned IPA artifact.

Important:
- Unsigned IPAs do not install on normal real iPhones without signing/provisioning, sideload tooling, or a special device environment.
- Signed App Store distribution can be added later with Apple certificate and provisioning profile secrets when distribution is needed.

## Roadmap
- [x] Preserve terminal core
- [x] Add SwiftUI workspace shell
- [x] Replace automatic iOS More overflow with a custom More hub
- [x] Add live app accent and modern terminal appearance settings
- [x] Add unsigned IPA CI pipeline
- [x] Add backend schema foundation
- [x] Replace mock SSH manager with local profiles and real terminal connect flow
- [x] Add local UTF-8 text editor
- [x] Add lightweight syntax highlighting and language detection
- [ ] Add language tooling, completions, and diff views
- [x] Add terminal-driven Git clone/status/pull/commit/push actions
- [ ] Add native Git engine integration
- [x] Connect configurable AI provider endpoint, prompt shortcuts, terminal handoff, and local usage history
- [ ] Add hosted AI proxy, rate limits, and server-side usage controls
- [x] Add local protected SSH key vault foundation
- [ ] Add encrypted vault sync across devices
- [ ] Add signed App Store distribution when needed

## Documentation
- `Documentation/OpenTerm-AI-Workspace-Blueprint.md`
- `Documentation/OpenTerm-Data-And-Monetization.md`
- `Documentation/OpenTerm-Backend-Architecture.md`

## License
OpenTerm is available under the GPLv2 (or later) and the MPLv2 license.

See [COPYING](./COPYING) for more license info.
