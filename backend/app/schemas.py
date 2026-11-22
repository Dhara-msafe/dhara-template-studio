from datetime import datetime
from typing import Any, Literal, Optional

from pydantic import BaseModel, EmailStr, Field

Locale = Literal["en", "hi", "mr"]
Tier = Literal["free", "pro"]
Mode = Literal["guided_self_serve", "advocate_reviewed", "advocate_only"]
LifecycleStatus = Literal[
    "draft", "in_legal_review", "in_language_review", "approved",
    "published", "needs_re_review", "deprecated",
]
ReviewStage = Literal["legal", "language"]
ReviewDecision = Literal["approved", "rejected"]


# ---------------------------------------------------------------- auth -----
class SignupRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)
    display_name: Optional[str] = None


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class PasswordResetRequest(BaseModel):
    email: EmailStr


class PasswordResetConfirm(BaseModel):
    access_token: str
    new_password: str = Field(min_length=8)


# ------------------------------------------------------------- templates ---
class TemplateCreate(BaseModel):
    slug: str
    title: str
    category: str
    legal_basis: Optional[str] = None
    tier: Tier = "free"
    mode: Mode = "guided_self_serve"
    field_schema: list[dict[str, Any]] = []


class TemplateOut(BaseModel):
    id: str
    slug: str
    title: str
    category: str
    legal_basis: Optional[str]
    tier: Tier
    mode: Mode
    status: LifecycleStatus
    field_schema: list[dict[str, Any]]
    created_at: datetime


class TemplateVersionCreate(BaseModel):
    content: dict[str, Any]


class TemplateVersionOut(BaseModel):
    id: str
    template_id: str
    version_number: int
    content: dict[str, Any]
    status: LifecycleStatus
    created_at: datetime


class TemplateVariantCreate(BaseModel):
    locale: Locale
    rendered_content: dict[str, Any]


class ReviewCreate(BaseModel):
    stage: ReviewStage
    locale: Optional[Locale] = None
    decision: ReviewDecision
    comment: Optional[str] = None


# ----------------------------------------------------------------- drafts --
class DraftCreate(BaseModel):
    template_id: str
    locale: Locale = "en"


class DraftUpdate(BaseModel):
    fields: dict[str, Any]


class DraftOut(BaseModel):
    id: str
    template_id: str
    template_version_id: str
    locale: Locale
    fields: dict[str, Any]
    updated_at: datetime


# ---------------------------------------------------------------- account --
class AccountUpdate(BaseModel):
    display_name: Optional[str] = None


class AdvocateVerificationRequest(BaseModel):
    bar_id: str
    document_refs: list[str] = []


# ---------------------------------------------------------------- billing --
class SubscribeRequest(BaseModel):
    plan: Tier = "pro"
    billing_cycle: Literal["monthly", "annual"] = "monthly"
