create table if not exists public.ai_rate_limits (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    feature_code text not null,
    window_start timestamptz not null,
    window_end timestamptz not null,
    request_count integer not null default 0 check (request_count >= 0),
    token_count integer not null default 0 check (token_count >= 0),
    limit_count integer not null default 50 check (limit_count > 0),
    limit_tokens integer not null default 100000 check (limit_tokens > 0),
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now()),
    unique (user_id, feature_code, window_start)
);

create table if not exists public.vault_sync_items (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    device_id uuid references public.devices(id) on delete set null,
    item_kind text not null check (item_kind in ('ssh_private_key', 'ssh_public_key', 'ssh_profile_secret', 'snippet_secret')),
    label text not null,
    public_fingerprint text,
    encrypted_payload bytea not null,
    payload_nonce text not null,
    key_version integer not null default 1 check (key_version > 0),
    sync_version bigint not null default 1 check (sync_version > 0),
    is_deleted boolean not null default false,
    last_used_at timestamptz,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.server_monitor_alerts (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    monitor_id uuid not null references public.server_monitors(id) on delete cascade,
    level text not null check (level in ('watch', 'alert', 'critical', 'resolved')),
    title text not null,
    detail text not null,
    snapshot jsonb not null default '{}'::jsonb,
    delivered_at timestamptz,
    acknowledged_at timestamptz,
    created_at timestamptz not null default timezone('utc', now())
);

create index if not exists ai_rate_limits_user_window_idx on public.ai_rate_limits (user_id, feature_code, window_start desc);
create index if not exists vault_sync_items_user_updated_idx on public.vault_sync_items (user_id, updated_at desc);
create index if not exists vault_sync_items_user_kind_idx on public.vault_sync_items (user_id, item_kind, is_deleted);
create index if not exists server_monitor_alerts_user_created_idx on public.server_monitor_alerts (user_id, created_at desc);
create index if not exists server_monitor_alerts_monitor_created_idx on public.server_monitor_alerts (monitor_id, created_at desc);

alter table public.ai_rate_limits enable row level security;
alter table public.vault_sync_items enable row level security;
alter table public.server_monitor_alerts enable row level security;

drop policy if exists "ai_rate_limits_select_own" on public.ai_rate_limits;
create policy "ai_rate_limits_select_own" on public.ai_rate_limits
    for select using (auth.uid() = user_id);

drop policy if exists "vault_sync_items_manage_own" on public.vault_sync_items;
create policy "vault_sync_items_manage_own" on public.vault_sync_items
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "server_monitor_alerts_select_own" on public.server_monitor_alerts;
create policy "server_monitor_alerts_select_own" on public.server_monitor_alerts
    for select using (auth.uid() = user_id);

create or replace function public.can_consume_ai_request(
    p_user_id uuid,
    p_feature_code text,
    p_estimated_tokens integer default 0
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
    current_window_start timestamptz := date_trunc('day', timezone('utc', now()));
    current_window_end timestamptz := date_trunc('day', timezone('utc', now())) + interval '1 day';
    current_row public.ai_rate_limits%rowtype;
begin
    if auth.uid() is null or auth.uid() <> p_user_id then
        raise exception 'not allowed';
    end if;

    insert into public.ai_rate_limits (user_id, feature_code, window_start, window_end)
    values (p_user_id, p_feature_code, current_window_start, current_window_end)
    on conflict (user_id, feature_code, window_start) do nothing;

    select * into current_row
    from public.ai_rate_limits
    where user_id = p_user_id
      and feature_code = p_feature_code
      and window_start = current_window_start
    for update;

    return current_row.request_count < current_row.limit_count
       and current_row.token_count + greatest(p_estimated_tokens, 0) <= current_row.limit_tokens;
end;
$$;

create or replace function public.record_ai_usage_limited(
    p_user_id uuid,
    p_device_id uuid,
    p_feature_code text,
    p_provider text,
    p_model text,
    p_prompt_tokens integer,
    p_completion_tokens integer
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    current_window_start timestamptz := date_trunc('day', timezone('utc', now()));
    current_window_end timestamptz := date_trunc('day', timezone('utc', now())) + interval '1 day';
    total_tokens integer := greatest(p_prompt_tokens, 0) + greatest(p_completion_tokens, 0);
begin
    if auth.uid() is null or auth.uid() <> p_user_id then
        raise exception 'not allowed';
    end if;

    insert into public.ai_rate_limits (user_id, feature_code, window_start, window_end, request_count, token_count)
    values (p_user_id, p_feature_code, current_window_start, current_window_end, 1, total_tokens)
    on conflict (user_id, feature_code, window_start)
    do update set
        request_count = public.ai_rate_limits.request_count + 1,
        token_count = public.ai_rate_limits.token_count + excluded.token_count,
        updated_at = timezone('utc', now());

    insert into public.ai_usage (user_id, device_id, feature_code, prompt_tokens, completion_tokens, provider, model)
    values (p_user_id, p_device_id, p_feature_code, greatest(p_prompt_tokens, 0), greatest(p_completion_tokens, 0), p_provider, p_model);
end;
$$;

drop trigger if exists ai_rate_limits_touch_updated_at on public.ai_rate_limits;
create trigger ai_rate_limits_touch_updated_at
before update on public.ai_rate_limits
for each row execute function public.touch_updated_at();

drop trigger if exists vault_sync_items_touch_updated_at on public.vault_sync_items;
create trigger vault_sync_items_touch_updated_at
before update on public.vault_sync_items
for each row execute function public.touch_updated_at();
