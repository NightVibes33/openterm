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
- SSH profiles include remote Tool Audit and Dev Stack actions that verify package managers/tool versions, then queue safe package-manager commands for Git, Python 3, pip, Node.js, npm, htop, nano, vim, and tmux on Debian/Ubuntu, Alpine, Fedora/RHEL, or auto-detected Linux hosts.
- A local SSH key vault foundation exists with protected on-device key files, metadata, import/delete actions, and attach-to-profile flow.
- Encrypted SSH vault push/pull is wired through Supabase RPC with AES-GCM payload encryption and a user-provided vault sync secret; raw private keys are not sent as plaintext.
- Local files are scanned from `DocumentManager.shared.activeDocumentsFolderURL`; UTF-8 files can open in an in-app syntax-highlighted editor with search/match highlighting and save back to disk.
- Command snippets persist locally and can run directly in the terminal, including remote Linux dev-stack setup snippets for Debian, Alpine, and Fedora servers.
- Git repositories are detected by scanning for `.git` folders, and clone/status/diff/log/pull/commit/push actions are terminal-driven.
- Server monitors persist locally and can poll Linux CPU, memory, disk, and load snapshots over noninteractive SSH.
- The AI assistant can call a configurable OpenAI-compatible chat endpoint, records local usage history, includes prompt shortcuts for errors, commands, scripts, SSH, remote dev setup, Docker, Git conflicts, and regex, and can insert assistant output back into the terminal.
- The iPhone More tab is custom now, not Apple's automatic overflow list, and contains real AI, Git, settings, theme, and terminal controls.
- Settings are free-preview focused with real AI/provider controls and live appearance controls instead of placeholder billing screens.
- Workspace backup export writes a JSON manifest for profiles, snippets, monitors, vault metadata, and AI routing metadata without raw private-key contents.
- Backend settings now store Supabase URL, access token, and device label locally for hosted AI proxy routing and future sync bootstrap.
- A Supabase schema foundation exists for users, subscriptions, devices, snippet sync, AI usage, monitors, audit logs, AI rate-limit windows, encrypted vault sync items, and monitor alerts.
- GitHub Actions includes a green unsigned IPA workflow for CI artifact generation.
- Vendored dependency compatibility patches have been added for modern Xcode/iOS SDK builds.

### Partially implemented
- SSH profile and key-vault storage are local first. App-side encrypted vault push/pull is wired through Supabase RPC, but production deployment, conflict resolution, and migration rollout still need validation.
- Server monitoring works for noninteractive SSH profiles; password-based profiles still require manual terminal sessions.
- Git actions are terminal-driven because this fork does not currently bundle a native Git engine.
- The editor has lightweight syntax highlighting, language detection, and search/match highlighting, but full language-server tooling, completions, and diff views are not finished.
- The AI assistant supports direct provider routing or hosted Supabase proxy routing, prompt shortcuts, terminal handoff, and local usage history. Backend tables/functions and an Edge Function scaffold exist for hosted rate-limit enforcement, but deployment secrets, production auth hardening, and remote configuration still need to be completed.

### Not implemented yet
- Automatic conflict-resolved SSH vault sync with background refresh and recovery UX.
- Full language-server tooling, completions, and diff views in the code editor.
- Native Git engine integration with structured conflict handling.
- Production AI proxy deployment secrets, remote configuration, and hosted auth hardening.
- StoreKit/subscription entitlements and server-side purchase verification.

## Architecture Notes

### App shell
- `OpenTerm/AppDelegate.swift` launches the SwiftUI workspace shell.
- `OpenTerm/Workspace/DeveloperWorkspaceRootView.swift` drives the main multi-surface experience.
- `OpenTerm/Workspace/LegacyTerminalContainerView.swift` wraps the legacy terminal controller.
- `OpenTerm/Workspace/WorkspaceStore.swift` owns local workspace state, persistence, terminal actions, SSH profile commands, protected local vault metadata, monitor refresh, Git command queuing, file editing, snippets, backup export, backend bootstrap settings, app accent state, and AI provider/proxy configuration. The SwiftUI workspace owns the lightweight highlighted editor surface.

### Backend foundation
- `supabase/migrations/20260506_workspace_foundation.sql` creates the initial hosted-data shape.
- `supabase/migrations/20260507_ai_vault_limits.sql` adds AI rate-limit windows, encrypted vault sync storage, monitor alert records, and rate-limit helper functions.
- `supabase/migrations/20260507_vault_sync_rpc.sql` adds RPC helpers for encrypted vault push/pull using base64 ciphertext over Supabase REST.
- `supabase/functions/ai-proxy/index.ts` is a deployable Edge Function scaffold for authenticated AI requests, rate-limit checks, OpenAI forwarding, and usage recording. It still needs hosted environment secrets, deployment, and production policy hardening before it should be treated as live infrastructure.
- Tables currently defined: `users`, `subscriptions`, `devices`, `ssh_profiles_metadata`, `snippets`, `ai_usage`, `server_monitors`, `audit_logs`, `ai_rate_limits`, `vault_sync_items`, `server_monitor_alerts`.
- Sensitive SSH material should remain end-to-end encrypted before upload. Raw private keys should not be stored server-side in plaintext.
- The active app direction is free until the core SSH, Git, editor, AI, monitoring, and sync workflows are stable.

### CI
- `.github/workflows/ios-unsigned-ipa.yml` builds an unsigned archive and packages an IPA artifact.
- The workflow raises stale vendored deployment targets, patches several older dependencies for modern Swift/iOS SDKs, and builds with an iOS 18.0 floor to avoid `libarclite` failures on current Xcode.
- Unsigned IPAs are for build verification and sideload-style testing only.

## Product Direction

### Core product goals
- Modernize the UX with SwiftUI while preserving terminal reliability.
- Build a tabbed mobile workspace for terminal, files, Git, servers, SSH, snippets, and AI.
- Position OpenTerm as a beautiful SSH + AI frontend for real Linux systems, not as a fake unrestricted Linux distro running locally on iPhone.
- Keep the app friendly to both advanced users and newer developers.
- Keep future paid features possible, but keep the current release free until product quality is stable.

### Current release direction
- Payment and entitlement work is intentionally deferred.
- Buy Me a Coffee, Stripe, StoreKit, and hosted subscription checks should be revisited only after the core workflows are reliable.
- No device serial-number scheme should be used for entitlement checks. Future verification should be account-based and privacy-preserving.

## Runtime And Sandbox Reality
- Sideloading does not automatically remove the iOS app sandbox. Without jailbreak-level changes or private Apple entitlements, OpenTerm still cannot behave like an unrestricted local Linux machine.
- Package managers such as `apt`, `brew`, `pkg`, `apk`, `dnf`, and `npm` are not available locally unless their runtimes are compiled into the app, embedded as app resources, or run on a remote machine.
- The practical product strategy is remote-first: connect to VPS/homelab/Linux servers over SSH, use snippets, SSH profile Dev Stack actions, and AI to generate safe setup commands, and run Git/Python/Node/Docker workflows on the real server.
- Local runtimes like Git, Python, Node, Vim, Nano, Tmux, or Htop should be treated as future embedded-toolchain work, with licensing, architecture, sandbox paths, and binary size reviewed per tool.

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
- Signed TestFlight/App Store distribution is intentionally not part of the active roadmap right now; this fork is focused on unsigned/sideload-style testing and SSH-first product quality.

## Roadmap
- [x] Preserve terminal core
- [x] Add SwiftUI workspace shell
- [x] Replace automatic iOS More overflow with a custom More hub
- [x] Add live app accent and modern terminal appearance settings
- [x] Add unsigned IPA CI pipeline
- [x] Add backend schema foundation
- [x] Replace mock SSH manager with local profiles and real terminal connect flow
- [x] Add remote SSH Tool Audit and Dev Stack setup actions for common Linux package managers
- [x] Add local UTF-8 text editor
- [x] Add lightweight syntax highlighting, language detection, and editor search
- [ ] Add language tooling, completions, and diff views
- [x] Add terminal-driven Git clone/status/diff/log/pull/commit/push actions
- [ ] Add native Git engine integration
- [x] Connect configurable AI provider endpoint, expanded command-layer prompt shortcuts, terminal handoff, and local usage history
- [x] Add backend AI rate-limit and usage-control schema
- [x] Add hosted AI proxy scaffold
- [x] Add app-side hosted proxy routing toggle
- [x] Add local production auth/backend bootstrap settings
- [ ] Add deployment secrets and hosted auth hardening
- [x] Add local protected SSH key vault foundation
- [x] Add backend encrypted vault sync tables
- [x] Add backup/export manifest for workspace metadata
- [x] Connect app-side encrypted vault push/pull controls with AES-GCM payload encryption
- [ ] Add vault sync conflict resolution, recovery UX, and background refresh

## Next Engineering Priorities
- Stabilize hosted AI proxy deployment: Supabase function secrets, auth validation, rate-limit policy tests, and remote feature flags.
- Harden encrypted vault sync: deploy RPC migration, test Supabase auth/RLS, add conflict resolution, recovery UX, and background refresh.
- Replace terminal-driven Git helpers with a native Git engine only after the current terminal-based workflow stays reliable.
- Add embedded local toolchains only where they are realistic: Git first, then Python/Node only after binary size, licensing, and sandbox behavior are validated.
- Improve remote server onboarding with deeper preflight checks for sudo availability, shell, disk space, and installed tool versions.
- Expand the editor from lightweight highlighting into real developer tooling: diff view, file tree actions, completions, and optional LSP-style assistance.
- Keep payment/subscription code deferred until the free core product is stable.

## Documentation
- `Documentation/OpenTerm-AI-Workspace-Blueprint.md`
- `Documentation/OpenTerm-Data-And-Monetization.md`
- `Documentation/OpenTerm-Backend-Architecture.md`

## License
OpenTerm is available under the GPLv2 (or later) and the MPLv2 license.

See [COPYING](./COPYING) for more license info.
