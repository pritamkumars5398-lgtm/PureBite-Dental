"""Unit tests for CloudinaryStorageBackend."""

import pytest
from unittest.mock import MagicMock, patch
import httpx
from app.modules.media.storage.cloudinary import CloudinaryStorageBackend


@pytest.fixture
def mock_cloudinary():
    """Mock cloudinary config and uploader."""
    with patch("app.modules.media.storage.cloudinary.cloudinary") as mock_cloud:
        yield mock_cloud


def test_cloudinary_init(mock_cloudinary):
    """Test initializing CloudinaryStorageBackend."""
    backend = CloudinaryStorageBackend(
        cloud_name="test_cloud",
        api_key="test_key",
        api_secret="test_secret"
    )
    assert backend.cloud_name == "test_cloud"
    assert backend.api_key == "test_key"
    assert backend.api_secret == "test_secret"

    mock_cloudinary.config.assert_called_once_with(
        cloud_name="test_cloud",
        api_key="test_key",
        api_secret="test_secret",
        secure=True,
    )


@pytest.mark.parametrize(
    "path,expected",
    [
        ("clinic/patient/file.jpg", "image"),
        ("clinic/patient/file.PNG", "image"),
        ("clinic/patient/file.webp", "image"),
        ("clinic/patient/file.pdf", "raw"),
        ("clinic/patient/file.txt", "raw"),
        ("clinic/patient/file", "raw"),
    ],
)
def test_get_resource_type(mock_cloudinary, path, expected):
    """Test _get_resource_type detects images vs raw files."""
    backend = CloudinaryStorageBackend("name", "key", "secret")
    assert backend._get_resource_type(path) == expected


@pytest.mark.parametrize(
    "path,resource_type,expected",
    [
        ("clinic/patient/file.jpg", "image", "clinic/patient/file"),
        ("clinic/patient/file.png", "image", "clinic/patient/file"),
        ("clinic/patient/file.pdf", "raw", "clinic/patient/file.pdf"),
    ],
)
def test_get_public_id(mock_cloudinary, path, resource_type, expected):
    """Test _get_public_id formats public ID correctly."""
    backend = CloudinaryStorageBackend("name", "key", "secret")
    assert backend._get_public_id(path, resource_type) == expected


@pytest.mark.asyncio
async def test_store_image(mock_cloudinary):
    """Test storing an image calls upload with stripped extension."""
    backend = CloudinaryStorageBackend("name", "key", "secret")
    
    mock_cloudinary.uploader.upload.return_value = {"public_id": "test_id"}

    path = "clinic/patient/image.jpg"
    data = b"fake_image_data"
    
    result = await backend.store(data, path)
    
    assert result == path
    # Check upload was called inside threadpool
    mock_cloudinary.uploader.upload.assert_called_once()
    args, kwargs = mock_cloudinary.uploader.upload.call_args
    # First arg is io.BytesIO
    assert kwargs["public_id"] == "clinic/patient/image"
    assert kwargs["resource_type"] == "image"
    assert kwargs["invalidate"] is True


@pytest.mark.asyncio
async def test_store_raw(mock_cloudinary):
    """Test storing a raw file calls upload with full path."""
    backend = CloudinaryStorageBackend("name", "key", "secret")
    
    mock_cloudinary.uploader.upload.return_value = {"public_id": "test_id"}

    path = "clinic/patient/doc.pdf"
    data = b"fake_pdf_data"
    
    result = await backend.store(data, path)
    
    assert result == path
    mock_cloudinary.uploader.upload.assert_called_once()
    args, kwargs = mock_cloudinary.uploader.upload.call_args
    assert kwargs["public_id"] == "clinic/patient/doc.pdf"
    assert kwargs["resource_type"] == "raw"
    assert kwargs["invalidate"] is True


@pytest.mark.asyncio
async def test_retrieve_success():
    """Test successful retrieve fetches content via httpx."""
    backend = CloudinaryStorageBackend("test_cloud", "key", "secret")
    
    fake_content = b"cloudinary_file_data"
    
    class FakeResponse:
        status_code = 200
        content = fake_content
        def raise_for_status(self):
            pass

    async def mock_get(*args, **kwargs):
        return FakeResponse()

    with patch("httpx.AsyncClient.get", side_effect=mock_get) as mock_client_get:
        result = await backend.retrieve("clinic/patient/file.jpg")
        assert result == fake_content
        mock_client_get.assert_called_once_with(
            "https://res.cloudinary.com/test_cloud/image/upload/clinic/patient/file.jpg",
            follow_redirects=True
        )


@pytest.mark.asyncio
async def test_retrieve_not_found():
    """Test retrieve raising FileNotFoundError on 404."""
    backend = CloudinaryStorageBackend("test_cloud", "key", "secret")
    
    class FakeResponse:
        status_code = 404
        content = b""

    async def mock_get(*args, **kwargs):
        return FakeResponse()

    with patch("httpx.AsyncClient.get", side_effect=mock_get):
        with pytest.raises(FileNotFoundError):
            await backend.retrieve("clinic/patient/missing.jpg")


@pytest.mark.asyncio
async def test_delete_success(mock_cloudinary):
    """Test successful delete calls destroy."""
    backend = CloudinaryStorageBackend("name", "key", "secret")
    mock_cloudinary.uploader.destroy.return_value = {"result": "ok"}
    
    result = await backend.delete("clinic/patient/file.jpg")
    assert result is True
    mock_cloudinary.uploader.destroy.assert_called_once_with(
        "clinic/patient/file",
        resource_type="image",
        invalidate=True
    )


@pytest.mark.asyncio
async def test_delete_fail(mock_cloudinary):
    """Test failed delete returns False."""
    backend = CloudinaryStorageBackend("name", "key", "secret")
    mock_cloudinary.uploader.destroy.return_value = {"result": "not found"}
    
    result = await backend.delete("clinic/patient/file.jpg")
    assert result is False


@pytest.mark.asyncio
async def test_exists_true():
    """Test exists returns True on 200 HEAD request."""
    backend = CloudinaryStorageBackend("test_cloud", "key", "secret")
    
    class FakeResponse:
        status_code = 200

    async def mock_head(*args, **kwargs):
        return FakeResponse()

    with patch("httpx.AsyncClient.head", side_effect=mock_head) as mock_client_head:
        result = await backend.exists("clinic/patient/file.jpg")
        assert result is True
        mock_client_head.assert_called_once_with(
            "https://res.cloudinary.com/test_cloud/image/upload/clinic/patient/file.jpg",
            follow_redirects=True
        )


@pytest.mark.asyncio
async def test_exists_false():
    """Test exists returns False on non-200 HEAD request."""
    backend = CloudinaryStorageBackend("test_cloud", "key", "secret")
    
    class FakeResponse:
        status_code = 404

    async def mock_head(*args, **kwargs):
        return FakeResponse()

    with patch("httpx.AsyncClient.head", side_effect=mock_head):
        result = await backend.exists("clinic/patient/missing.jpg")
        assert result is False
