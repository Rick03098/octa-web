"""
API dependencies for dependency injection.
"""
from typing import Optional, Annotated
from fastapi import Depends, HTTPException, status, Header
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.core.security import validate_token
from app.core.errors import UnauthorizedError, ForbiddenError
from app.models.auth import UserSession
from app.repositories.users_repo import UsersRepository
from app.core.config import get_settings

settings = get_settings()

# Security scheme
security = HTTPBearer()


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(security)]
) -> UserSession:
    """
    Get current authenticated user from JWT token.

    Args:
        credentials: Bearer token from Authorization header

    Returns:
        UserSession object

    Raises:
        UnauthorizedError: If token is invalid or expired
    """
    try:
        # Validate token and get user ID
        user_id = validate_token(credentials.credentials, token_type="access")

        # Get user from repository
        users_repo = UsersRepository()
        user = await users_repo.get_user_by_id(user_id)

        if not user:
            raise UnauthorizedError("User not found")

        if not user.is_active:
            raise UnauthorizedError("User account is deactivated")

        # Create user session
        return UserSession(
            user_id=user.user_id,
            email=user.email,
            is_verified=user.is_verified,
            is_active=user.is_active,
            subscription_tier=user.subscription_tier,
            created_at=user.created_at,
            last_login=user.last_login,
        )

    except Exception as e:
        raise UnauthorizedError(str(e))


async def get_current_verified_user(
    current_user: Annotated[UserSession, Depends(get_current_user)]
) -> UserSession:
    """
    Get current user and ensure email is verified.

    Args:
        current_user: Current authenticated user

    Returns:
        UserSession object

    Raises:
        ForbiddenError: If email is not verified
    """
    if not current_user.is_verified:
        raise ForbiddenError("Email verification required")
    return current_user


async def get_current_pro_user(
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
) -> UserSession:
    """
    Get current user and ensure they have Pro subscription.

    Args:
        current_user: Current verified user

    Returns:
        UserSession object

    Raises:
        ForbiddenError: If user doesn't have Pro subscription
    """
    if current_user.subscription_tier != "pro":
        raise ForbiddenError("Pro subscription required")
    return current_user


async def get_optional_current_user(
    authorization: Optional[str] = Header(None)
) -> Optional[UserSession]:
    """
    Get current user if authenticated, otherwise return None.

    Args:
        authorization: Optional Authorization header

    Returns:
        UserSession object or None
    """
    if not authorization or not authorization.startswith("Bearer "):
        return None

    try:
        token = authorization.split(" ")[1]
        user_id = validate_token(token, token_type="access")

        users_repo = UsersRepository()
        user = await users_repo.get_user_by_id(user_id)

        if user and user.is_active:
            return UserSession(
                user_id=user.user_id,
                email=user.email,
                is_verified=user.is_verified,
                is_active=user.is_active,
                subscription_tier=user.subscription_tier,
                created_at=user.created_at,
                last_login=user.last_login,
            )
    except:
        pass

    return None


class RateLimiter:
    """
    Rate limiting dependency.
    """

    def __init__(self, calls: int, period: int):
        """
        Initialize rate limiter.

        Args:
            calls: Number of calls allowed
            period: Time period in seconds
        """
        self.calls = calls
        self.period = period

    async def __call__(
        self,
        current_user: Annotated[UserSession, Depends(get_current_user)]
    ) -> None:
        """
        Check rate limit for current user.

        Args:
            current_user: Current authenticated user

        Raises:
            HTTPException: If rate limit exceeded
        """
        # TODO: Implement actual rate limiting with Redis
        # For now, Pro users have no rate limit
        if current_user.subscription_tier == "pro":
            return

        # Implement rate limiting logic here
        pass


# Pre-configured rate limiters
rate_limit_standard = RateLimiter(calls=60, period=60)  # 60 calls per minute
rate_limit_strict = RateLimiter(calls=10, period=60)  # 10 calls per minute
rate_limit_analysis = RateLimiter(calls=5, period=3600)  # 5 analyses per hour