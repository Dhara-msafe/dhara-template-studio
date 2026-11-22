"""POST /auth/* — thin proxies over Supabase's own GoTrue auth, kept as our
own endpoints (rather than having the frontend call supabase-js directly)
so the documented API surface (POST /auth/signup, POST /auth/login, etc.
from the Login & Signup page's build notes) stays stable even if we ever
swap auth providers.
"""

from fastapi import APIRouter, HTTPException, status

from ..db import anon_client
from ..schemas import LoginRequest, PasswordResetConfirm, PasswordResetRequest, SignupRequest

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/signup", status_code=status.HTTP_201_CREATED)
def signup(payload: SignupRequest):
    client = anon_client()
    try:
        result = client.auth.sign_up(
            {
                "email": payload.email,
                "password": payload.password,
                "options": {"data": {"display_name": payload.display_name}},
            }
        )
    except Exception as exc:  # supabase-py raises its own AuthApiError
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc

    # role defaults to citizen_free via the profiles table default + the
    # handle_new_user() trigger in supabase/schema.sql — nothing else to do.
    return {"user_id": result.user.id if result.user else None, "email": payload.email}


@router.post("/login")
def login(payload: LoginRequest):
    client = anon_client()
    try:
        result = client.auth.sign_in_with_password({"email": payload.email, "password": payload.password})
    except Exception as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid email or password") from exc

    return {
        "access_token": result.session.access_token,
        "refresh_token": result.session.refresh_token,
        "expires_at": result.session.expires_at,
    }


@router.post("/password-reset/request", status_code=status.HTTP_202_ACCEPTED)
def request_password_reset(payload: PasswordResetRequest):
    client = anon_client()
    client.auth.reset_password_for_email(payload.email)
    return {"message": "If that email exists, a reset link has been sent."}


@router.patch("/password-reset/confirm")
def confirm_password_reset(payload: PasswordResetConfirm):
    client = anon_client(payload.access_token)
    try:
        client.auth.update_user({"password": payload.new_password})
    except Exception as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc
    return {"message": "Password updated."}
