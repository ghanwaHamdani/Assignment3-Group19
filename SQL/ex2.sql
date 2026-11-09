
#Create and select the Code Blue database
CREATE DATABASE IF NOT EXISTS code_blue;

USE code_blue;

#Check which database is being used
SELECT DATABASE();


#Store information about hospital departments
CREATE TABLE Department (
    departmentName VARCHAR(100) PRIMARY KEY,
    location VARCHAR(100),
    phoneNo VARCHAR(20),
    opHrsDescription VARCHAR(255),
    specialty VARCHAR(100)
);

USE code_blue;

DESCRIBE Department;

#Store patient personal and contact information
CREATE TABLE Patient (
    healthCardNo VARCHAR(20) PRIMARY KEY,
    fName VARCHAR(50) NOT NULL,
    lName VARCHAR(50) NOT NULL,
    DOB DATE,
    address VARCHAR(255),
    phoneNo VARCHAR(20),
    email VARCHAR(100)
);

DESCRIBE Patient;

#Store doctor information and their assigned department
CREATE TABLE Doctor (
    staffId INT PRIMARY KEY,
    fName VARCHAR(50) NOT NULL,
    lName VARCHAR(50) NOT NULL,
    specialization VARCHAR(100),
    phoneNo VARCHAR(20),
    email VARCHAR(100),
    availabilityStatus VARCHAR(50),
    departmentName VARCHAR(100),
    FOREIGN KEY (departmentName)
        REFERENCES Department(departmentName)
);


DESCRIBE Doctor;

SHOW CREATE TABLE Doctor;


#Store hospital room information and availability
CREATE TABLE HospitalRoom (
    roomId INT PRIMARY KEY,
    roomNo INT NOT NULL,
    floorNo INT NOT NULL,
    roomType VARCHAR(50),
    capacity INT,
    availabilityStatus VARCHAR(50),
    UNIQUE (roomNo, floorNo),
    CHECK (capacity > 0)
);


DESCRIBE HospitalRoom;

SHOW CREATE TABLE HospitalRoom;


# Store information about medications

CREATE TABLE Medication (
    medicationId INT PRIMARY KEY,
    medicationName VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    unitCost DECIMAL(10,2)
);

DESCRIBE Medication;


#Store information about hospital procedures
CREATE TABLE `Procedure` (
    procedureId INT PRIMARY KEY,
    procedureName VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    cost DECIMAL(10,2)
);

DESCRIBE `Procedure`;

# Store appointments scheduled between patients and doctors
CREATE TABLE Appointment (
    appointmentId INT PRIMARY KEY,
    healthCardNo VARCHAR(20) NOT NULL,
    staffId INT NOT NULL,
    appointmentDate DATE NOT NULL,
    appointmentTime TIME NOT NULL,
    appointmentType VARCHAR(100),
    status VARCHAR(50),

    FOREIGN KEY (healthCardNo)
        REFERENCES Patient(healthCardNo),

    FOREIGN KEY (staffId)
        REFERENCES Doctor(staffId)
);

DESCRIBE Appointment;

SHOW CREATE TABLE Appointment;

# Store patient hospital admissions and assigned rooms
CREATE TABLE Admission (
    admissionId INT PRIMARY KEY,
    healthCardNo VARCHAR(20) NOT NULL,
    roomId INT NOT NULL,
    admissionDate DATE NOT NULL,
    dischargeDate DATE,

    FOREIGN KEY (healthCardNo)
        REFERENCES Patient(healthCardNo),

    FOREIGN KEY (roomId)
        REFERENCES HospitalRoom(roomId),

    CHECK (
        dischargeDate IS NULL
        OR dischargeDate >= admissionDate
    )
);

DESCRIBE Admission;

SHOW CREATE TABLE Admission;

# Store medications prescribed to patients
CREATE TABLE Prescription (
    prescriptionId INT PRIMARY KEY,
    healthCardNo VARCHAR(20) NOT NULL,
    staffId INT NOT NULL,
    medicationId INT NOT NULL,
    prescriptionDate DATE NOT NULL,
    dosage VARCHAR(100),
    frequency VARCHAR(100),

    FOREIGN KEY (healthCardNo)
        REFERENCES Patient(healthCardNo),

    FOREIGN KEY (staffId)
        REFERENCES Doctor(staffId),

    FOREIGN KEY (medicationId)
        REFERENCES Medication(medicationId)
);

DESCRIBE Prescription;

SHOW CREATE TABLE Prescription;

# Record procedures performed on patients
CREATE TABLE PatientProcedure (
    patientProcedureId INT PRIMARY KEY,
    healthCardNo VARCHAR(20) NOT NULL,
    procedureId INT NOT NULL,
    procedureDate DATE NOT NULL,

    FOREIGN KEY (healthCardNo)
        REFERENCES Patient(healthCardNo),

    FOREIGN KEY (procedureId)
        REFERENCES `Procedure`(procedureId)
);

DESCRIBE PatientProcedure;

SHOW CREATE TABLE PatientProcedure;

# Store patient billing information
CREATE TABLE Bill (
    billId INT PRIMARY KEY,
    healthCardNo VARCHAR(20) NOT NULL,
    billDate DATE NOT NULL,
    issueDate DATE,
    dueDate DATE,
    paymentStatus VARCHAR(50),

    FOREIGN KEY (healthCardNo)
        REFERENCES Patient(healthCardNo)
);


DESCRIBE Bill;

SHOW CREATE TABLE Bill;

# Link billed procedures to patient bills
CREATE TABLE BillProcedure (
    billId INT NOT NULL,
    patientProcedureId INT NOT NULL,

    PRIMARY KEY (billId, patientProcedureId),

    FOREIGN KEY (billId)
        REFERENCES Bill(billId),

    FOREIGN KEY (patientProcedureId)
        REFERENCES PatientProcedure(patientProcedureId)
);

DESCRIBE BillProcedure;

SHOW TABLES;

USE code_blue;
SHOW TABLES;

USE code_blue;

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'code_blue'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;

USE code_blue;

SELECT
    TABLE_NAME,
    TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'code_blue'
  AND TABLE_TYPE = 'BASE TABLE';
