USE code_blue;

-- create a view for displaying patient contact information (VIEW 1)
CREATE VIEW PatientContact AS
SELECT healthCardNo, fName, lName, phoneNo
FROM Patient;

-- joins the Doctor and Appointment tables + displays appointments associated with each doctor (VIEW 2)
CREATE VIEW DoctorAppointments AS
SELECT d.staffId, d.fName, d.lName, d.departmentName, COUNT(a.appointmentId) totalAppts
FROM Doctor d 
JOIN Appointment a
    ON d.staffId = a.staffId
GROUP BY d.staffId, d.fName, d.lName, d.departmentName;

-- queries for previously created views
SELECT *
FROM PatientContact
LIMIT 5;

SELECT *
FROM DoctorAppointments
ORDER BY totalAppts DESC
LIMIT 5;

-- testing modification of the PatientContact view by changing a value
START TRANSACTION;

UPDATE patientcontact
SET phoneNo = '519-555-0199'
WHERE healthCardNo = '1001-466-370-XT'; -- updates the phone number at this specific healthCardNo

SELECT * 
FROM PatientContact
WHERE healthCardNo = '1001-466-370-XT'; -- checks if it was changed in the PatientContact view

SELECT healthCardNo, phoneNo
FROM Patient
WHERE healthCardNo = '1001-466-370-XT'; -- checks if it was changed in the original Patient table

ROLLBACK; -- changes the phone number back

SELECT healthCardNo, phoneNo
FROM Patient
WHERE healthCardNo = '1001-466-370-XT';

-- testing INSERT through simple view
START TRANSACTION;

INSERT INTO PatientContact (healthCardNo, fName, lName, phoneNo)
VALUES ('EX7-TEST-0001', 'Test', 'Patient', '519-555-0100');

SELECT *
FROM PatientContact
WHERE healthCardNo = 'EX7-TEST-0001';

ROLLBACK;

-- testing INSERT with missing required attributes
INSERT INTO PatientContact (healthCardNo, phoneNo)
VALUES ('EX7-TEST-0002', '519-555-0101');

-- testing modification of the DoctorAppointment view by changing a value
UPDATE DoctorAppointments
SET totalAppts = 100
WHERE staffId = 1001;

-- testing by inserting a tuple into a view to check if modification is allowed
INSERT INTO DoctorAppointments (staffId, fName, lName, departmentName, totalAppts)
VALUES (9999, 'Test', 'Doctor', 'Cardiology', 10);

