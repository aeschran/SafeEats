from starlette.middleware.base import BaseHTTPMiddleware
import logging

logger = logging.getLogger("uvicorn")

class LoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        response = await call_next(request)
        logger.info(f"Request: {request.method} {request.url} - Response: {response.status_code}")
        return response