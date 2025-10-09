"""
Security utilities for authentication and authorization.
"""
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from app.core.config import get_settings
from app.core.errors import InvalidCredentialsError, TokenExpiredError

settings = get_settings()

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plain password against a hashed password."""
    return pwd_context.verify(plain_password, hashed_password)


def hash_password(password: str) -> str:
    """Hash a password."""
    return pwd_context.hash(password)


def create_access_token(
    subject: str,
    expires_delta: Optional[timedelta] = None,
    extra_claims: Optional[Dict[str, Any]] = None,
) -> str:
    """
    Create a JWT access token.

    Args:
        subject: The subject of the token (usually user ID)
        expires_delta: Optional expiration time delta
        extra_claims: Additional claims to include in the token

    Returns:
        Encoded JWT token
    """
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(
            minutes=settings.access_token_expire_minutes
        )

    to_encode = {
        "sub": subject,
        "exp": expire,
        "iat": datetime.now(timezone.utc),
        "type": "access",
    }

    if extra_claims:
        to_encode.update(extra_claims)

    encoded_jwt = jwt.encode(
        to_encode,
        settings.jwt_secret_key,
        algorithm=settings.jwt_algorithm,
    )
    return encoded_jwt


def create_refresh_token(
    subject: str,
    expires_delta: Optional[timedelta] = None,
    extra_claims: Optional[Dict[str, Any]] = None,
) -> str:
    """
    Create a JWT refresh token.

    Args:
        subject: The subject of the token (usually user ID)
        expires_delta: Optional expiration time delta
        extra_claims: Additional claims to include in the token

    Returns:
        Encoded JWT token
    """
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(
            days=settings.refresh_token_expire_days
        )

    to_encode = {
        "sub": subject,
        "exp": expire,
        "iat": datetime.now(timezone.utc),
        "type": "refresh",
    }

    if extra_claims:
        to_encode.update(extra_claims)

    encoded_jwt = jwt.encode(
        to_encode,
        settings.jwt_secret_key,
        algorithm=settings.jwt_algorithm,
    )
    return encoded_jwt


def decode_token(token: str) -> Dict[str, Any]:
    """
    Decode and validate a JWT token.

    Args:
        token: The JWT token to decode

    Returns:
        Decoded token payload

    Raises:
        InvalidCredentialsError: If token is invalid
        TokenExpiredError: If token has expired
    """
    try:
        payload = jwt.decode(
            token,
            settings.jwt_secret_key,
            algorithms=[settings.jwt_algorithm],
        )
        return payload
    except jwt.ExpiredSignatureError:
        raise TokenExpiredError()
    except JWTError:
        raise InvalidCredentialsError("Invalid token")


def validate_token(token: str, token_type: str = "access") -> str:
    """
    Validate a token and return the subject.

    Args:
        token: The JWT token to validate
        token_type: Expected token type ("access" or "refresh")

    Returns:
        The subject (user ID) from the token

    Raises:
        InvalidCredentialsError: If token is invalid or wrong type
        TokenExpiredError: If token has expired
    """
    payload = decode_token(token)

    # Check token type
    if payload.get("type") != token_type:
        raise InvalidCredentialsError(f"Invalid token type, expected {token_type}")

    # Get subject
    subject = payload.get("sub")
    if subject is None:
        raise InvalidCredentialsError("Token missing subject")

    return subject


def create_email_verification_token(email: str) -> str:
    """
    Create a token for email verification.

    Args:
        email: Email address to verify

    Returns:
        Encoded JWT token
    """
    expire = datetime.now(timezone.utc) + timedelta(hours=24)
    to_encode = {
        "sub": email,
        "exp": expire,
        "type": "email_verification",
    }
    return jwt.encode(
        to_encode,
        settings.jwt_secret_key,
        algorithm=settings.jwt_algorithm,
    )


def verify_email_token(token: str) -> str:
    """
    Verify an email verification token.

    Args:
        token: The verification token

    Returns:
        Email address from the token

    Raises:
        InvalidCredentialsError: If token is invalid
        TokenExpiredError: If token has expired
    """
    payload = decode_token(token)

    if payload.get("type") != "email_verification":
        raise InvalidCredentialsError("Invalid verification token")

    email = payload.get("sub")
    if not email:
        raise InvalidCredentialsError("Invalid verification token")

    return email


def create_password_reset_token(user_id: str) -> str:
    """
    Create a token for password reset.

    Args:
        user_id: User ID

    Returns:
        Encoded JWT token
    """
    expire = datetime.now(timezone.utc) + timedelta(hours=1)
    to_encode = {
        "sub": user_id,
        "exp": expire,
        "type": "password_reset",
    }
    return jwt.encode(
        to_encode,
        settings.jwt_secret_key,
        algorithm=settings.jwt_algorithm,
    )


def verify_password_reset_token(token: str) -> str:
    """
    Verify a password reset token.

    Args:
        token: The reset token

    Returns:
        User ID from the token

    Raises:
        InvalidCredentialsError: If token is invalid
        TokenExpiredError: If token has expired
    """
    payload = decode_token(token)

    if payload.get("type") != "password_reset":
        raise InvalidCredentialsError("Invalid reset token")

    user_id = payload.get("sub")
    if not user_id:
        raise InvalidCredentialsError("Invalid reset token")

    return user_id