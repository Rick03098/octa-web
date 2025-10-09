"""
Media upload and management API endpoints.
"""
from typing import Annotated, Optional
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, status
from datetime import datetime, timedelta

from app.api.deps import get_current_verified_user
from app.models.auth import UserSession
from app.core.errors import ValidationError, NotFoundError
from app.core.config import get_settings
from app.utils.ids import generate_prefixed_id
from app.core.logging import get_logger

router = APIRouter()
logger = get_logger(__name__)
settings = get_settings()

# Allowed file types
ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/jpg", "image/webp"}
MAX_FILE_SIZE = settings.max_image_size_mb * 1024 * 1024  # Convert MB to bytes


@router.post("/:init")
async def init_media_upload(
    current_user: Annotated[UserSession, Depends(get_current_verified_user)],
    file_type: str = Form(...),
    file_size: int = Form(...),
    file_name: Optional[str] = Form(None)
):
    """
    Initialize media upload and get signed URL for direct upload to GCS.

    Args:
        file_type: MIME type of the file
        file_size: File size in bytes
        file_name: Original filename

    Returns:
        Media ID and signed upload URL
    """
    # Validate file type
    if file_type not in ALLOWED_IMAGE_TYPES:
        raise ValidationError(
            message="Invalid file type",
            details={"allowed_types": list(ALLOWED_IMAGE_TYPES)}
        )

    # Validate file size
    if file_size > MAX_FILE_SIZE:
        raise ValidationError(
            message=f"File size exceeds maximum of {settings.max_image_size_mb}MB",
            details={"max_size_mb": settings.max_image_size_mb}
        )

    # Generate media ID
    media_id = generate_prefixed_id("media")

    # Generate GCS path
    extension = file_type.split("/")[1]
    gcs_path = f"users/{current_user.user_id}/media/{media_id}.{extension}"

    # TODO: Generate signed URL for GCS upload
    # from google.cloud import storage
    # storage_client = storage.Client()
    # bucket = storage_client.bucket(settings.gcs_bucket)
    # blob = bucket.blob(gcs_path)
    # signed_url = blob.generate_signed_url(
    #     version="v4",
    #     expiration=timedelta(minutes=15),
    #     method="PUT",
    #     content_type=file_type
    # )

    signed_url = f"https://storage.googleapis.com/{settings.gcs_bucket}/{gcs_path}?upload_token=mock"

    # Store media metadata (pending state)
    media_metadata = {
        "media_id": media_id,
        "user_id": current_user.user_id,
        "file_name": file_name,
        "file_type": file_type,
        "file_size": file_size,
        "gcs_path": gcs_path,
        "status": "pending",  # pending, ready, failed
        "created_at": datetime.utcnow()
    }

    # TODO: Save metadata to database
    # await media_repo.create_media(media_metadata)

    logger.info(f"Media upload initiated: {media_id} for user {current_user.user_id}")

    return {
        "media_id": media_id,
        "upload_url": signed_url,
        "method": "PUT",
        "headers": {
            "Content-Type": file_type
        },
        "expires_in": 900  # 15 minutes
    }


@router.post("/:commit")
async def commit_media_upload(
    current_user: Annotated[UserSession, Depends(get_current_verified_user)],
    media_id: str = Form(...)
):
    """
    Confirm media upload completion and mark as ready.

    Args:
        media_id: Media ID

    Returns:
        Media status
    """
    # TODO: Verify upload completion
    # - Check if file exists in GCS
    # - Validate file integrity
    # - Update status to 'ready'

    # TODO: Get media from database
    # media = await media_repo.get_media(media_id)

    # if not media or media.user_id != current_user.user_id:
    #     raise NotFoundError("Media", media_id)

    # if media.status != "pending":
    #     raise ValidationError("Media is not in pending state")

    # TODO: Update status
    # await media_repo.update_media_status(media_id, "ready")

    logger.info(f"Media upload committed: {media_id}")

    return {
        "media_id": media_id,
        "status": "ready",
        "message": "Upload confirmed successfully"
    }


@router.get("/{media_id}")
async def get_media_download_url(
    media_id: str,
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Get signed download URL for media.

    Args:
        media_id: Media ID

    Returns:
        Signed download URL
    """
    # TODO: Get media from database
    # media = await media_repo.get_media(media_id)

    # if not media or media.user_id != current_user.user_id:
    #     raise NotFoundError("Media", media_id)

    # if media.status != "ready":
    #     raise ValidationError("Media is not ready for download")

    # TODO: Generate signed download URL
    # from google.cloud import storage
    # storage_client = storage.Client()
    # bucket = storage_client.bucket(settings.gcs_bucket)
    # blob = bucket.blob(media.gcs_path)
    # download_url = blob.generate_signed_url(
    #     version="v4",
    #     expiration=timedelta(minutes=60),
    #     method="GET"
    # )

    download_url = f"https://storage.googleapis.com/{settings.gcs_bucket}/mock-path/{media_id}?download_token=mock"

    return {
        "media_id": media_id,
        "download_url": download_url,
        "expires_in": 3600  # 1 hour
    }


@router.delete("/{media_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_media(
    media_id: str,
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Delete media file.

    Args:
        media_id: Media ID
    """
    # TODO: Get media from database
    # media = await media_repo.get_media(media_id)

    # if not media or media.user_id != current_user.user_id:
    #     raise NotFoundError("Media", media_id)

    # TODO: Delete from GCS
    # from google.cloud import storage
    # storage_client = storage.Client()
    # bucket = storage_client.bucket(settings.gcs_bucket)
    # blob = bucket.blob(media.gcs_path)
    # blob.delete()

    # TODO: Delete from database
    # await media_repo.delete_media(media_id)

    logger.info(f"Media deleted: {media_id}")

    return None


@router.post("/sets", status_code=status.HTTP_201_CREATED)
async def create_media_set(
    current_user: Annotated[UserSession, Depends(get_current_verified_user)],
    media_ids: str = Form(...),  # Comma-separated media IDs
    set_type: str = Form(...)  # e.g., "lookaround8"
):
    """
    Create a media set (for lookaround 8-direction analysis).

    Args:
        media_ids: Comma-separated media IDs
        set_type: Type of media set

    Returns:
        Media set ID
    """
    # Parse media IDs
    media_id_list = [id.strip() for id in media_ids.split(",") if id.strip()]

    # Validate count based on set type
    if set_type == "lookaround8" and len(media_id_list) != 8:
        raise ValidationError(
            message="Lookaround8 requires exactly 8 images",
            details={"provided": len(media_id_list), "required": 8}
        )

    # TODO: Verify all media IDs belong to user and are ready
    # for media_id in media_id_list:
    #     media = await media_repo.get_media(media_id)
    #     if not media or media.user_id != current_user.user_id:
    #         raise NotFoundError("Media", media_id)

    # Create media set
    set_id = generate_prefixed_id("mediaset")

    set_data = {
        "set_id": set_id,
        "user_id": current_user.user_id,
        "media_ids": media_id_list,
        "set_type": set_type,
        "created_at": datetime.utcnow()
    }

    # TODO: Save to database
    # await media_repo.create_media_set(set_data)

    logger.info(f"Media set created: {set_id} with {len(media_id_list)} images")

    return {
        "set_id": set_id,
        "media_count": len(media_id_list),
        "set_type": set_type
    }


@router.get("/sets/{set_id}")
async def get_media_set(
    set_id: str,
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Get media set details.

    Args:
        set_id: Media set ID

    Returns:
        Media set with download URLs
    """
    # TODO: Get media set from database
    # media_set = await media_repo.get_media_set(set_id)

    # if not media_set or media_set.user_id != current_user.user_id:
    #     raise NotFoundError("Media set", set_id)

    raise NotFoundError("Media set", set_id)