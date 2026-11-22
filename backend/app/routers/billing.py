"""Pricing & Upgrade page's backend. The payment gateway itself is an open
question (see docs/BUILD_PLAN.md Open Questions) — this router implements
the shape of the flow (TS from the Command Center's Pricing workflow) with
the actual gateway call stubbed, so swapping in Razorpay/Stripe later is a
localized change to `_create_checkout_session` / `_verify_webhook_signature`
only.
"""

from fastapi import APIRouter, Depends, HTTPException, Request, status

from ..config import get_settings
from ..db import service_client
from ..deps import CurrentUser, get_current_user
from ..schemas import SubscribeRequest

router = APIRouter(prefix="/billing", tags=["billing"])


def _create_checkout_session(user: CurrentUser, payload: SubscribeRequest) -> str:
    settings = get_settings()
    if not settings.payment_gateway_provider:
        raise HTTPException(
            status_code=status.HTTP_501_NOT_IMPLEMENTED,
            detail="No payment gateway configured yet — set PAYMENT_GATEWAY_PROVIDER once chosen (see Open Questions).",
        )
    # TODO: call the real gateway SDK here once PAYMENT_GATEWAY_PROVIDER is decided.
    return f"https://checkout.example/{settings.payment_gateway_provider}/session-placeholder"


@router.post("/subscribe")
def subscribe(payload: SubscribeRequest, user: CurrentUser = Depends(get_current_user)):
    checkout_url = _create_checkout_session(user, payload)
    return {"checkout_url": checkout_url}


@router.post("/webhook", status_code=status.HTTP_204_NO_CONTENT)
async def webhook(request: Request):
    # TODO: verify the gateway's signature header before trusting this body.
    body = await request.json()
    user_id = body.get("user_id")
    if not user_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Missing user_id")
    service_client().table("profiles").update({"plan": "pro"}).eq("id", user_id).execute()


@router.post("/cancel")
def cancel(user: CurrentUser = Depends(get_current_user)):
    # Scheduling a downgrade "at period end" needs the gateway's own
    # subscription-cancel API; until the provider is chosen this just
    # records the request for the admin team to action manually.
    service_client().table("audit_events").insert(
        {"actor_id": user.id, "action": "billing.cancel_requested", "entity_type": "profile", "entity_id": user.id}
    ).execute()
    return {"status": "cancellation_requested"}
