
-- SE 3309 Assignment 3 - Group 19
-- Exercise 6: Data Modification Commands
-- Code Blue Database
--
-- Three UPDATE commands:
-- 1. Mark past scheduled appointments as No-show
-- 2. Populate Bill issueDate and dueDate
-- 3. Mark qualifying unpaid bills as Overdue
--
-- Prerequisite: Bill already contains issueDate and dueDate
-- as defined in SQL/ex2.sql.

USE code_blue;


-- ============================================================
-- MODIFICATION 1: Mark Past Scheduled Appointments as No-show
-- ============================================================

-- STEP 1: BEFORE - Display appointments requiring an update.

SELECT
    appointmentId,
    appointmentDate,
    status
FROM Appointment
WHERE status = 'Scheduled'
  AND appointmentDate < CURRENT_DATE
ORDER BY appointmentDate
LIMIT 20;


-- STEP 2: PREVIEW - Show the proposed status changes.

SELECT
    appointmentId,
    appointmentDate,
    status AS currentStatus,
    'No-show' AS proposedStatus
FROM Appointment
WHERE status = 'Scheduled'
  AND appointmentDate < CURRENT_DATE
ORDER BY appointmentDate
LIMIT 20;


-- STEP 3: UPDATE - Mark qualifying appointments as No-show.

UPDATE Appointment
SET status = 'No-show'
WHERE appointmentId > 0
  AND status = 'Scheduled'
  AND appointmentDate < CURRENT_DATE;


-- STEP 4: AFTER - Verify updated appointment records.

SELECT
    appointmentId,
    appointmentDate,
    status
FROM Appointment
WHERE status = 'No-show'
ORDER BY appointmentDate
LIMIT 20;


-- STEP 5: VERIFICATION - Check for remaining qualifying rows.

SELECT
    COUNT(*) AS remainingPastScheduledAppointments
FROM Appointment
WHERE status = 'Scheduled'
  AND appointmentDate < CURRENT_DATE;



-- ============================================================
-- MODIFICATION 2: Populate Bill Issue and Due Dates
-- ============================================================

-- The columns already exist in ex2.sql.
-- No ALTER TABLE statement is required.

-- STEP 1: BEFORE - Display existing bill information.

SELECT
    billId,
    billDate,
    issueDate,
    dueDate,
    paymentStatus
FROM Bill
ORDER BY billId
LIMIT 20;


-- STEP 2: PREVIEW - Show the proposed dates.
-- issueDate = billDate
-- dueDate = 30 days after billDate

SELECT
    billId,
    billDate,
    billDate AS proposedIssueDate,
    billDate + INTERVAL '30' DAY AS proposedDueDate
FROM Bill
ORDER BY billId
LIMIT 20;


-- STEP 3: UPDATE - Populate both columns in one command.

UPDATE Bill
SET issueDate = billDate,
    dueDate = billDate + INTERVAL '30' DAY
WHERE billId > 0;


-- STEP 4: AFTER - Display updated bill information.

SELECT
    billId,
    billDate,
    issueDate,
    dueDate,
    paymentStatus
FROM Bill
ORDER BY billId
LIMIT 20;


-- STEP 5: VERIFICATION - Check for missing dates.

SELECT
    COUNT(*) AS totalBills,
    SUM(CASE WHEN issueDate IS NULL THEN 1 ELSE 0 END)
        AS missingIssueDates,
    SUM(CASE WHEN dueDate IS NULL THEN 1 ELSE 0 END)
        AS missingDueDates
FROM Bill;



-- ============================================================
-- MODIFICATION 3: Update Overdue Bill Payment Statuses
-- ============================================================

-- Reference date: November 1, 2026.
-- Bills with dueDate before this date are overdue
-- if their paymentStatus is Unpaid or Partially Paid.

-- STEP 1: BEFORE - Display bills requiring an update.

SELECT
    billId,
    billDate,
    issueDate,
    dueDate,
    paymentStatus
FROM Bill
WHERE dueDate < DATE '2026-11-01'
  AND paymentStatus IN ('Unpaid', 'Partially Paid')
ORDER BY dueDate;


-- STEP 2: PREVIEW - Show the proposed status changes.

SELECT
    billId,
    dueDate,
    paymentStatus AS currentPaymentStatus,
    'Overdue' AS proposedPaymentStatus
FROM Bill
WHERE dueDate < DATE '2026-11-01'
  AND paymentStatus IN ('Unpaid', 'Partially Paid')
ORDER BY dueDate;


-- STEP 3: UPDATE - Mark qualifying bills as Overdue.

UPDATE Bill
SET paymentStatus = 'Overdue'
WHERE billId > 0
  AND dueDate < DATE '2026-11-01'
  AND paymentStatus IN ('Unpaid', 'Partially Paid');


-- STEP 4: AFTER - Display bills marked as Overdue.

SELECT
    billId,
    billDate,
    issueDate,
    dueDate,
    paymentStatus
FROM Bill
WHERE paymentStatus = 'Overdue'
ORDER BY dueDate;


-- STEP 5: VERIFICATION - Count bills by payment status.

SELECT
    paymentStatus,
    COUNT(*) AS numberOfBills
FROM Bill
GROUP BY paymentStatus
ORDER BY paymentStatus;


-- STEP 6: FINAL CHECK - Ensure no qualifying unpaid bills remain.

SELECT
    COUNT(*) AS remainingOverdueBills
FROM Bill
WHERE dueDate < DATE '2026-11-01'
  AND paymentStatus IN ('Unpaid', 'Partially Paid');
