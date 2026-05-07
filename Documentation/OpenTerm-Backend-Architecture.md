# OpenTerm Backend Architecture

## Verified Direction

For this app shape, Supabase is the better first backend than Firebase:

- PostgreSQL gives cleaner subscription, audit, and server-monitoring data models.
- Row Level Security is a better fit for per-user workspace records.
- SQL migrations make pricing, entitlement, and audit changes easier to review.
- Edge Functions are a reasonable place to verify Stripe webhooks and mint remote feature flags.

## Billing Model

Use a hybrid billing architecture:

- App Store builds: StoreKit 2 for digital entitlements inside the iOS app.
- Web companion or unsigned enterprise-style builds: Stripe Checkout for account billing.
- Backend source of truth: normalized entitlement records in Supabase.

Do not make the iOS app depend on direct Stripe-only digital unlock logic for App Store distribution.

## Security Boundaries

- Supabase Auth stores the user identity.
- Subscription state is server-authoritative.
- Stripe webhooks are verified server-side before entitlements change.
- Sensitive SSH material stays local unless end-to-end encrypted first.
- Uploaded vault records should only store metadata and encrypted references, not raw private keys.
- AI usage metering is append-only and auditable.

## Required Server Checks

Every premium endpoint should verify:

1. authenticated user id
2. device registration status
3. active subscription or feature entitlement
4. rate-limit window
5. request audit trail

## Suggested Edge Functions

- `create-checkout-session`
- `stripe-webhook`
- `resolve-entitlements`
- `record-ai-usage`
- `issue-device-token`
- `store-vault-reference`
- `send-monitor-alert`

## Remote Config

Premium and rollout flags should be remote-configurable:

- AI request limits
- enabled model providers
- premium theme packs
- GitHub assistant availability
- monitoring alert thresholds
- staged feature rollouts

## Backup And Export

- nightly Postgres backups
- encrypted user export for snippets and SSH metadata
- periodic audit log export to cold storage
- webhook replay support for subscription recovery
