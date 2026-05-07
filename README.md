<h1 align="center">OpenTerm</h1>

<p align="center">
The modern free SSH + terminal workspace for iPhone and iPad.
</p>

<p align="center">
<a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift"/></a>
<img src="https://img.shields.io/badge/Platform-iOS%2018.0+-lightgrey.svg" alt="Platform: iOS">
<a href="https://github.com/NightVibes33/openterm/actions/workflows/ios-unsigned-ipa.yml"><img src="https://github.com/NightVibes33/openterm/actions/workflows/ios-unsigned-ipa.yml/badge.svg" alt="Build Status"/></a>
<br>
<a href="http://twitter.com/NightVibes33"><img src="https://img.shields.io/badge/Twitter-@NightVibes33-blue.svg?style=flat" alt="Twitter"/></a>
</p>

## About
OpenTerm is being refocused from a standalone terminal app into a free SSH + terminal workspace for iPhone and iPad, with optional AI command assistance after the user configures a provider.

The current design target is real-tool clarity first: fewer marketing cards, lighter system-native surfaces, clear local-vs-remote labels, honest setup states, fast terminal access, and an interface that does not pretend unavailable features are ready.

## Current Repo Status

Donations support development only: the app is currently free, and Buy Me a Coffee is exposed as a support link rather than an entitlement or paywall.

### Implemented in this fork right now
- Legacy OpenTerm terminal core is still present and embedded inside the SwiftUI workspace. Several older storyboard/XIB scripting and documentation panels still exist and are tracked as modernization debt rather than finished 2026-quality UI, but the Scripts panel remains functional and the bundled examples are maintained as runnable script samples.
- `AppDelegate` launches the modern workspace shell with Home, Files, Terminal, Servers, and a custom More hub on iPhone, plus full workspace navigation on iPad. Home now shows a real capability check instead of marketing cards, and empty Home/Git/Server/AI states explicitly ask for real user data or provider configuration.
- iOS 18.0 is the deployment floor, with Liquid Glass-style SwiftUI surfaces enabled conditionally when the SDK/runtime supports them instead of pretending unsupported devices have native iOS 26 materials.
- Terminal commands can now be queued or executed from workspace actions, so SSH, Git, snippets, and generated commands can jump into the active terminal tab.
- Terminal appearance has a modernized canvas with live font, cursor, keyboard, text color, background color, and app accent controls.
- SSH profiles persist locally with label, host, username, port, auth type, key path, startup path, notes, and last-used timestamps; new installs no longer seed fake example hosts, and blank profiles are rejected.
- SSH quick connect now builds and runs real `ssh` commands through the terminal instead of only switching screens.
- SSH profiles include remote Tool Audit and Dev Stack actions that verify package managers/tool versions, then queue safe package-manager commands for Git, Python 3, pip, Node.js, npm, htop, nano, vim, and tmux on Debian/Ubuntu, Alpine, Fedora/RHEL, or auto-detected Linux hosts.
- A local SSH key vault foundation exists with protected on-device key files, metadata, import/delete actions, and attach-to-profile flow.
- Encrypted SSH vault push/pull is wired through Supabase RPC with AES-GCM payload encryption, a user-provided vault sync secret, newer-wins conflict handling, local metadata repair, and app-active background refresh; raw private keys are not sent as plaintext. The UI now blocks push/pull until the required Supabase/auth/secret configuration exists.
- The Files tab now works as a real iOS document workspace with a stronger file-manager UI: Apple document-browser access, visible import/new/refresh actions, folder/file counts, folder navigation, Files app import, create file/folder, rename, delete, file share/export, folder tar archive export, UTF-8 editing, syntax highlighting, search/match highlighting, lightweight completion chips, diff view against the opened version, and save back to disk.
- Command snippets persist locally and can be created, edited, deleted, and run directly in the terminal. New installs no longer seed generic fake deploy/server snippets.
- Bundled Prideland script examples include runnable local workflows for system snapshots, website probes, API checks, tar archives, grep/sed notes, SSH command templates, dice, clipboard, regex, and cleanup tasks.
- Git repositories are detected by scanning for `.git` folders, and clone/status/diff/log/pull/commit/push plus structured conflict actions are terminal-driven with a `git` availability preflight before commands run.
- Server monitors persist locally, poll Linux CPU/memory/disk/load snapshots over noninteractive SSH, and keep a local acknowledgeable alert history when thresholds change; monitors are user-created and monitor cards appear only after real poll results.
- The AI assistant can call a configurable OpenAI-compatible chat endpoint or hosted Supabase proxy, records local usage history, includes prompt shortcuts for errors, commands, scripts, SSH, remote dev setup, Docker, Git conflicts, and regex, and can insert assistant output back into the terminal. Live sending is disabled until a real endpoint/key or proxy/token is configured.
- The iPhone More tab is custom now, not Apple's automatic overflow list. It acts as a focused hub for AI, Git, refresh, setup summary, About/Support links, and Buy Me a Coffee; the full Settings form opens intentionally instead of being dumped inline.
- The SwiftUI workspace now uses semantic text colors, stronger shared glass cards, a richer backdrop, rounded typography in key hero/action surfaces, and more deliberate action tiles instead of flat generic blocks.
- Workspace status messages are no longer rendered as a floating global bar; they remain internal feedback/state so the main tabs are not covered.
- The home and More copy now avoids inflated âlive/command centerâ language and labels Git/AI as terminal-driven or configuration-gated where appropriate.
- Home quick actions are configuration-aware: AI routes to setup until configured, monitors route to SSH/server setup until monitors exist, and Git starts with repo discovery.
- Git commit action now requires a user-entered commit message instead of defaulting to generic generated text.
- Prototype wording such as âpreview build,â âFree preview,â âlive answers,â and broad âreadyâ labels was removed from the in-app workspace copy.
- First-run onboarding now explains the real workflow: terminal, Files import/editing, SSH profiles, optional AI setup, and setup shortcuts. Settings are free-app focused with real AI/provider controls, appearance controls, and clearly optional backend bootstrap fields instead of placeholder billing screens.
- Optional backend settings are now labeled as manual bootstrap, and remote config refresh is disabled until required Supabase fields are present.
- Workspace backup export writes a JSON manifest for profiles, snippets, monitors, vault metadata, and AI routing metadata without raw private-key contents.
- Backend settings store non-secret routing metadata locally, while AI provider keys, Supabase anon/access tokens, and vault sync secrets are routed through Keychain-backed local storage for hosted AI proxy routing, encrypted vault sync, and remote config refresh.
- A Supabase schema foundation exists for users, subscriptions, devices, snippet sync, AI usage, monitors, audit logs, AI rate-limit windows, encrypted vault sync items, and monitor alerts.
- GitHub Actions includes a green unsigned IPA workflow for CI artifact generation. The dependency bootstrap now validates the legacy `ios_error.h` download so transient GitHub HTML error pages are not compiled as C headers.
- Vendored dependency compatibility patches have been added for modern Xcode/iOS SDK builds. The checked-in Pods project has been normalized to the iOS 18 floor and Swift 5 build settings instead of old iOS 8/10/11 and Swift 4 values. Several old utility, settings, scripting, and ANSI parsing crash paths have been hardened, stale TODO/FIXME comments in touched app code were cleaned up, but legacy controller cleanup is still ongoing.

### Partially implemented
- SSH profile and key-vault storage are local first. App-side encrypted vault push/pull, newer-wins conflict handling, local repair, and app-active refresh are wired; production migration rollout and real multi-device testing still need validation.
- Server monitoring works for noninteractive SSH profiles with local alert history; password-based profiles still require manual terminal sessions.
- Git actions are terminal-driven because this fork does not currently bundle a native Git engine.
- The editor has lightweight syntax highlighting, language detection, search/match highlighting, completion chips, and an in-app diff view. Full external LSP daemon integration is not bundled yet.
- The AI assistant supports direct provider routing or hosted Supabase proxy routing, prompt shortcuts, terminal handoff, local usage history, and app-side remote config refresh. Backend tables/functions and an Edge Function scaffold exist for hosted rate-limit enforcement, but live deployment secrets and production auth hardening still need environment setup.

### Not implemented yet
- Full external language-server daemon integration in the code editor.
- Embedded native Git engine integration; structured conflict workflows exist but still run through terminal Git.
- Production AI proxy deployment secrets and hosted auth hardening.
- Payment, StoreKit, subscription entitlements, and server-side purchase verification are intentionally deferred and not active product behavior.

## Architecture Notes

### App shell
- `OpenTerm/AppDelegate.swift` launches the SwiftUI workspace shell. Bundle, iCloud container, document UTI, and Spotlight-style local identifiers have been moved to `com.nightvibes33.openterm*` fork-owned values. Real production signing still needs matching Apple team entitlements.
- `OpenTerm/Workspace/DeveloperWorkspaceRootView.swift` drives the main multi-surface experience.
- `OpenTerm/Workspace/LegacyTerminalContainerView.swift` wraps the legacy terminal controller.
- `OpenTerm/Workspace/WorkspaceStore.swift` owns local workspace state, persistence, terminal actions, SSH profile commands, protected local vault metadata, monitor refresh, Git command queuing, file editing, snippets, backup export, backend bootstrap settings, app accent state, and AI provider/proxy configuration. The SwiftUI workspace owns the lightweight highlighted editor surface.

### Backend foundation
- `supabase/migrations/20260506_workspace_foundation.sql` creates the initial hosted-data shape.
- `supabase/migrations/20260507_ai_vault_limits.sql` adds AI rate-limit windows, encrypted vault sync storage, monitor alert records, and rate-limit helper functions.
- `supabase/migrations/20260507_vault_sync_rpc.sql` adds RPC helpers for encrypted vault push/pull using base64 ciphertext over Supabase REST.
- `supabase/migrations/20260507_remote_config.sql` adds enabled remote config records for AI proxy, vault sync, and remote tool policy.
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
- Buy Me a Coffee is currently a donation/support link only. Stripe, StoreKit, hosted subscription checks, and entitlement gates should be revisited only after the core workflows are reliable.
- No device serial-number scheme should be used for entitlement checks. Future verification should be account-based and privacy-preserving.

## Dependency modernization note
- Legacy Pods are still present because the terminal, scripts, input assistant, and Cub editor paths still depend on them. The immediate modernization path is to keep the working terminal stack compiling on the iOS 18 floor, remove unused legacy UI usage as it is replaced, then delete Pods one by one only after their imports are gone.

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
- Run `bootstrap.sh` if you need to restore local dependencies, Apple OSS sources, frameworks, and pods in one pass. It validates the legacy `ios_error.h` framework header after download before continuing.
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
- [x] Remove seeded fake SSH/server monitor demo data and show honest empty states
- [x] Add honest empty states for Home activity and Git repository discovery
- [x] Disable unconfigured AI live sends and show explicit provider/proxy setup state
- [x] Stop showing monitor and recent-activity cards until real actions produce data
- [x] Remove the floating global status bar so it no longer covers the workspace tabs
- [x] Remove seeded fake snippets and add real snippet create/edit/delete flow
- [x] Add terminal Git availability preflight before Git commands
- [x] Reject blank SSH profiles and invalid monitor records before they create broken cards
- [x] Make encrypted vault sync visibly unavailable until required backend settings are configured
- [x] Replace Home marketing capability cards with a real configured/missing capability dashboard
- [x] Add repo reality audit documentation
- [x] Add remote SSH Tool Audit and Dev Stack setup actions for common Linux package managers
- [x] Add local server monitor alert history and acknowledgement
- [x] Add real iOS file navigation, Files import, create folder/file, rename, delete, file export, folder archive export, and local UTF-8 text editing
- [x] Add lightweight syntax highlighting, language detection, and editor search
- [x] Add lightweight editor completions and diff view
- [ ] Add external LSP daemon integration
- [x] Add terminal-driven Git clone/status/diff/log/pull/commit/push actions
- [x] Add structured Git conflict workflow actions
- [ ] Add embedded native Git engine integration
- [x] Connect configurable AI provider endpoint, expanded command-layer prompt shortcuts, terminal handoff, and local usage history
- [x] Add backend AI rate-limit and usage-control schema
- [x] Add hosted AI proxy scaffold
- [x] Add app-side hosted proxy routing toggle
- [x] Add local production auth/backend bootstrap settings
- [x] Move AI/backend/vault secrets into Keychain-backed local storage
- [x] Add Supabase remote config schema and app refresh action
- [ ] Add deployment secrets and hosted auth hardening
- [x] Add local protected SSH key vault foundation
- [x] Add backend encrypted vault sync tables
- [x] Add backup/export manifest for workspace metadata
- [x] Connect app-side encrypted vault push/pull controls with AES-GCM payload encryption
- [x] Add vault sync newer-wins conflict handling, local repair, and app-active refresh
- [x] Disable stale StoreKit review prompting, remove the old App Store review settings action, and replace stale legacy Settings identity links while the app is free/unsigned focused
- [x] Harden selected old utility force-cast crash paths
- [ ] Replace legacy storyboard/XIB scripting and documentation panels with modern SwiftUI or remove them from the primary flow
- [x] Harden legacy scripting/examples/documentation panels against missing resources and bad cell casts
- [x] Keep the working Scripts panel available and expand bundled runnable examples for system checks, HTTP/API probes, archives, grep notes, and SSH command templates
- [x] Replace the darkest generic AI-card backdrop with lighter system-native workspace surfaces
- [x] Replace hard-coded white workspace labels with semantic text colors for readable light/dark/glass surfaces
- [x] Harden legacy terminal storyboard panel loading against bad casts
- [x] Replace safe legacy coder fatal errors with failable initializers
- [x] Move Spotlight, bundle, iCloud container, and document UTI identity off old `com.silverfox.*` values
- [x] Harden command execution/share command force unwraps
- [x] Remove remaining scanned `fatalError`, `as!`, `try!`, and obvious force-unwrap crash paths from app Swift source
- [x] Make Home capability badges and main workspace copy use local/configured/terminal-driven labels instead of broad ready/live claims
- [ ] Replace optional-fallback legacy storyboard flows with real SwiftUI screens

## Next Engineering Priorities
- Stabilize hosted AI proxy deployment: Supabase function secrets, auth validation, rate-limit policy tests, and real-device Keychain migration checks.
- Harden encrypted vault sync: deploy RPC migration, test Supabase auth/RLS, and validate real multi-device conflict behavior.
- Replace terminal-driven Git helpers with a native Git engine only after the current terminal-based workflow stays reliable.
- Add embedded local toolchains only where they are realistic: Git first, then Python/Node only after binary size, licensing, and sandbox behavior are validated.
- Improve remote server onboarding with deeper preflight checks for sudo availability, shell, disk space, installed tool versions, and monitor alert delivery.
- Expand the editor from lightweight highlighting into real developer tooling: move/copy file actions, richer completions, language intelligence, and optional LSP-style assistance.
- Keep payment/subscription code deferred until the free core product is stable.

## Documentation
- `Documentation/OpenTerm-AI-Workspace-Blueprint.md`
- `Documentation/OpenTerm-Data-And-Monetization.md`
- `Documentation/OpenTerm-Backend-Architecture.md`
- `Documentation/Reality-Audit.md`
- `Documentation/Full-Repo-Audit.md`

## License
OpenTerm is available under the GPLv2 (or later) and the MPLv2 license.

See [COPYING](./COPYING) for more license info.
