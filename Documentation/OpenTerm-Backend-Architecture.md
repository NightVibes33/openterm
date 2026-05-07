# OpenTerm Backend Architecture

## Active Product Decision

The backend is not production-live yet. Supabase migrations and the AI proxy function are scaffolding for future hosted behavior. The app must work honestly without a backend unless the user configures one.

## Current Backend Pieces In Repo

- `supabase/migrations/20260506_workspace_foundation.sql`
- `supabase/migrations/20260507_ai_vault_limits.sql`
- `supabase/migrations/20260507_vault_sync_rpc.sql`
- `supabase/migrations/20260507_remote_config.sql`
- `supabase/functions/ai-proxy/index.ts`

## Config Required Before Backend Features Work

The app requires these user-provided values before hosted features can work:

- Supabase project URL
- Supabase anon key
- Supabase user access token
- authenticated user id
- optional device id/device label
- vault sync secret for local AES-GCM encryption
- AI provider secret if direct provider routing is used

The UI should not present hosted AI or vault sync as ready until these exist.

## Real Hosted Capabilities Intended

- AI proxy request forwarding with usage records and rate-limit checks.
- Encrypted vault item push/pull through RPC helpers.
- Remote config fetch for feature policy.
- Monitor alert records after real monitor delivery exists.

## Not Production Validated Yet

- Supabase project deployment.
- RLS policies against real authenticated users.
- Edge Function secrets and auth hardening.
- Rate-limit bypass resistance.
- Multi-device vault conflict behavior under real network races.
- Alert delivery channels.

## Security Rules

- Never upload plaintext private keys.
- Never trust device-submitted subscription or entitlement state.
- Treat access tokens as secrets. The app now stores AI/backend/vault secrets through Keychain-backed local storage, but production should still validate migration, backup, and device-restore behavior.
- Verify webhook signatures if payments are ever reintroduced.
- Keep audit logs append-only for hosted actions.

## Deferred Billing

Billing is not active. Previous Stripe/StoreKit planning is archived as future consideration only. No current app screen should claim paid entitlements, premium unlocks, or subscription status.
