create table if not exists public.remote_config (
    key text primary key,
    value jsonb not null default '{}'::jsonb,
    is_enabled boolean not null default true,
    min_app_version text,
    notes text,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

alter table public.remote_config enable row level security;

drop policy if exists "remote_config_read_enabled" on public.remote_config;
create policy "remote_config_read_enabled" on public.remote_config
    for select using (is_enabled = true);

drop trigger if exists remote_config_touch_updated_at on public.remote_config;
create trigger remote_config_touch_updated_at
before update on public.remote_config
for each row execute function public.touch_updated_at();

insert into public.remote_config (key, value, notes) values
    ('ai_proxy', '{"enabled": true, "function": "ai-proxy", "default_model": "gpt-4.1-mini", "rate_limit_feature": "assistant"}'::jsonb, 'Hosted AI proxy routing defaults'),
    ('vault_sync', '{"enabled": true, "conflict_policy": "newer_wins", "background_refresh_seconds": 900}'::jsonb, 'Encrypted vault sync client policy'),
    ('remote_tools', '{"enabled": true, "tools": ["git", "python3", "pip3", "node", "npm", "htop", "nano", "vim", "tmux", "docker"]}'::jsonb, 'Remote SSH tool audit list')
on conflict (key) do update set
    value = excluded.value,
    notes = excluded.notes,
    updated_at = timezone('utc', now());
