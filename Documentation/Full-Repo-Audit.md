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
- File import/export/editing is now real in the SwiftUI Files tab.
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
- Xcode project, iCloud, and UTI identifiers still carry `com.silverfox` legacy identity values. Spotlight indexing now uses the fork identity, but signing/iCloud container migration still needs a deliberate entitlements pass.
- The hero previously claimed a static iOS SDK version instead of runtime-conditional support.

## Fixed In Current Anti-Fake Pass

- Removed fake SSH hosts and demo server monitors.
- Removed seeded command snippets and added user snippet create/edit/delete.
- Added honest empty states for Home, Git, Servers, AI, Files, monitors, vault, alerts, and snippets, plus a Home capability dashboard for configured/missing states.
- Added global workspace status feedback.
- Disabled live AI sending until a real endpoint/key or hosted proxy/token is configured.
- Added `git` preflight before terminal-driven Git commands.
- Rejected blank SSH profiles and invalid monitor records before persistence.
- Blocked vault push/pull UI until required Supabase configuration exists.
- Rewrote active docs to mark billing/backend production work as deferred/scaffolded.
- Removed old App Store badge/Terminal for iOS README framing, disabled the legacy StoreKit review prompt call, replaced the old App Store review settings row with repo/support links, and removed the old Silver Fox copyright text from the legacy Settings footer.
- Hardened several old crash-prone utility paths: bundle version/build lookup, directory file-size metadata, attributed file-link mutation, drag/drop URL paste handling, asset color lookup, legacy settings color picker loading, malformed ANSI color parsing, missing script examples, missing Cub docs, and legacy terminal storyboard panel loading, unsupported coder initializers, command execution data writes, share argv parsing, and Spotlight identity now avoid stale/fatal behavior where safe.

## Still Bad / High Priority

1. The visual design has been moved away from the dark generic AI-card look, but still needs a deeper information-architecture pass to reduce card count and make each surface feel more like a focused tool.
2. The terminal screen is still the 2017/2018 UIKit terminal embedded inside SwiftUI. It needs a modern toolbar, session switcher, and terminal-specific status/action surface.
3. Legacy storyboards and scripting panels remain old. They are real legacy features, but visually inconsistent and still need replacement even after the worst force-cast/fatal paths were reduced.
4. Git is still terminal-driven, not native. That is acceptable only if the UI keeps saying so.
5. Editor is still lightweight text editing, not an IDE. There is no LSP, diagnostics, rename, file tree refactor, or package awareness.
6. Local developer toolchains are not embedded. Python/Node/Vim/Nano/Tmux/Htop are not local app features.
7. Supabase backend is not production deployed/validated from this repo alone.
8. Tokens/API keys should move to Keychain before production.
9. `extraCommandsDictionary.plist` advertises extra command entries, but the active app currently relies on `commandsAsArray()` from ios_system and selected replacements. Command availability should be verified at runtime before docs claim support.
10. iCloud container identifiers are legacy-shaped and may not match the current bundle/team without signing validation.

## Next Concrete Fixes

- Replace the remaining marketing/card-heavy UI with compact operational surfaces. Home now has the first version of a real capability dashboard.
- Add a real capability/status screen that shows configured/missing requirements for AI, vault sync, Git, monitors, SSH, files, and terminal.
- Add file rename/move and folder export.
- Replace or quarantine the old storyboard scripting/documentation screens before calling the UI modern.
- Continue removing `fatalError` and force-cast paths from legacy controllers.
- Add runtime command availability capture and surface it in Help/README.
- Add Keychain-backed storage for AI and Supabase secrets.
- Add SSH monitor preflight command that checks `ssh`, auth type, `top`, `awk`, `df`, `uptime`, and `/proc/meminfo` before creating monitor expectations.
