"""
Authentication API endpoints.
"""
from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException, status
from datetime import datetime, timedelta

from app.models.auth import (
    RegisterRequest,
    LoginRequest,
    OAuthLoginRequest,
    RefreshTokenRequest,
    VerifyEmailRequest,
    TokenResponse,
    MessageResponse
)
from app.core.security import (
    hash_password,
    verify_password,
    create_access_token,
    create_refresh_token,
    create_email_verification_token,
    verify_email_token,
    validate_token
)
from app.core.errors import (
    InvalidCredentialsError,
    ConflictError,
    NotFoundError
)
from app.repositories.users_repo import UsersRepository
from app.core.logging import get_logger

router = APIRouter()
logger = get_logger(__name__)


@router.post("/register", response_model=MessageResponse, status_code=status.HTTP_201_CREATED)
async def register(request: RegisterRequest):
    """
    Register a new user with email and password.

    Args:
        request: Registration request with email, password, language, timezone

    Returns:
        Success message with instruction to verify email
    """
    users_repo = UsersRepository()

    # Check if email already exists
    existing_user = await users_repo.check_email_exists(request.email)
    if existing_user:
        raise ConflictError("Email already registered")

    # Hash password
    hashed_password = hash_password(request.password)

    # Create user
    user = await users_repo.create_user(
        email=request.email,
        hashed_password=hashed_password,
        language=request.language,
        timezone=request.timezone
    )

    # Generate verification token
    verification_token = create_email_verification_token(request.email)

    # TODO: Send verification email
    # await email_service.send_verification_email(request.email, verification_token)

    logger.info(f"User registered: {user.user_id}")

    return MessageResponse(
        message=f"Registration successful. Please verify your email. (Token: {verification_token})"
    )


@router.post("/verify", response_model=MessageResponse)
async def verify_email(request: VerifyEmailRequest):
    """
    Verify user email with verification token.

    Args:
        request: Verification request with token

    Returns:
        Success message
    """
    users_repo = UsersRepository()

    # Verify token and get email
    email = verify_email_token(request.token)

    # Get user by email
    user_data = await users_repo.get_user_by_email(email)
    if not user_data:
        raise NotFoundError("User", email)

    # Mark email as verified
    await users_repo.verify_user_email(user_data["user_id"])

    logger.info(f"Email verified for user: {user_data['user_id']}")

    return MessageResponse(message="Email verified successfully")


@router.post("/login", response_model=TokenResponse)
async def login(request: LoginRequest):
    """
    Login with email and password.

    Args:
        request: Login request with email and password

    Returns:
        Access and refresh tokens
    """
    users_repo = UsersRepository()

    # Get user by email (includes hashed password)
    user_data = await users_repo.get_user_by_email(request.email)
    if not user_data:
        raise InvalidCredentialsError()

    # Verify password
    if not verify_password(request.password, user_data["hashed_password"]):
        raise InvalidCredentialsError()

    # Check if user is active
    if not user_data.get("is_active", True):
        raise InvalidCredentialsError("Account is deactivated")

    # Create tokens
    access_token = create_access_token(subject=user_data["user_id"])
    refresh_token = create_refresh_token(subject=user_data["user_id"])

    # Update last login
    await users_repo.update_user(
        user_id=user_data["user_id"],
        last_login=datetime.utcnow()
    )

    logger.info(f"User logged in: {user_data['user_id']}")

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="Bearer",
        expires_in=15 * 60  # 15 minutes in seconds
    )


@router.post("/login-oauth", response_model=TokenResponse)
async def login_oauth(request: OAuthLoginRequest):
    """
    Login with OAuth provider (Google/Apple).

    Args:
        request: OAuth login request with provider and id_token

    Returns:
        Access and refresh tokens
    """
    # TODO: Implement OAuth verification
    # - Verify id_token with provider
    # - Extract user info (email, name, etc.)
    # - Create or update user
    # - Return tokens

    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="OAuth login not yet implemented"
    )


@router.post("/logout", response_model=MessageResponse)
async def logout(refresh_token: str):
    """
    Logout and revoke refresh token.

    Args:
        refresh_token: Refresh token to revoke

    Returns:
        Success message
    """
    # TODO: Add refresh token to revocation list (Redis)
    # For now, just validate the token
    try:
        user_id = validate_token(refresh_token, token_type="refresh")
        logger.info(f"User logged out: {user_id}")
    except Exception:
        pass

    return MessageResponse(message="Logged out successfully")


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(request: RefreshTokenRequest):
    """
    Refresh access token using refresh token.

    Args:
        request: Refresh token request

    Returns:
        New access token
    """
    # Validate refresh token
    user_id = validate_token(request.refresh_token, token_type="refresh")

    # TODO: Check if token is revoked (from Redis)

    # Create new access token
    access_token = create_access_token(subject=user_id)

    logger.info(f"Token refreshed for user: {user_id}")

    return TokenResponse(
        access_token=access_token,
        refresh_token=request.refresh_token,  # Keep same refresh token
        token_type="Bearer",
        expires_in=15 * 60
    )