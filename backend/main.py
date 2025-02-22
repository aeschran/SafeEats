from fastapi import FastAPI

from api.endpoints import users, profile, business_owners, auth, business_auth, business_search, notifications
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
app.include_router(business_auth.router, prefix="/business_auth", tags=["Business Auth"])
app.include_router(profile.router, prefix="/profile", tags=["Profile"])
app.include_router(business_owners.router, prefix="/business_owners", tags=["Business Owners"])
app.include_router(business_search.router, prefix="/business_search", tags=["Business Search"])
app.include_router(notifications.router, prefix="/notifications", tags=["Notifications"])

# Health check
@app.get("/health")
async def health_check():
    return {"status": "ok"}