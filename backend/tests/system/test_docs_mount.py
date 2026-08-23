"""Tests for the internal docs mount (/docs/internal)."""
import pytest
from starlette.testclient import TestClient

from app.main import app


@pytest.fixture
def client():
    with TestClient(app) as c:
        yield c


def test_docs_mount_serves_index(client):
    """The MkDocs site should be served at /docs/internal/."""
    response = client.get("/docs/internal/")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]


def test_docs_mount_serves_module_pages(client):
    """Generated module pages should be accessible under /docs/internal/modules/."""
    response = client.get("/docs/internal/modules/")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]
