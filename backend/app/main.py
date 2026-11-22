from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import get_settings
from .routers import admin, auth, billing, public

settings = get_settings()

app = FastAPI(
    title="DHARA Template Studio API",
    version="0.1.0",
    description="Backend for DHARA Template Studio — see /docs for the live OpenAPI explorer.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(public.router)
app.include_router(admin.router)
app.include_router(billing.router)


@app.get("/health")
def health():
    return {"status": "ok"}
