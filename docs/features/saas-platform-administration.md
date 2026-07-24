# SaaS Platform Administration & Subscription Management

**Status:** Proposed / Draft
**Target Module:** `dentalpin-saas` (New External Module) & `frontend/landing`

## 1. Overview
This document outlines the architecture and requirements for transforming the PureBite-Dental system into a fully managed Software-as-a-Service (SaaS) platform. It introduces a Superadmin (Platform Admin) layer, a public landing page for lead generation, and a robust subscription enforcement mechanism.

## 2. Core Features

### 2.1. Public Landing Page & Lead Generation
*   **Portfolio Showcase:** A beautifully designed, public-facing landing page built (e.g., using Nuxt.js public pages). It will showcase the platform's features, the problems it solves for dental clinics, and testimonials.
*   **Pricing Display:** Display subscription pricing (e.g., 1-month, 3-month, 1-year plans). Prices are managed by the Superadmin.
*   **"Join Us" Flow:** 
    *   There is **no self-service registration**.
    *   Interested clinics fill out a "Contact / Join Us" lead generation form (Name, Clinic Name, Phone, Email, Expected Users).
    *   This form submits data to a new backend table (e.g., `saas_leads`) and sends an email notification to the Superadmin.

### 2.2. Superadmin Dashboard (The Control Plane)
*   **Role:** A new system role `superadmin` which operates completely independently from the standard clinic `admin` role. 
*   **Interface:** A dedicated dashboard accessible only to platform administrators (mounted strictly at `/admin`).
*   **Strict Routing Barricades (Edge Case Handled):** 
    *   Superadmins are strictly barred from accessing clinic routes (e.g., `/`, `/patients`). If a superadmin navigates to a clinic route, the middleware intercepts and redirects them back to `/admin`.
    *   Conversely, clinic members are strictly barred from `/admin`. If attempted, they are bounced back to their clinic dashboard `/`.
    *   Unauthenticated users are cleanly routed to `/landing` if they hit root, avoiding an immediate harsh `/login` intercept.
*   **Capabilities (UI Features to Complete):**
    *   **Lead Management:** View, contact, and process leads directly from the dashboard table.
    *   **Tenant Provisioning (UI):** A modal UI to trigger the clinic creation process. The Superadmin inputs clinic details (Name, Tax ID) and admin details (First Name, Last Name, Email, Password). This securely calls the `POST /api/v1/saas/clinics/provision` endpoint.
    *   **Clinic Directory & History (UI):** A dedicated tab in the dashboard listing all provisioned clinics. Clicking on a specific company (clinic) opens a detailed slideover or dedicated page.
        *   **Subscription History:** Within this company-specific view, the superadmin can see the full chronological history of all past, active, and expired subscriptions assigned to that company.
    *   **Subscription Assignment (UI):** 
        *   Located directly inside the company-specific slideover/view mentioned above.
        *   A "Grant Subscription" or "Renew" button allows the superadmin to quickly assign a new time-based subscription (e.g., duration in months) to that specific company.
        *   This ties directly to the backend stacking logic to ensure seamless renewals.

### 2.3. Subscription Tracking & Visibility (Clinic Dashboard)
*   **Access:** Visible to the Clinic Admin within their own clinic dashboard.
*   **Information Displayed:** 
    *   Current active subscription status.
    *   Exact end date of the current subscription.
    *   Lockout warnings if the subscription has expired or hasn't been activated.

### 2.4. Subscription Stacking Logic (Time Accumulation)
When a clinic is assigned a new subscription via the Superadmin UI, the system handles stacking seamlessly:
*   **Appending Time (Edge Case Handled):** If a clinic has a subscription ending in the future, the backend queries the latest active subscription and appends the new duration (e.g., `current_end_date + (duration_months * 30 days)`).
*   **Lapsed Time (Edge Case Handled):** If a clinic's previous subscription expired in the past, or if they never had one, the new subscription activates immediately from `utcnow()`.

### 2.5. Subscription Enforcement & Lockout
When a clinic's subscription expires or does not exist, the system securely restricts access without degrading the user experience.

#### **Implementation Details:**
1.  **Backend Enforcement:** The backend `ClinicContext` validates the clinic's `SaasSubscription`. If no active subscription is found, `subscription_active` is evaluated as `False` and the frontend is informed via `useAuth()`.
2.  **Frontend Handling (`locked.vue`):** Instead of bouncing the user back to login, the user lands on a locked screen.
    *   **Edge Case 1 (Expired):** If they *had* a subscription but it expired, the screen displays "Subscription expired" with the exact expiration date.
    *   **Edge Case 2 (Never Activated):** If the clinic was provisioned but the Superadmin hasn't granted the initial subscription yet, the screen displays "Subscription not activated".
3.  **Graceful Exit:** The locked screen maintains a visible "Sign out" button, allowing users to cleanly exit the platform while waiting for the Superadmin to renew them.

## 3. Database Schema Additions (Implemented)

The following tables exist in the `dentalpin-saas` module:

*   **`saas_subscriptions`**: Tracks active, stacked, and expired timeframes per clinic.
*   **`saas_leads`**: Publicly submitted lead forms.
*   **`saas_pricing_plans`**: Custom duration and pricing plans.

## 4. Development Roadmap (Status Update)

*   **Phase 1 (Complete):** Public Landing Page and Lead Generation form API.
*   **Phase 2 (In Progress):** Superadmin Dashboard UI and backend APIs to manage clinics. Route barricades and SaaS navigation structure are **complete**. The UI modals for Provisioning and Granting Subscriptions are pending.
*   **Phase 3 (Complete):** Introduce `saas_subscriptions` table and backend subscription date injection.
*   **Phase 4 (Complete):** Build the Frontend Locked Screen (`locked.vue`) with dynamic edge-case messaging.
