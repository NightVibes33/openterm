create or replace function public.upsert_vault_sync_item(
    p_id uuid,
    p_user_id uuid,
    p_device_id uuid default null,
    p_item_kind text default 'ssh_private_key',
    p_label text default 'Vault item',
    p_public_fingerprint text default null,
    p_encrypted_payload_base64 text default '',
    p_payload_nonce text default '',
    p_key_version integer default 1,
    p_sync_version bigint default 1,
    p_is_deleted boolean default false,
    p_last_used_at timestamptz default null
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
begin
    if auth.uid() is null or auth.uid() <> p_user_id then
        raise exception 'vault sync user mismatch';
    end if;

    insert into public.vault_sync_items (
        id, user_id, device_id, item_kind, label, public_fingerprint, encrypted_payload,
        payload_nonce, key_version, sync_version, is_deleted, last_used_at
    ) values (
        p_id,
        p_user_id,
        case
            when p_device_id is not null and exists (select 1 from public.devices d where d.id = p_device_id and d.user_id = auth.uid()) then p_device_id
            else null
        end,
        p_item_kind,
        p_label,
        p_public_fingerprint,
        decode(p_encrypted_payload_base64, 'base64'),
        p_payload_nonce,
        p_key_version,
        p_sync_version,
        p_is_deleted,
        p_last_used_at
    )
    on conflict (id) do update set
        device_id = excluded.device_id,
        item_kind = excluded.item_kind,
        label = excluded.label,
        public_fingerprint = excluded.public_fingerprint,
        encrypted_payload = excluded.encrypted_payload,
        payload_nonce = excluded.payload_nonce,
        key_version = excluded.key_version,
        sync_version = greatest(public.vault_sync_items.sync_version, excluded.sync_version),
        is_deleted = excluded.is_deleted,
        last_used_at = excluded.last_used_at,
        updated_at = timezone('utc', now())
    where public.vault_sync_items.user_id = auth.uid();

    return p_id;
end;
$$;

create or replace function public.list_vault_sync_items()
returns table (
    id uuid,
    item_kind text,
    label text,
    public_fingerprint text,
    encrypted_payload_base64 text,
    payload_nonce text,
    key_version integer,
    sync_version bigint,
    last_used_at timestamptz,
    created_at timestamptz,
    updated_at timestamptz
)
language sql
security invoker
set search_path = public
as $$
    select
        v.id,
        v.item_kind,
        v.label,
        v.public_fingerprint,
        encode(v.encrypted_payload, 'base64') as encrypted_payload_base64,
        v.payload_nonce,
        v.key_version,
        v.sync_version,
        v.last_used_at,
        v.created_at,
        v.updated_at
    from public.vault_sync_items v
    where v.user_id = auth.uid()
      and v.is_deleted = false
    order by v.updated_at desc;
$$;
