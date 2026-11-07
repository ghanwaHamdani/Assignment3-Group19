USE code_blue;

-- Modification 1
-- Mark past scheduled appointments as no-shows
UPDATE Appointment
SET status = 'No-show'
WHERE appointmentId > 0
AND status = 'Scheduled'
AND appointmentDate < CURRENT_DATE;
