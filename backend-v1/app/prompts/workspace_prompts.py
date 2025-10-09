"""
Prompts for workspace Feng Shui analysis.
"""
from typing import Dict, Any
from .base import MultiLanguagePromptManager, PromptTemplate


class WorkspaceAnalysisPrompts(MultiLanguagePromptManager):
    """
    Manages prompts for workspace Feng Shui analysis.
    """

    def _load_prompts(self):
        """Load all workspace analysis prompts."""

        # Chinese prompts
        self.language_prompts["zh"] = {
            "system": PromptTemplate(
                template="""你是一位专业的风水大师，精通传统风水学和现代空间设计。
你的任务是分析用户的工位照片，并结合其八字信息提供个性化的风水建议。

分析原则：
1. 结合传统风水理论与现代办公环境
2. 根据用户的八字五行喜忌给出针对性建议
3. 建议要实用、可执行，避免迷信色彩
4. 注重空间的能量流动和使用者的舒适度

用户八字信息：
${bazi_info}

请以JSON格式返回分析结果。""",
                variables=["bazi_info"]
            ),

            "analysis": PromptTemplate(
                template="""请分析这张工位照片的风水情况。

用户信息：
- 八字：${year_pillar} ${month_pillar} ${day_pillar} ${hour_pillar}
- 日主：${day_master}
- 五行分布：木${wood}% 火${fire}% 土${earth}% 金${metal}% 水${water}%
- 喜用神：${lucky_elements}
- 忌神：${unlucky_elements}

分析要点：
1. 办公桌位置评估
   - 是否背有靠山
   - 是否面向门窗
   - 是否有横梁压顶

2. 五行元素平衡
   - 现有环境的五行分布
   - 与用户八字的匹配度
   - 需要补充或减少的元素

3. 能量流动分析
   - 气流是否通畅
   - 是否有煞气（尖角、直冲等）
   - 光线是否适宜

4. 改善建议
   - 摆放建议（植物、装饰品等）
   - 颜色调整（基于喜用神）
   - 方位优化

请返回JSON格式：
{
    "overall_score": 0-100的整数,
    "desk_position": {
        "score": 0-100,
        "description": "描述",
        "issues": ["问题1", "问题2"]
    },
    "element_balance": {
        "current_elements": {"wood": %, "fire": %, "earth": %, "metal": %, "water": %},
        "compatibility_score": 0-100,
        "missing_elements": ["元素"],
        "excess_elements": ["元素"]
    },
    "energy_flow": {
        "score": 0-100,
        "positive_aspects": ["正面1", "正面2"],
        "negative_aspects": ["负面1", "负面2"]
    },
    "recommendations": [
        {
            "category": "placement/color/decoration/direction",
            "priority": "high/medium/low",
            "title": "建议标题",
            "description": "详细说明",
            "expected_benefit": "预期效果"
        }
    ],
    "summary": "总体评价（100字以内）"
}""",
                variables=["year_pillar", "month_pillar", "day_pillar", "hour_pillar",
                          "day_master", "wood", "fire", "earth", "metal", "water",
                          "lucky_elements", "unlucky_elements"]
            ),

            "quick_analysis": PromptTemplate(
                template="""快速分析工位风水。

用户喜用神：${lucky_elements}
用户忌神：${unlucky_elements}

请给出3-5条最重要的改善建议，返回JSON：
{
    "quick_tips": [
        {
            "tip": "建议内容",
            "reason": "原因",
            "difficulty": "easy/medium/hard"
        }
    ]
}""",
                variables=["lucky_elements", "unlucky_elements"]
            )
        }

        # English prompts
        self.language_prompts["en"] = {
            "system": PromptTemplate(
                template="""You are a professional Feng Shui master, skilled in both traditional Feng Shui and modern space design.
Your task is to analyze the user's workspace photo and provide personalized Feng Shui advice based on their Bazi information.

Analysis principles:
1. Combine traditional Feng Shui theory with modern office environments
2. Provide targeted suggestions based on the user's Bazi elements
3. Suggestions should be practical and actionable, avoiding superstition
4. Focus on energy flow and user comfort

User's Bazi information:
${bazi_info}

Please return the analysis in JSON format.""",
                variables=["bazi_info"]
            ),

            "analysis": PromptTemplate(
                template="""Please analyze the Feng Shui of this workspace photo.

User Information:
- Bazi: ${year_pillar} ${month_pillar} ${day_pillar} ${hour_pillar}
- Day Master: ${day_master}
- Five Elements: Wood ${wood}% Fire ${fire}% Earth ${earth}% Metal ${metal}% Water ${water}%
- Lucky Elements: ${lucky_elements}
- Unlucky Elements: ${unlucky_elements}

Analysis Points:
1. Desk Position Assessment
   - Back support
   - Facing direction
   - Overhead beams

2. Five Elements Balance
   - Current environmental elements
   - Compatibility with user's Bazi
   - Elements to add or reduce

3. Energy Flow Analysis
   - Air circulation
   - Sha Qi (sharp corners, direct confrontation)
   - Lighting conditions

4. Improvement Suggestions
   - Placement recommendations
   - Color adjustments
   - Direction optimization

Return in JSON format:
{
    "overall_score": integer 0-100,
    "desk_position": {
        "score": 0-100,
        "description": "description",
        "issues": ["issue1", "issue2"]
    },
    "element_balance": {
        "current_elements": {"wood": %, "fire": %, "earth": %, "metal": %, "water": %},
        "compatibility_score": 0-100,
        "missing_elements": ["element"],
        "excess_elements": ["element"]
    },
    "energy_flow": {
        "score": 0-100,
        "positive_aspects": ["positive1", "positive2"],
        "negative_aspects": ["negative1", "negative2"]
    },
    "recommendations": [
        {
            "category": "placement/color/decoration/direction",
            "priority": "high/medium/low",
            "title": "suggestion title",
            "description": "detailed description",
            "expected_benefit": "expected outcome"
        }
    ],
    "summary": "Overall evaluation (within 100 words)"
}""",
                variables=["year_pillar", "month_pillar", "day_pillar", "hour_pillar",
                          "day_master", "wood", "fire", "earth", "metal", "water",
                          "lucky_elements", "unlucky_elements"]
            )
        }

    def get_workspace_analysis_prompt(
        self,
        bazi_data: Dict[str, Any],
        language: str = "zh",
        analysis_type: str = "full"
    ) -> str:
        """
        Get workspace analysis prompt with Bazi data.

        Args:
            bazi_data: User's Bazi information
            language: Language code
            analysis_type: Type of analysis (full, quick)

        Returns:
            Formatted prompt string
        """
        # Prepare variables from Bazi data
        variables = {
            "year_pillar": f"{bazi_data.get('year_gan', '')}{bazi_data.get('year_zhi', '')}",
            "month_pillar": f"{bazi_data.get('month_gan', '')}{bazi_data.get('month_zhi', '')}",
            "day_pillar": f"{bazi_data.get('day_gan', '')}{bazi_data.get('day_zhi', '')}",
            "hour_pillar": f"{bazi_data.get('hour_gan', '')}{bazi_data.get('hour_zhi', '')}" if bazi_data.get('hour_gan') else "未知",
            "day_master": bazi_data.get('day_master', ''),
            "wood": bazi_data.get('elements', {}).get('wood', 0),
            "fire": bazi_data.get('elements', {}).get('fire', 0),
            "earth": bazi_data.get('elements', {}).get('earth', 0),
            "metal": bazi_data.get('elements', {}).get('metal', 0),
            "water": bazi_data.get('elements', {}).get('water', 0),
            "lucky_elements": ', '.join(bazi_data.get('lucky_elements', [])),
            "unlucky_elements": ', '.join(bazi_data.get('unlucky_elements', []))
        }

        # Select prompt based on analysis type
        if analysis_type == "quick":
            prompt_name = "quick_analysis"
        else:
            prompt_name = "analysis"

        return self.get_prompt(prompt_name, language=language, **variables)

    def get_system_prompt(self, language: str = "zh") -> str:
        """Get the system prompt for workspace analysis."""
        return self.language_prompts[language]["system"].template