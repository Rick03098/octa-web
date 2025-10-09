"""
Main API router for v1 endpoints.
"""
from fastapi import APIRouter
from app.api.v1 import (
    auth,
    users,
    profiles,
    media,
    analysis,
    reports,
    entitlements
)

api_router = APIRouter()

# Include all route modules
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(users.router, prefix="/users", tags=["Users"])
api_router.include_router(profiles.router, prefix="/profiles", tags=["Profiles"])
api_router.include_router(media.router, prefix="/media", tags=["Media"])
api_router.include_router(analysis.router, prefix="/analysis", tags=["Analysis"])
api_router.include_router(reports.router, prefix="/reports", tags=["Reports"])
api_router.include_router(entitlements.router, prefix="/entitlements", tags=["Entitlements"])

# Optional: Add chat routes only if enabled
# if settings.enable_chat:
#     from app.api.v1 import chat
#     api_router.include_router(chat.router, prefix="/chat", tags=["Chat"])