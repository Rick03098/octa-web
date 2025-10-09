"""
Bazi profiles management service.
"""
from typing import List, Optional
from datetime import datetime, timedelta

from app.services.bazi_service import BaziService
from app.models.profiles import (
    CreateBaziProfileRequest,
    BaziProfile,
    UpdateBaziProfileRequest
)
from app.core.errors import NotFoundError, ValidationError, ConflictError
from app.utils.ids import generate_prefixed_id
from app.core.logging import get_logger

logger = get_logger(__name__)


class ProfilesService:
    """Service for Bazi profiles management."""

    def __init__(self):
        """Initialize profiles service."""
        self.bazi_service = BaziService()
        # TODO: Initialize profiles repository
        # self.profiles_repo = ProfilesRepository()

    async def create_bazi_profile(
        self,
        user_id: str,
        request: CreateBaziProfileRequest
    ) -> BaziProfile:
        """
        Create a new Bazi profile with calculation.

        Args:
            user_id: User ID
            request: Profile creation request

        Returns:
            Created Bazi profile with calculation results

        Raises:
            ConflictError: If user already has max profiles
            ValidationError: If calculation fails
        """
        # TODO: Check max profiles limit
        # existing_profiles = await self.profiles_repo.get_user_profiles(user_id)
        # if len(existing_profiles) >= 1:  # Currently max 1
        #     raise ConflictError("Maximum number of Bazi profiles reached")

        # Extract longitude from location (simplified)
        longitude = self._extract_longitude(request.birth_location)

        # Calculate Bazi chart
        try:
            birth_datetime = None
            if request.birth_time:
                birth_datetime = datetime.combine(
                    request.birth_date,
                    request.birth_time
                )

            chart = self.bazi_service.calculate_bazi_chart(
                birth_date=request.birth_date,
                birth_time=birth_datetime,
                longitude=longitude
            )

            # Analyze lucky elements
            lucky_elements, unlucky_elements = self.bazi_service.analyze_lucky_elements(chart)
            lucky_directions = self.bazi_service.get_lucky_directions(lucky_elements)
            lucky_colors = self.bazi_service.get_lucky_colors(lucky_elements)

        except Exception as e:
            logger.error(f"Bazi calculation failed: {e}")
            raise ValidationError(f"Failed to calculate Bazi: {str(e)}")

        # Create profile
        profile_id = generate_prefixed_id("bazi")
        now = datetime.utcnow()

        profile = BaziProfile(
            profile_id=profile_id,
            user_id=user_id,
            name=request.name,
            birth_date=request.birth_date,
            birth_time=request.birth_time,
            birth_location=request.birth_location,
            gender=request.gender,
            chart=chart,
            lucky_elements=lucky_elements,
            unlucky_elements=unlucky_elements,
            lucky_directions=lucky_directions,
            lucky_colors=lucky_colors,
            personality_traits={},  # TODO: Generate from AI
            is_active=True,
            created_at=now,
            updated_at=now,
            last_modified_at=None
        )

        # TODO: Save to database
        # await self.profiles_repo.create_profile(profile)

        logger.info(f"Bazi profile created: {profile_id} for user {user_id}")
        return profile

    async def get_user_profiles(self, user_id: str) -> List[BaziProfile]:
        """
        Get all user's Bazi profiles.

        Args:
            user_id: User ID

        Returns:
            List of Bazi profiles
        """
        # TODO: Get from database
        # return await self.profiles_repo.get_user_profiles(user_id)
        return []

    async def get_profile(self, profile_id: str, user_id: str) -> BaziProfile:
        """
        Get specific Bazi profile.

        Args:
            profile_id: Profile ID
            user_id: User ID (for ownership check)

        Returns:
            Bazi profile

        Raises:
            NotFoundError: If profile not found or doesn't belong to user
        """
        # TODO: Get from database
        # profile = await self.profiles_repo.get_profile(profile_id)
        # if not profile or profile.user_id != user_id:
        #     raise NotFoundError("Bazi profile", profile_id)
        # return profile
        raise NotFoundError("Bazi profile", profile_id)

    async def update_profile(
        self,
        profile_id: str,
        user_id: str,
        update_data: UpdateBaziProfileRequest
    ) -> BaziProfile:
        """
        Update Bazi profile (with cooldown check).

        Args:
            profile_id: Profile ID
            user_id: User ID
            update_data: Update request

        Returns:
            Updated profile

        Raises:
            NotFoundError: If profile not found
            ValidationError: If cooldown period not passed
        """
        # TODO: Get profile
        # profile = await self.profiles_repo.get_profile(profile_id)
        # if not profile or profile.user_id != user_id:
        #     raise NotFoundError("Bazi profile", profile_id)

        # Check cooldown (24 hours)
        # if profile.last_modified_at:
        #     cooldown_end = profile.last_modified_at + timedelta(hours=24)
        #     if datetime.utcnow() < cooldown_end:
        #         raise ValidationError(
        #             "Cannot modify profile yet",
        #             details={"cooldown_ends_at": cooldown_end.isoformat()}
        #         )

        # TODO: Update profile
        # updated_profile = await self.profiles_repo.update_profile(
        #     profile_id=profile_id,
        #     name=update_data.name,
        #     is_active=update_data.is_active,
        #     last_modified_at=datetime.utcnow()
        # )

        # return updated_profile
        raise NotFoundError("Bazi profile", profile_id)

    async def delete_profile(self, profile_id: str, user_id: str) -> bool:
        """
        Delete Bazi profile.

        Args:
            profile_id: Profile ID
            user_id: User ID

        Returns:
            True if successful

        Raises:
            NotFoundError: If profile not found
        """
        # TODO: Get and verify ownership
        # profile = await self.profiles_repo.get_profile(profile_id)
        # if not profile or profile.user_id != user_id:
        #     raise NotFoundError("Bazi profile", profile_id)

        # TODO: Delete (soft or hard delete based on requirements)
        # await self.profiles_repo.delete_profile(profile_id)

        logger.info(f"Bazi profile deleted: {profile_id}")
        return True

    async def activate_profile(self, profile_id: str, user_id: str) -> BaziProfile:
        """
        Activate a specific profile (deactivate others).

        Args:
            profile_id: Profile ID to activate
            user_id: User ID

        Returns:
            Activated profile

        Raises:
            NotFoundError: If profile not found
        """
        # TODO: Deactivate all user's profiles
        # await self.profiles_repo.deactivate_all_profiles(user_id)

        # TODO: Activate specified profile
        # profile = await self.profiles_repo.activate_profile(profile_id, user_id)
        # if not profile:
        #     raise NotFoundError("Bazi profile", profile_id)

        # return profile
        raise NotFoundError("Bazi profile", profile_id)

    def _extract_longitude(self, location: str) -> Optional[float]:
        """
        Extract longitude from location string.

        This is a simplified version. In production, use geocoding service.

        Args:
            location: Location string

        Returns:
            Longitude or None
        """
        # Simple mapping for common locations
        location_to_lon = {
            "beijing": 116.4,
            "shanghai": 121.5,
            "guangzhou": 113.3,
            "shenzhen": 114.1,
            "singapore": 103.8,
            "hong kong": 114.2,
            "taipei": 121.6,
            "tokyo": 139.7,
            "new york": -74.0,
            "london": -0.13,
            "paris": 2.35,
            "san francisco": -122.4
        }

        location_lower = location.lower()
        for city, lon in location_to_lon.items():
            if city in location_lower:
                return lon

        # Default to Beijing if not found
        return 116.4