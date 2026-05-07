# Full Repo Audit

Last updated: 2026-05-07

This audit covers the whole checked-in repo, not only the new SwiftUI workspace.

## Repo Shape

- Swift app source: 72 Swift files, about 13,195 Swift lines.
- Interface Builder legacy UI: 1 large `Main.storyboard`, 1 launch storyboard, 3 XIB cells.
- Workspace shell: 3 Swift files, about 3,787 Swift lines.
- Legacy terminal/UI controllers: 20 controller files, about 4,019 Swift lines.
- Vendored dependencies: CocoaPods plus old `Dependencies` folders including ios_system/libssh2/network assets.
- Commands: 53 commands in `Resources/commandDictionary.plist`; 40 extra command entries in `Resources/extraCommandsDictionary.plist`.
- Backend scaffolding: Supabase migrations and one AI proxy Edge Function.
- CI: one unsigned IPA workflow.

## Real Core

- `TerminalViewController`, `TerminalView`, `CommandExecutor`, and `SystemExecutorCommand` run commands through `ios_system`.
- Terminal tabs are real through `TerminalTabViewController`, but the UI is still old UIKit/TabView.
- File import/export/rename/archive/editing is now real in the SwiftUI Files tab.
- SSH profile actions queue real `ssh` commands into the terminal.
- Server monitors run SSH command captures, but only work for noninteractive auth and compatible Linux tooling.
- AI live requests are real `URLSession` calls only after the user configures a provider/proxy.

## Fake Or Overstated Areas Found

- The SwiftUI workspace was previously presenting roadmap features like product cards instead of measured capability state.
- Home activity previously treated saved records as activity even before actual use.
- Demo SSH hosts, seeded monitor data, and seeded snippets made empty installs look falsely configured.
- AI previously looked ready before endpoint/key/proxy config existed.
- Git buttons previously assumed `git` existed in the terminal environment.
- Vault sync previously looked ready before Supabase/auth/secret config existed.
- Docs still presented monetization/premium/subscriptions as active product direction even though billing is deferred.
- README still linked the old App Store listing and old Terminal for iOS branding.
- Old App Store review prompt was still wired to keyboard-dismiss behavior.
- Xcode project, iCloud, and UTI identifiers previously carried `com.silverfox` legacy identity values. They now use `com.nightvibes33.openterm*`; production signing still needs matching Apple team entitlements.
- The hero previously claimed a static iOS SDK version instead of runtime-conditional support.

## Fixed In Current Anti-Fake Pass

- Removed fake SSH hosts and demo server monitors.
- Removed seeded command snippets and added user snippet create/edit/delete.
- Added honest empty states for Home, Git, Servers, AI, Files, monitors, vault, alerts, and snippets, plus a Home capability dashboard for configured/missing states.
- Removed the global floating workspace status bar after it proved disruptive over the tab workspace.
- Added runnable bundled script examples for system snapshots, website/API probes, archives, text search, and SSH command templates.
- Replaced hard-coded white text on light system cards with semantic foreground colors across the SwiftUI workspace shell and removed duplicate hero panel padding.
- Status text now remains internal feedback/state instead of rendering as a global overlay.
- Reworded inflated Live Workspace/Command Center copy to describe real activity and terminal-driven/configuration-gated tools. Home quick actions are now configuration-aware instead of opening unconfigured feature panels as if they were ready.
- Added real file/folder rename plus folder tar archive export from the Files tab.
- Removed prototype wording like preview build/free preview/live answers and broad ready-state labels from the in-app workspace copy. Optional backend bootstrap controls now read as manual setup rather than a finished account system.
- Disabled live AI sending until a real endpoint/key or hosted proxy/token is configured.
- Added `git` preflight before terminal-driven Git commands and removed the default generated commit message from the Git UI.
- Rejected blank SSH profiles and invalid monitor records before persistence.
- Blocked vault push/pull UI until required Supabase configuration exists.
- Rewrote active docs to mark billing/backend production work as deferred/scaffolded.
- Removed old App Store badge/Terminal for iOS README framing, disabled the legacy StoreKit review prompt call, replaced the old App Store review settings row with repo/support links, removed the old Silver Fox copyright text from the legacy Settings footer, and migrated active bundle/iCloud/UTI identifiers to fork-owned values.
- Hardened several old crash-prone utility paths: bundle version/build lookup, directory file-size metadata, attributed file-link mutation, drag/drop URL paste handling, asset color lookup, legacy settings color picker loading, malformed ANSI color parsing, missing script examples, missing Cub docs, and legacy terminal storyboard panel loading, unsupported coder initializers, command execution data writes, share argv parsing, optional storyboard factory loading, and Spotlight identity now avoid stale/fatal behavior where safe. Stale TODO/FIXME comments in touched app code were removed where the behavior is now explicit.

## Still Bad / High Priority

1. The visual design no longer uses the worst white-on-light card mismatch, but still needs a deeper information-architecture pass to reduce card count and make each surface feel more like a focused tool.
2. The terminal screen is still the 2017/2018 UIKit terminal embedded inside SwiftUI. It needs a modern toolbar, session switcher, and terminal-specific status/action surface.
3. Legacy storyboards and scripting panels remain old. They are real legacy features, but visually inconsistent and still need replacement even after force-cast/fatal crash paths were removed from the app source scan.
4. Git is still terminal-driven, not native. That is acceptable only if the UI keeps saying so.
5. Editor is still lightweight text editing, not an IDE. There is no LSP, diagnostics, rename, file tree refactor, or package awareness.
6. Local developer toolchains are not embedded. Python/Node/Vim/Nano/Tmux/Htop are not local app features.
7. Supabase backend is not production deployed/validated from this repo alone.
8. AI and backend secrets now use Keychain-backed storage, but older installs should be validated for one-time migration from legacy JSON fields.
9. `extraCommandsDictionary.plist` advertises extra command entries, but the active app currently relies on `commandsAsArray()` from ios_system and selected replacements. Command availability should be verified at runtime before docs claim support.
10. iCloud container identifiers are fork-shaped now, but still need validation with the actual Apple team and provisioning profile before production signing.

## Next Concrete Fixes

- Replace the remaining marketing/card-heavy UI with compact operational surfaces. Home now has the first version of a real capability dashboard.
- Keep capability/status labels strict: local, configured, terminal-driven, or missing; avoid broad ready/live claims unless the app has verified them.
- Add file move/copy and richer binary preview metadata. Rename and folder tar export are now implemented.
- Replace the old storyboard scripting/documentation screens before calling the UI modern; examples remain available because the scripting flow works, but the controller is still legacy UIKit.
- Replace the optional-fallback legacy storyboard flows with real SwiftUI screens instead of relying on old Interface Builder scenes.
- Add runtime command availability capture and surface it in Help/README.
- Validate Keychain secret migration on a real device and confirm legacy JSON fields are redacted after save.
- Add SSH monitor preflight command that checks `ssh`, auth type, `top`, `awk`, `df`, `uptime`, and `/proc/meminfo` before creating monitor expectations.

## Current Findings
- Reworked the More tab into a focused hub and moved the full Settings form behind an explicit Settings sheet instead of dumping every setting inline.
- Removed the global floating workspace status strip entirely and upgraded shared workspace card/backdrop/action tile styling so the main shell is less flat and less generic.
- Reworked the Files tab from generic rows into a visible file-manager workspace with import/new/refresh actions, folder/file counts, explicit row actions, and honest real-storage copy.
- Added first-run onboarding and a SwiftUI About/Support card with Buy Me a Coffee, GitHub, X, and contact links so the modern app shell no longer hides those legacy About links.
- Validated network_ios header downloads in CI/local bootstrap so a transient GitHub HTML error page cannot be compiled as `ios_error.h`.
