USE code_blue;

-- Modification 1
-- Mark past scheduled appointments as no-shows
UPDATE Appointment
SET status = 'No-show'
WHERE appointmentId > 0
AND status = 'Scheduled'
AND appointmentDate < CURRENT_DATE;



-- ============================================================
-- MODIFICATION 2: Add and Populate Bill Issue and Due Dates
-- ============================================================

-- STEP 1: Add the two new columns to the Bill table.

ALTER TABLE Bill
ADD COLUMN issueDate DATE,
ADD COLUMN dueDate DATE;


-- STEP 2: BEFORE - Display existing bill information.

SELECT
    billID,
    billDate,
    paymentStatus
FROM Bill
ORDER BY billID
LIMIT 20;


-- STEP 3: PREVIEW - Show what the new dates will look like.
-- issueDate will match billDate.
-- dueDate will be 30 days after billDate.

SELECT
    billID,
    billDate,
    billDate AS proposedIssueDate,
    DATE_ADD(billDate, INTERVAL 30 DAY) AS proposedDueDate
FROM Bill
ORDER BY billID
LIMIT 20;


-- STEP 4: UPDATE - Run these after verifying the preview.
-- Remove the comment markers to execute.


-- UPDATE 1: Set issueDate equal to billDate.

UPDATE Bill
SET issueDate = billDate
WHERE billID > 0;


-- UPDATE 2: Set dueDate to 30 days after issueDate.

UPDATE Bill
SET dueDate = DATE_ADD(issueDate, INTERVAL 30 DAY)
WHERE billID > 0;



-- STEP 5: AFTER - Display the updated bill information.

SELECT
    billID,
    billDate,
    issueDate,
    dueDate
FROM Bill
ORDER BY billID
LIMIT 20;


-- STEP 6: VERIFICATION - Check for missing dates.

SELECT
    COUNT(*) AS totalBills,
    SUM(issueDate IS NULL) AS missingIssueDates,
    SUM(dueDate IS NULL) AS missingDueDates
FROM Bill;

-- ensure 654 bills
SELECT
    COUNT(*) AS totalBills,
    SUM(issueDate IS NULL) AS missingIssueDates,
    SUM(dueDate IS NULL) AS missingDueDates
FROM Bill;



-- ============================================================
-- MODIFICATION 3: Update Overdue Bill Payment Statuses
-- ============================================================

-- Assumed current date: November 1, 2026.
-- Bills with a due date before this date are overdue
-- if their payment status is Unpaid or Partially Paid.


-- STEP 1: BEFORE - Display bills that may need updating.

SELECT
    billID,
    billDate,
    issueDate,
    dueDate,
    paymentStatus
FROM Bill
WHERE dueDate < '2026-11-01'
  AND paymentStatus IN ('Unpaid', 'Partially Paid')
ORDER BY dueDate;


-- STEP 2: PREVIEW - Show the proposed payment status changes.
-- This SELECT does not modify any data.

SELECT
    billID,
    dueDate,
    paymentStatus AS currentPaymentStatus,
    'Overdue' AS proposedPaymentStatus
FROM Bill
WHERE dueDate < '2026-11-01'
  AND paymentStatus IN ('Unpaid', 'Partially Paid')
ORDER BY dueDate;


-- STEP 3: UPDATE - Change qualifying bills to Overdue.

UPDATE Bill
SET paymentStatus = 'Overdue'
WHERE billID > 0
  AND dueDate < '2026-11-01'
  AND paymentStatus IN ('Unpaid', 'Partially Paid');



-- STEP 4: AFTER - Display bills now marked as Overdue.

SELECT
    billID,
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


-- STEP 6: FINAL CHECK - Ensure no qualifying unpaid bills
-- remain with a due date before November 1, 2026.

SELECT
    COUNT(*) AS remainingOverdueBills
FROM Bill
WHERE dueDate < '2026-11-01'
  AND paymentStatus IN ('Unpaid', 'Partially Paid');
