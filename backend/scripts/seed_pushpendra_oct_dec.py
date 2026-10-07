#!/usr/bin/env python3
"""
Seed realistic appointments, invoices, and payments for Pushpendra Dental clinic
from mid-September 2026 through December 31, 2026.

Ensures:
  - Appointments across October, November, and December 2026 (Mon-Sat).
  - Today (Oct 7, 2026) has 4 appointments:
      * 1 completed
      * 1 in_treatment (shows in 'In clinic now')
      * 2 upcoming scheduled
  - Past appointments are completed (with corresponding invoices & payments).
  - Invoices have proper sequential numbers following INV-2026-1009.
  - All DB constraints (created_at, updated_at, status events, etc.) are fulfilled.
"""

import asyncio
import random
import uuid
from datetime import date, datetime, timedelta, timezone
from decimal import Decimal

import asyncpg

DB_URL = (
    "postgresql://neondb_owner:npg_UKLeREGcuJ40"
    "@ep-snowy-star-aixtxi7u.c-4.us-east-1.aws.neon.tech/neondb?sslmode=require"
)

CLINIC_ID = uuid.UUID("1b88ab23-44b1-4387-b2c1-29137d745ddc")
DENTIST_USER_ID = uuid.UUID("db27e383-6f80-45dc-8ff1-f80c5dc24632")  # Priya Sharma
ADMIN_USER_ID = uuid.UUID("41b10984-758e-4fed-bed3-351fafb64bb9")    # Pushpendra
SERIES_ID = uuid.UUID("b3e251dd-eacc-4c91-be92-7eca8c183914")

CAB_A = uuid.UUID("55ae9696-dd83-430a-9494-8c76c7fda415")  # Surgery A
CAB_B = uuid.UUID("221b6037-4a84-4ca5-a9f2-50e3cf0650d1")  # Surgery B

IST = timezone(timedelta(hours=5, minutes=30))

PATIENTS = [
    {
        "id": uuid.UUID("e0000001-1111-4000-8000-000000000001"),
        "name": "Rajesh Verma",
        "email": "rajesh.verma@example.com",
    },
    {
        "id": uuid.UUID("e0000001-1111-4000-8000-000000000002"),
        "name": "Ananya Iyer",
        "email": "ananya.iyer@example.com",
    },
    {
        "id": uuid.UUID("e0000001-1111-4000-8000-000000000003"),
        "name": "Vikram Malhotra",
        "email": "vikram.malhotra@example.com",
    },
    {
        "id": uuid.UUID("e0000001-1111-4000-8000-000000000004"),
        "name": "Sneha Patel",
        "email": "sneha.patel@example.com",
    },
    {
        "id": uuid.UUID("e0000001-1111-4000-8000-000000000005"),
        "name": "Rahul Deshmukh",
        "email": "rahul.deshmukh@example.com",
    },
    {
        "id": uuid.UUID("e0000001-1111-4000-8000-000000000006"),
        "name": "Pooja Gupta",
        "email": "pooja.gupta@example.com",
    },
    {
        "id": uuid.UUID("e0000001-1111-4000-8000-000000000007"),
        "name": "Amit Banerjee",
        "email": "amit.banerjee@example.com",
    },
    {
        "id": uuid.UUID("e0000001-1111-4000-8000-000000000008"),
        "name": "Meera Joshi",
        "email": "meera.joshi@example.com",
    },
    {
        "id": uuid.UUID("e0000001-1111-4000-8000-000000000009"),
        "name": "Rohan Nair",
        "email": "rohan.nair@example.com",
    },
    {
        "id": uuid.UUID("e0000001-1111-4000-8000-000000000010"),
        "name": "Kavita Reddy",
        "email": "kavita.reddy@example.com",
    },
    {
        "id": uuid.UUID("2111eba7-4677-4355-96e6-2e7b2de2be02"),
        "name": "Manual User",
        "email": "manual@gmail.com",
    },
]

TREATMENTS = [
    {"code": "DX-VISIT", "desc": "Initial Consultation & Diagnosis", "price": 800.0},
    {"code": "PREV-CLEAN", "desc": "Professional Ultrasonic Dental Cleaning", "price": 1500.0},
    {"code": "REST-COMP", "desc": "Light Cure Composite Restoration", "price": 2200.0},
    {"code": "ENDO-RCT", "desc": "Root Canal Treatment (Molar)", "price": 6500.0},
    {"code": "PROSTH-CRWN", "desc": "Zirconia Aesthetic Dental Crown", "price": 9500.0},
    {"code": "SURG-EXT", "desc": "Simple Dental Extraction", "price": 1800.0},
    {"code": "ORTHO-CHK", "desc": "Orthodontic Progress Check & Wire Adjustment", "price": 1200.0},
    {"code": "PREV-BLEACH", "desc": "In-Office Teeth Whitening Session", "price": 7500.0},
    {"code": "DX-RXPAN", "desc": "Digital Panoramic Radiography (OPG)", "price": 1100.0},
]


def ist_dt(year, month, day, hour, minute):
    return datetime(year, month, day, hour, minute, 0, tzinfo=IST)


async def main():
    conn = await asyncpg.connect(DB_URL)

    print("\n" + "=" * 60)
    print("  Pushpendra Dental — Seeding Oct–Dec 2026 Data")
    print("=" * 60 + "\n")

    # Clean any previous appointments seeded in test runs after Sept 14, 2026
    deleted_appts = await conn.execute(
        "DELETE FROM appointments WHERE clinic_id = $1 AND start_time >= $2",
        CLINIC_ID,
        datetime(2026, 9, 14, tzinfo=timezone.utc),
    )
    print(f"Cleaned previous test appointments: {deleted_appts}")

    # Build calendar of appointments
    now_ist = datetime(2026, 10, 7, 10, 0, 0, tzinfo=IST)
    appointments = []

    # 1. Past appointments (Sept 15 – Oct 6, 2026)
    curr_date = date(2026, 9, 15)
    end_date = date(2026, 12, 31)
    p_idx = 0

    while curr_date <= end_date:
        # Skip Sundays
        if curr_date.weekday() == 6:
            curr_date += timedelta(days=1)
            continue

        # Check if today (Oct 7, 2026)
        is_today = (curr_date == date(2026, 10, 7))

        if is_today:
            # Specific realistic appointments for Today!
            today_slots = [
                (9, 30, 10, 15, CAB_A, "Surgery A", "completed", "Professional Ultrasonic Dental Cleaning", 0),
                (11, 0, 11, 45, CAB_A, "Surgery A", "in_treatment", "Light Cure Composite Restoration", 1),
                (14, 0, 14, 45, CAB_B, "Surgery B", "scheduled", "Root Canal Treatment (Molar)", 2),
                (16, 30, 17, 15, CAB_A, "Surgery A", "scheduled", "Orthodontic Progress Check & Wire Adjustment", 3),
            ]
            for start_h, start_m, end_h, end_m, cab_id, cab_name, st, tt, pat_i in today_slots:
                st_time = ist_dt(2026, 10, 7, start_h, start_m)
                ed_time = ist_dt(2026, 10, 7, end_h, end_m)
                created_t = st_time - timedelta(days=2)
                appointments.append({
                    "id": uuid.uuid4(),
                    "clinic_id": CLINIC_ID,
                    "patient": PATIENTS[pat_i % len(PATIENTS)],
                    "professional_id": DENTIST_USER_ID,
                    "cabinet_id": cab_id,
                    "cabinet": cab_name,
                    "start_time": st_time,
                    "end_time": ed_time,
                    "treatment_type": tt,
                    "status": st,
                    "created_at": created_t,
                    "updated_at": created_t,
                })
        elif curr_date < date(2026, 10, 7):
            # Past days: 1 to 2 appointments per day
            slots = [
                (10, 0, 10, 45, CAB_A, "Surgery A"),
                (15, 0, 15, 45, CAB_B, "Surgery B"),
            ]
            for sh, sm, eh, em, cab_id, cab_name in slots:
                st_time = ist_dt(curr_date.year, curr_date.month, curr_date.day, sh, sm)
                ed_time = ist_dt(curr_date.year, curr_date.month, curr_date.day, eh, em)
                status_choice = "completed" if (p_idx % 7 != 0) else "no_show"
                t_item = TREATMENTS[p_idx % len(TREATMENTS)]
                created_t = st_time - timedelta(days=3)
                appointments.append({
                    "id": uuid.uuid4(),
                    "clinic_id": CLINIC_ID,
                    "patient": PATIENTS[p_idx % len(PATIENTS)],
                    "professional_id": DENTIST_USER_ID,
                    "cabinet_id": cab_id,
                    "cabinet": cab_name,
                    "start_time": st_time,
                    "end_time": ed_time,
                    "treatment_type": t_item["desc"],
                    "status": status_choice,
                    "created_at": created_t,
                    "updated_at": created_t,
                    "treatment": t_item,
                })
                p_idx += 1
        else:
            # Future days (Oct 8 - Dec 31, 2026): 2 appointments per working day
            slots = [
                (10, 30, 11, 15, CAB_A, "Surgery A"),
                (16, 0, 16, 45, CAB_B, "Surgery B"),
            ]
            for sh, sm, eh, em, cab_id, cab_name in slots:
                st_time = ist_dt(curr_date.year, curr_date.month, curr_date.day, sh, sm)
                ed_time = ist_dt(curr_date.year, curr_date.month, curr_date.day, eh, em)
                t_item = TREATMENTS[p_idx % len(TREATMENTS)]
                created_t = now_ist - timedelta(hours=12)
                appointments.append({
                    "id": uuid.uuid4(),
                    "clinic_id": CLINIC_ID,
                    "patient": PATIENTS[p_idx % len(PATIENTS)],
                    "professional_id": DENTIST_USER_ID,
                    "cabinet_id": cab_id,
                    "cabinet": cab_name,
                    "start_time": st_time,
                    "end_time": ed_time,
                    "treatment_type": t_item["desc"],
                    "status": "scheduled",
                    "created_at": created_t,
                    "updated_at": created_t,
                    "treatment": t_item,
                })
                p_idx += 1

        curr_date += timedelta(days=1)

    print(f"Generated {len(appointments)} appointments across Sep, Oct, Nov, Dec 2026.")

    # Invoices & Payments for completed past appointments
    completed_appts = [a for a in appointments if a["status"] == "completed"]
    invoices = []
    invoice_items = []
    payments = []
    invoice_payments = []

    seq_num = 10  # Starting after INV-2026-1009
    methods = ["upi", "card", "cash", "bank_transfer"]

    for i, appt in enumerate(completed_appts):
        t_item = appt.get("treatment") or TREATMENTS[i % len(TREATMENTS)]
        price = Decimal(str(t_item["price"]))
        inv_id = uuid.uuid4()
        inv_code = f"INV-2026-{1000 + seq_num}"
        issue_d = appt["start_time"].date()
        due_d = issue_d + timedelta(days=30)
        c_at = appt["start_time"]

        # Most are paid, 2 are overdue, 1 is partial
        if i % 8 == 0:
            inv_status = "issued"  # Unpaid / overdue
            paid_amount = Decimal("0.00")
        elif i % 8 == 1:
            inv_status = "partial"
            paid_amount = price / 2
        else:
            inv_status = "paid"
            paid_amount = price

        invoices.append({
            "id": inv_id,
            "clinic_id": CLINIC_ID,
            "patient_id": appt["patient"]["id"],
            "invoice_number": inv_code,
            "series_id": SERIES_ID,
            "sequential_number": seq_num,
            "status": inv_status,
            "issue_date": issue_d,
            "due_date": due_d,
            "payment_term_days": 30,
            "billing_name": appt["patient"]["name"],
            "billing_email": appt["patient"]["email"],
            "subtotal": price,
            "total_discount": Decimal("0.00"),
            "total_tax": Decimal("0.00"),
            "total": price,
            "created_by": ADMIN_USER_ID,
            "issued_by": ADMIN_USER_ID,
            "created_at": c_at,
            "updated_at": c_at,
            "pdf_stale": False,
        })

        invoice_items.append({
            "id": uuid.uuid4(),
            "clinic_id": CLINIC_ID,
            "invoice_id": inv_id,
            "description": t_item["desc"],
            "unit_price": price,
            "quantity": 1,
            "vat_rate": 0.0,
            "line_subtotal": price,
            "line_discount": Decimal("0.00"),
            "line_tax": Decimal("0.00"),
            "line_total": price,
            "display_order": 0,
            "created_at": c_at,
            "updated_at": c_at,
        })

        if paid_amount > 0:
            pay_id = uuid.uuid4()
            pay_date = issue_d
            payments.append({
                "id": pay_id,
                "clinic_id": CLINIC_ID,
                "patient_id": appt["patient"]["id"],
                "amount": paid_amount,
                "currency": "INR",
                "method": methods[i % len(methods)],
                "payment_date": pay_date,
                "reference": f"UPI/2026/{issue_d.month:02d}/{100000 + i}",
                "notes": f"Payment for {t_item['desc']}",
                "recorded_by": ADMIN_USER_ID,
                "created_at": c_at + timedelta(minutes=15),
                "updated_at": c_at + timedelta(minutes=15),
            })
            invoice_payments.append({
                "id": uuid.uuid4(),
                "clinic_id": CLINIC_ID,
                "invoice_id": inv_id,
                "payment_id": pay_id,
                "amount": paid_amount,
                "created_by": ADMIN_USER_ID,
                "created_at": c_at + timedelta(minutes=15),
                "updated_at": c_at + timedelta(minutes=15),
            })

        seq_num += 1

    print(f"Generated {len(invoices)} invoices, {len(payments)} payments.")

    # Begin DB transaction
    async with conn.transaction():
        # 1. Insert appointments
        print("[1/5] Inserting appointments...")
        for a in appointments:
            await conn.execute("""
                INSERT INTO appointments
                    (id, clinic_id, patient_id, professional_id, cabinet, cabinet_id,
                     start_time, end_time, treatment_type, status, current_status_since,
                     created_at, updated_at)
                VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
            """,
                a["id"], a["clinic_id"], a["patient"]["id"], a["professional_id"],
                a["cabinet"], a["cabinet_id"], a["start_time"], a["end_time"],
                a["treatment_type"], a["status"], a["start_time"],
                a["created_at"], a["updated_at"]
            )

        # 2. Insert appointment status events
        print("[2/5] Inserting appointment status events...")
        for a in appointments:
            await conn.execute("""
                INSERT INTO appointment_status_events
                    (id, clinic_id, appointment_id, from_status, to_status, changed_at, created_at)
                VALUES ($1,$2,$3,$4,$5,$6,$7)
            """,
                uuid.uuid4(), a["clinic_id"], a["id"], None, "scheduled", a["created_at"], a["created_at"]
            )
            if a["status"] != "scheduled":
                await conn.execute("""
                    INSERT INTO appointment_status_events
                        (id, clinic_id, appointment_id, from_status, to_status, changed_at, created_at)
                    VALUES ($1,$2,$3,$4,$5,$6,$7)
                """,
                    uuid.uuid4(), a["clinic_id"], a["id"], "scheduled", a["status"], a["start_time"], a["start_time"]
                )

        # 3. Insert invoices
        print("[3/5] Inserting invoices & invoice items...")
        for inv in invoices:
            await conn.execute("""
                INSERT INTO invoices
                    (id, clinic_id, patient_id, invoice_number, series_id, sequential_number,
                     status, issue_date, due_date, payment_term_days, billing_name, billing_email,
                     subtotal, total_discount, total_tax, total, created_by, issued_by,
                     created_at, updated_at, pdf_stale)
                VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21)
            """,
                inv["id"], inv["clinic_id"], inv["patient_id"], inv["invoice_number"],
                inv["series_id"], inv["sequential_number"], inv["status"], inv["issue_date"],
                inv["due_date"], inv["payment_term_days"], inv["billing_name"], inv["billing_email"],
                inv["subtotal"], inv["total_discount"], inv["total_tax"], inv["total"],
                inv["created_by"], inv["issued_by"], inv["created_at"], inv["updated_at"],
                inv["pdf_stale"]
            )

        for item in invoice_items:
            await conn.execute("""
                INSERT INTO invoice_items
                    (id, clinic_id, invoice_id, description, unit_price, quantity,
                     vat_rate, line_subtotal, line_discount, line_tax, line_total,
                     display_order, created_at, updated_at)
                VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
            """,
                item["id"], item["clinic_id"], item["invoice_id"], item["description"],
                item["unit_price"], item["quantity"], item["vat_rate"], item["line_subtotal"],
                item["line_discount"], item["line_tax"], item["line_total"],
                item["display_order"], item["created_at"], item["updated_at"]
            )

        # 4. Insert payments
        print("[4/5] Inserting payments & invoice payments...")
        for pay in payments:
            await conn.execute("""
                INSERT INTO payments
                    (id, clinic_id, patient_id, amount, currency, method,
                     payment_date, reference, notes, recorded_by, created_at, updated_at)
                VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
            """,
                pay["id"], pay["clinic_id"], pay["patient_id"], pay["amount"],
                pay["currency"], pay["method"], pay["payment_date"], pay["reference"],
                pay["notes"], pay["recorded_by"], pay["created_at"], pay["updated_at"]
            )

        for ip in invoice_payments:
            await conn.execute("""
                INSERT INTO invoice_payments
                    (id, clinic_id, invoice_id, payment_id, amount, created_by, created_at, updated_at)
                VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
            """,
                ip["id"], ip["clinic_id"], ip["invoice_id"], ip["payment_id"],
                ip["amount"], ip["created_by"], ip["created_at"], ip["updated_at"]
            )

        # 5. Update invoice_series current_number
        print("[5/5] Updating invoice series counter...")
        await conn.execute(
            "UPDATE invoice_series SET current_number = $1 WHERE id = $2",
            seq_num, SERIES_ID
        )

    await conn.close()

    print("\n" + "=" * 60)
    print("  ✅ All data successfully seeded till December 31, 2026!")
    print(f"     Total appointments added : {len(appointments)}")
    print(f"     Total invoices added     : {len(invoices)}")
    print(f"     Total payments recorded  : {len(payments)}")
    print("=" * 60 + "\n")


if __name__ == "__main__":
    asyncio.run(main())
