try:
    from pydantic import BaseSettings
except Exception:
    # pydantic v2.12 moved BaseSettings into the pydantic-settings package
    # keep a fallback import to support different environments
    from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: str = "sqlite:///./habio.db"
    SECRET_KEY: str = "change-me"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7


settings = Settings()
