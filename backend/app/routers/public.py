"""The citizen-facing API. Every read here is published-only by construction:
these routes use the **anon/user-scoped client**, so the RLS policies in
supabase/schema.sql (`templates_select_published`, `drafts_owner_select`, …)
are the actual enforcement — this file does not re-implement that gate,
exactly as ADR-001 intends. This satisfies TS-07 and TS-09.
"""

from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, Response, status

from ..db import anon_client, service_client
from ..deps import CurrentUser, get_current_user, get_current_user_optional, user_scoped_client
from ..rendering import render_body, render_docx, render_pdf
from ..schemas import AccountUpdate, AdvocateVerificationRequest, DraftCreate, DraftUpdate

router = APIRouter(tags=["public"])


# --------------------------------------------------------------- templates -
@router.get("/templates")
def list_templates(
    category: Optional[str] = None,
    tier: Optional[str] = None,
    search: Optional[str] = None,
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    user: Optional[CurrentUser] = Depends(get_current_user_optional),
):
    client = user_scoped_client(user) if user else anon_client()
    query = client.table("templates").select("*")
    if category:
        query = query.eq("category", category)
    if tier:
        query = query.eq("tier", tier)
    if search:
        query = query.ilike("title", f"%{search}%")
    start = (page - 1) * page_size
    result = query.range(start, start + page_size - 1).execute()
    return {"items": result.data, "page": page, "page_size": page_size}


@router.get("/templates/{template_id}")
def get_template(template_id: str, user: Optional[CurrentUser] = Depends(get_current_user_optional)):
    client = user_scoped_client(user) if user else anon_client()
    result = client.table("templates").select("*").eq("id", template_id).single().execute()
    if not result.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Template not found")
    return result.data


# ------------------------------------------------------------------ drafts -
def _check_access(client, template: dict, user: CurrentUser):
    """Mirrors the frontend's tier/mode gate server-side — "Access check...
    mirrors the frontend gate so it can't be bypassed via the API" per the
    Template Detail page's build notes."""
    if template["mode"] == "advocate_only" and user.role not in ("verified_advocate", "admin"):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="This template is advocate-only")
    if template["tier"] == "pro" and user.plan != "pro" and user.role != "admin":
        raise HTTPException(status_code=status.HTTP_402_PAYMENT_REQUIRED, detail="This template requires a Pro plan")


@router.post("/drafts", status_code=status.HTTP_201_CREATED)
def create_draft(payload: DraftCreate, user: CurrentUser = Depends(get_current_user)):
    client = user_scoped_client(user)
    template = client.table("templates").select("*").eq("id", payload.template_id).single().execute().data
    if not template:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Template not found")
    _check_access(client, template, user)
    if not template.get("current_published_version_id"):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="This template has no published version yet")

    draft = (
        client.table("drafts")
        .insert(
            {
                "user_id": user.id,
                "template_id": template["id"],
                "template_version_id": template["current_published_version_id"],
                "locale": payload.locale,
                "fields": {},
            }
        )
        .execute()
    )
    return draft.data[0]


@router.get("/drafts")
def list_my_drafts(user: CurrentUser = Depends(get_current_user)):
    client = user_scoped_client(user)
    result = client.table("drafts").select("*").eq("user_id", user.id).order("updated_at", desc=True).execute()
    return {"items": result.data}


@router.get("/drafts/{draft_id}")
def get_draft(draft_id: str, user: CurrentUser = Depends(get_current_user)):
    client = user_scoped_client(user)
    result = client.table("drafts").select("*").eq("id", draft_id).single().execute()
    if not result.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Draft not found")
    return result.data


@router.patch("/drafts/{draft_id}")
def update_draft(draft_id: str, payload: DraftUpdate, user: CurrentUser = Depends(get_current_user)):
    client = user_scoped_client(user)
    result = client.table("drafts").update({"fields": payload.fields}).eq("id", draft_id).execute()
    if not result.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Draft not found")
    return result.data[0]


@router.delete("/drafts/{draft_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_draft(draft_id: str, user: CurrentUser = Depends(get_current_user)):
    client = user_scoped_client(user)
    client.table("drafts").delete().eq("id", draft_id).execute()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/drafts/{draft_id}/duplicate", status_code=status.HTTP_201_CREATED)
def duplicate_draft(draft_id: str, user: CurrentUser = Depends(get_current_user)):
    client = user_scoped_client(user)
    original = client.table("drafts").select("*").eq("id", draft_id).single().execute().data
    if not original:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Draft not found")
    copy = client.table("drafts").insert(
        {
            "user_id": user.id,
            "template_id": original["template_id"],
            "template_version_id": original["template_version_id"],
            "locale": original["locale"],
            "fields": original["fields"],
        }
    ).execute()
    return copy.data[0]


@router.get("/drafts/{draft_id}/export")
def export_draft(draft_id: str, format: str = Query("pdf", pattern="^(pdf|docx)$"), user: CurrentUser = Depends(get_current_user)):
    client = user_scoped_client(user)
    draft = client.table("drafts").select("*").eq("id", draft_id).single().execute().data
    if not draft:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Draft not found")

    version = client.table("template_versions").select("*").eq("id", draft["template_version_id"]).single().execute().data
    template = client.table("templates").select("title").eq("id", draft["template_id"]).single().execute().data
    body = render_body(version["content"], draft["fields"])

    if format == "docx":
        data = render_docx(template["title"], body)
        media_type = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        filename = f"{draft_id}.docx"
    else:
        data = render_pdf(template["title"], body)
        media_type = "application/pdf"
        filename = f"{draft_id}.pdf"

    return Response(
        content=data,
        media_type=media_type,
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


# ------------------------------------------------------------------ account -
@router.get("/account")
def get_account(user: CurrentUser = Depends(get_current_user)):
    client = user_scoped_client(user)
    result = client.table("profiles").select("*").eq("id", user.id).single().execute()
    return result.data


@router.patch("/account")
def update_account(payload: AccountUpdate, user: CurrentUser = Depends(get_current_user)):
    client = user_scoped_client(user)
    updates = {k: v for k, v in payload.model_dump().items() if v is not None}
    result = client.table("profiles").update(updates).eq("id", user.id).execute()
    return result.data[0]


@router.post("/account/advocate-verification", status_code=status.HTTP_202_ACCEPTED)
def request_advocate_verification(payload: AdvocateVerificationRequest, user: CurrentUser = Depends(get_current_user)):
    # Writes via the service client: an ordinary user can read/update their
    # own profile per RLS, but flipping advocate_verification to "pending"
    # plus recording document refs is a privileged transition we want
    # audited — never auto-approved, per the My Drafts page's build notes.
    client = service_client()
    client.table("profiles").update(
        {
            "advocate_bar_id": payload.bar_id,
            "advocate_documents": payload.document_refs,
            "advocate_verification": "pending",
        }
    ).eq("id", user.id).execute()
    client.table("audit_events").insert(
        {
            "actor_id": user.id,
            "action": "advocate_verification.request",
            "entity_type": "profile",
            "entity_id": user.id,
            "metadata": {"bar_id": payload.bar_id},
        }
    ).execute()
    return {"status": "pending"}
