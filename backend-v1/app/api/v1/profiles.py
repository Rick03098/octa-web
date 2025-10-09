"""
Bazi profile management API endpoints.
"""
from typing import Annotated, List
from fastapi import APIRouter, Depends, status, HTTPException
from datetime import datetime, time

from app.api.deps import get_current_verified_user
from app.models.auth import UserSession
from app.models.profiles import (
    CreateBaziProfileRequest,
    BaziProfileResponse,
    UpdateBaziProfileRequest
)
from app.services.bazi_service import BaziService
from app.core.errors import NotFoundError, ValidationError, ConflictError
from app.core.logging import get_logger
from app.utils.ids import generate_prefixed_id

router = APIRouter()
logger = get_logger(__name__)
bazi_service = BaziService()


@router.post("/bazi", response_model=BaziProfileResponse, status_code=status.HTTP_201_CREATED)
async def create_bazi_profile(
    request: CreateBaziProfileRequest,
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Create user's Bazi profile with instant calculation.

    Args:
        request: Bazi profile creation request

    Returns:
        Created Bazi profile with calculation results
    """
    # TODO: Check if user already has max profiles (currently max=1)
    # existing_profiles = await profiles_repo.get_user_profiles(current_user.user_id)
    # if len(existing_profiles) >= 1:
    #     raise ConflictError("Maximum number of Bazi profiles reached")

    # Calculate Bazi chart
    try:
        # Combine date and time for birth_time parameter
        birth_datetime = None
        longitude = None

        # TODO: Extract longitude from birth_location
        # This would typically involve geocoding the location
        # For now, we'll use a default longitude based on common locations
        location_to_lon = {
            "beijing": 116.4,
            "shanghai": 121.5,
            "singapore": 103.8,
            "new york": -74.0,
            "london": -0.13
        }

        location_lower = request.birth_location.lower()
        for loc, lon in location_to_lon.items():
            if loc in location_lower:
                longitude = lon
                break

        if request.birth_time:
            birth_datetime = datetime.combine(request.birth_date, request.birth_time)

        # Calculate Bazi chart
        chart = bazi_service.calculate_bazi_chart(
            birth_date=request.birth_date,
            birth_time=birth_datetime if birth_datetime else None,
            longitude=longitude
        )

        # Analyze lucky elements
        lucky_elements, unlucky_elements = bazi_service.analyze_lucky_elements(chart)

        # Get lucky directions and colors
        lucky_directions = bazi_service.get_lucky_directions(lucky_elements)
        lucky_colors = bazi_service.get_lucky_colors(lucky_elements)

    except Exception as e:
        logger.error(f"Bazi calculation failed: {e}")
        raise ValidationError(f"Failed to calculate Bazi: {str(e)}")

    # Create profile
    profile_id = generate_prefixed_id("bazi")
    now = datetime.utcnow()

    profile_data = {
        "profile_id": profile_id,
        "user_id": current_user.user_id,
        "name": request.name,
        "birth_date": request.birth_date,
        "birth_time": request.birth_time,
        "birth_location": request.birth_location,
        "gender": request.gender,
        "chart": chart.dict(),
        "lucky_elements": lucky_elements,
        "unlucky_elements": unlucky_elements,
        "lucky_directions": lucky_directions,
        "lucky_colors": lucky_colors,
        "personality_traits": {},  # TODO: Calculate from AI
        "is_active": True,
        "created_at": now,
        "updated_at": now
    }

    # TODO: Save to database
    # await profiles_repo.create_profile(profile_data)

    logger.info(f"Bazi profile created: {profile_id} for user {current_user.user_id}")

    return BaziProfileResponse(
        profile_id=profile_id,
        name=request.name,
        birth_date=request.birth_date,
        birth_time=request.birth_time,
        birth_location=request.birth_location,
        gender=request.gender,
        chart=chart,
        lucky_elements=lucky_elements,
        lucky_directions=lucky_directions,
        lucky_colors=lucky_colors,
        is_active=True,
        created_at=now
    )


@router.get("/bazi", response_model=List[BaziProfileResponse])
async def list_bazi_profiles(
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    List all user's Bazi profiles.

    Returns:
        List of Bazi profiles (currently max 1)
    """
    # TODO: Get profiles from database
    # profiles = await profiles_repo.get_user_profiles(current_user.user_id)

    # Mock response
    profiles = []

    return profiles


@router.get("/bazi/{profile_id}", response_model=BaziProfileResponse)
async def get_bazi_profile(
    profile_id: str,
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Get specific Bazi profile details.

    Args:
        profile_id: Profile ID

    Returns:
        Bazi profile details
    """
    # TODO: Get profile from database
    # profile = await profiles_repo.get_profile(profile_id)

    # if not profile or profile.user_id != current_user.user_id:
    #     raise NotFoundError("Bazi profile", profile_id)

    raise NotFoundError("Bazi profile", profile_id)


@router.patch("/bazi/{profile_id}", response_model=BaziProfileResponse)
async def update_bazi_profile(
    profile_id: str,
    request: UpdateBaziProfileRequest,
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Update Bazi profile (limited fields, with cooldown period).

    Args:
        profile_id: Profile ID
        request: Update request

    Returns:
        Updated profile
    """
    # TODO: Implement update logic with cooldown check
    # - Check if profile exists and belongs to user
    # - Check if 24-hour cooldown has passed since last modification
    # - Update allowed fields (name, is_active)
    # - Update last_modified_at timestamp

    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Profile update with cooldown check not yet implemented"
    )


@router.delete("/bazi/{profile_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_bazi_profile(
    profile_id: str,
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Delete Bazi profile.

    Args:
        profile_id: Profile ID
    """
    # TODO: Implement deletion
    # - Check if profile exists and belongs to user
    # - Soft delete or hard delete based on requirements
    # - Consider if there are related analysis records

    raise NotFoundError("Bazi profile", profile_id)


@router.post("/bazi/{profile_id}:activate", response_model=BaziProfileResponse)
async def activate_bazi_profile(
    profile_id: str,
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Activate a specific Bazi profile (for future multi-profile support).

    This deactivates all other profiles and activates the specified one.

    Args:
        profile_id: Profile ID to activate

    Returns:
        Activated profile
    """
    # TODO: Implement profile switching
    # - Deactivate all user's profiles
    # - Activate specified profile
    # - Update is_active flags

    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Multi-profile support not yet implemented"
    )