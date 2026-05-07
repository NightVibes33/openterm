# OpenTerm Reality Audit

Last updated: 2026-05-07

This fork should not pretend to be a native full IDE yet. The real product direction is a polished iOS workspace around terminal, files, SSH, remote Linux workflows, and optional AI.

## Real, Wired Behavior

- Terminal core is real and still executes built-in OpenTerm commands.
- Files tab now browses the app documents root, navigates folders, imports from iOS Files, creates files/folders, deletes items, exports files through the share sheet, and edits UTF-8 text files.
- SSH profiles are persisted locally and generate real terminal `ssh` commands.
- SSH key vault stores pasted keys as protected local files and metadata.
- Server monitor refresh runs noninteractive SSH commands and only shows monitor cards after a real poll result.
- AI requests use `URLSession` against a configured OpenAI-compatible endpoint or Supabase proxy. Without configuration, live sending is disabled.
- Git actions are real terminal commands queued in detected repositories. They are not a native embedded Git engine, and queued Git commands now preflight `git` availability before running.
- Workspace status is surfaced globally so failed preconditions and queued work are visible.
- Bundled Prideland examples remain available and now include practical runnable local workflows instead of only toy demos.

## Previously Fake Or Misleading Areas Fixed

- Hard-coded white-on-light workspace text was replaced with semantic foreground colors so the SwiftUI shell is readable across light, dark, and glass-style backgrounds.
- Prototype labels such as preview build/free preview and broad ready-state language were removed from the in-app workspace copy.
- Removed seeded fake SSH hosts, seeded demo monitors, and generic seeded command snippets. Blank SSH profiles and invalid monitor records are rejected before persistence.
- Home recent activity no longer shows saved SSH profiles until they have actually been used.
- Monitor snapshots are no longer created just because a monitor was configured.
- Empty Home, Git, Server, Vault, Monitor, and AI states now state what real setup is required.
- The AI panel no longer says it is ready before a real provider/proxy is configured.
- The add-monitor button now opens SSH profile setup when no profile exists instead of silently doing nothing.
- The Scripts panel remains available because it works; bundled examples were expanded with practical runnable workflows instead of being removed.

## Still Terminal-Driven, Not Native

- Git clone/status/diff/log/pull/commit/push run through terminal Git. This requires `git` to exist in the active local/remote shell environment.
- Remote dev-stack setup runs package-manager commands over SSH. It does not install local iOS app binaries.
- SSH password auth is interactive and cannot be polled for monitor snapshots without manual terminal interaction.

## Still Old Or Legacy

- The scripts and Cub documentation surfaces are still UIKit/storyboard-era features. They work and examples remain available, but the UI still needs a SwiftUI replacement.

## Still Not Implemented

- Native embedded Git engine with structured status/diff/conflict APIs.
- Full language server protocol runtime, completions, diagnostics, and refactors.
- Production hosted AI proxy deployment secrets, remote policy hardening, and hosted auth tests.
- Real multi-device encrypted vault sync validation against deployed Supabase RLS. The app now blocks push/pull UI until required backend settings are present, but deployed RLS still needs validation.
- Embedded local Python/Node/Vim/Nano/Tmux/Htop toolchains.

## Next Anti-Fake Work

- Replace terminal-driven Git UI with capability checks that verify `git` exists before showing action buttons as ready.
- Add real file rename/move, binary preview metadata, and folder export zip support.
- Add monitor setup validation for SSH auth type and required remote tools.
- Add explicit local-vs-remote labels everywhere a command depends on the active terminal environment.
- Continue replacing terminal-wrapper UI with native capability checks before showing actions as ready.
- Add form-level validation messages that prevent sheets from closing when required fields are missing.
