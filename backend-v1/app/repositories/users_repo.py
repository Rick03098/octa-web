"""
Users repository for data access.
"""
from typing import Optional, List
from datetime import datetime
from google.cloud import firestore
from app.models.users import UserProfile
from app.utils.ids import generate_prefixed_id
from app.core.config import get_settings
from app.core.logging import get_logger

settings = get_settings()
logger = get_logger(__name__)


class UsersRepository:
    """Repository for user data operations."""

    def __init__(self):
        """Initialize Firestore client."""
        self.db = firestore.Client(
            project=settings.google_cloud_project,
            database=settings.firestore_database,
        )
        self.collection = self.db.collection("users")

    async def create_user(
        self,
        email: str,
        hashed_password: str,
        language: str = "en",
        timezone: str = "UTC",
    ) -> UserProfile:
        """
        Create a new user.

        Args:
            email: User email
            hashed_password: Hashed password
            language: User language preference
            timezone: User timezone

        Returns:
            Created UserProfile
        """
        user_id = generate_prefixed_id("user")
        now = datetime.utcnow()

        user_data = {
            "user_id": user_id,
            "email": email,
            "hashed_password": hashed_password,
            "display_name": None,
            "language": language,
            "timezone": timezone,
            "is_verified": False,
            "is_active": True,
            "subscription_tier": "free",
            "subscription_expires_at": None,
            "created_at": now,
            "updated_at": now,
            "last_login": None,
            "metadata": {},
        }

        # Create document
        self.collection.document(user_id).set(user_data)
        logger.info(f"Created user: {user_id}")

        # Remove password from response
        user_data.pop("hashed_password")
        return UserProfile(**user_data)

    async def get_user_by_id(self, user_id: str) -> Optional[UserProfile]:
        """
        Get user by ID.

        Args:
            user_id: User ID

        Returns:
            UserProfile or None if not found
        """
        doc = self.collection.document(user_id).get()
        if not doc.exists:
            return None

        data = doc.to_dict()
        data.pop("hashed_password", None)  # Remove password
        return UserProfile(**data)

    async def get_user_by_email(self, email: str) -> Optional[dict]:
        """
        Get user by email (includes hashed password for auth).

        Args:
            email: User email

        Returns:
            User dict with hashed_password or None
        """
        query = self.collection.where("email", "==", email).limit(1)
        docs = query.get()

        for doc in docs:
            return doc.to_dict()

        return None

    async def update_user(
        self,
        user_id: str,
        display_name: Optional[str] = None,
        language: Optional[str] = None,
        timezone: Optional[str] = None,
        is_verified: Optional[bool] = None,
        subscription_tier: Optional[str] = None,
        subscription_expires_at: Optional[datetime] = None,
        last_login: Optional[datetime] = None,
    ) -> Optional[UserProfile]:
        """
        Update user profile.

        Args:
            user_id: User ID
            display_name: Display name
            language: Language preference
            timezone: Timezone
            is_verified: Verification status
            subscription_tier: Subscription tier
            subscription_expires_at: Subscription expiration
            last_login: Last login time

        Returns:
            Updated UserProfile or None
        """
        update_data = {
            "updated_at": datetime.utcnow(),
        }

        if display_name is not None:
            update_data["display_name"] = display_name
        if language is not None:
            update_data["language"] = language
        if timezone is not None:
            update_data["timezone"] = timezone
        if is_verified is not None:
            update_data["is_verified"] = is_verified
        if subscription_tier is not None:
            update_data["subscription_tier"] = subscription_tier
        if subscription_expires_at is not None:
            update_data["subscription_expires_at"] = subscription_expires_at
        if last_login is not None:
            update_data["last_login"] = last_login

        # Update document
        doc_ref = self.collection.document(user_id)
        doc_ref.update(update_data)

        logger.info(f"Updated user: {user_id}")
        return await self.get_user_by_id(user_id)

    async def delete_user(self, user_id: str) -> bool:
        """
        Soft delete user (mark as inactive).

        Args:
            user_id: User ID

        Returns:
            True if successful
        """
        try:
            self.collection.document(user_id).update({
                "is_active": False,
                "updated_at": datetime.utcnow(),
            })
            logger.info(f"Soft deleted user: {user_id}")
            return True
        except Exception as e:
            logger.error(f"Failed to delete user {user_id}: {e}")
            return False

    async def verify_user_email(self, user_id: str) -> bool:
        """
        Mark user email as verified.

        Args:
            user_id: User ID

        Returns:
            True if successful
        """
        try:
            self.collection.document(user_id).update({
                "is_verified": True,
                "updated_at": datetime.utcnow(),
            })
            logger.info(f"Verified user email: {user_id}")
            return True
        except Exception as e:
            logger.error(f"Failed to verify user {user_id}: {e}")
            return False

    async def check_email_exists(self, email: str) -> bool:
        """
        Check if email already exists.

        Args:
            email: Email to check

        Returns:
            True if exists
        """
        query = self.collection.where("email", "==", email).limit(1)
        docs = query.get()
        return len(list(docs)) > 0