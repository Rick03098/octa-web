"""
Authentication models.
"""
from typing import Optional
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field, validator


# Request Models
class RegisterRequest(BaseModel):
    """User registration request."""
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=100)
    language: Optional[str] = Field(default="en", max_length=5)
    timezone: Optional[str] = Field(default="UTC", max_length=50)

    @validator("password")
    def validate_password(cls, v):
        """Validate password complexity."""
        if not any(c.isupper() for c in v):
            raise ValueError("Password must contain at least one uppercase letter")
        if not any(c.islower() for c in v):
            raise ValueError("Password must contain at least one lowercase letter")
        if not any(c.isdigit() for c in v):
            raise ValueError("Password must contain at least one digit")
        return v


class LoginRequest(BaseModel):
    """User login request."""
    email: EmailStr
    password: str


class OAuthLoginRequest(BaseModel):
    """OAuth login request."""
    provider: str = Field(..., regex="^(google|apple)$")
    id_token: str


class RefreshTokenRequest(BaseModel):
    """Refresh token request."""
    refresh_token: str


class VerifyEmailRequest(BaseModel):
    """Email verification request."""
    token: str


class ResendVerificationRequest(BaseModel):
    """Resend verification email request."""
    email: EmailStr


class ForgotPasswordRequest(BaseModel):
    """Forgot password request."""
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    """Reset password request."""
    token: str
    new_password: str = Field(..., min_length=8, max_length=100)


# Response Models
class TokenResponse(BaseModel):
    """Token response."""
    access_token: str
    refresh_token: str
    token_type: str = "Bearer"
    expires_in: int  # seconds


class AuthResponse(BaseModel):
    """Authentication response with user info."""
    tokens: TokenResponse
    user: dict  # User info


class MessageResponse(BaseModel):
    """Simple message response."""
    message: str


# Domain Models
class UserSession(BaseModel):
    """User session information."""
    user_id: str
    email: str
    is_verified: bool
    is_active: bool
    subscription_tier: str = "free"  # free, pro
    created_at: datetime
    last_login: Optional[datetime] = None