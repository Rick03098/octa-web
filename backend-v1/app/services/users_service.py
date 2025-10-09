"""
User management service.
"""
from typing import Optional
from datetime import datetime

from app.repositories.users_repo import UsersRepository
from app.models.users import UserProfile, UpdateUserRequest
from app.core.errors import NotFoundError
from app.core.logging import get_logger

logger = get_logger(__name__)


class UsersService:
    """Service for user management operations."""

    def __init__(self):
        """Initialize users service."""
        self.users_repo = UsersRepository()

    async def get_user_profile(self, user_id: str) -> UserProfile:
        """
        Get user profile by ID.

        Args:
            user_id: User ID

        Returns:
            User profile

        Raises:
            NotFoundError: If user not found
        """
        user = await self.users_repo.get_user_by_id(user_id)
        if not user:
            raise NotFoundError("User", user_id)

        return user

    async def update_user_profile(
        self,
        user_id: str,
        update_data: UpdateUserRequest
    ) -> UserProfile:
        """
        Update user profile.

        Args:
            user_id: User ID
            update_data: Update request data

        Returns:
            Updated user profile

        Raises:
            NotFoundError: If user not found
        """
        updated_user = await self.users_repo.update_user(
            user_id=user_id,
            display_name=update_data.display_name,
            language=update_data.language,
            timezone=update_data.timezone
        )

        if not updated_user:
            raise NotFoundError("User", user_id)

        logger.info(f"User profile updated: {user_id}")
        return updated_user

    async def request_account_deletion(self, user_id: str) -> dict:
        """
        Request account deletion.

        Args:
            user_id: User ID

        Returns:
            Deletion request details
        """
        # Soft delete (mark as inactive)
        success = await self.users_repo.delete_user(user_id)

        if not success:
            raise NotFoundError("User", user_id)

        # TODO: Schedule permanent deletion after grace period
        # TODO: Send confirmation email

        logger.info(f"Account deletion requested: {user_id}")

        return {
            "status": "pending",
            "grace_period_days": 30,
            "scheduled_deletion_date": "2024-XX-XX"  # TODO: Calculate actual date
        }

    async def get_deletion_status(self, user_id: str) -> dict:
        """
        Get account deletion status.

        Args:
            user_id: User ID

        Returns:
            Deletion status
        """
        # TODO: Get actual deletion status from database
        user = await self.users_repo.get_user_by_id(user_id)

        if not user:
            return {
                "status": "not_found"
            }

        if not user.is_active:
            return {
                "status": "pending",
                "requested_at": user.updated_at,
                "scheduled_deletion_date": "2024-XX-XX"
            }

        return {
            "status": "none"
        }

    async def cancel_account_deletion(self, user_id: str) -> bool:
        """
        Cancel account deletion request.

        Args:
            user_id: User ID

        Returns:
            True if successful
        """
        # TODO: Reactivate account
        # For now, just update is_active flag

        updated_user = await self.users_repo.update_user(
            user_id=user_id,
            # is_active=True  # TODO: Uncomment when implementing
        )

        logger.info(f"Account deletion cancelled: {user_id}")
        return True