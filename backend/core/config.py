from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "SafeEats Backend"
    MONGODB_URI: str
    MONGODB_NAME: str
    FOURSQUARE_SECRET: str
    SENDGRID_KEY: str  
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    SENDGRID_KEY: str
    TWILIO_SID: str
    TWILIO_AUTH_TOKEN: str
    TWILIO_PHONE: str
    GEOCODE_KEY: str
    AWS_ACCESS_KEY: str
    AWS_SECRET_KEY: str
    AWS_REGION: str
    AWS_BUCKET_NAME: str


    class Config:
        env_file = ".env"

settings = Settings()