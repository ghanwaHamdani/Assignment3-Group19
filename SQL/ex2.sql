
CREATE DATABASE IF NOT EXISTS code_blue;

USE code_blue;

SELECT DATABASE();

CREATE TABLE Department (
    departmentName VARCHAR(100) PRIMARY KEY,
    location VARCHAR(100),
    phoneNo VARCHAR(20),
    opHrsDescription VARCHAR(255),
    specialty VARCHAR(100)
);


