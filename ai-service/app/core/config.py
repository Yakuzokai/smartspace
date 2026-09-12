from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Literal

class Settings(BaseSettings):
    HOST: str = "127.0.0.1"
    PORT: int = 8001
    SERVICE_API_KEY: str = "smartspace_internal_secret_key"
    ACTIVE_PROVIDER: Literal["gemini", "rule_based", "mock"] = "gemini"
    GEMINI_API_KEY: str = ""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

settings = Settings()
