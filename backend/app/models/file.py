from datetime import datetime
from pydantic import BaseModel, Field
from uuid import UUID


class FileUploadMetadata(BaseModel):
    title: str
    author: str | None = None
    source: str | None = None
    user_id: UUID


class FileUploadResponse(BaseModel):
    id: UUID
    title: str
    size_kb: float
    uploaded_at: datetime
