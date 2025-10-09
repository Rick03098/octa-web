"""
Media upload and management service.
"""
from typing import Optional, List
from datetime import datetime, timedelta

from app.core.config import get_settings
from app.core.errors import ValidationError, NotFoundError
from app.utils.ids import generate_prefixed_id
from app.core.logging import get_logger

settings = get_settings()
logger = get_logger(__name__)

# Allowed file types
ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/jpg", "image/webp"}


class MediaService:
    """Service for media upload and management."""

    def __init__(self):
        """Initialize media service."""
        # TODO: Initialize GCS client
        # from google.cloud import storage
        # self.storage_client = storage.Client()
        # self.bucket = self.storage_client.bucket(settings.gcs_bucket)
        pass

    async def init_upload(
        self,
        user_id: str,
        file_type: str,
        file_size: int,
        file_name: Optional[str] = None
    ) -> dict:
        """
        Initialize media upload and generate signed URL.

        Args:
            user_id: User ID
            file_type: MIME type
            file_size: File size in bytes
            file_name: Original filename

        Returns:
            Media ID and signed upload URL

        Raises:
            ValidationError: If file type or size invalid
        """
        # Validate file type
        if file_type not in ALLOWED_IMAGE_TYPES:
            raise ValidationError(
                message="Invalid file type",
                details={"allowed_types": list(ALLOWED_IMAGE_TYPES)}
            )

        # Validate file size
        max_size = settings.max_image_size_mb * 1024 * 1024
        if file_size > max_size:
            raise ValidationError(
                message=f"File size exceeds maximum of {settings.max_image_size_mb}MB",
                details={"max_size_mb": settings.max_image_size_mb}
            )

        # Generate media ID and path
        media_id = generate_prefixed_id("media")
        extension = file_type.split("/")[1]
        gcs_path = f"users/{user_id}/media/{media_id}.{extension}"

        # TODO: Generate signed URL for GCS upload
        # blob = self.bucket.blob(gcs_path)
        # signed_url = blob.generate_signed_url(
        #     version="v4",
        #     expiration=timedelta(minutes=15),
        #     method="PUT",
        #     content_type=file_type
        # )

        # Mock signed URL
        signed_url = f"https://storage.googleapis.com/{settings.gcs_bucket}/{gcs_path}?upload_token=mock"

        # TODO: Save media metadata to database
        # media_metadata = {
        #     "media_id": media_id,
        #     "user_id": user_id,
        #     "file_name": file_name,
        #     "file_type": file_type,
        #     "file_size": file_size,
        #     "gcs_path": gcs_path,
        #     "status": "pending",
        #     "created_at": datetime.utcnow()
        # }
        # await self.media_repo.create_media(media_metadata)

        logger.info(f"Media upload initiated: {media_id} for user {user_id}")

        return {
            "media_id": media_id,
            "upload_url": signed_url,
            "method": "PUT",
            "headers": {
                "Content-Type": file_type
            },
            "expires_in": 900
        }

    async def commit_upload(self, media_id: str, user_id: str) -> dict:
        """
        Confirm upload completion.

        Args:
            media_id: Media ID
            user_id: User ID

        Returns:
            Media status

        Raises:
            NotFoundError: If media not found
            ValidationError: If media not in pending state
        """
        # TODO: Verify upload in GCS
        # TODO: Update status to 'ready'

        logger.info(f"Media upload committed: {media_id}")

        return {
            "media_id": media_id,
            "status": "ready"
        }

    async def get_download_url(self, media_id: str, user_id: str) -> dict:
        """
        Get signed download URL for media.

        Args:
            media_id: Media ID
            user_id: User ID (for ownership check)

        Returns:
            Signed download URL

        Raises:
            NotFoundError: If media not found
        """
        # TODO: Get media from database and verify ownership
        # TODO: Generate signed download URL

        download_url = f"https://storage.googleapis.com/{settings.gcs_bucket}/mock-path/{media_id}?download_token=mock"

        return {
            "media_id": media_id,
            "download_url": download_url,
            "expires_in": 3600
        }

    async def delete_media(self, media_id: str, user_id: str) -> bool:
        """
        Delete media file.

        Args:
            media_id: Media ID
            user_id: User ID

        Returns:
            True if successful

        Raises:
            NotFoundError: If media not found
        """
        # TODO: Get media and verify ownership
        # TODO: Delete from GCS
        # TODO: Delete from database

        logger.info(f"Media deleted: {media_id}")
        return True

    async def create_media_set(
        self,
        user_id: str,
        media_ids: List[str],
        set_type: str
    ) -> dict:
        """
        Create a media set (for lookaround analysis).

        Args:
            user_id: User ID
            media_ids: List of media IDs
            set_type: Type of set (e.g., "lookaround8")

        Returns:
            Media set details

        Raises:
            ValidationError: If media count doesn't match set type
        """
        # Validate count based on set type
        if set_type == "lookaround8" and len(media_ids) != 8:
            raise ValidationError(
                message="Lookaround8 requires exactly 8 images",
                details={"provided": len(media_ids), "required": 8}
            )

        # TODO: Verify all media IDs belong to user

        # Create media set
        set_id = generate_prefixed_id("mediaset")

        # TODO: Save to database
        # set_data = {
        #     "set_id": set_id,
        #     "user_id": user_id,
        #     "media_ids": media_ids,
        #     "set_type": set_type,
        #     "created_at": datetime.utcnow()
        # }
        # await self.media_repo.create_media_set(set_data)

        logger.info(f"Media set created: {set_id} with {len(media_ids)} images")

        return {
            "set_id": set_id,
            "media_count": len(media_ids),
            "set_type": set_type
        }

    async def get_media_set(self, set_id: str, user_id: str) -> dict:
        """
        Get media set details with download URLs.

        Args:
            set_id: Media set ID
            user_id: User ID

        Returns:
            Media set with URLs

        Raises:
            NotFoundError: If media set not found
        """
        # TODO: Get media set from database
        # TODO: Generate download URLs for all media

        raise NotFoundError("Media set", set_id)