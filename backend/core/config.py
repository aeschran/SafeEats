from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "SafeEats Backend"
    MONGODB_URI: str
    MONGODB_NAME: str
    FOURSQUARE_SECRET: str
    SENDGRID_KEY: str  
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    SENDGRID_KEY: str

    class Config:
        env_file = ".env"

settings = Settings()