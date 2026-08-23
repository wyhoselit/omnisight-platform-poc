from typing import Any
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text

from app.modules.core.config import settings
from app.modules.core.logging import setup_logging
from app.modules.core.middleware import RequestIDMiddleware
from app.modules.ai.middleware import CostTrackingMiddleware
from app.modules.ai.rate_limiting import RateLimitingMiddleware
from app.modules.core.exceptions import AuthException
from app.modules.core.version import get_version
from app.api.router import api_router
from init_db import init_db
from app.modules.core.observability import setup_observability
from app.modules.core.database import engine, get_db

# Initialize logging
setup_logging()

@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    yield
def create_app(lifespan: Any = lifespan):
    app = FastAPI(
        title="Backend API",
        version=get_version(),
        lifespan=lifespan,
    )

    # Add Request ID middleware (must be first to capture request ID)
    app.add_middleware(RequestIDMiddleware)
    app.add_middleware(CostTrackingMiddleware)
    app.add_middleware(RateLimitingMiddleware)

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS.split(","),
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    @app.exception_handler(AuthException)
    async def auth_exception_handler(request: Request, exc: AuthException):
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "detail": exc.detail,
                "error_code": exc.error_code,
            },
            headers={"X-Request-ID": getattr(request.state, "request_id", "")}
        )

    @app.exception_handler(HTTPException)
    async def http_exception_handler(request: Request, exc: HTTPException):
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "detail": exc.detail,
                "error_code": "HTTP_ERROR"
            },
            headers={"X-Request-ID": getattr(request.state, "request_id", "")}
        )

    @app.exception_handler(Exception)
    async def general_exception_handler(request: Request, exc: Exception):
        return JSONResponse(
            status_code=500,
            content={
                "detail": "Internal server error",
                "error_code": "INTERNAL_ERROR"
            },
            headers={"X-Request-ID": getattr(request.state, "request_id", "")}
        )

    @app.get("/health")
    async def health_check(db: Session = Depends(get_db)):
        try:
            # Check database connectivity
            db.execute(text("SELECT 1"))
            db_status = "ok"
        except Exception:
            db_status = "error"
            raise HTTPException(status_code=503, detail="Database connection error")

        return {"status": "ok", "database": db_status}

    
    app.include_router(api_router, prefix="/api")

    setup_observability(app, engine)
    
    from prometheus_fastapi_instrumentator import Instrumentator
    Instrumentator().instrument(app).expose(app)

    return app

app = create_app()