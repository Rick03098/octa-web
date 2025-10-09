"""
Analysis dispatcher to route different scene types to appropriate pipelines.
"""
from typing import Dict, Any, Optional
from app.models.analysis import SceneType, AnalysisJob, AnalysisResult
from app.services.analysis.workspace_pipeline import WorkspaceAnalysisPipeline
from app.services.analysis.floorplan_pipeline import FloorplanAnalysisPipeline
from app.services.analysis.lookaround8_pipeline import Lookaround8AnalysisPipeline
from app.core.logging import get_logger

logger = get_logger(__name__)


class AnalysisDispatcher:
    """
    Dispatcher for routing analysis jobs to appropriate pipelines.
    """

    def __init__(self):
        """Initialize the dispatcher with available pipelines."""
        self.pipelines = {
            SceneType.WORKSPACE: WorkspaceAnalysisPipeline(),
            SceneType.FLOORPLAN: FloorplanAnalysisPipeline(),
            SceneType.LOOKAROUND8: Lookaround8AnalysisPipeline(),
        }

    async def dispatch(
        self,
        job: AnalysisJob,
        bazi_profile: Dict[str, Any],
        media_urls: list[str],
        language: str = "zh"
    ) -> AnalysisResult:
        """
        Dispatch analysis job to appropriate pipeline.

        Args:
            job: Analysis job
            bazi_profile: User's Bazi profile
            media_urls: URLs of media files
            language: Language for analysis

        Returns:
            Analysis result

        Raises:
            ValueError: If scene type is not supported
        """
        logger.info(f"Dispatching analysis job {job.job_id} for scene type {job.scene_type}")

        # Get appropriate pipeline
        pipeline = self.pipelines.get(job.scene_type)
        if not pipeline:
            raise ValueError(f"Unsupported scene type: {job.scene_type}")

        # Execute analysis based on scene type
        if job.scene_type == SceneType.WORKSPACE:
            # Workspace expects single image
            if not media_urls:
                raise ValueError("No media URL provided for workspace analysis")

            result = await pipeline.analyze(
                job=job,
                image_url=media_urls[0],
                bazi_profile=bazi_profile,
                language=language
            )

        elif job.scene_type == SceneType.FLOORPLAN:
            # Floorplan analysis
            if not media_urls:
                raise ValueError("No media URL provided for floorplan analysis")

            result = await pipeline.analyze(
                job=job,
                image_url=media_urls[0],
                bazi_profile=bazi_profile,
                language=language
            )

        elif job.scene_type == SceneType.LOOKAROUND8:
            # 8-direction analysis - requires exactly 8 images
            if len(media_urls) != 8:
                raise ValueError(f"Lookaround8 requires exactly 8 images, got {len(media_urls)}")

            result = await pipeline.analyze(
                job=job,
                image_urls=media_urls,
                bazi_profile=bazi_profile,
                language=language
            )

        else:
            raise ValueError(f"Unknown scene type: {job.scene_type}")

        logger.info(f"Analysis completed for job {job.job_id}")
        return result

    def is_supported(self, scene_type: SceneType) -> bool:
        """
        Check if a scene type is supported.

        Args:
            scene_type: Scene type to check

        Returns:
            True if supported, False otherwise
        """
        return scene_type in self.pipelines