from fastapi import FastAPI
from api.endpoints import users, auth
from core.config import settings
from db.init_db import connect_db, close_db, db
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    await connect_db()
    if db is None:
        raise Exception("Database connection failed.")
    try:
        print("Opening database connection.")
        yield
    finally:
        print("Closing database connection.")
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
app.include_router(auth.router, prefix="/auth", tags=["Auth"])

# Health check
@app.get("/health")
async def health_check():
    return {"status": "ok"}