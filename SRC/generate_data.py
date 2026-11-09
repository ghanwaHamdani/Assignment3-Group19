"""
SE 3309 Assignment 3 - Group 19 - Item 4
Data generator for the Code Blue database (code_blue).

Writes SRC/code_blue_data.sql: INSERT statements for every table except
Department, which comes from ex3.sql.

Load order:
    1. SQL/ex2.sql            (creates the tables)
    2. SQL/ex3.sql            (6 departments + doctors 1001-1006)
    3. SRC/code_blue_data.sql (this generator's output)

How referential integrity is kept:
    - Tables are generated parents-first. Each child table only picks foreign
      key values from lists of keys that were already generated for its parent.
    - Primary keys are sequential numbers or drawn with random.sample, so they
      never repeat.
    - BillProcedure only links a bill to procedures of the SAME patient.
      No foreign key enforces this, so the generator does.
    - A room never holds more patients at once than its capacity, and its
      availabilityStatus is computed from its current admissions.

Uses a fixed random seed, so every run produces exactly the same data.
Run from any folder:  python3 /full/path/to/SRC/generate_data.py
"""

import random
from datetime import date, time, timedelta
from pathlib import Path

random.seed(3309)

OUTPUT_FILE = Path(__file__).parent / "code_blue_data.sql"

# A fixed "today", so statuses like Scheduled / Overdue don't change between runs
REF_DATE = date(2026, 11, 1)

# Row counts (spec: two tables with a few thousand rows, one with hundreds)
NUM_PATIENTS = 2000
NUM_APPOINTMENTS = 5000
NUM_PRESCRIPTIONS = 600
NUM_ADMISSIONS = 400
NUM_PATIENT_PROCEDURES = 800
NUM_NEW_DOCTORS = 34          # added after ex3's doctors 1001-1006

# "Procedure" is a reserved word in MySQL, so the table name needs backticks.
# If the group renames the table in ex2.sql, change it here too.
PROCEDURE_TABLE = "`Procedure`"


# ---------------------------------------------------------------------------
# Data that already exists from ex3.sql
# ---------------------------------------------------------------------------

DEPARTMENTS = {
    "Emergency": "Emergency Medicine",
    "Cardiology": "Cardiology",
    "Neurology": "Neurology",
    "Oncology": "Oncology",
    "Pediatrics": "Pediatrics",
    "Radiology": "Diagnostic Imaging",
}
EX3_DOCTOR_IDS = [1001, 1002, 1003, 1004, 1005, 1006]


# ---------------------------------------------------------------------------
# Lists used to make values look meaningful
# ---------------------------------------------------------------------------

FIRST_NAMES = [
    "Liam", "Olivia", "Noah", "Emma", "Ethan", "Ava", "Lucas", "Sophia", "Mason",
    "Isabella", "Logan", "Mia", "James", "Amelia", "Aiden", "Harper", "Benjamin",
    "Evelyn", "Elijah", "Abigail", "Jacob", "Emily", "Daniel", "Ella", "Henry",
    "Chloe", "Samuel", "Grace", "David", "Zoe", "Omar", "Fatima", "Wei", "Mei",
    "Arjun", "Priya", "Mateo", "Sofia", "Yusuf", "Leila",
]
LAST_NAMES = [
    "Smith", "Brown", "Tremblay", "Martin", "Roy", "Wilson", "Macdonald", "Gagnon",
    "Johnson", "Taylor", "Campbell", "Anderson", "Lee", "Wong", "Patel", "Singh",
    "Nguyen", "Chen", "Kim", "Ali", "Khan", "Garcia", "Rossi", "Cohen", "Murphy",
    "O'Brien", "Kowalski", "Haddad", "Fraser", "Bouchard",
]
STREETS = [
    "Richmond St", "Oxford St", "Dundas St", "Wellington Rd", "Western Rd",
    "Adelaide St", "Commissioners Rd", "Wharncliffe Rd", "Highbury Ave", "Sarnia Rd",
]
CITIES = ["London", "London", "London", "St. Thomas", "Strathroy", "Woodstock"]

# (name, description, unit cost, strength used in the dosage text)
MEDICATIONS = [
    ("Amoxicillin", "Penicillin antibiotic", 0.45, "500 mg"),
    ("Metformin", "Blood sugar control for type 2 diabetes", 0.20, "500 mg"),
    ("Atorvastatin", "Lowers cholesterol", 0.35, "20 mg"),
    ("Lisinopril", "ACE inhibitor for high blood pressure", 0.25, "10 mg"),
    ("Amlodipine", "Calcium channel blocker for blood pressure", 0.30, "5 mg"),
    ("Levothyroxine", "Thyroid hormone replacement", 0.22, "50 mcg"),
    ("Omeprazole", "Reduces stomach acid", 0.40, "20 mg"),
    ("Salbutamol", "Inhaler for asthma relief", 12.50, "100 mcg"),
    ("Ibuprofen", "Pain and inflammation relief", 0.10, "400 mg"),
    ("Acetaminophen", "Pain and fever relief", 0.08, "500 mg"),
    ("Sertraline", "Antidepressant (SSRI)", 0.50, "50 mg"),
    ("Warfarin", "Blood thinner", 0.18, "5 mg"),
    ("Apixaban", "Blood thinner", 1.60, "5 mg"),
    ("Prednisone", "Corticosteroid for inflammation", 0.15, "10 mg"),
    ("Insulin Glargine", "Long-acting insulin", 25.00, "10 units"),
    ("Ciprofloxacin", "Fluoroquinolone antibiotic", 0.75, "500 mg"),
    ("Gabapentin", "Nerve pain and seizure control", 0.30, "300 mg"),
    ("Furosemide", "Diuretic for fluid retention", 0.12, "40 mg"),
    ("Metoprolol", "Beta blocker for heart rate", 0.20, "50 mg"),
    ("Clopidogrel", "Prevents blood clots", 0.55, "75 mg"),
    ("Ondansetron", "Prevents nausea", 1.10, "4 mg"),
    ("Morphine", "Opioid for severe pain", 2.00, "10 mg"),
    ("Cetirizine", "Antihistamine for allergies", 0.15, "10 mg"),
    ("Pantoprazole", "Reduces stomach acid", 0.45, "40 mg"),
    ("Azithromycin", "Macrolide antibiotic", 1.20, "250 mg"),
    ("Hydrochlorothiazide", "Diuretic for blood pressure", 0.10, "25 mg"),
    ("Montelukast", "Asthma and allergy control", 0.60, "10 mg"),
    ("Tamoxifen", "Breast cancer treatment", 0.90, "20 mg"),
    ("Methotrexate", "Chemotherapy and autoimmune treatment", 1.40, "2.5 mg"),
    ("Levetiracetam", "Anti-seizure medication", 0.80, "500 mg"),
]

FREQUENCIES = [
    "Once daily", "Twice daily", "Three times daily", "Every 4 hours as needed",
    "Every 6 hours as needed", "Once weekly", "At bedtime",
]

# (name, description, cost)
PROCEDURES = [
    ("Appendectomy", "Surgical removal of the appendix", 4200.00),
    ("MRI Scan", "Magnetic resonance imaging", 850.00),
    ("CT Scan", "Computed tomography imaging", 600.00),
    ("X-Ray", "Diagnostic radiograph", 120.00),
    ("Ultrasound", "Diagnostic ultrasound imaging", 250.00),
    ("Echocardiogram", "Ultrasound of the heart", 400.00),
    ("Electrocardiogram", "Heart rhythm recording (ECG)", 75.00),
    ("Colonoscopy", "Examination of the colon", 900.00),
    ("Cardiac Catheterization", "Imaging of heart arteries", 3500.00),
    ("Angioplasty", "Opening of a blocked artery", 9800.00),
    ("Knee Arthroscopy", "Minimally invasive knee surgery", 3100.00),
    ("Hip Replacement", "Total hip arthroplasty", 15500.00),
    ("Cataract Surgery", "Lens replacement in the eye", 1800.00),
    ("Tonsillectomy", "Removal of the tonsils", 2100.00),
    ("Lumbar Puncture", "Spinal fluid sample", 650.00),
    ("EEG", "Brain activity recording", 300.00),
    ("Chemotherapy Session", "Single cancer drug infusion session", 2500.00),
    ("Biopsy", "Tissue sample for diagnosis", 700.00),
    ("Blood Transfusion", "Transfusion of blood products", 950.00),
    ("Fracture Casting", "Setting and casting a broken bone", 350.00),
]

APPOINTMENT_TYPES = ["Check-up", "Follow-up", "Consultation", "Pre-surgery Consult", "Lab Review"]
DOCTOR_STATUSES = ["Available", "Unavailable", "On Leave"]


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def random_date(start, end):
    """A random date between start and end, inclusive."""
    return start + timedelta(days=random.randint(0, (end - start).days))


def random_phone():
    return f"519-{random.randint(200, 999)}-{random.randint(0, 9999):04d}"


def sql_value(value):
    """Turn a Python value into SQL text. Quotes inside strings are doubled (ISO style)."""
    if value is None:
        return "NULL"
    if isinstance(value, str):
        return "'" + value.replace("'", "''") + "'"
    if isinstance(value, (date, time)):
        return "'" + value.isoformat() + "'"
    if isinstance(value, float):
        return f"{value:.2f}"
    return str(value)


def write_inserts(out, table, columns, rows, batch_size=500):
    """Write rows as multi-row INSERT statements, batch_size rows per statement."""
    out.write(f"\n-- {table}: {len(rows)} rows\n")
    for start in range(0, len(rows), batch_size):
        batch = rows[start:start + batch_size]
        out.write(f"INSERT INTO {table} ({', '.join(columns)})\nVALUES\n")
        lines = ["    (" + ", ".join(sql_value(v) for v in row) + ")" for row in batch]
        out.write(",\n".join(lines) + ";\n")


# ---------------------------------------------------------------------------
# Level 0 and 1: tables other tables point to
# ---------------------------------------------------------------------------

def make_patients():
    # Ontario health card style: 10 unique digits + a 2-letter version code
    numbers = random.sample(range(1_000_000_000, 10_000_000_000), NUM_PATIENTS)
    rows = []
    for i, n in enumerate(numbers, start=1):
        digits = str(n)
        card = f"{digits[:4]}-{digits[4:7]}-{digits[7:]}-{random.choice('ABCDEFGHJKMNPRSTVWXYZ')}{random.choice('ABCDEFGHJKMNPRSTVWXYZ')}"
        first = random.choice(FIRST_NAMES)
        last = random.choice(LAST_NAMES)
        dob = random_date(date(1935, 1, 1), date(2024, 12, 31))
        address = f"{random.randint(1, 2999)} {random.choice(STREETS)}, {random.choice(CITIES)}, ON"
        email = f"{first}.{last}{i}@example.com".lower().replace("'", "")
        rows.append((card, first, last, dob, address, random_phone(), email))
    return rows


def make_doctors():
    rows = []
    for staff_id in range(1007, 1007 + NUM_NEW_DOCTORS):
        first = random.choice(FIRST_NAMES)
        last = random.choice(LAST_NAMES)
        department = random.choice(list(DEPARTMENTS))
        email = f"{first[0]}{last}{staff_id}@codeblue.ca".lower().replace("'", "")
        status = random.choices(DOCTOR_STATUSES, weights=[8, 1, 1])[0]
        rows.append((staff_id, first, last, DEPARTMENTS[department], random_phone(),
                     email, status, department))
    return rows


def make_rooms():
    # 5 floors x 12 rooms. roomNo = floor * 100 + n, so (roomNo, floorNo) is always unique.
    # Room n on each floor: 1-6 Ward, 7-9 Semi-Private, 10-11 Private, 12 ICU
    # (floor 5's room 12 is an Operating Room instead).
    rows = []
    room_id = 1
    for floor in range(1, 6):
        for n in range(1, 13):
            if n <= 6:
                room_type, capacity = "Ward", 4
            elif n <= 9:
                room_type, capacity = "Semi-Private", 2
            elif n <= 11:
                room_type, capacity = "Private", 1
            elif floor == 5:
                room_type, capacity = "Operating Room", 1
            else:
                room_type, capacity = "ICU", 1
            # The real status is set later by set_room_status(), from the admissions.
            # This draw is kept only so the random sequence (and so every other
            # table's data) stays exactly the same as before the fix.
            random.choices(["Available", "Occupied", "Cleaning"], weights=[5, 4, 1])
            rows.append((room_id, floor * 100 + n, floor, room_type, capacity, None))
            room_id += 1
    return rows


def make_medications():
    return [(i, name, desc, cost) for i, (name, desc, cost, _) in enumerate(MEDICATIONS, start=1)]


def make_procedures():
    return [(i, name, desc, cost) for i, (name, desc, cost) in enumerate(PROCEDURES, start=1)]


# ---------------------------------------------------------------------------
# Level 2: tables that point to the ones above
# ---------------------------------------------------------------------------

def pick_patients_weighted(patient_cards):
    """About 15% of patients are 'frequent' and are 6x more likely to be picked.
    This gives some patients many appointments, so GROUP BY / HAVING queries
    have interesting results."""
    weights = [6 if random.random() < 0.15 else 1 for _ in patient_cards]
    return lambda: random.choices(patient_cards, weights=weights)[0]


def make_appointments(pick_patient, doctor_ids):
    rows = []
    doctor_slots = set()   # (staffId, date, time): a doctor can't be double-booked
    patient_slots = set()  # (healthCardNo, date, time): neither can a patient
    times = [time(h, m) for h in range(8, 17) for m in (0, 15, 30, 45)]
    appointment_id = 1
    while len(rows) < NUM_APPOINTMENTS:
        card = pick_patient()
        staff_id = random.choice(doctor_ids)
        day = random_date(date(2025, 1, 1), date(2027, 1, 31))
        if day.weekday() >= 5:  # no weekend appointments
            continue
        slot = random.choice(times)
        if (staff_id, day, slot) in doctor_slots or (card, day, slot) in patient_slots:
            continue
        doctor_slots.add((staff_id, day, slot))
        patient_slots.add((card, day, slot))

        if day >= REF_DATE:
            status = "Scheduled"
        else:
            status = random.choices(["Completed", "Cancelled", "No-show"], weights=[85, 10, 5])[0]
        rows.append((appointment_id, card, staff_id, day, slot,
                     random.choice(APPOINTMENT_TYPES), status))
        appointment_id += 1
    return rows


def make_admissions(patient_cards, rooms):
    # Operating rooms are for procedures, not overnight stays
    bed_room_ids = [r[0] for r in rooms if r[3] != "Operating Room"]
    capacity = {r[0]: r[4] for r in rooms}
    stays = {room_id: [] for room_id in bed_room_ids}  # roomId -> [(admitted, discharged)]
    rows = []
    for admission_id in range(1, NUM_ADMISSIONS + 1):
        card = random.choice(patient_cards)
        admitted = random_date(date(2025, 1, 1), REF_DATE)
        # Patients admitted in the last 2 weeks may still be in hospital (NULL discharge)
        if (REF_DATE - admitted).days <= 14 and random.random() < 0.6:
            discharged = None
        else:
            discharged = admitted + timedelta(days=random.randint(0, 14))  # always >= admitted
            # A discharge can't be recorded after "today", so cap it at REF_DATE
            discharged = min(discharged, REF_DATE)
        room_id = random.choice(bed_room_ids)
        # A room can never hold more patients at once than its capacity.
        # If the chosen room is full on any day of this stay, use the next room
        # (in roomId order) that has a free bed for the whole stay.
        start = bed_room_ids.index(room_id)
        for k in range(len(bed_room_ids)):
            candidate = bed_room_ids[(start + k) % len(bed_room_ids)]
            if room_has_space(stays[candidate], capacity[candidate], admitted, discharged):
                room_id = candidate
                break
        stays[room_id].append((admitted, discharged))
        rows.append((admission_id, card, room_id, admitted, discharged))
    return rows


def room_has_space(room_stays, room_capacity, admitted, discharged):
    """True if adding the stay [admitted, discharged] never puts more than
    room_capacity patients in the room on the same day. None = still admitted."""
    end = discharged or date.max
    # The number of patients only goes up when someone is admitted, so it is
    # enough to check the first day of this stay and every later admission day.
    check_days = [admitted] + [a for a, _ in room_stays if admitted < a <= end]
    for day in check_days:
        present = sum(1 for a, d in room_stays if a <= day <= (d or date.max))
        if present + 1 > room_capacity:
            return False
    return True


def set_room_status(rooms, admissions):
    """availabilityStatus must agree with the admissions: a room is 'Occupied'
    when its current patients (dischargeDate IS NULL) fill its capacity,
    otherwise 'Available'."""
    current = {}
    for _, _, room_id, _, discharged in admissions:
        if discharged is None:
            current[room_id] = current.get(room_id, 0) + 1
    return [(room_id, room_no, floor, room_type, capacity,
             "Occupied" if current.get(room_id, 0) >= capacity else "Available")
            for room_id, room_no, floor, room_type, capacity, _ in rooms]


def make_prescriptions(pick_patient, doctor_ids, medications):
    rows = []
    for prescription_id in range(1, NUM_PRESCRIPTIONS + 1):
        med_index = random.randrange(len(medications))
        strength = MEDICATIONS[med_index][3]
        rows.append((prescription_id, pick_patient(), random.choice(doctor_ids),
                     medications[med_index][0],
                     random_date(date(2025, 1, 1), REF_DATE),
                     strength, random.choice(FREQUENCIES)))
    return rows


def make_patient_procedures(pick_patient, procedures):
    procedure_ids = [p[0] for p in procedures]
    rows = []
    for pp_id in range(1, NUM_PATIENT_PROCEDURES + 1):
        rows.append((pp_id, pick_patient(), random.choice(procedure_ids),
                     random_date(date(2025, 1, 1), REF_DATE)))
    return rows


# ---------------------------------------------------------------------------
# Level 2 + 3: Bill and BillProcedure, built together so each bill only
# contains procedures of its own patient
# ---------------------------------------------------------------------------

def make_bills(patient_procedures):
    # Group procedures by patient, oldest first
    by_patient = {}
    for pp_id, card, _, pp_date in patient_procedures:
        by_patient.setdefault(card, []).append((pp_date, pp_id))

    bills, bill_procedures = [], []
    bill_id = 1
    for card, procs in by_patient.items():
        procs.sort()
        i = 0
        while i < len(procs):
            # Each bill covers the next 1-3 procedures of this patient
            chunk = procs[i:i + random.randint(1, 3)]
            i += len(chunk)
            bill_date = min(chunk[-1][0] + timedelta(days=random.randint(0, 14)), REF_DATE)

            if (REF_DATE - bill_date).days > 60:
                status = random.choices(["Paid", "Overdue"], weights=[80, 20])[0]
            else:
                status = random.choices(["Unpaid", "Paid", "Partially Paid"], weights=[5, 3, 2])[0]

            bills.append((bill_id, card, bill_date, status))
            for _, pp_id in chunk:
                bill_procedures.append((bill_id, pp_id))
            bill_id += 1
    return bills, bill_procedures


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    patients = make_patients()
    doctors = make_doctors()
    rooms = make_rooms()
    medications = make_medications()
    procedures = make_procedures()

    patient_cards = [p[0] for p in patients]
    doctor_ids = EX3_DOCTOR_IDS + [d[0] for d in doctors]
    pick_patient = pick_patients_weighted(patient_cards)

    appointments = make_appointments(pick_patient, doctor_ids)
    admissions = make_admissions(patient_cards, rooms)
    rooms = set_room_status(rooms, admissions)  # status must match the admissions
    prescriptions = make_prescriptions(pick_patient, doctor_ids, medications)
    patient_procedures = make_patient_procedures(pick_patient, procedures)
    bills, bill_procedures = make_bills(patient_procedures)

    with open(OUTPUT_FILE, "w", encoding="utf-8") as out:
        out.write("-- SE 3309 Assignment 3 - Group 19 - Item 4\n")
        out.write("-- Generated by SRC/generate_data.py. Do not edit by hand; rerun the generator.\n")
        out.write("-- Run AFTER SQL/ex2.sql and SQL/ex3.sql.\n\n")
        out.write("USE code_blue;\n")
        out.write("START TRANSACTION;\n")

        # Parents first, so every foreign key already has a row to point to
        write_inserts(out, "Patient",
                      ["healthCardNo", "fName", "lName", "DOB", "address", "phoneNo", "email"], patients)
        write_inserts(out, "Doctor",
                      ["staffId", "fName", "lName", "specialization", "phoneNo", "email",
                       "availabilityStatus", "departmentName"], doctors)
        write_inserts(out, "HospitalRoom",
                      ["roomId", "roomNo", "floorNo", "roomType", "capacity", "availabilityStatus"], rooms)
        write_inserts(out, "Medication",
                      ["medicationId", "medicationName", "description", "unitCost"], medications)
        write_inserts(out, PROCEDURE_TABLE,
                      ["procedureId", "procedureName", "description", "cost"], procedures)
        write_inserts(out, "Appointment",
                      ["appointmentId", "healthCardNo", "staffId", "appointmentDate",
                       "appointmentTime", "appointmentType", "status"], appointments)
        write_inserts(out, "Admission",
                      ["admissionId", "healthCardNo", "roomId", "admissionDate", "dischargeDate"], admissions)
        write_inserts(out, "Prescription",
                      ["prescriptionId", "healthCardNo", "staffId", "medicationId",
                       "prescriptionDate", "dosage", "frequency"], prescriptions)
        write_inserts(out, "PatientProcedure",
                      ["patientProcedureId", "healthCardNo", "procedureId", "procedureDate"],
                      patient_procedures)
        write_inserts(out, "Bill",
                      ["billId", "healthCardNo", "billDate", "paymentStatus"], bills)
        write_inserts(out, "BillProcedure",
                      ["billId", "patientProcedureId"], bill_procedures)

        out.write("\nCOMMIT;\n")

    counts = {
        "Patient": len(patients), "Doctor (new)": len(doctors), "HospitalRoom": len(rooms),
        "Medication": len(medications), "Procedure": len(procedures),
        "Appointment": len(appointments), "Admission": len(admissions),
        "Prescription": len(prescriptions), "PatientProcedure": len(patient_procedures),
        "Bill": len(bills), "BillProcedure": len(bill_procedures),
    }
    print(f"Wrote {OUTPUT_FILE}")
    for table, n in counts.items():
        print(f"  {table:<18}{n:>6}")


if __name__ == "__main__":
    main()
