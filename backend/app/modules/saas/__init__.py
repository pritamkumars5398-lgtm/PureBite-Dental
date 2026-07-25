"""SaaS Platform Administration module.

Handles superadmin tasks, clinic provisioning, lead generation,
and subscription management.
"""

from fastapi import APIRouter

from app.core.plugins import BaseModule

from .models import SaasLead, SaasPricingPlan, SaasSubscription
from .router import router


class SaasModule(BaseModule):
    """SaaS module for platform administration."""

    manifest = {
        "name": "saas",
        "version": "0.1.0",
        "summary": "Platform administration, leads, and subscriptions.",
        "author": "DentalPin Core Team",
        "license": "BSL-1.1",
        "category": "official",
        "depends": [],
        "installable": True,
        "auto_install": True,
        "removable": False,
        "role_permissions": {
            "admin": ["*"],
            "dentist": ["subscriptions.read"],
            "hygienist": [],
            "assistant": ["subscriptions.read"],
            "receptionist": ["subscriptions.read"],
            # superadmin will have access via the core RBAC but we can map here if we introduce a role in `permissions.py`
        },
        "frontend": {
            "layer_path": "frontend",
            "navigation": [
                {
                    "label": "nav.dashboard",
                    "icon": "i-lucide-layout-dashboard",
                    "to": "/admin",
                    "permission": "saas.leads.read",
                    "order": 100,
                },
                {
                    "label": "saasAdmin.tabs.plans",
                    "icon": "i-lucide-tags",
                    "to": "/admin/plans",
                    "permission": "saas.leads.read",
                    "order": 110,
                },
                {
                    "label": "saasAdmin.tabs.clinics",
                    "icon": "i-lucide-building",
                    "to": "/admin/clinics",
                    "permission": "saas.leads.read",
                    "order": 120,
                },
                {
                    "label": "saasAdmin.tabs.leads",
                    "icon": "i-lucide-users",
                    "to": "/admin/leads",
                    "permission": "saas.leads.read",
                    "order": 130,
                },
            ],
        },
    }

    def get_models(self) -> list:
        return [SaasLead, SaasPricingPlan, SaasSubscription]

    def get_router(self) -> APIRouter:
        return router

    def get_permissions(self) -> list[str]:
        return ["leads.read", "leads.write", "subscriptions.read", "subscriptions.write"]

    def get_tools(self) -> list:
        return []
