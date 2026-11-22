"""Auth dependencies: decode the Supabase-issued JWT, load the caller's
profile (role, plan, advocate-verification status), and gate endpoints by
role. This is where the "mirrors the frontend gate so it can't be bypassed
via the API" rule from the Template Detail page's build notes is enforced.
"""

from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt

from .config import get_settings
from .db import anon_client, service_client

bearer_scheme = HTTPBearer(auto_error=False)


class CurrentUser:
    def __init__(self, id: str, role: str, plan: str, jwt_token: str):
        self.id = id
        self.role = role
        self.plan = plan
        self.jwt_token = jwt_token


def _decode_token(token: str) -> dict:
    settings = get_settings()
    try:
        return jwt.decode(
            token,
            settings.supabase_jwt_secret,
            algorithms=["HS256"],
            audience="authenticated",
        )
    except JWTError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired token") from exc


async def get_current_user_optional(
    creds: Optional[HTTPAuthorizationCredentials] = Depends(bearer_scheme),
) -> Optional[CurrentUser]:
    """Guests hit this too — returns None rather than raising, so public,
    published-only endpoints (GET /templates, GET /templates/{id}) work for
    unauthenticated visitors exactly as the Browse page's build notes
    describe ("Guest browsing cuts drop-off")."""
    if creds is None:
        return None
    payload = _decode_token(creds.credentials)
    user_id = payload["sub"]

    profile = (
        service_client()
        .table("profiles")
        .select("id, role, plan")
        .eq("id", user_id)
        .single()
        .execute()
    )
    row = profile.data
    if not row:
        return None
    return CurrentUser(id=row["id"], role=row["role"], plan=row["plan"], jwt_token=creds.credentials)


async def get_current_user(
    user: Optional[CurrentUser] = Depends(get_current_user_optional),
) -> CurrentUser:
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Authentication required")
    return user


def require_role(*allowed_roles: str):
    """Dependency factory: `Depends(require_role("admin", "reviewer_legal"))`.
    Used by every Admin API route — see routers/admin.py."""

    async def checker(user: CurrentUser = Depends(get_current_user)) -> CurrentUser:
        if user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Role '{user.role}' is not permitted to do this",
            )
        return user

    return checker


def user_scoped_client(user: CurrentUser):
    """A Supabase client carrying the caller's own JWT, so every query obeys
    RLS (drafts_owner_select etc.) instead of the service role's full access."""
    return anon_client(user.jwt_token)
