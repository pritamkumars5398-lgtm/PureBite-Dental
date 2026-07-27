"""Cloudinary storage backend."""

import io

import cloudinary
import cloudinary.uploader
import httpx
from fastapi.concurrency import run_in_threadpool

from .base import StorageBackend


class CloudinaryStorageBackend(StorageBackend):
    """Store files on Cloudinary cloud service."""

    def __init__(self, cloud_name: str, api_key: str, api_secret: str) -> None:
        """Initialize with Cloudinary credentials.

        Args:
            cloud_name: Cloudinary cloud name
            api_key: Cloudinary API key
            api_secret: Cloudinary API secret
        """
        self.cloud_name = cloud_name
        self.api_key = api_key
        self.api_secret = api_secret

        # Configure Cloudinary SDK settings
        cloudinary.config(
            cloud_name=self.cloud_name,
            api_key=self.api_key,
            api_secret=self.api_secret,
            secure=True,
        )

    def _get_resource_type(self, path: str) -> str:
        """Determine Cloudinary resource type from path extension."""
        ext = path.split(".")[-1].lower() if "." in path else ""
        if ext in ("jpg", "jpeg", "png", "webp", "gif", "svg", "bmp", "tiff", "heic"):
            return "image"
        return "raw"

    def _get_public_id(self, path: str, resource_type: str) -> str:
        """Determine Cloudinary public ID from path.

        For image resource types, the public ID must exclude the file extension.
        For raw resource types, the public ID must include the file extension.
        """
        if resource_type == "image":
            if "." in path:
                return ".".join(path.split(".")[:-1])
        return path

    async def store(self, data: bytes, path: str) -> str:
        """Store file data at path on Cloudinary."""
        resource_type = self._get_resource_type(path)
        public_id = self._get_public_id(path, resource_type)

        file_obj = io.BytesIO(data)

        await run_in_threadpool(
            cloudinary.uploader.upload,
            file_obj,
            public_id=public_id,
            resource_type=resource_type,
            invalidate=True,
        )

        return path

    async def retrieve(self, path: str) -> bytes:
        """Retrieve file content from Cloudinary secure delivery URL."""
        resource_type = self._get_resource_type(path)
        url = f"https://res.cloudinary.com/{self.cloud_name}/{resource_type}/upload/{path}"

        async with httpx.AsyncClient() as client:
            response = await client.get(url, follow_redirects=True)
            if response.status_code == 404:
                raise FileNotFoundError(f"File not found on Cloudinary: {path}")
            response.raise_for_status()
            return response.content

    async def delete(self, path: str) -> bool:
        """Delete file from Cloudinary."""
        resource_type = self._get_resource_type(path)
        public_id = self._get_public_id(path, resource_type)

        result = await run_in_threadpool(
            cloudinary.uploader.destroy,
            public_id,
            resource_type=resource_type,
            invalidate=True,
        )

        return result.get("result") == "ok"

    async def exists(self, path: str) -> bool:
        """Check if file exists on Cloudinary using HTTP HEAD request."""
        resource_type = self._get_resource_type(path)
        url = f"https://res.cloudinary.com/{self.cloud_name}/{resource_type}/upload/{path}"

        async with httpx.AsyncClient() as client:
            response = await client.head(url, follow_redirects=True)
            return response.status_code == 200
