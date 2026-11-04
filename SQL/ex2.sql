
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

#Store information about medications
CREATE TABLE Medication (
    medicationId INT PRIMARY KEY,
    medicationName VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    unitCost DECIMAL(10,2)
);

#Store information about hospital procedures
CREATE TABLE `Procedure` (
    procedureId INT PRIMARY KEY,
    procedureName VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    cost DECIMAL(10,2)
);

