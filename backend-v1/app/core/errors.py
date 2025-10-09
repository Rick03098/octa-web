"""
Custom exceptions and error handlers.
"""
from typing import Any, Dict, Optional
from fastapi import HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel


class ErrorDetail(BaseModel):
    """Error detail model for API responses."""
    code: str
    message: str
    details: Optional[Dict[str, Any]] = None


class APIError(HTTPException):
    """Base API exception class."""

    def __init__(
        self,
        status_code: int,
        code: str,
        message: str,
        details: Optional[Dict[str, Any]] = None,
    ):
        self.code = code
        self.message = message
        self.details = details
        super().__init__(status_code=status_code, detail=message)

    def to_response(self) -> JSONResponse:
        """Convert to JSON response."""
        content = {
            "error": {
                "code": self.code,
                "message": self.message,
            }
        }
        if self.details:
            content["error"]["details"] = self.details
        return JSONResponse(status_code=self.status_code, content=content)


# Authentication Errors
class UnauthorizedError(APIError):
    """Raised when authentication is required but not provided."""

    def __init__(self, message: str = "Authentication required"):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="UNAUTHORIZED",
            message=message,
        )


class InvalidCredentialsError(APIError):
    """Raised when credentials are invalid."""

    def __init__(self, message: str = "Invalid credentials"):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="INVALID_CREDENTIALS",
            message=message,
        )


class TokenExpiredError(APIError):
    """Raised when token has expired."""

    def __init__(self, message: str = "Token has expired"):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="TOKEN_EXPIRED",
            message=message,
        )


# Permission Errors
class ForbiddenError(APIError):
    """Raised when user doesn't have permission."""

    def __init__(self, message: str = "Permission denied"):
        super().__init__(
            status_code=status.HTTP_403_FORBIDDEN,
            code="FORBIDDEN",
            message=message,
        )


class SubscriptionRequiredError(APIError):
    """Raised when feature requires subscription."""

    def __init__(self, message: str = "Pro subscription required"):
        super().__init__(
            status_code=status.HTTP_403_FORBIDDEN,
            code="SUBSCRIPTION_REQUIRED",
            message=message,
        )


# Resource Errors
class NotFoundError(APIError):
    """Raised when resource is not found."""

    def __init__(self, resource: str, resource_id: Optional[str] = None):
        message = f"{resource} not found"
        if resource_id:
            message = f"{resource} with id '{resource_id}' not found"
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            code="NOT_FOUND",
            message=message,
            details={"resource": resource, "id": resource_id},
        )


class ConflictError(APIError):
    """Raised when resource already exists."""

    def __init__(self, message: str = "Resource already exists"):
        super().__init__(
            status_code=status.HTTP_409_CONFLICT,
            code="CONFLICT",
            message=message,
        )


# Validation Errors
class ValidationError(APIError):
    """Raised when request validation fails."""

    def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
        super().__init__(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            code="VALIDATION_ERROR",
            message=message,
            details=details,
        )


class InvalidFileTypeError(ValidationError):
    """Raised when file type is invalid."""

    def __init__(self, allowed_types: list[str]):
        super().__init__(
            message="Invalid file type",
            details={"allowed_types": allowed_types},
        )


# Rate Limiting
class RateLimitExceededError(APIError):
    """Raised when rate limit is exceeded."""

    def __init__(self, message: str = "Rate limit exceeded", retry_after: Optional[int] = None):
        details = {}
        if retry_after:
            details["retry_after_seconds"] = retry_after
        super().__init__(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            code="RATE_LIMIT_EXCEEDED",
            message=message,
            details=details,
        )


# Business Logic Errors
class QuotaExceededError(APIError):
    """Raised when user exceeds their quota."""

    def __init__(self, resource: str, limit: int):
        super().__init__(
            status_code=status.HTTP_403_FORBIDDEN,
            code="QUOTA_EXCEEDED",
            message=f"Monthly {resource} limit ({limit}) exceeded",
            details={"resource": resource, "limit": limit},
        )


class AnalysisFailedError(APIError):
    """Raised when analysis fails."""

    def __init__(self, reason: str):
        super().__init__(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code="ANALYSIS_FAILED",
            message="Analysis failed",
            details={"reason": reason},
        )


# External Service Errors
class ExternalServiceError(APIError):
    """Raised when external service fails."""

    def __init__(self, service: str, message: str = "External service error"):
        super().__init__(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            code="EXTERNAL_SERVICE_ERROR",
            message=message,
            details={"service": service},
        )


def create_error_response(
    status_code: int,
    code: str,
    message: str,
    details: Optional[Dict[str, Any]] = None,
) -> JSONResponse:
    """Create a standard error response."""
    content = {
        "error": {
            "code": code,
            "message": message,
        }
    }
    if details:
        content["error"]["details"] = details
    return JSONResponse(status_code=status_code, content=content)