-- SE 3309 Assignment 3 - Group 19 - Item 5
-- Seven SELECT-FROM-WHERE queries on the Code Blue database (code_blue).
-- Each query uses a different SQL feature (Q1 is the one plain query allowed).
-- Written in ISO SQL: DATE '...' literals, EXTRACT, CASE, explicit JOIN ... ON.

USE code_blue;


-- Q1 - Simple query (single table, WHERE + ORDER BY)
-- Front desk: today's schedule. All scheduled appointments on 1 Dec 2026, in time order.
SELECT appointmentTime, healthCardNo, staffId, appointmentType
FROM Appointment
WHERE appointmentDate = DATE '2026-12-01'
  AND status = 'Scheduled'
ORDER BY appointmentTime;


-- Q2 - Join over three relations
-- Cardiology's upcoming schedule: who is seeing which cardiologist, 1-11 Dec 2026.
-- Patient and Doctor are joined in to turn the foreign keys into names.
SELECT CAST(a.appointmentDate AS CHAR(10)) AS appointmentDate, a.appointmentTime,
       p.fName AS patientFirst, p.lName AS patientLast,
       d.lName AS doctor, a.appointmentType
FROM Appointment AS a
JOIN Patient AS p ON p.healthCardNo = a.healthCardNo
JOIN Doctor  AS d ON d.staffId = a.staffId
WHERE d.departmentName = 'Cardiology'
  AND a.status = 'Scheduled'
  AND a.appointmentDate BETWEEN DATE '2026-12-01' AND DATE '2026-12-11'
ORDER BY a.appointmentDate, a.appointmentTime;


-- Q3 - GROUP BY with HAVING
-- Frequent patients: patients with 11 or more completed visits.
-- WHERE filters rows BEFORE grouping (only completed visits are counted);
-- HAVING filters groups AFTER counting.
SELECT p.healthCardNo, p.fName, p.lName, COUNT(*) AS completedVisits
FROM Patient AS p
JOIN Appointment AS a ON a.healthCardNo = p.healthCardNo
WHERE a.status = 'Completed'
GROUP BY p.healthCardNo, p.fName, p.lName
HAVING COUNT(*) >= 11
ORDER BY completedVisits DESC, p.lName;


-- Q4 - EXISTS and NOT EXISTS (correlated subqueries)
-- Follow-up list: patients admitted since 1 Jul 2026 who have never had an appointment,
-- so the clinic can call them to book a follow-up.
-- Each subquery is re-checked for every patient p (that is what "correlated" means).
SELECT p.healthCardNo, p.fName, p.lName, p.phoneNo
FROM Patient AS p
WHERE EXISTS (SELECT *
              FROM Admission AS ad
              WHERE ad.healthCardNo = p.healthCardNo
                AND ad.admissionDate >= DATE '2026-07-01')
  AND NOT EXISTS (SELECT *
                  FROM Appointment AS a
                  WHERE a.healthCardNo = p.healthCardNo)
ORDER BY p.lName, p.fName;


-- Q5 - Nested aggregate: subquery in HAVING over a derived table
-- Busiest doctors: doctors with more appointments than the average doctor.
-- The inner query counts appointments per doctor; the middle one averages those counts;
-- HAVING keeps only doctors above that average.
SELECT d.staffId, d.fName, d.lName, d.departmentName, COUNT(*) AS numAppointments
FROM Doctor AS d
JOIN Appointment AS a ON a.staffId = d.staffId
GROUP BY d.staffId, d.fName, d.lName, d.departmentName
HAVING COUNT(*) > (SELECT AVG(perDoctor.cnt)
                   FROM (SELECT COUNT(*) AS cnt
                         FROM Appointment
                         GROUP BY staffId) AS perDoctor)
ORDER BY numAppointments DESC;


-- Q6 - LEFT OUTER JOIN with aggregation
-- Room occupancy report: for each room type, how many rooms exist and how many
-- patients are currently in them (still admitted = dischargeDate IS NULL).
-- The LEFT OUTER JOIN keeps room types with no current patients (they show 0),
-- which an inner join would drop. The discharge condition is in ON, not WHERE,
-- so that empty rooms are not filtered out.
SELECT r.roomType,
       COUNT(DISTINCT r.roomId) AS numRooms,
       COUNT(ad.admissionId)    AS currentPatients
FROM HospitalRoom AS r
LEFT OUTER JOIN Admission AS ad
       ON ad.roomId = r.roomId
      AND ad.dischargeDate IS NULL
GROUP BY r.roomType
ORDER BY r.roomType;


-- Q7 - CASE expressions inside aggregates (conditional counting) + EXTRACT
-- Monthly appointment report for Jan-Oct 2026: totals, and how many were
-- completed, cancelled, or no-shows. One pass over the table produces all columns.
SELECT EXTRACT(MONTH FROM appointmentDate) AS appointmentMonth,
       COUNT(*) AS total,
       SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS completed,
       SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
       SUM(CASE WHEN status = 'No-show'   THEN 1 ELSE 0 END) AS noShows
FROM Appointment
WHERE appointmentDate BETWEEN DATE '2026-01-01' AND DATE '2026-10-31'
GROUP BY EXTRACT(MONTH FROM appointmentDate)
ORDER BY appointmentMonth;
