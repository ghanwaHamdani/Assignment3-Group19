-- SE 3309 Assignment 3 - Group 19 - Item 4
-- Checks to run after loading SRC/code_blue_data.sql.
-- Screenshots of these results are the proof for the DESC document.

USE code_blue;

-- 1. Row count of every table
SELECT 'Department' AS tableName, COUNT(*) AS numRows FROM Department
UNION ALL SELECT 'Doctor', COUNT(*) FROM Doctor
UNION ALL SELECT 'Patient', COUNT(*) FROM Patient
UNION ALL SELECT 'HospitalRoom', COUNT(*) FROM HospitalRoom
UNION ALL SELECT 'Medication', COUNT(*) FROM Medication
UNION ALL SELECT 'Procedure', COUNT(*) FROM `Procedure`
UNION ALL SELECT 'Appointment', COUNT(*) FROM Appointment
UNION ALL SELECT 'Admission', COUNT(*) FROM Admission
UNION ALL SELECT 'Prescription', COUNT(*) FROM Prescription
UNION ALL SELECT 'PatientProcedure', COUNT(*) FROM PatientProcedure
UNION ALL SELECT 'Bill', COUNT(*) FROM Bill
UNION ALL SELECT 'BillProcedure', COUNT(*) FROM BillProcedure;

-- 2. Every bill only contains procedures of its own patient (expected: 0)
SELECT COUNT(*) AS mismatchedBillProcedures
FROM BillProcedure bp
JOIN Bill b ON b.billId = bp.billId
JOIN PatientProcedure pp ON pp.patientProcedureId = bp.patientProcedureId
WHERE b.healthCardNo <> pp.healthCardNo;

-- 3. About 5 sample rows per table, for the DESC document.
-- LIMIT is MySQL syntax (MySQL doesn't support the ISO FETCH FIRST n ROWS ONLY).
-- These are helper checks, not one of the graded exN.sql files.
SELECT * FROM Department;
SELECT * FROM Doctor ORDER BY staffId LIMIT 5;
SELECT * FROM Patient LIMIT 5;
SELECT * FROM HospitalRoom LIMIT 5;
SELECT * FROM Medication LIMIT 5;
SELECT * FROM `Procedure` LIMIT 5;
SELECT * FROM Appointment LIMIT 5;
SELECT * FROM Admission LIMIT 5;
SELECT * FROM Prescription LIMIT 5;
SELECT * FROM PatientProcedure LIMIT 5;
SELECT * FROM Bill LIMIT 5;
SELECT * FROM BillProcedure LIMIT 5;
