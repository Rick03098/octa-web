"""
Feng Shui analysis models.
"""
from typing import Optional, Dict, Any, List, Literal
from datetime import datetime
from pydantic import BaseModel, Field, validator
from enum import Enum


class SceneType(str, Enum):
    """Types of Feng Shui analysis scenes."""
    WORKSPACE = "workspace"  # 工位风水
    FLOORPLAN = "floorplan"  # 户型风水
    LOOKAROUND8 = "lookaround8"  # 八方环扫


class JobStatus(str, Enum):
    """Analysis job status."""
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"


class CreateAnalysisJobRequest(BaseModel):
    """Create analysis job request."""
    scene_type: SceneType
    bazi_profile_id: str
    media_ids: Optional[List[str]] = Field(None, min_items=1, max_items=10)
    media_set_id: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = Field(default_factory=dict)

    @validator("media_set_id")
    def validate_media_inputs(cls, v, values):
        """Ensure either media_ids or media_set_id is provided."""
        if not v and not values.get("media_ids"):
            raise ValueError("Either media_ids or media_set_id must be provided")
        if v and values.get("media_ids"):
            raise ValueError("Cannot provide both media_ids and media_set_id")
        return v


class AnalysisJob(BaseModel):
    """Analysis job model."""
    job_id: str
    user_id: str
    scene_type: SceneType
    bazi_profile_id: str
    media_ids: Optional[List[str]]
    media_set_id: Optional[str]
    status: JobStatus
    result_id: Optional[str] = None
    error_message: Optional[str] = None
    created_at: datetime
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    metadata: Dict[str, Any] = Field(default_factory=dict)


class WorkspaceAnalysisDetails(BaseModel):
    """Detailed workspace Feng Shui analysis results."""
    # Desk Position Analysis (办公桌分析)
    desk_position: Dict[str, Any] = Field(..., description="Desk position evaluation")
    facing_direction: str = Field(..., description="Desk facing direction")
    command_position_score: float = Field(..., ge=0, le=100, description="Command position score")
    back_support_score: float = Field(..., ge=0, le=100, description="Back support score")

    # Energy Flow (气流分析)
    energy_flow: Dict[str, Any] = Field(..., description="Energy flow patterns")
    has_door_alignment: bool = Field(..., description="Direct door-desk alignment")
    has_window_glare: bool = Field(..., description="Window glare issues")
    has_sharp_corners: bool = Field(..., description="Sharp corner sha")

    # Element Analysis (五行分析)
    element_balance: Dict[str, float] = Field(..., description="Five elements distribution")
    missing_elements: List[str] = Field(..., description="Missing elements")
    excess_elements: List[str] = Field(..., description="Excess elements")

    # Compatibility Score (适配度)
    bazi_compatibility_score: float = Field(..., ge=0, le=100, description="Bazi compatibility")
    overall_score: float = Field(..., ge=0, le=100, description="Overall Feng Shui score")


class FengShuiRecommendation(BaseModel):
    """Feng Shui improvement recommendation."""
    category: str = Field(..., description="Recommendation category")
    priority: Literal["high", "medium", "low"]
    title: str
    description: str
    expected_improvement: str
    implementation_tips: List[str]


class AnalysisResult(BaseModel):
    """Complete analysis result."""
    result_id: str
    job_id: str
    user_id: str
    scene_type: SceneType
    bazi_profile_id: str

    # Core Analysis
    overall_score: float = Field(..., ge=0, le=100)
    summary: str = Field(..., max_length=500)

    # Detailed Analysis (varies by scene_type)
    details: Dict[str, Any]  # WorkspaceAnalysisDetails for workspace

    # Recommendations
    recommendations: List[FengShuiRecommendation]

    # Lucky Elements Integration
    lucky_elements_present: List[str]
    unlucky_elements_present: List[str]
    suggested_colors: List[str]
    suggested_items: List[str]

    # Metadata
    analysis_version: str = "1.0"
    created_at: datetime
    processing_time_seconds: float


class AnalysisReport(BaseModel):
    """User-facing analysis report."""
    report_id: str
    user_id: str
    scene_type: SceneType
    title: str
    summary: str
    overall_score: float
    key_findings: List[str]
    recommendations: List[FengShuiRecommendation]
    created_at: datetime
    is_shared: bool = False
    share_url: Optional[str] = None
    view_count: int = 0


class AnalysisJobResponse(BaseModel):
    """Analysis job response."""
    job_id: str
    status: JobStatus
    scene_type: SceneType
    result_id: Optional[str]
    created_at: datetime
    completed_at: Optional[datetime]


class AnalysisResultResponse(BaseModel):
    """Analysis result response (varies by subscription)."""
    result_id: str
    overall_score: float
    summary: str
    key_findings: List[str]
    recommendations: List[FengShuiRecommendation]
    # Pro users get additional fields
    details: Optional[Dict[str, Any]] = None
    lucky_elements_analysis: Optional[Dict[str, Any]] = None
    advanced_recommendations: Optional[List[FengShuiRecommendation]] = None