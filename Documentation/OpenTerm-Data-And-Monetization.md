# OpenTerm Data Notes

## Active Product Decision

OpenTerm is currently a free app while the real terminal, file, SSH, Git, AI, monitor, and sync workflows are stabilized. There is no active payment system, no active StoreKit entitlement layer, and no production subscription verification in the app.

This file used to describe monetization ideas. Those ideas are archived as future notes only and should not be treated as implemented product behavior.

## Verified Current Persistence

Current storage is split across:

- `UserDefaults` for terminal colors, font size, caret style, keyboard preference, status/review timing, and lightweight workspace settings.
- Document files in the active app documents folder for command history, bookmarks, scripts, user files, workspace JSON state, SSH vault metadata, and backups.
- Optional iCloud documents through `DocumentManager` when the configured iCloud container is available.
- Supabase REST/RPC only when the user configures URL, anon key, access token, user id, device id, and vault sync secret.

## Current Local Workspace State

The current fork persists these JSON records under `.openterm-workspace`:

- `ssh-profiles.json`
- `ssh-vault.json`
- `snippets.json`
- `server-monitors.json`
- `server-snapshots.json`
- `server-alerts.json`
- `ai-configuration.json`
- `backend-configuration.json`
- `ai-usage-history.json`

## Security Boundaries

Do not store private keys, provider tokens, Supabase tokens, or raw secrets in plaintext database rows.

Current app behavior:

- Pasted SSH keys are written to protected local files in the app documents workspace.
- Vault sync encrypts private-key payload bytes with AES-GCM before upload.
- Supabase receives metadata, fingerprints, nonce, and ciphertext for vault sync.
- AI provider keys and backend tokens are currently local app settings and still need Keychain migration before production use.

## Recommended Data Roadmap

1. Keep the current JSON files until the core product stabilizes.
2. Move secrets and provider tokens into Keychain.
3. Add SwiftData only after the object model stops changing every build.
4. Add migration code from JSON state into SwiftData.
5. Validate Supabase RLS and Edge Function auth against a real deployed project.
6. Add encrypted export/import recovery for SSH vault and workspace metadata.

## Deferred Monetization Notes

Payments are intentionally deferred. If monetization returns later, it must be designed after the core is real.

Potential future paid capabilities:

- Hosted AI usage beyond a free local/configured provider mode.
- Cloud sync after vault, snippets, and profiles are proven reliable.
- Monitoring alert delivery after live monitors are dependable.
- Team/shared workspaces after single-user flows are solid.

App Store builds should use App Store-compliant purchase mechanisms for digital features. Web checkout or donations should not be used to bypass App Store rules inside an App Store build.
