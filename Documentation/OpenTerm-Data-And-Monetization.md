# OpenTerm Data And Monetization

## Verified Current Persistence

The current app does not have a structured application database.

Current storage is split across:

- `UserDefaults`
  - terminal colors
  - font size
  - caret style
  - keyboard preference
  - store review prompt timing
- document files in the app sandbox
  - command history via `.history`
  - bookmarks in `.bookmarks`
  - scripts and script packages in the active documents folder
- iCloud documents
  - script syncing through `DocumentManager`

This is workable for a simple terminal app, but it is not enough for:

- SSH vaults
- multi-session restoration
- AI history
- premium entitlements
- server monitoring snapshots
- cloud sync conflict resolution
- team/shared workspace metadata

## Recommended Database

Use SwiftData as the primary app database for iOS 18+.

Recommended model groups:

- `WorkspaceProfile`
  - workspace name
  - last opened section
  - active theme
  - pinned sessions
- `TerminalSessionRecord`
  - session id
  - local vs remote kind
  - host metadata
  - cwd
  - last command summary
  - restoration state
- `SSHProfile`
  - display name
  - host
  - port
  - username
  - auth type
  - key reference
  - last successful connection
- `GitWorkspaceRecord`
  - repo path
  - branch
  - last fetch time
  - dirty state snapshot
- `ServerSnapshot`
  - cpu
  - memory
  - disk
  - uptime
  - latency
  - alert state
- `AIConversationRecord`
  - feature kind
  - prompt
  - response summary
  - token usage
  - created at
- `PremiumEntitlementRecord`
  - product id
  - source
  - active state
  - renewal / expiration metadata

## Security-Sensitive Data

Do not store private keys, tokens, or raw secrets directly in SwiftData.

Use:

- Keychain for API keys and tokens
- Secure Enclave-backed flows where practical
- encrypted export/import for SSH vault backup

## Monetization Recommendation

For App Store-distributed digital unlocks, premium features should use StoreKit 2.

Best premium candidates:

- unlimited AI requests
- advanced AI coding tools
- SSH vault
- encrypted cloud sync
- team/server sync
- premium widgets
- server monitoring alerts
- premium themes and workspace customization packs

## Suggested Tiers

### Free

- local terminal
- basic tabs
- basic SSH
- basic file browsing
- limited AI credits

### Pro

- unlimited local sessions
- advanced themes
- AI assistant bundle
- git tools
- file manager power features
- session restore

### Infra

- SSH vault
- server dashboards
- monitoring history
- alert rules
- premium widgets

### Team

- shared server profiles
- shared snippets
- shared AI prompt templates
- audit trail / activity feed

## Payment Architecture

### In-App

Use StoreKit 2 for:

- subscriptions
- feature unlocks
- premium theme packs
- AI request tiers

### Optional Web Billing

If there is a companion web service later, that service can manage:

- team billing
- hosted AI credits
- shared cloud infrastructure

But app-side digital unlocks should still be modeled around App Store-compliant flows for the iOS app.

## Migration Plan

### Stage 1

- keep existing file-based command history and scripts
- add SwiftData for new workspace/session/server/AI entities

### Stage 2

- mirror legacy settings into modern settings records
- add import/migration helpers

### Stage 3

- unify sync around SwiftData-backed domain models plus file attachments

## Decision Summary

The current app has no true database to preserve.

That is a good thing for this redesign:

- there is very little legacy database migration risk
- the team can adopt SwiftData cleanly
- security boundaries can be designed correctly from the start
