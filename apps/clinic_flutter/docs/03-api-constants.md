# API constants

All paths live in `lib/core/constants/api_constants.dart`. **No URL strings in widgets, ViewModels, or repositories.**

Backend: FastAPI DentalPin. Default base: `http://localhost:8000` (override with `--dart-define=API_BASE_URL=`).

## Prefix

```
ApiConstants.apiV1 = '/api/v1'
```

## Auth

| Constant | Path | Notes |
|----------|------|--------|
| `login` | `/api/v1/auth/login` | Form `username` + `password` (OAuth2). Raw `{ access_token, refresh_token, token_type }` — **not** wrapped. |
| `refresh` | `/api/v1/auth/refresh` | JSON `{ refresh_token }` |
| `me` | `/api/v1/auth/me` | User, clinics, permissions |
| `logout` | `/api/v1/auth/logout` | If present; otherwise clear local tokens |

## Patients

| Constant | Path |
|----------|------|
| `patients` | `/api/v1/patients` |
| `patientsRecent` | `/api/v1/patients/recent` |
| `patient(id)` | `/api/v1/patients/{id}` |
| `patientExtended(id)` | `/api/v1/patients/{id}/extended` |

Query: `search`, `page`, `page_size`, `include_archived`, `sort`

## Agenda

| Constant | Path |
|----------|------|
| `appointments` | `/api/v1/agenda/appointments` |
| `appointment(id)` | `/api/v1/agenda/appointments/{id}` |
| `cabinets` | `/api/v1/agenda/cabinets` |

Query: `start_date`, `end_date`, `status`, `patient_id`, `professional_id`, `page`, `page_size`

## Headers and tokens

| Constant | Value |
|----------|--------|
| `authorization` | `Authorization` |
| `bearerPrefix` | `Bearer ` |
| `contentType` | `Content-Type` |
| `json` | `application/json` |
| `formUrlEncoded` | `application/x-www-form-urlencoded` |

## Timeouts and paging

- Connect timeout: 15 s
- Receive timeout: 60 s
- Default page size: 20 (patients), 100 (appointments)
- Max page size: never exceed backend caps (100 patients, 500 appointments)

## Envelope

Success lists: `{ data, total, page, page_size, message? }`  
Success item: `{ data, message? }`  
Error: `{ message, errors[] }`

Parse only in `data/services/api/api_envelope.dart`.
