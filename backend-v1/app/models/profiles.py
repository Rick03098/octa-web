"""
Bazi profile models.
"""
from typing import Optional, Dict, Any, List
from datetime import datetime, date, time
from pydantic import BaseModel, Field, validator


class CreateBaziProfileRequest(BaseModel):
    """Create Bazi profile request."""
    birth_date: date
    birth_time: time
    birth_location: str = Field(..., min_length=1, max_length=200)
    gender: str = Field(..., regex="^(male|female|other)$")
    name: Optional[str] = Field(None, max_length=100)

    @validator("birth_date")
    def validate_birth_date(cls, v):
        """Ensure birth date is not in the future."""
        if v > date.today():
            raise ValueError("Birth date cannot be in the future")
        if v.year < 1900:
            raise ValueError("Birth date year must be after 1900")
        return v


class BaziElements(BaseModel):
    """Bazi five elements distribution."""
    wood: float = Field(..., ge=0, le=100)
    fire: float = Field(..., ge=0, le=100)
    earth: float = Field(..., ge=0, le=100)
    metal: float = Field(..., ge=0, le=100)
    water: float = Field(..., ge=0, le=100)

    @validator("water")
    def validate_total(cls, v, values):
        """Ensure elements sum to 100."""
        total = v + values.get("wood", 0) + values.get("fire", 0) + values.get("earth", 0) + values.get("metal", 0)
        if abs(total - 100) > 0.01:  # Allow small floating point errors
            raise ValueError("Elements must sum to 100")
        return v


class BaziPillar(BaseModel):
    """Single Bazi pillar (天干地支)."""
    heavenly_stem: str  # 天干
    earthly_branch: str  # 地支
    element: str  # 五行


class BaziChart(BaseModel):
    """Complete Bazi chart (四柱八字)."""
    year_pillar: BaziPillar  # 年柱
    month_pillar: BaziPillar  # 月柱
    day_pillar: BaziPillar  # 日柱
    hour_pillar: BaziPillar  # 时柱
    day_master: str  # 日主
    elements: BaziElements  # 五行分布


class BaziProfile(BaseModel):
    """Bazi profile model."""
    profile_id: str
    user_id: str
    name: Optional[str]
    birth_date: date
    birth_time: time
    birth_location: str
    gender: str
    chart: BaziChart
    lucky_elements: List[str]  # 喜用神
    unlucky_elements: List[str]  # 忌神
    lucky_directions: List[str]  # 吉方位
    lucky_colors: List[str]  # 幸运色
    personality_traits: Dict[str, Any]
    is_active: bool = True
    created_at: datetime
    updated_at: datetime
    last_modified_at: Optional[datetime] = None


class BaziProfileResponse(BaseModel):
    """Bazi profile response."""
    profile_id: str
    name: Optional[str]
    birth_date: date
    birth_time: time
    birth_location: str
    gender: str
    chart: BaziChart
    lucky_elements: List[str]
    lucky_directions: List[str]
    lucky_colors: List[str]
    is_active: bool
    created_at: datetime


class UpdateBaziProfileRequest(BaseModel):
    """Update Bazi profile request (limited fields)."""
    name: Optional[str] = Field(None, max_length=100)
    is_active: Optional[bool] = None