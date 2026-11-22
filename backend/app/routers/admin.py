"""The reviewer/admin-facing API — the legal-safety backbone of the whole
product per the Admin & Review Dashboard page's build notes: "Nothing
reaches a citizen without legal and (per language) language review."

Every route here uses the **service-role client**, which bypasses RLS —
that's deliberate (see the NOTE at the bottom of supabase/schema.sql) and is
exactly why every route is also gated by `require_role(...)` first. Never
add a route to this router without a role dependency.
"""

from fastapi import APIRouter, Depends, HTTPException, Query, status

from ..db import service_client
from ..deps import CurrentUser, require_role
from ..schemas import ReviewCreate, TemplateCreate, TemplateVariantCreate, TemplateVersionCreate

router = APIRouter(prefix="/admin", tags=["admin"])

REVIEWER_OR_ADMIN = require_role("reviewer_legal", "reviewer_language", "admin")
ADMIN_ONLY = require_role("admin")


def _log(actor_id: str, action: str, entity_type: str, entity_id: str, metadata: dict | None = None):
    service_client().table("audit_events").insert(
        {"actor_id": actor_id, "action": action, "entity_type": entity_type, "entity_id": entity_id, "metadata": metadata or {}}
    ).execute()


@router.get("/templates")
def list_templates_admin(status_filter: str | None = Query(None, alias="status"), user: CurrentUser = Depends(REVIEWER_OR_ADMIN)):
    client = service_client()
    query = client.table("templates").select("*")
    if status_filter:
        query = query.eq("status", status_filter)
    result = query.order("created_at", desc=True).execute()
    return {"items": result.data}


@router.post("/templates", status_code=status.HTTP_201_CREATED)
def create_template(payload: TemplateCreate, user: CurrentUser = Depends(ADMIN_ONLY)):
    client = service_client()
    result = client.table("templates").insert(
        {**payload.model_dump(), "created_by": user.id}
    ).execute()
    row = result.data[0]
    _log(user.id, "template.create", "template", row["id"])
    return row


@router.get("/templates/{template_id}/versions")
def list_template_versions(template_id: str, user: CurrentUser = Depends(REVIEWER_OR_ADMIN)):
    client = service_client()
    result = (
        client.table("template_versions")
        .select("*")
        .eq("template_id", template_id)
        .order("version_number", desc=True)
        .execute()
    )
    return {"items": result.data}


@router.post("/templates/{template_id}/version", status_code=status.HTTP_201_CREATED)
def add_template_version(template_id: str, payload: TemplateVersionCreate, user: CurrentUser = Depends(ADMIN_ONLY)):
    client = service_client()
    existing = client.table("template_versions").select("version_number").eq("template_id", template_id).order(
        "version_number", desc=True
    ).limit(1).execute().data
    next_number = (existing[0]["version_number"] + 1) if existing else 1

    result = client.table("template_versions").insert(
        {
            "template_id": template_id,
            "version_number": next_number,
            "content": payload.content,
            "status": "draft",
            "authored_by": user.id,
        }
    ).execute()
    row = result.data[0]
    _log(user.id, "template_version.create", "template_version", row["id"], {"version_number": next_number})
    return row


@router.post("/templates/{template_id}/variant", status_code=status.HTTP_201_CREATED)
def add_template_variant(template_id: str, payload: TemplateVariantCreate, version_id: str, user: CurrentUser = Depends(ADMIN_ONLY)):
    client = service_client()
    result = client.table("template_variants").insert(
        {"version_id": version_id, "locale": payload.locale, "rendered_content": payload.rendered_content, "status": "draft"}
    ).execute()
    row = result.data[0]
    _log(user.id, "template_variant.create", "template_variant", row["id"], {"locale": payload.locale})
    return row


@router.post("/templates/{template_id}/review", status_code=status.HTTP_201_CREATED)
def record_review(template_id: str, payload: ReviewCreate, version_id: str, user: CurrentUser = Depends(REVIEWER_OR_ADMIN)):
    if payload.stage == "legal" and user.role not in ("reviewer_legal", "admin"):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only a legal reviewer can record a legal review")
    if payload.stage == "language" and user.role not in ("reviewer_language", "admin"):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only a language reviewer can record a language review")

    client = service_client()
    review = client.table("reviews").insert(
        {
            "version_id": version_id,
            "stage": payload.stage,
            "locale": payload.locale,
            "reviewer_id": user.id,
            "decision": payload.decision,
            "comment": payload.comment,
        }
    ).execute().data[0]

    # Advance the version's lifecycle status. Simple MVP state machine:
    # draft -> in_legal_review -> in_language_review -> approved -> (publish is separate)
    new_status = None
    if payload.decision == "rejected":
        new_status = "draft"
    elif payload.stage == "legal":
        new_status = "in_language_review"
    elif payload.stage == "language":
        new_status = "approved"

    if new_status:
        client.table("template_versions").update({"status": new_status}).eq("id", version_id).execute()

    _log(user.id, f"review.{payload.decision}", "template_version", version_id, {"stage": payload.stage, "locale": payload.locale})
    return review


@router.post("/templates/{template_id}/publish")
def publish_template(template_id: str, version_id: str, user: CurrentUser = Depends(ADMIN_ONLY)):
    client = service_client()
    version = client.table("template_versions").select("status").eq("id", version_id).single().execute().data
    if not version or version["status"] != "approved":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Version must be fully approved (legal + every language) before it can be published",
        )

    client.table("template_versions").update({"status": "published", "published_at": "now()"}).eq("id", version_id).execute()
    _log(user.id, "template.publish", "template_version", version_id)
    return {"status": "published"}
