"""
Entitlements and subscription management API endpoints.
"""
from typing import Annotated
from fastapi import APIRouter, Depends, Request, HTTPException, status, Header
from datetime import datetime

from app.api.deps import get_current_verified_user
from app.models.auth import UserSession
from app.core.config import get_settings
from app.core.logging import get_logger

router = APIRouter()
logger = get_logger(__name__)
settings = get_settings()


@router.get("/me")
async def get_user_entitlements(
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Get current user's subscription status and entitlements.

    Returns:
        Subscription tier, limits, and usage
    """
    # TODO: Get actual subscription data from database
    # subscription = await entitlements_repo.get_subscription(current_user.user_id)

    # Mock entitlements
    if current_user.subscription_tier == "pro":
        return {
            "is_active": True,
            "plan": "pro",
            "expires_at": "2025-12-31T23:59:59Z",
            "limits": {
                "analysis_per_month": -1,  # Unlimited
                "chat_messages_per_day": -1,  # Unlimited
                "max_bazi_profiles": 5,
                "max_media_storage_mb": 1000,
                "advanced_features": True,
                "priority_support": True
            },
            "usage": {
                "analysis_this_month": 15,
                "chat_messages_today": 20,
                "bazi_profiles": 1,
                "media_storage_used_mb": 45
            },
            "features": [
                "unlimited_analysis",
                "ai_chat",
                "detailed_reports",
                "priority_processing",
                "export_pdf",
                "historical_comparison"
            ]
        }
    else:
        # Free tier
        return {
            "is_active": True,
            "plan": "free",
            "expires_at": None,
            "limits": {
                "analysis_per_month": settings.free_analysis_per_month,
                "chat_messages_per_day": 0,  # No chat for free
                "max_bazi_profiles": 1,
                "max_media_storage_mb": 50,
                "advanced_features": False,
                "priority_support": False
            },
            "usage": {
                "analysis_this_month": 2,
                "chat_messages_today": 0,
                "bazi_profiles": 1,
                "media_storage_used_mb": 12
            },
            "features": [
                "basic_analysis",
                "summary_reports"
            ],
            "upgrade_url": "https://app.octa.ai/pricing"
        }


@router.post("/refresh")
async def refresh_entitlements(
    current_user: Annotated[UserSession, Depends(get_current_verified_user)]
):
    """
    Manually refresh subscription status from payment provider.

    This is useful when user just subscribed and wants to see updated status.

    Returns:
        Updated entitlements
    """
    # TODO: Query RevenueCat or payment provider for latest status
    # subscriber_info = await revenuecat_service.get_subscriber_info(current_user.user_id)

    # TODO: Update local subscription data
    # await entitlements_repo.sync_subscription(current_user.user_id, subscriber_info)

    logger.info(f"Entitlements refreshed for user: {current_user.user_id}")

    # Return updated entitlements (same as GET /me)
    return {
        "message": "Entitlements refreshed successfully",
        "plan": current_user.subscription_tier,
        "synced_at": datetime.utcnow()
    }


@router.get("/offerings")
async def get_available_offerings():
    """
    Get available subscription offerings.

    This returns the current pricing and features for different tiers.
    Useful for paywall display.

    Returns:
        Available subscription packages
    """
    # In production, this might come from RevenueCat or database
    return {
        "offerings": [
            {
                "identifier": "monthly_pro",
                "plan": "pro",
                "billing_period": "monthly",
                "price": {
                    "amount": 9.99,
                    "currency": "USD",
                    "formatted": "$9.99/month"
                },
                "features": [
                    "Unlimited workspace analysis",
                    "Unlimited floorplan analysis",
                    "AI-powered chat assistant",
                    "Detailed PDF reports",
                    "Priority processing",
                    "Historical trend analysis",
                    "Multiple Bazi profiles"
                ],
                "trial": {
                    "available": True,
                    "duration_days": 7
                }
            },
            {
                "identifier": "yearly_pro",
                "plan": "pro",
                "billing_period": "yearly",
                "price": {
                    "amount": 99.99,
                    "currency": "USD",
                    "formatted": "$99.99/year"
                },
                "discount": {
                    "percentage": 17,
                    "description": "Save $20 compared to monthly"
                },
                "features": [
                    "All monthly features",
                    "17% discount",
                    "Extended cloud storage"
                ],
                "trial": {
                    "available": True,
                    "duration_days": 7
                }
            },
            {
                "identifier": "free",
                "plan": "free",
                "billing_period": None,
                "price": {
                    "amount": 0,
                    "currency": "USD",
                    "formatted": "Free"
                },
                "features": [
                    "3 workspace analyses per month",
                    "Basic reports",
                    "Community support"
                ],
                "trial": None
            }
        ],
        "current_user_plan": "free"  # Will be determined based on auth
    }


@router.post("/webhooks/revenuecat")
async def revenuecat_webhook(
    request: Request,
    revenuecat_signature: str = Header(None, alias="X-RevenueCat-Signature")
):
    """
    Handle webhooks from RevenueCat for subscription events.

    This endpoint is called by RevenueCat when subscription status changes.

    Events include:
    - INITIAL_PURCHASE
    - RENEWAL
    - CANCELLATION
    - BILLING_ISSUE
    - SUBSCRIBER_ALIAS

    Returns:
        Success response
    """
    # TODO: Verify webhook signature
    # if not revenuecat_signature:
    #     raise HTTPException(
    #         status_code=status.HTTP_401_UNAUTHORIZED,
    #         detail="Missing signature"
    #     )

    # Get webhook body
    body = await request.json()

    # TODO: Verify signature
    # webhook_secret = settings.revenuecat_webhook_secret
    # is_valid = verify_revenuecat_signature(body, revenuecat_signature, webhook_secret)
    # if not is_valid:
    #     raise HTTPException(
    #         status_code=status.HTTP_401_UNAUTHORIZED,
    #         detail="Invalid signature"
    #     )

    # Extract event data
    event_type = body.get("type")
    event_data = body.get("event", {})
    app_user_id = event_data.get("app_user_id")

    logger.info(f"RevenueCat webhook received: {event_type} for user {app_user_id}")

    # TODO: Process event based on type
    # if event_type == "INITIAL_PURCHASE":
    #     await entitlements_repo.activate_subscription(app_user_id, event_data)
    # elif event_type == "RENEWAL":
    #     await entitlements_repo.renew_subscription(app_user_id, event_data)
    # elif event_type == "CANCELLATION":
    #     await entitlements_repo.cancel_subscription(app_user_id, event_data)
    # elif event_type == "BILLING_ISSUE":
    #     await entitlements_repo.mark_billing_issue(app_user_id, event_data)

    return {"received": True}


@router.post("/webhooks/stripe")
async def stripe_webhook(
    request: Request,
    stripe_signature: str = Header(None, alias="Stripe-Signature")
):
    """
    Handle webhooks from Stripe (optional, for web payments).

    Args:
        request: Request with webhook payload
        stripe_signature: Stripe signature header

    Returns:
        Success response
    """
    # TODO: Implement Stripe webhook handling
    # Similar to RevenueCat but with Stripe event structure

    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Stripe webhooks not yet implemented"
    )