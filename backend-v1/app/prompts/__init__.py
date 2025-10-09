"""
Prompt management system for Feng Shui analysis.
"""
from .base import PromptTemplate, PromptManager
from .workspace_prompts import WorkspaceAnalysisPrompts

__all__ = ["PromptTemplate", "PromptManager", "WorkspaceAnalysisPrompts"]