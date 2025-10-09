"""
Feng Shui analysis API endpoints.
"""
from typing import Annotated, Optional
from fastapi import APIRouter, Depends, UploadFile, File, Form, BackgroundTasks
from app.api.deps import get_current_verified_user, rate_limit_analysis
from app.models.auth import UserSession
from app.models.analysis import (
    CreateAnalysisJobRequest,
    AnalysisJobResponse,
    AnalysisResultResponse,
    JobStatus
)
from app.services.analysis.dispatcher import AnalysisDispatcher
from app.core.errors import NotFoundError, ValidationError, QuotaExceededError
from app.utils.ids import generate_prefixed_id
from datetime import datetime

router = APIRouter()


@router.post("/jobs", response_model=AnalysisJobResponse)
async def create_analysis_job(
    current_user: Annotated[UserSession, Depends(get_current_verified_user)],
    background_tasks: BackgroundTasks,
    scene_type: str = Form(...),
    bazi_profile_id: str = Form(...),
    media_file: Optional[UploadFile] = File(None),
    media_ids: Optional[str] = Form(None),  # Comma-separated IDs
    media_set_id: Optional[str] = Form(None),
    _: None = Depends(rate_limit_analysis)
):
    """
    Create a new Feng Shui analysis job.

    Args:
        scene_type: Type of analysis (workspace, floorplan, lookaround8)
        bazi_profile_id: ID of user's Bazi profile
        media_file: Direct upload of image (for workspace/floorplan)
        media_ids: Pre-uploaded media IDs (comma-separated)
        media_set_id: Media set ID (for lookaround8)

    Returns:
        Analysis job response with job ID and status
    """
    # Validate scene type
    if scene_type not in ["workspace", "floorplan", "lookaround8"]:
        raise ValidationError(
            message="Invalid scene type",
            details={"valid_types": ["workspace", "floorplan", "lookaround8"]}
        )

    # Check user quota for free tier
    if current_user.subscription_tier == "free":
        # TODO: Check monthly analysis count from database
        analysis_count = 0  # Placeholder
        if analysis_count >= 3:
            raise QuotaExceededError(resource="workspace analysis", limit=3)

    # Parse media IDs if provided
    media_id_list = None
    if media_ids:
        media_id_list = [id.strip() for id in media_ids.split(",") if id.strip()]

    # Validate media input
    if not media_file and not media_id_list and not media_set_id:
        raise ValidationError("No media provided. Upload a file or provide media IDs")

    if scene_type == "lookaround8" and not media_set_id:
        raise ValidationError("Lookaround analysis requires media_set_id")

    if scene_type in ["workspace", "floorplan"] and not (media_file or media_id_list):
        raise ValidationError(f"{scene_type} analysis requires an image")

    # Handle direct file upload
    if media_file:
        # TODO: Upload to GCS and get media ID
        # For now, create a mock media ID
        uploaded_media_id = generate_prefixed_id("media")
        media_id_list = [uploaded_media_id]

    # Create analysis job
    job_id = generate_prefixed_id("job")
    job_data = {
        "job_id": job_id,
        "user_id": current_user.user_id,
        "scene_type": scene_type,
        "bazi_profile_id": bazi_profile_id,
        "media_ids": media_id_list,
        "media_set_id": media_set_id,
        "status": JobStatus.PENDING,
        "created_at": datetime.utcnow()
    }

    # TODO: Save job to database
    # await analysis_repo.create_job(job_data)

    # Start analysis in background
    background_tasks.add_task(
        run_analysis,
        job_id=job_id,
        user_id=current_user.user_id,
        scene_type=scene_type,
        bazi_profile_id=bazi_profile_id,
        media_ids=media_id_list,
        media_set_id=media_set_id
    )

    return AnalysisJobResponse(
        job_id=job_id,
        status=JobStatus.PENDING,
        scene_type=scene_type,
        result_id=None,
        created_at=job_data["created_at"],
        completed_at=None
    )


@router.get("/jobs/{job_id}", response_model=AnalysisJobResponse)
async def get_analysis_job(
    job_id: str,
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Get analysis job status.

    Args:
        job_id: Job ID

    Returns:
        Job status and result ID if completed
    """
    # TODO: Get job from database
    # job = await analysis_repo.get_job(job_id)

    # Mock response for now
    job = {
        "job_id": job_id,
        "user_id": current_user.user_id,
        "status": JobStatus.COMPLETED,
        "scene_type": "workspace",
        "result_id": generate_prefixed_id("result"),
        "created_at": datetime.utcnow(),
        "completed_at": datetime.utcnow()
    }

    if not job or job["user_id"] != current_user.user_id:
        raise NotFoundError("Analysis job", job_id)

    return AnalysisJobResponse(
        job_id=job["job_id"],
        status=job["status"],
        scene_type=job["scene_type"],
        result_id=job.get("result_id"),
        created_at=job["created_at"],
        completed_at=job.get("completed_at")
    )


@router.get("/results/{result_id}", response_model=AnalysisResultResponse)
async def get_analysis_result(
    result_id: str,
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Get analysis result.

    Args:
        result_id: Result ID

    Returns:
        Analysis result (limited for free users)
    """
    # TODO: Get result from database
    # result = await analysis_repo.get_result(result_id)

    # Mock response
    result = {
        "result_id": result_id,
        "user_id": current_user.user_id,
        "overall_score": 75,
        "summary": "工位风水整体良好，建议增强背后支撑并优化五行平衡。",
        "key_findings": [
            "办公桌位置基本合理",
            "光线充足但需要调节",
            "缺少火元素装饰"
        ],
        "recommendations": [
            {
                "category": "placement",
                "priority": "high",
                "title": "添加背后支撑",
                "description": "在座椅后方放置书柜或高大植物",
                "expected_improvement": "提升事业稳定性",
                "implementation_tips": ["选择稳固的家具", "避免镜子在背后"]
            },
            {
                "category": "color",
                "priority": "medium",
                "title": "增加暖色调",
                "description": "添加红色或橙色装饰品",
                "expected_improvement": "激发创造力和热情",
                "implementation_tips": ["可选择红色台灯", "橙色抱枕或画作"]
            }
        ],
        "details": {
            "desk_position": {
                "score": 70,
                "description": "位置合理但可优化"
            },
            "element_balance": {
                "compatibility_score": 65,
                "missing_elements": ["fire"],
                "excess_elements": ["wood"]
            }
        },
        "lucky_elements_analysis": {
            "present": ["wood", "metal"],
            "missing": ["fire"]
        }
    }

    if not result or result["user_id"] != current_user.user_id:
        raise NotFoundError("Analysis result", result_id)

    # Prepare response based on subscription
    response = AnalysisResultResponse(
        result_id=result["result_id"],
        overall_score=result["overall_score"],
        summary=result["summary"],
        key_findings=result["key_findings"],
        recommendations=result["recommendations"][:2] if current_user.subscription_tier == "free" else result["recommendations"]
    )

    # Add pro-only fields
    if current_user.subscription_tier == "pro":
        response.details = result.get("details")
        response.lucky_elements_analysis = result.get("lucky_elements_analysis")
        response.advanced_recommendations = result.get("advanced_recommendations")

    return response


async def run_analysis(
    job_id: str,
    user_id: str,
    scene_type: str,
    bazi_profile_id: str,
    media_ids: Optional[list] = None,
    media_set_id: Optional[str] = None
):
    """
    Background task to run analysis.

    This would be better implemented with Cloud Tasks or Pub/Sub in production.
    """
    try:
        # Update job status to running
        # await analysis_repo.update_job_status(job_id, JobStatus.RUNNING)

        # Get Bazi profile
        # bazi_profile = await profiles_repo.get_profile(bazi_profile_id)

        # Dispatch to appropriate pipeline
        dispatcher = AnalysisDispatcher()
        # result = await dispatcher.dispatch(...)

        # Save result
        # await analysis_repo.save_result(result)

        # Update job status to completed
        # await analysis_repo.update_job_status(job_id, JobStatus.COMPLETED, result.result_id)

        pass

    except Exception as e:
        # Update job status to failed
        # await analysis_repo.update_job_status(job_id, JobStatus.FAILED, error=str(e))
        pass