"""
Workspace Feng Shui analysis pipeline.
"""
import json
from typing import Dict, Any, Optional, List
from datetime import datetime
from app.models.analysis import (
    AnalysisJob,
    AnalysisResult,
    WorkspaceAnalysisDetails,
    FengShuiRecommendation,
    JobStatus
)
from app.services.bazi_service import BaziService
from app.prompts.workspace_prompts import WorkspaceAnalysisPrompts
from app.core.logging import get_logger
from app.utils.ids import generate_prefixed_id

logger = get_logger(__name__)


class WorkspaceAnalysisPipeline:
    """
    Pipeline for analyzing workspace Feng Shui.
    """

    def __init__(self):
        """Initialize the workspace analysis pipeline."""
        self.bazi_service = BaziService()
        self.prompt_manager = WorkspaceAnalysisPrompts()

    async def analyze(
        self,
        job: AnalysisJob,
        image_url: str,
        bazi_profile: Dict[str, Any],
        language: str = "zh"
    ) -> AnalysisResult:
        """
        Analyze workspace Feng Shui.

        Args:
            job: Analysis job
            image_url: URL of workspace image
            bazi_profile: User's Bazi profile data
            language: Language for analysis

        Returns:
            AnalysisResult with workspace analysis
        """
        try:
            start_time = datetime.utcnow()

            # 1. Prepare Bazi data for prompt
            bazi_data = self._prepare_bazi_data(bazi_profile)

            # 2. Get analysis prompt
            prompt = self.prompt_manager.get_workspace_analysis_prompt(
                bazi_data=bazi_data,
                language=language,
                analysis_type="full"
            )

            # 3. Call AI model for analysis (placeholder for now)
            # In production, this would call Vertex AI or another LLM
            analysis_response = await self._call_ai_model(prompt, image_url)

            # 4. Parse AI response
            analysis_data = self._parse_ai_response(analysis_response)

            # 5. Create detailed analysis
            details = WorkspaceAnalysisDetails(
                desk_position=analysis_data.get("desk_position", {}),
                facing_direction=analysis_data.get("desk_position", {}).get("facing", "unknown"),
                command_position_score=analysis_data.get("desk_position", {}).get("score", 50),
                back_support_score=analysis_data.get("desk_position", {}).get("back_support_score", 50),

                energy_flow=analysis_data.get("energy_flow", {}),
                has_door_alignment=analysis_data.get("energy_flow", {}).get("has_door_alignment", False),
                has_window_glare=analysis_data.get("energy_flow", {}).get("has_window_glare", False),
                has_sharp_corners=analysis_data.get("energy_flow", {}).get("has_sharp_corners", False),

                element_balance=analysis_data.get("element_balance", {}).get("current_elements", {}),
                missing_elements=analysis_data.get("element_balance", {}).get("missing_elements", []),
                excess_elements=analysis_data.get("element_balance", {}).get("excess_elements", []),

                bazi_compatibility_score=analysis_data.get("element_balance", {}).get("compatibility_score", 50),
                overall_score=analysis_data.get("overall_score", 50)
            )

            # 6. Create recommendations
            recommendations = self._create_recommendations(analysis_data.get("recommendations", []))

            # 7. Calculate processing time
            processing_time = (datetime.utcnow() - start_time).total_seconds()

            # 8. Create and return result
            result = AnalysisResult(
                result_id=generate_prefixed_id("result"),
                job_id=job.job_id,
                user_id=job.user_id,
                scene_type=job.scene_type,
                bazi_profile_id=job.bazi_profile_id,
                overall_score=details.overall_score,
                summary=analysis_data.get("summary", "工位风水分析完成"),
                details=details.dict(),
                recommendations=recommendations,
                lucky_elements_present=bazi_data.get("lucky_elements", []),
                unlucky_elements_present=bazi_data.get("unlucky_elements", []),
                suggested_colors=self._get_suggested_colors(bazi_data.get("lucky_elements", [])),
                suggested_items=self._get_suggested_items(bazi_data.get("lucky_elements", [])),
                analysis_version="1.0",
                created_at=datetime.utcnow(),
                processing_time_seconds=processing_time
            )

            logger.info(f"Workspace analysis completed for job {job.job_id}")
            return result

        except Exception as e:
            logger.error(f"Workspace analysis failed for job {job.job_id}: {str(e)}")
            raise

    def _prepare_bazi_data(self, bazi_profile: Dict[str, Any]) -> Dict[str, Any]:
        """Prepare Bazi data for prompt."""
        chart = bazi_profile.get("chart", {})

        return {
            "year_gan": chart.get("year_pillar", {}).get("heavenly_stem", ""),
            "year_zhi": chart.get("year_pillar", {}).get("earthly_branch", ""),
            "month_gan": chart.get("month_pillar", {}).get("heavenly_stem", ""),
            "month_zhi": chart.get("month_pillar", {}).get("earthly_branch", ""),
            "day_gan": chart.get("day_pillar", {}).get("heavenly_stem", ""),
            "day_zhi": chart.get("day_pillar", {}).get("earthly_branch", ""),
            "hour_gan": chart.get("hour_pillar", {}).get("heavenly_stem", ""),
            "hour_zhi": chart.get("hour_pillar", {}).get("earthly_branch", ""),
            "day_master": chart.get("day_master", ""),
            "elements": chart.get("elements", {}),
            "lucky_elements": bazi_profile.get("lucky_elements", []),
            "unlucky_elements": bazi_profile.get("unlucky_elements", []),
            "lucky_directions": bazi_profile.get("lucky_directions", []),
            "lucky_colors": bazi_profile.get("lucky_colors", [])
        }

    async def _call_ai_model(self, prompt: str, image_url: str) -> str:
        """
        Call AI model for analysis.

        This is a placeholder - in production, this would call Vertex AI or another LLM.
        """
        # TODO: Integrate with actual AI service (Vertex AI, OpenAI, etc.)

        # For now, return a mock response
        mock_response = {
            "overall_score": 75,
            "desk_position": {
                "score": 70,
                "description": "办公桌位置基本合理，背后有墙但缺少支撑感",
                "issues": ["背后缺少高背椅或书柜支撑", "正对窗户可能造成注意力分散"]
            },
            "element_balance": {
                "current_elements": {"wood": 30, "fire": 10, "earth": 20, "metal": 25, "water": 15},
                "compatibility_score": 65,
                "missing_elements": ["fire"],
                "excess_elements": ["wood"]
            },
            "energy_flow": {
                "score": 80,
                "positive_aspects": ["空间开阔", "光线充足"],
                "negative_aspects": ["缺少植物调节气场", "线路杂乱影响能量流动"]
            },
            "recommendations": [
                {
                    "category": "placement",
                    "priority": "high",
                    "title": "添加背后支撑",
                    "description": "在座椅后方放置书柜或高大的植物，增强靠山之势",
                    "expected_benefit": "提升事业稳定性和贵人运"
                },
                {
                    "category": "decoration",
                    "priority": "medium",
                    "title": "增加火元素装饰",
                    "description": "添加红色或紫色的装饰品，如台灯或艺术品",
                    "expected_benefit": "平衡五行，激发创造力和热情"
                }
            ],
            "summary": "工位整体风水良好，主要需要加强背后支撑和五行平衡。建议增加火元素装饰并整理线路以优化能量流动。"
        }

        return json.dumps(mock_response, ensure_ascii=False)

    def _parse_ai_response(self, response_text: str) -> Dict[str, Any]:
        """Parse AI model response."""
        try:
            return json.loads(response_text)
        except json.JSONDecodeError:
            # Try to extract JSON from response
            import re
            json_match = re.search(r'\{[\s\S]*\}', response_text)
            if json_match:
                return json.loads(json_match.group())
            else:
                logger.error(f"Failed to parse AI response: {response_text[:200]}")
                return {}

    def _create_recommendations(self, recommendations_data: List[Dict]) -> List[FengShuiRecommendation]:
        """Create FengShuiRecommendation objects from data."""
        recommendations = []

        for rec_data in recommendations_data:
            recommendations.append(
                FengShuiRecommendation(
                    category=rec_data.get("category", "general"),
                    priority=rec_data.get("priority", "medium"),
                    title=rec_data.get("title", ""),
                    description=rec_data.get("description", ""),
                    expected_improvement=rec_data.get("expected_benefit", ""),
                    implementation_tips=rec_data.get("tips", [])
                )
            )

        return recommendations

    def _get_suggested_colors(self, lucky_elements: List[str]) -> List[str]:
        """Get suggested colors based on lucky elements."""
        element_colors = {
            "wood": ["green", "cyan", "turquoise"],
            "fire": ["red", "orange", "purple"],
            "earth": ["yellow", "brown", "beige"],
            "metal": ["white", "silver", "gold"],
            "water": ["black", "blue", "gray"]
        }

        colors = []
        for element in lucky_elements:
            colors.extend(element_colors.get(element, []))

        return list(set(colors))

    def _get_suggested_items(self, lucky_elements: List[str]) -> List[str]:
        """Get suggested items based on lucky elements."""
        element_items = {
            "wood": ["植物", "木质装饰", "绿色画作"],
            "fire": ["台灯", "红色装饰", "三角形摆件"],
            "earth": ["陶瓷", "石头", "方形物品"],
            "metal": ["金属摆件", "圆形装饰", "白色物品"],
            "water": ["水晶", "鱼缸", "流线型装饰"]
        }

        items = []
        for element in lucky_elements:
            items.extend(element_items.get(element, []))

        return items