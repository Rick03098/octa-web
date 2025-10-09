"""
Base classes for prompt management.
"""
from typing import Dict, Any, Optional, List
from abc import ABC, abstractmethod
from string import Template
import json
from pathlib import Path


class PromptTemplate:
    """
    A template for generating prompts with variable substitution.
    """

    def __init__(self, template: str, variables: Optional[List[str]] = None):
        """
        Initialize a prompt template.

        Args:
            template: The template string with ${variable} placeholders
            variables: List of required variables
        """
        self.template = template
        self.variables = variables or []
        self._template_obj = Template(template)

    def format(self, **kwargs) -> str:
        """
        Format the template with provided variables.

        Args:
            **kwargs: Variables to substitute

        Returns:
            Formatted prompt string
        """
        # Check required variables
        missing = [v for v in self.variables if v not in kwargs]
        if missing:
            raise ValueError(f"Missing required variables: {missing}")

        # Safe substitute (keeps undefined variables as-is)
        return self._template_obj.safe_substitute(**kwargs)

    def get_system_prompt(self) -> str:
        """Get the base system prompt without variables."""
        return self.template

    @classmethod
    def from_file(cls, filepath: Path) -> "PromptTemplate":
        """Load template from a file."""
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            # Extract variables list from comment if exists
            lines = content.split('\n')
            variables = []
            if lines and lines[0].startswith('# Variables:'):
                variables = [v.strip() for v in lines[0].replace('# Variables:', '').split(',')]
                content = '\n'.join(lines[1:])
            return cls(content, variables)


class PromptManager(ABC):
    """
    Abstract base class for managing prompts for a specific feature.
    """

    def __init__(self, language: str = "zh"):
        """
        Initialize prompt manager.

        Args:
            language: Language code (zh, en)
        """
        self.language = language
        self.prompts: Dict[str, PromptTemplate] = {}
        self._load_prompts()

    @abstractmethod
    def _load_prompts(self):
        """Load all prompts for this feature."""
        pass

    def get_prompt(self, name: str, **variables) -> str:
        """
        Get a formatted prompt by name.

        Args:
            name: Prompt name
            **variables: Variables to substitute

        Returns:
            Formatted prompt string
        """
        if name not in self.prompts:
            raise ValueError(f"Prompt '{name}' not found")

        return self.prompts[name].format(**variables)

    def add_prompt(self, name: str, template: PromptTemplate):
        """Add a prompt template."""
        self.prompts[name] = template

    def list_prompts(self) -> List[str]:
        """List all available prompt names."""
        return list(self.prompts.keys())


class MultiLanguagePromptManager(PromptManager):
    """
    Prompt manager that supports multiple languages.
    """

    def __init__(self, default_language: str = "zh"):
        """
        Initialize multi-language prompt manager.

        Args:
            default_language: Default language code
        """
        self.default_language = default_language
        self.language_prompts: Dict[str, Dict[str, PromptTemplate]] = {}
        super().__init__(default_language)

    def _load_prompts(self):
        """Load prompts for all languages."""
        # This will be overridden by subclasses
        pass

    def get_prompt(self, name: str, language: Optional[str] = None, **variables) -> str:
        """
        Get a formatted prompt by name and language.

        Args:
            name: Prompt name
            language: Language code (optional, uses default if not provided)
            **variables: Variables to substitute

        Returns:
            Formatted prompt string
        """
        lang = language or self.default_language

        if lang not in self.language_prompts:
            # Fallback to default language
            lang = self.default_language

        if lang not in self.language_prompts or name not in self.language_prompts[lang]:
            raise ValueError(f"Prompt '{name}' not found for language '{lang}'")

        return self.language_prompts[lang][name].format(**variables)

    def add_prompt(self, name: str, template: PromptTemplate, language: Optional[str] = None):
        """Add a prompt template for a specific language."""
        lang = language or self.default_language
        if lang not in self.language_prompts:
            self.language_prompts[lang] = {}
        self.language_prompts[lang][name] = template