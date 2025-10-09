"""
User management API endpoints.
"""
from typing import Annotated
from fastapi import APIRouter, Depends, status

from app.api.deps import get_current_user, get_current_verified_user
from app.models.auth import UserSession
from app.models.users import UserResponse, UpdateUserRequest
from app.core.errors import NotFoundError
from app.repositories.users_repo import UsersRepository
from app.core.logging import get_logger

router = APIRouter()
logger = get_logger(__name__)


@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(
    current_user: Annotated[UserSession, Depends(get_current_user)]
):
    """
    Get current user's profile.

    Returns:
        User profile information
    """
    users_repo = UsersRepository()
    user = await users_repo.get_user_by_id(current_user.user_id)

    if not user:
        raise NotFoundError("User", current_user.user_id)

    return UserResponse(
        user_id=user.user_id,
        email=user.email,
        display_name=user.display_name,
        language=user.language,
        timezone=user.timezone,
        is_verified=user.is_verified,
        subscription_tier=user.subscription_tier,
        created_at=user.created_at
    )


@router.patch("/me", response_model=UserResponse)
async def update_current_user_profile(
    request: UpdateUserRequest,
    current_user: Annotated[UserSession, Depends(get_current_user)]
):
    """
    Update current user's profile.

    Args:
        request: Update request with optional fields

    Returns:
        Updated user profile
    """
    users_repo = UsersRepository()

    # Update user
    updated_user = await users_repo.update_user(
        user_id=current_user.user_id,
        display_name=request.display_name,
        language=request.language,
        timezone=request.timezone
    )

    if not updated_user:
        raise NotFoundError("User", current_user.user_id)

    logger.info(f"User profile updated: {current_user.user_id}")

    return UserResponse(
        user_id=updated_user.user_id,
        email=updated_user.email,
        display_name=updated_user.display_name,
        language=updated_user.language,
        timezone=updated_user.timezone,
        is_verified=updated_user.is_verified,
        subscription_tier=updated_user.subscription_tier,
        created_at=updated_user.created_at
    )


@router.post("/me/deletion", status_code=status.HTTP_202_ACCEPTED)
async def request_account_deletion(
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Request account deletion (for Apple compliance).

    This initiates the deletion process. The account will be deactivated immediately
    and data will be permanently deleted after a grace period.

    Returns:
        Deletion request confirmation
    """
    users_repo = UsersRepository()

    # Soft delete (mark as inactive)
    success = await users_repo.delete_user(current_user.user_id)

    if not success:
        raise NotFoundError("User", current_user.user_id)

    # TODO: Schedule permanent deletion after grace period (e.g., 30 days)
    # TODO: Send confirmation email

    logger.info(f"Account deletion requested: {current_user.user_id}")

    return {
        "message": "Account deletion request received",
        "status": "pending",
        "grace_period_days": 30,
        "deletion_date": "2024-XX-XX"  # TODO: Calculate actual date
    }


@router.get("/me/deletion")
async def get_deletion_status(
    current_user: Annotated[UserSession, Depends(get_current_user)]
):
    """
    Get account deletion status.

    Returns:
        Deletion request status and timeline
    """
    # TODO: Get actual deletion status from database
    return {
        "status": "none",  # none, pending, completed
        "requested_at": None,
        "scheduled_deletion_date": None,
        "can_cancel": False
    }


@router.delete("/me/deletion")
async def cancel_account_deletion(
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Cancel account deletion request.

    Returns:
        Cancellation confirmation
    """
    # TODO: Implement cancellation logic
    # - Check if deletion is still in grace period
    # - Reactivate account
    # - Cancel scheduled deletion

    logger.info(f"Account deletion cancelled: {current_user.user_id}")

    return {
        "message": "Account deletion cancelled",
        "status": "active"
    }