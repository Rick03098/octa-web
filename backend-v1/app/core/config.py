"""
Application configuration using Pydantic Settings.
"""
from typing import List, Optional
from pydantic import Field, validator
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings with validation."""

    # Environment
    environment: str = Field(default="development", env="ENVIRONMENT")
    api_version: str = Field(default="v1", env="API_VERSION")
    debug: bool = Field(default=False, env="DEBUG")

    # Server
    host: str = Field(default="0.0.0.0", env="HOST")
    port: int = Field(default=8000, env="PORT")

    # Security
    jwt_secret_key: str = Field(..., env="JWT_SECRET_KEY")
    jwt_algorithm: str = Field(default="HS256", env="JWT_ALGORITHM")
    access_token_expire_minutes: int = Field(default=15, env="ACCESS_TOKEN_EXPIRE_MINUTES")
    refresh_token_expire_days: int = Field(default=7, env="REFRESH_TOKEN_EXPIRE_DAYS")

    # Google Cloud
    google_cloud_project: str = Field(..., env="GOOGLE_CLOUD_PROJECT")
    gcs_bucket: str = Field(..., env="GCS_BUCKET")
    firestore_database: str = Field(default="(default)", env="FIRESTORE_DATABASE")

    # Redis
    redis_url: Optional[str] = Field(None, env="REDIS_URL")

    # RevenueCat
    revenuecat_api_key: Optional[str] = Field(None, env="REVENUECAT_API_KEY")
    revenuecat_webhook_secret: Optional[str] = Field(None, env="REVENUECAT_WEBHOOK_SECRET")

    # OAuth
    google_client_id: Optional[str] = Field(None, env="GOOGLE_CLIENT_ID")
    apple_client_id: Optional[str] = Field(None, env="APPLE_CLIENT_ID")

    # Rate Limiting
    rate_limit_per_minute: int = Field(default=60, env="RATE_LIMIT_PER_MINUTE")
    rate_limit_per_hour: int = Field(default=1000, env="RATE_LIMIT_PER_HOUR")

    # Analysis Settings
    max_image_size_mb: int = Field(default=10, env="MAX_IMAGE_SIZE_MB")
    analysis_timeout_seconds: int = Field(default=300, env="ANALYSIS_TIMEOUT_SECONDS")

    # CORS
    cors_origins: List[str] = Field(
        default=["http://localhost:3000", "http://localhost:5173"],
        env="CORS_ORIGINS"
    )

    # Feature Flags
    enable_chat: bool = Field(default=True, env="ENABLE_CHAT")
    enable_oauth: bool = Field(default=False, env="ENABLE_OAUTH")

    # Subscription Limits
    free_analysis_per_month: int = Field(default=3, env="FREE_ANALYSIS_PER_MONTH")
    free_chat_messages_per_day: int = Field(default=10, env="FREE_CHAT_MESSAGES_PER_DAY")

    @validator("environment")
    def validate_environment(cls, v):
        """Validate environment value."""
        if v not in ["development", "staging", "production"]:
            raise ValueError("environment must be development, staging, or production")
        return v

    @validator("cors_origins", pre=True)
    def parse_cors_origins(cls, v):
        """Parse CORS origins from string or list."""
        if isinstance(v, str):
            return [origin.strip() for origin in v.split(",")]
        return v

    @property
    def is_production(self) -> bool:
        """Check if running in production."""
        return self.environment == "production"

    @property
    def is_development(self) -> bool:
        """Check if running in development."""
        return self.environment == "development"

    @property
    def database_url(self) -> str:
        """Get Firestore database URL."""
        return f"projects/{self.google_cloud_project}/databases/{self.firestore_database}"

    @property
    def gcs_media_url(self) -> str:
        """Get GCS media bucket URL."""
        return f"gs://{self.gcs_bucket}"

    class Config:
        """Pydantic config."""
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False


@lru_cache()
def get_settings() -> Settings:
    """
    Get cached settings instance.
    Using lru_cache ensures we only create one instance.
    """
    return Settings()


# Export for convenience
settings = get_settings()