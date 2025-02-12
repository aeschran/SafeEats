from fastapi import FastAPI
from api.endpoints import users
from core.config import settings
from db.init_db import connect_db, close_db
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    if connect_db() == None:
        raise Exception("Database connection failed.")
    try:
        yield
    finally:
        await close_db()

app = FastAPI(title=settings.PROJECT_NAME, lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Replace "*" with frontend URL for security
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routers
app.include_router(users.router, prefix="/users", tags=["Users"])

# Health check
@app.get("/health")
async def health_check():
    return {"status": "ok"}