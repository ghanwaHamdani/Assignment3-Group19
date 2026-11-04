#  SE 3309 Assignment 3 - Group 19 - Item 3
#  Three different INSERT techniques on the Doctor relation (code_blue database)

USE code_blue;

#  Reset: remove rows left over from an earlier run so the script can be re-run.
#  Doctor is cleared first because its rows reference Department.
DELETE FROM Doctor;
DELETE FROM Department;

#  Setup (not one of the three demo INSERTs):
#  Doctor.departmentName is a foreign key to Department, so the departments
#  must exist first. Departments 4-6 deliberately have no doctor yet; INSERT #3 uses that.
INSERT INTO Department (departmentName, location, phoneNo, opHrsDescription, specialty)
VALUES
    ('Emergency',  'Building A, Floor 1', '519-555-0100', 'Open 24/7',             'Emergency Medicine'),
    ('Cardiology', 'Building B, Floor 2', '519-555-0200', 'Mon-Fri 08:00-17:00',   'Cardiology'),
    ('Neurology',  'Building B, Floor 3', '519-555-0300', 'Mon-Fri 08:00-17:00',   'Neurology'),
    ('Oncology',   'Building C, Floor 2', '519-555-0400', 'Mon-Fri 07:30-18:00',   'Oncology'),
    ('Pediatrics', 'Building D, Floor 1', '519-555-0500', 'Mon-Sat 08:00-20:00',   'Pediatrics'),
    ('Radiology',  'Building A, Floor B1', '519-555-0600', 'Mon-Sun 07:00-23:00',  'Diagnostic Imaging');

#  Doctor is empty before the demo
SELECT * FROM Doctor;


#  INSERT 1 - One complete row, positional VALUES, no column list
#  A value is given for all 8 columns, in the exact order the table was created.
INSERT INTO Doctor
VALUES (1001, 'Sarah', 'Chen', 'Emergency Medicine', '519-555-0101',
        'schen@codeblue.ca', 'Available', 'Emergency');


#  INSERT 2 - Explicit column list, several rows in one statement
#  Only 6 of the 8 columns are named; email and availabilityStatus are left out,
#  so the DBMS fills them with their default (NULL).
INSERT INTO Doctor (staffId, fName, lName, specialization, phoneNo, departmentName)
VALUES
    (1002, 'Omar',  'Haddad', 'Interventional Cardiology', '519-555-0201', 'Cardiology'),
    (1003, 'Priya', 'Nair',   'Neurophysiology',           '519-555-0301', 'Neurology');


#  INSERT 3 - INSERT ... SELECT (rows produced by a query)
#  Creates one on-call doctor for every department that has no doctor yet.
#  The values are derived from other data: specialization and phone come from
#  Department, and staffId continues from the highest existing staffId.
#  availabilityStatus uses one of the values defined in Assignment 2
#  (Available / Unavailable / On Leave).
INSERT INTO Doctor (staffId, fName, lName, specialization, phoneNo, availabilityStatus, departmentName)
SELECT (SELECT MAX(staffId) FROM Doctor)
           + ROW_NUMBER() OVER (ORDER BY d.departmentName),
       'On-Call',
       'Resident',
       d.specialty,
       d.phoneNo,
       'Available',
       d.departmentName
FROM Department d
WHERE NOT EXISTS (SELECT *
                  FROM Doctor doc
                  WHERE doc.departmentName = d.departmentName);


#  Show the resulting relation
SELECT * FROM Doctor;