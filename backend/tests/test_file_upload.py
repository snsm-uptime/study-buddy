import io

import pytest
from httpx import AsyncClient
from starlette.status import HTTP_201_CREATED

from app.main import app  # Make sure this path reflects your actual structure


@pytest.mark.asyncio
async def test_upload_txt_file_returns_201():
    file = io.BytesIO(b"Study Buddy loves TDD!")
    file.name = "example.txt"

    async with AsyncClient(app=app, base_url="http://testserver") as ac:
        response = await ac.post(
            "/files/upload",
            files={"file": ("example.txt", file, "text/plain")},
        )

    assert response.status_code == HTTP_201_CREATED
    json = response.json()
    assert "file_id" in json
    assert json["filename"] == "example.txt"
