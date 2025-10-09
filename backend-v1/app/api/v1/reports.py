"""
Analysis reports API endpoints.
"""
from typing import Annotated, List, Optional
from fastapi import APIRouter, Depends, Query, status

from app.api.deps import get_current_verified_user, get_optional_current_user
from app.models.auth import UserSession
from app.core.errors import NotFoundError, ForbiddenError
from app.utils.ids import generate_prefixed_id
from app.core.logging import get_logger
from datetime import datetime

router = APIRouter()
logger = get_logger(__name__)


@router.get("/")
async def list_reports(
    current_user: Annotated[UserSession, Depends(get_current_verified_user)],
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0)
):
    """
    List user's analysis reports.

    Args:
        limit: Number of reports to return
        offset: Offset for pagination

    Returns:
        List of reports
    """
    # TODO: Get reports from database
    # reports = await reports_repo.get_user_reports(
    #     user_id=current_user.user_id,
    #     limit=limit,
    #     offset=offset
    # )

    # Mock response
    reports = []

    return {
        "reports": reports,
        "total": 0,
        "limit": limit,
        "offset": offset
    }


@router.get("/{report_id}")
async def get_report(
    report_id: str,
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Get report details.

    Free users see summary only, Pro users see full report.

    Args:
        report_id: Report ID

    Returns:
        Report details
    """
    # TODO: Get report from database
    # report = await reports_repo.get_report(report_id)

    # if not report or report.user_id != current_user.user_id:
    #     raise NotFoundError("Report", report_id)

    # Mock report
    report = {
        "report_id": report_id,
        "user_id": current_user.user_id,
        "scene_type": "workspace",
        "title": "工位风水分析报告",
        "summary": "您的工位风水整体良好，建议优化几个关键点以提升运势。",
        "overall_score": 75,
        "key_findings": [
            "办公桌位置基本合理",
            "光线充足但需调节",
            "缺少火元素装饰"
        ],
        "recommendations": [
            {
                "category": "placement",
                "priority": "high",
                "title": "添加背后支撑",
                "description": "在座椅后方放置书柜或高大植物"
            }
        ],
        "created_at": datetime.utcnow(),
        "is_shared": False,
        "view_count": 1
    }

    # Filter based on subscription
    if current_user.subscription_tier == "free":
        # Free users only see summary
        return {
            "report_id": report["report_id"],
            "title": report["title"],
            "summary": report["summary"],
            "overall_score": report["overall_score"],
            "key_findings": report["key_findings"][:2],  # Limited findings
            "created_at": report["created_at"],
            "upgrade_required": True
        }
    else:
        # Pro users see full report
        return report


@router.delete("/{report_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_report(
    report_id: str,
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Delete (soft delete) a report.

    Args:
        report_id: Report ID
    """
    # TODO: Soft delete report
    # report = await reports_repo.get_report(report_id)

    # if not report or report.user_id != current_user.user_id:
    #     raise NotFoundError("Report", report_id)

    # await reports_repo.soft_delete_report(report_id)

    logger.info(f"Report deleted: {report_id}")
    return None


@router.post("/{report_id}/share")
async def create_share_link(
    report_id: str,
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Generate a shareable link for the report.

    Args:
        report_id: Report ID

    Returns:
        Share link details
    """
    # TODO: Get report and verify ownership
    # report = await reports_repo.get_report(report_id)

    # if not report or report.user_id != current_user.user_id:
    #     raise NotFoundError("Report", report_id)

    # Generate share token
    share_token = generate_prefixed_id("share")

    # TODO: Save share link
    # share_data = {
    #     "share_token": share_token,
    #     "report_id": report_id,
    #     "created_by": current_user.user_id,
    #     "created_at": datetime.utcnow(),
    #     "expires_at": None,  # Optional expiration
    #     "view_count": 0
    # }
    # await reports_repo.create_share_link(share_data)

    # TODO: Update report is_shared status
    # await reports_repo.update_report(report_id, is_shared=True)

    share_url = f"https://app.octa.ai/shared/{share_token}"

    logger.info(f"Share link created for report: {report_id}")

    return {
        "share_token": share_token,
        "share_url": share_url,
        "expires_at": None
    }


@router.delete("/{report_id}/share", status_code=status.HTTP_204_NO_CONTENT)
async def revoke_share_link(
    report_id: str,
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Revoke share link for report.

    Args:
        report_id: Report ID
    """
    # TODO: Verify ownership and revoke share link
    # report = await reports_repo.get_report(report_id)

    # if not report or report.user_id != current_user.user_id:
    #     raise NotFoundError("Report", report_id)

    # await reports_repo.delete_share_links(report_id)
    # await reports_repo.update_report(report_id, is_shared=False)

    logger.info(f"Share link revoked for report: {report_id}")
    return None


@router.get("/shared/{share_token}")
async def get_shared_report(
    share_token: str,
    current_user: Annotated[Optional[UserSession], Depends(get_optional_current_user)]
):
    """
    Get publicly shared report (no authentication required).

    Args:
        share_token: Share token

    Returns:
        Shared report (limited info)
    """
    # TODO: Get share link and report
    # share_link = await reports_repo.get_share_link(share_token)

    # if not share_link:
    #     raise NotFoundError("Shared report", share_token)

    # # Check if expired
    # if share_link.expires_at and share_link.expires_at < datetime.utcnow():
    #     raise ForbiddenError("Share link has expired")

    # report = await reports_repo.get_report(share_link.report_id)

    # # Increment view count
    # await reports_repo.increment_share_view_count(share_token)
    # await reports_repo.increment_report_view_count(share_link.report_id)

    # Mock shared report (limited information)
    shared_report = {
        "report_id": "mock_report",
        "title": "工位风水分析报告",
        "summary": "这是一个分享的风水分析报告",
        "overall_score": 75,
        "key_findings": [
            "办公桌位置基本合理",
            "光线充足但需调节"
        ],
        "created_at": datetime.utcnow(),
        "is_shared": True,
        "disclaimer": "本报告仅供参考，不构成专业建议"
    }

    return shared_report