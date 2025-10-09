"""
User models.
"""
from typing import Optional, Dict, Any
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field


class UserProfile(BaseModel):
    """User profile model."""
    user_id: str
    email: EmailStr
    display_name: Optional[str] = None
    language: str = "en"
    timezone: str = "UTC"
    is_verified: bool = False
    is_active: bool = True
    subscription_tier: str = "free"
    subscription_expires_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    last_login: Optional[datetime] = None
    metadata: Dict[str, Any] = Field(default_factory=dict)


class UpdateUserRequest(BaseModel):
    """Update user profile request."""
    display_name: Optional[str] = Field(None, max_length=100)
    language: Optional[str] = Field(None, max_length=5)
    timezone: Optional[str] = Field(None, max_length=50)


class UserResponse(BaseModel):
    """User response model."""
    user_id: str
    email: EmailStr
    display_name: Optional[str]
    language: str
    timezone: str
    is_verified: bool
    subscription_tier: str
    created_at: datetime