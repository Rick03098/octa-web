"""
Authentication service for user registration, login, and token management.
"""
from typing import Optional, Dict, Any
from datetime import datetime

from app.core.security import (
    hash_password,
    verify_password,
    create_access_token,
    create_refresh_token,
    create_email_verification_token,
    verify_email_token
)
from app.core.errors import InvalidCredentialsError, ConflictError, NotFoundError
from app.repositories.users_repo import UsersRepository
from app.models.auth import TokenResponse
from app.core.logging import get_logger

logger = get_logger(__name__)


class AuthService:
    """Service for authentication operations."""

    def __init__(self):
        """Initialize auth service."""
        self.users_repo = UsersRepository()

    async def register_user(
        self,
        email: str,
        password: str,
        language: str = "en",
        timezone: str = "UTC"
    ) -> Dict[str, Any]:
        """
        Register a new user.

        Args:
            email: User email
            password: Plain text password
            language: User language preference
            timezone: User timezone

        Returns:
            User data and verification token

        Raises:
            ConflictError: If email already exists
        """
        # Check if email exists
        if await self.users_repo.check_email_exists(email):
            raise ConflictError("Email already registered")

        # Hash password
        hashed_password = hash_password(password)

        # Create user
        user = await self.users_repo.create_user(
            email=email,
            hashed_password=hashed_password,
            language=language,
            timezone=timezone
        )

        # Generate verification token
        verification_token = create_email_verification_token(email)

        logger.info(f"User registered: {user.user_id}")

        return {
            "user_id": user.user_id,
            "email": user.email,
            "verification_token": verification_token
        }

    async def verify_email(self, token: str) -> bool:
        """
        Verify user email with token.

        Args:
            token: Verification token

        Returns:
            True if successful

        Raises:
            NotFoundError: If user not found
        """
        # Verify token and get email
        email = verify_email_token(token)

        # Get user
        user_data = await self.users_repo.get_user_by_email(email)
        if not user_data:
            raise NotFoundError("User", email)

        # Mark as verified
        await self.users_repo.verify_user_email(user_data["user_id"])

        logger.info(f"Email verified for user: {user_data['user_id']}")
        return True

    async def login(self, email: str, password: str) -> TokenResponse:
        """
        Login user with email and password.

        Args:
            email: User email
            password: Plain text password

        Returns:
            Access and refresh tokens

        Raises:
            InvalidCredentialsError: If credentials are invalid
        """
        # Get user with password
        user_data = await self.users_repo.get_user_by_email(email)
        if not user_data:
            raise InvalidCredentialsError()

        # Verify password
        if not verify_password(password, user_data["hashed_password"]):
            raise InvalidCredentialsError()

        # Check if active
        if not user_data.get("is_active", True):
            raise InvalidCredentialsError("Account is deactivated")

        # Create tokens
        access_token = create_access_token(subject=user_data["user_id"])
        refresh_token = create_refresh_token(subject=user_data["user_id"])

        # Update last login
        await self.users_repo.update_user(
            user_id=user_data["user_id"],
            last_login=datetime.utcnow()
        )

        logger.info(f"User logged in: {user_data['user_id']}")

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="Bearer",
            expires_in=15 * 60
        )

    async def refresh_access_token(self, user_id: str) -> TokenResponse:
        """
        Refresh access token.

        Args:
            user_id: User ID from refresh token

        Returns:
            New access token
        """
        # Create new access token
        access_token = create_access_token(subject=user_id)

        logger.info(f"Access token refreshed for user: {user_id}")

        return TokenResponse(
            access_token=access_token,
            refresh_token="",  # Keep same refresh token
            token_type="Bearer",
            expires_in=15 * 60
        )

    async def logout(self, user_id: str, refresh_token: str) -> bool:
        """
        Logout user and revoke refresh token.

        Args:
            user_id: User ID
            refresh_token: Refresh token to revoke

        Returns:
            True if successful
        """
        # TODO: Add refresh token to revocation list (Redis)
        # For now, just log the action

        logger.info(f"User logged out: {user_id}")
        return True