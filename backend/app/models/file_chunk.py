from datetime import datetime
from pydantic import BaseModel
from uuid import UUID


class FileChunkResponse(BaseModel):
    id: UUID
    chunk_index: int
    section: str | None
    text: str
    created_at: datetime
