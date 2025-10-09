"""
FastAPI application entry point.
"""
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
import logging

from app.core.config import get_settings
from app.core.logging import setup_logging
from app.core.errors import APIError
from app.middlewares.request_id import RequestIDMiddleware
from app.api.v1.router import api_router

# Get settings
settings = get_settings()

# Setup logging
setup_logging(
    level="DEBUG" if settings.debug else "INFO",
    json_logs=not settings.is_development
)

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan events.
    """
    # Startup
    logger.info(f"Starting Octa Backend API {settings.api_version}")
    logger.info(f"Environment: {settings.environment}")
    logger.info(f"Debug mode: {settings.debug}")

    # Initialize services here if needed
    # e.g., database connections, cache, etc.

    yield

    # Shutdown
    logger.info("Shutting down Octa Backend API")


# Create FastAPI app
app = FastAPI(
    title="Octa Feng Shui API",
    description="Backend API for Feng Shui analysis platform",
    version=settings.api_version,
    docs_url="/docs" if settings.debug else None,  # Disable docs in production
    redoc_url="/redoc" if settings.debug else None,
    openapi_url=f"/{settings.api_version}/openapi.json" if settings.debug else None,
    lifespan=lifespan
)

# Add middlewares
app.add_middleware(RequestIDMiddleware)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["X-Request-ID"]
)


# Exception handlers
@app.exception_handler(APIError)
async def api_error_handler(request: Request, exc: APIError):
    """Handle API errors."""
    return exc.to_response()


@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """Handle unexpected errors."""
    logger.error(f"Unexpected error: {exc}", exc_info=True)

    if settings.is_production:
        # Don't expose internal errors in production
        return JSONResponse(
            status_code=500,
            content={
                "error": {
                    "code": "INTERNAL_ERROR",
                    "message": "An unexpected error occurred"
                }
            }
        )
    else:
        # Show details in development
        return JSONResponse(
            status_code=500,
            content={
                "error": {
                    "code": "INTERNAL_ERROR",
                    "message": str(exc),
                    "details": {"type": type(exc).__name__}
                }
            }
        )


# Health check endpoints (directly in main for simplicity)
@app.get("/healthz")
async def health_check():
    """
    Liveness probe - checks if the service is running.
    """
    return {"status": "healthy", "service": "octa-backend", "version": settings.api_version}


@app.get("/readyz")
async def readiness_check():
    """
    Readiness probe - checks if the service is ready to accept requests.
    """
    # TODO: Add actual readiness checks (database, external services, etc.)
    ready = True
    checks = {
        "database": True,  # TODO: Check Firestore connection
        "storage": True,   # TODO: Check GCS access
        "cache": True      # TODO: Check Redis if used
    }

    if not all(checks.values()):
        ready = False

    return {
        "status": "ready" if ready else "not_ready",
        "checks": checks,
        "version": settings.api_version
    }


# Include API routes
app.include_router(api_router, prefix=f"/{settings.api_version}")


# Root endpoint
@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "name": "Octa Feng Shui API",
        "version": settings.api_version,
        "environment": settings.environment,
        "docs": f"/docs" if settings.debug else None
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.is_development,
        log_level="debug" if settings.debug else "info"
    )