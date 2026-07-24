"""Shared constants for the SaaS platform administration module."""

PLATFORM_ADMIN_CLINIC_NAME = "Platform Administration"


def is_platform_clinic(clinic_name: str) -> bool:
    """Whether ``clinic_name`` is the internal platform-admin workspace.

    Superadmins operate inside this synthetic clinic instead of a real
    tenant. Subscription enforcement, `/me`, and the clinic directory all
    need to agree on the same check, so it lives here once instead of as
    a magic string repeated at each call site.
    """
    return clinic_name == PLATFORM_ADMIN_CLINIC_NAME
