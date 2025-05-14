import io
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_upload_file_returns_metadata():
    fake_file = io.BytesIO(b"Hello world")
    response = client.post(
        "/files/",
        files={"file": ("test.txt", fake_file, "text/plain")},
    )

    assert response.status_code == 201
    data = response.json()

    assert data["title"] == "test.txt"
    assert data["size_kb"] > 0
    assert "id" in data
    assert data["uploaded_at"] is not None
