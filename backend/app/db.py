"""Two Supabase clients, used for very different reasons:

- `anon_client()` — scoped to a single request, with the caller's own JWT
  attached. Every query it runs is subject to the RLS policies in
  supabase/schema.sql. Use this everywhere in the Public API.

- `service_client()` — the service-role key, which bypasses RLS entirely.
  Only the Admin API (backend/app/routers/admin.py) should use this, and
  only after `deps.require_role(...)` has already checked the caller's role.
"""

from functools import lru_cache

from supabase import Client, create_client

from .config import get_settings


@lru_cache
def service_client() -> Client:
    settings = get_settings()
    return create_client(settings.supabase_url, settings.supabase_service_role_key)


def anon_client(user_jwt: str | None = None) -> Client:
    settings = get_settings()
    client = create_client(settings.supabase_url, settings.supabase_anon_key)
    if user_jwt:
        # Forward the caller's own token so Postgres sees auth.uid() and RLS
        # policies apply exactly as they would for a direct frontend call.
        client.postgrest.auth(user_jwt)
    return client
