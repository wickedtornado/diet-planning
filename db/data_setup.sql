-- Create the main patient table
CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('M', 'F', 'Other') NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100),
    address TEXT,
    emergency_contact VARCHAR(100),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create the visits table to track each doctor visit
CREATE TABLE visits (
    visit_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    visit_date DATE NOT NULL,
    doctor_name VARCHAR(100) NOT NULL,
    visit_type VARCHAR(50) DEFAULT 'Regular Checkup',
    notes TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

-- Create the diagnoses table with ICD-10 codes
CREATE TABLE diagnoses (
    diagnosis_id INT PRIMARY KEY AUTO_INCREMENT,
    visit_id INT NOT NULL,
    icd10_code VARCHAR(10) NOT NULL,
    diagnosis_description TEXT NOT NULL,
    severity ENUM('Mild', 'Moderate', 'Severe') DEFAULT 'Moderate',
    diagnosis_date DATE NOT NULL,
    FOREIGN KEY (visit_id) REFERENCES visits(visit_id)
);

-- Create the medications table
CREATE TABLE medications (
    medication_id INT PRIMARY KEY AUTO_INCREMENT,
    diagnosis_id INT NOT NULL,
    medication_name VARCHAR(100) NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    frequency VARCHAR(50) NOT NULL,
    duration VARCHAR(50) NOT NULL,
    instructions TEXT,
    prescribed_date DATE NOT NULL,
    FOREIGN KEY (diagnosis_id) REFERENCES diagnoses(diagnosis_id)
);

-- Insert 50 patients
INSERT INTO patients (first_name, last_name, date_of_birth, gender, phone, email, address, emergency_contact) VALUES
('John', 'Smith', '1985-03-15', 'M', '555-0101', 'john.smith@email.com', '123 Main St, Anytown, USA', 'Jane Smith - 555-0102'),
('Emily', 'Johnson', '1990-07-22', 'F', '555-0103', 'emily.johnson@email.com', '456 Oak Ave, Anytown, USA', 'Robert Johnson - 555-0104'),
('Michael', 'Brown', '1978-11-08', 'M', '555-0105', 'michael.brown@email.com', '789 Pine Rd, Anytown, USA', 'Sarah Brown - 555-0106'),
('Sarah', 'Davis', '1992-02-14', 'F', '555-0107', 'sarah.davis@email.com', '321 Elm St, Anytown, USA', 'David Davis - 555-0108'),
('David', 'Wilson', '1975-09-30', 'M', '555-0109', 'david.wilson@email.com', '654 Maple Dr, Anytown, USA', 'Lisa Wilson - 555-0110'),
('Lisa', 'Miller', '1988-05-18', 'F', '555-0111', 'lisa.miller@email.com', '987 Cedar Ln, Anytown, USA', 'Mark Miller - 555-0112'),
('Robert', 'Garcia', '1982-12-03', 'M', '555-0113', 'robert.garcia@email.com', '147 Birch Way, Anytown, USA', 'Maria Garcia - 555-0114'),
('Jennifer', 'Martinez', '1995-08-27', 'F', '555-0115', 'jennifer.martinez@email.com', '258 Spruce St, Anytown, USA', 'Carlos Martinez - 555-0116'),
('Christopher', 'Anderson', '1973-04-12', 'M', '555-0117', 'chris.anderson@email.com', '369 Willow Ave, Anytown, USA', 'Amanda Anderson - 555-0118'),
('Jessica', 'Taylor', '1987-10-05', 'F', '555-0119', 'jessica.taylor@email.com', '741 Poplar Rd, Anytown, USA', 'Brian Taylor - 555-0120'),
('Matthew', 'Thomas', '1980-01-19', 'M', '555-0121', 'matthew.thomas@email.com', '852 Ash Dr, Anytown, USA', 'Michelle Thomas - 555-0122'),
('Ashley', 'Jackson', '1993-06-11', 'F', '555-0123', 'ashley.jackson@email.com', '963 Hickory Ln, Anytown, USA', 'James Jackson - 555-0124'),
('Joshua', 'White', '1976-03-28', 'M', '555-0125', 'joshua.white@email.com', '159 Sycamore St, Anytown, USA', 'Rachel White - 555-0126'),
('Amanda', 'Harris', '1991-09-16', 'F', '555-0127', 'amanda.harris@email.com', '357 Magnolia Ave, Anytown, USA', 'Kevin Harris - 555-0128'),
('Daniel', 'Clark', '1984-12-07', 'M', '555-0129', 'daniel.clark@email.com', '468 Dogwood Rd, Anytown, USA', 'Nicole Clark - 555-0130'),
('Stephanie', 'Lewis', '1989-05-24', 'F', '555-0131', 'stephanie.lewis@email.com', '579 Redwood Dr, Anytown, USA', 'Andrew Lewis - 555-0132'),
('Ryan', 'Lee', '1977-02-08', 'M', '555-0133', 'ryan.lee@email.com', '681 Sequoia Ln, Anytown, USA', 'Jennifer Lee - 555-0134'),
('Nicole', 'Walker', '1994-08-13', 'F', '555-0135', 'nicole.walker@email.com', '792 Fir St, Anytown, USA', 'Tyler Walker - 555-0136'),
('Kevin', 'Hall', '1981-11-26', 'M', '555-0137', 'kevin.hall@email.com', '903 Pine Ave, Anytown, USA', 'Melissa Hall - 555-0138'),
('Melissa', 'Allen', '1986-07-04', 'F', '555-0139', 'melissa.allen@email.com', '124 Oak Rd, Anytown, USA', 'Steven Allen - 555-0140'),
('Steven', 'Young', '1972-04-21', 'M', '555-0141', 'steven.young@email.com', '235 Maple Dr, Anytown, USA', 'Laura Young - 555-0142'),
('Laura', 'Hernandez', '1990-01-17', 'F', '555-0143', 'laura.hernandez@email.com', '346 Cedar Ln, Anytown, USA', 'Miguel Hernandez - 555-0144'),
('Jason', 'King', '1983-10-02', 'M', '555-0145', 'jason.king@email.com', '457 Birch Way, Anytown, USA', 'Christina King - 555-0146'),
('Christina', 'Wright', '1996-06-29', 'F', '555-0147', 'christina.wright@email.com', '568 Spruce St, Anytown, USA', 'Jonathan Wright - 555-0148'),
('Jonathan', 'Lopez', '1979-03-14', 'M', '555-0149', 'jonathan.lopez@email.com', '679 Willow Ave, Anytown, USA', 'Samantha Lopez - 555-0150'),
('Samantha', 'Hill', '1992-12-09', 'F', '555-0151', 'samantha.hill@email.com', '780 Poplar Rd, Anytown, USA', 'Benjamin Hill - 555-0152'),
('Benjamin', 'Scott', '1974-09-25', 'M', '555-0153', 'benjamin.scott@email.com', '891 Ash Dr, Anytown, USA', 'Katherine Scott - 555-0154'),
('Katherine', 'Green', '1988-06-12', 'F', '555-0155', 'katherine.green@email.com', '902 Hickory Ln, Anytown, USA', 'Patrick Green - 555-0156'),
('Patrick', 'Adams', '1985-02-28', 'M', '555-0157', 'patrick.adams@email.com', '113 Sycamore St, Anytown, USA', 'Rebecca Adams - 555-0158'),
('Rebecca', 'Baker', '1991-11-15', 'F', '555-0159', 'rebecca.baker@email.com', '224 Magnolia Ave, Anytown, USA', 'Timothy Baker - 555-0160'),
('Timothy', 'Gonzalez', '1976-08-03', 'M', '555-0161', 'timothy.gonzalez@email.com', '335 Dogwood Rd, Anytown, USA', 'Angela Gonzalez - 555-0162'),
('Angela', 'Nelson', '1989-04-20', 'F', '555-0163', 'angela.nelson@email.com', '446 Redwood Dr, Anytown, USA', 'Gregory Nelson - 555-0164'),
('Gregory', 'Carter', '1982-01-06', 'M', '555-0165', 'gregory.carter@email.com', '557 Sequoia Ln, Anytown, USA', 'Heather Carter - 555-0166'),
('Heather', 'Mitchell', '1987-10-23', 'F', '555-0167', 'heather.mitchell@email.com', '668 Fir St, Anytown, USA', 'Nathan Mitchell - 555-0168'),
('Nathan', 'Perez', '1973-07-10', 'M', '555-0169', 'nathan.perez@email.com', '779 Pine Ave, Anytown, USA', 'Kimberly Perez - 555-0170'),
('Kimberly', 'Roberts', '1994-04-27', 'F', '555-0171', 'kimberly.roberts@email.com', '880 Oak Rd, Anytown, USA', 'Eric Roberts - 555-0172'),
('Eric', 'Turner', '1978-01-13', 'M', '555-0173', 'eric.turner@email.com', '991 Maple Dr, Anytown, USA', 'Tiffany Turner - 555-0174'),
('Tiffany', 'Phillips', '1993-09-30', 'F', '555-0175', 'tiffany.phillips@email.com', '102 Cedar Ln, Anytown, USA', 'Adam Phillips - 555-0176'),
('Adam', 'Campbell', '1975-06-17', 'M', '555-0177', 'adam.campbell@email.com', '213 Birch Way, Anytown, USA', 'Crystal Campbell - 555-0178'),
('Crystal', 'Parker', '1990-03-04', 'F', '555-0179', 'crystal.parker@email.com', '324 Spruce St, Anytown, USA', 'Shane Parker - 555-0180'),
('Shane', 'Evans', '1984-12-21', 'M', '555-0181', 'shane.evans@email.com', '435 Willow Ave, Anytown, USA', 'Brittany Evans - 555-0182'),
('Brittany', 'Edwards', '1997-09-08', 'F', '555-0183', 'brittany.edwards@email.com', '546 Poplar Rd, Anytown, USA', 'Marcus Edwards - 555-0184'),
('Marcus', 'Collins', '1971-05-25', 'M', '555-0185', 'marcus.collins@email.com', '657 Ash Dr, Anytown, USA', 'Vanessa Collins - 555-0186'),
('Vanessa', 'Stewart', '1986-02-11', 'F', '555-0187', 'vanessa.stewart@email.com', '768 Hickory Ln, Anytown, USA', 'Derek Stewart - 555-0188'),
('Derek', 'Sanchez', '1980-11-28', 'M', '555-0189', 'derek.sanchez@email.com', '879 Sycamore St, Anytown, USA', 'Monica Sanchez - 555-0190'),
('Monica', 'Morris', '1995-08-15', 'F', '555-0191', 'monica.morris@email.com', '980 Magnolia Ave, Anytown, USA', 'Austin Morris - 555-0192'),
('Austin', 'Rogers', '1977-05-02', 'M', '555-0193', 'austin.rogers@email.com', '191 Dogwood Rd, Anytown, USA', 'Courtney Rogers - 555-0194'),
('Courtney', 'Reed', '1992-01-19', 'F', '555-0195', 'courtney.reed@email.com', '202 Redwood Dr, Anytown, USA', 'Vincent Reed - 555-0196'),
('Vincent', 'Cook', '1983-10-06', 'M', '555-0197', 'vincent.cook@email.com', '313 Sequoia Ln, Anytown, USA', 'Danielle Cook - 555-0198'),
('Danielle', 'Morgan', '1988-07-23', 'F', '555-0199', 'danielle.morgan@email.com', '424 Fir St, Anytown, USA', 'Brandon Morgan - 555-0200'),
('Brandon', 'Bell', '1974-04-10', 'M', '555-0201', 'brandon.bell@email.com', '535 Pine Ave, Anytown, USA', 'Amber Bell - 555-0202');

-- Insert visits for each patient (2 visits per patient = 100 visits total)
INSERT INTO visits (patient_id, visit_date, doctor_name, visit_type, notes) VALUES
-- Patient 1 visits
(1, '2024-01-15', 'Dr. Smith', 'Regular Checkup', 'Annual physical examination'),
(1, '2024-06-20', 'Dr. Johnson', 'Follow-up', 'Follow-up for hypertension management'),
-- Patient 2 visits
(2, '2024-02-10', 'Dr. Brown', 'Consultation', 'Respiratory symptoms evaluation'),
(2, '2024-08-05', 'Dr. Davis', 'Emergency', 'Acute migraine episode'),
-- Patient 3 visits
(3, '2024-01-25', 'Dr. Wilson', 'Regular Checkup', 'Routine diabetes monitoring'),
(3, '2024-07-15', 'Dr. Miller', 'Specialist', 'Cardiology consultation'),
-- Patient 4 visits
(4, '2024-03-08', 'Dr. Garcia', 'Regular Checkup', 'Annual wellness visit'),
(4, '2024-09-12', 'Dr. Martinez', 'Follow-up', 'Depression management follow-up'),
-- Patient 5 visits
(5, '2024-02-28', 'Dr. Anderson', 'Consultation', 'Joint pain evaluation'),
(5, '2024-08-18', 'Dr. Taylor', 'Follow-up', 'Arthritis treatment monitoring'),
-- Patient 6 visits
(6, '2024-01-12', 'Dr. Thomas', 'Regular Checkup', 'Preventive care visit'),
(6, '2024-06-30', 'Dr. Jackson', 'Consultation', 'Thyroid function assessment'),
-- Patient 7 visits
(7, '2024-03-20', 'Dr. White', 'Emergency', 'Chest pain evaluation'),
(7, '2024-09-05', 'Dr. Harris', 'Follow-up', 'Post-MI care management'),
-- Patient 8 visits
(8, '2024-02-14', 'Dr. Clark', 'Regular Checkup', 'Annual gynecological exam'),
(8, '2024-07-28', 'Dr. Lewis', 'Consultation', 'Digestive issues evaluation'),
-- Patient 9 visits
(9, '2024-01-30', 'Dr. Lee', 'Consultation', 'Sleep disorder assessment'),
(9, '2024-08-22', 'Dr. Walker', 'Follow-up', 'Sleep apnea treatment monitoring'),
-- Patient 10 visits
(10, '2024-03-15', 'Dr. Hall', 'Regular Checkup', 'Routine health screening'),
(10, '2024-09-08', 'Dr. Allen', 'Consultation', 'Skin condition evaluation'),
-- Continue with remaining patients (11-50)
(11, '2024-01-18', 'Dr. Young', 'Regular Checkup', 'Annual physical'),
(11, '2024-07-02', 'Dr. Hernandez', 'Follow-up', 'Blood pressure management'),
(12, '2024-02-22', 'Dr. King', 'Consultation', 'Anxiety symptoms'),
(12, '2024-08-14', 'Dr. Wright', 'Follow-up', 'Mental health follow-up'),
(13, '2024-03-05', 'Dr. Lopez', 'Regular Checkup', 'Diabetes screening'),
(13, '2024-09-18', 'Dr. Hill', 'Specialist', 'Endocrinology consultation'),
(14, '2024-01-08', 'Dr. Scott', 'Consultation', 'Chronic fatigue evaluation'),
(14, '2024-06-25', 'Dr. Green', 'Follow-up', 'Fibromyalgia management'),
(15, '2024-02-16', 'Dr. Adams', 'Regular Checkup', 'Preventive screening'),
(15, '2024-08-10', 'Dr. Baker', 'Emergency', 'Acute abdominal pain'),
(16, '2024-03-12', 'Dr. Gonzalez', 'Consultation', 'Vision problems'),
(16, '2024-09-01', 'Dr. Nelson', 'Follow-up', 'Eye care follow-up'),
(17, '2024-01-26', 'Dr. Carter', 'Regular Checkup', 'Annual wellness'),
(17, '2024-07-20', 'Dr. Mitchell', 'Consultation', 'Back pain evaluation'),
(18, '2024-02-08', 'Dr. Perez', 'Consultation', 'Allergic reactions'),
(18, '2024-08-26', 'Dr. Roberts', 'Follow-up', 'Allergy management'),
(19, '2024-03-18', 'Dr. Turner', 'Regular Checkup', 'Health maintenance'),
(19, '2024-09-10', 'Dr. Phillips', 'Consultation', 'Headache evaluation'),
(20, '2024-01-05', 'Dr. Campbell', 'Consultation', 'Digestive problems'),
(20, '2024-06-15', 'Dr. Parker', 'Follow-up', 'GERD management'),
(21, '2024-02-20', 'Dr. Evans', 'Regular Checkup', 'Routine screening'),
(21, '2024-08-06', 'Dr. Edwards', 'Consultation', 'Cholesterol concerns'),
(22, '2024-03-25', 'Dr. Collins', 'Consultation', 'Skin rash evaluation'),
(22, '2024-09-15', 'Dr. Stewart', 'Follow-up', 'Dermatitis treatment'),
(23, '2024-01-15', 'Dr. Sanchez', 'Regular Checkup', 'Annual physical'),
(23, '2024-07-08', 'Dr. Morris', 'Emergency', 'Injury assessment'),
(24, '2024-02-12', 'Dr. Rogers', 'Consultation', 'Respiratory issues'),
(24, '2024-08-28', 'Dr. Reed', 'Follow-up', 'Asthma management'),
(25, '2024-03-02', 'Dr. Cook', 'Regular Checkup', 'Health screening'),
(25, '2024-09-22', 'Dr. Morgan', 'Consultation', 'Joint stiffness'),
(26, '2024-01-22', 'Dr. Bell', 'Consultation', 'Mood changes'),
(26, '2024-07-12', 'Dr. Smith', 'Follow-up', 'Depression treatment'),
(27, '2024-02-28', 'Dr. Johnson', 'Regular Checkup', 'Preventive care'),
(27, '2024-08-18', 'Dr. Brown', 'Consultation', 'Hearing problems'),
(28, '2024-03-08', 'Dr. Davis', 'Consultation', 'Menstrual irregularities'),
(28, '2024-09-25', 'Dr. Wilson', 'Follow-up', 'Hormonal therapy'),
(29, '2024-01-18', 'Dr. Miller', 'Regular Checkup', 'Annual wellness'),
(29, '2024-06-28', 'Dr. Garcia', 'Emergency', 'Sports injury'),
(30, '2024-02-05', 'Dr. Martinez', 'Consultation', 'Memory concerns'),
(30, '2024-08-15', 'Dr. Anderson', 'Follow-up', 'Cognitive assessment'),
(31, '2024-03-15', 'Dr. Taylor', 'Regular Checkup', 'Health maintenance'),
(31, '2024-09-02', 'Dr. Thomas', 'Consultation', 'Urinary symptoms'),
(32, '2024-01-28', 'Dr. Jackson', 'Consultation', 'Chronic pain'),
(32, '2024-07-18', 'Dr. White', 'Follow-up', 'Pain management'),
(33, '2024-02-18', 'Dr. Harris', 'Regular Checkup', 'Routine screening'),
(33, '2024-08-08', 'Dr. Clark', 'Consultation', 'Fatigue evaluation'),
(34, '2024-03-22', 'Dr. Lewis', 'Consultation', 'Shortness of breath'),
(34, '2024-09-12', 'Dr. Lee', 'Follow-up', 'Pulmonary function'),
(35, '2024-01-10', 'Dr. Walker', 'Regular Checkup', 'Annual physical'),
(35, '2024-06-22', 'Dr. Hall', 'Emergency', 'Allergic reaction'),
(36, '2024-02-25', 'Dr. Allen', 'Consultation', 'Weight management'),
(36, '2024-08-30', 'Dr. Young', 'Follow-up', 'Obesity treatment'),
(37, '2024-03-10', 'Dr. Hernandez', 'Regular Checkup', 'Health screening'),
(37, '2024-09-28', 'Dr. King', 'Consultation', 'Dizziness episodes'),
(38, '2024-01-25', 'Dr. Wright', 'Consultation', 'Muscle weakness'),
(38, '2024-07-05', 'Dr. Lopez', 'Follow-up', 'Neurological assessment'),
(39, '2024-02-15', 'Dr. Hill', 'Regular Checkup', 'Preventive care'),
(39, '2024-08-20', 'Dr. Scott', 'Consultation', 'Hair loss concerns'),
(40, '2024-03-28', 'Dr. Green', 'Consultation', 'Digestive discomfort'),
(40, '2024-09-18', 'Dr. Adams', 'Follow-up', 'IBS management'),
(41, '2024-01-12', 'Dr. Baker', 'Regular Checkup', 'Annual wellness'),
(41, '2024-06-18', 'Dr. Gonzalez', 'Emergency', 'Severe headache'),
(42, '2024-02-08', 'Dr. Nelson', 'Consultation', 'Sleep disturbances'),
(42, '2024-08-25', 'Dr. Carter', 'Follow-up', 'Insomnia treatment'),
(43, '2024-03-18', 'Dr. Mitchell', 'Regular Checkup', 'Health maintenance'),
(43, '2024-09-05', 'Dr. Perez', 'Consultation', 'Leg cramps'),
(44, '2024-01-30', 'Dr. Roberts', 'Consultation', 'Irregular heartbeat'),
(44, '2024-07-25', 'Dr. Turner', 'Follow-up', 'Cardiac monitoring'),
(45, '2024-02-22', 'Dr. Phillips', 'Regular Checkup', 'Routine screening'),
(45, '2024-08-12', 'Dr. Campbell', 'Consultation', 'Thyroid symptoms'),
(46, '2024-03-05', 'Dr. Parker', 'Consultation', 'Joint inflammation'),
(46, '2024-09-20', 'Dr. Evans', 'Follow-up', 'Rheumatoid arthritis'),
(47, '2024-01-18', 'Dr. Edwards', 'Regular Checkup', 'Annual physical'),
(47, '2024-06-30', 'Dr. Collins', 'Emergency', 'Chest tightness'),
(48, '2024-02-12', 'Dr. Stewart', 'Consultation', 'Mood swings'),
(48, '2024-08-18', 'Dr. Sanchez', 'Follow-up', 'Bipolar management'),
(49, '2024-03-25', 'Dr. Morris', 'Regular Checkup', 'Health screening'),
(49, '2024-09-08', 'Dr. Rogers', 'Consultation', 'Varicose veins'),
(50, '2024-01-08', 'Dr. Reed', 'Consultation', 'Chronic cough'),
(50, '2024-07-15', 'Dr. Cook', 'Follow-up', 'Bronchitis treatment');

-- Insert diagnoses with ICD-10 codes (2 diagnoses per patient = 100 diagnoses total)
INSERT INTO diagnoses (visit_id, icd10_code, diagnosis_description, severity, diagnosis_date) VALUES
-- Patient 1 diagnoses
(1, 'I10', 'Essential (primary) hypertension', 'Moderate', '2024-01-15'),
(2, 'I10', 'Essential (primary) hypertension', 'Moderate', '2024-06-20'),
-- Patient 2 diagnoses
(3, 'J06.9', 'Acute upper respiratory infection, unspecified', 'Mild', '2024-02-10'),
(4, 'G43.909', 'Migraine, unspecified, not intractable, without status migrainosus', 'Severe', '2024-08-05'),
-- Patient 3 diagnoses
(5, 'E11.9', 'Type 2 diabetes mellitus without complications', 'Moderate', '2024-01-25'),
(6, 'I25.10', 'Atherosclerotic heart disease of native coronary artery without angina pectoris', 'Moderate', '2024-07-15'),
-- Patient 4 diagnoses
(7, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-03-08'),
(8, 'F32.9', 'Major depressive disorder, single episode, unspecified', 'Moderate', '2024-09-12'),
-- Patient 5 diagnoses
(9, 'M25.50', 'Pain in unspecified joint', 'Moderate', '2024-02-28'),
(10, 'M06.9', 'Rheumatoid arthritis, unspecified', 'Moderate', '2024-08-18'),
-- Patient 6 diagnoses
(11, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-01-12'),
(12, 'E03.9', 'Hypothyroidism, unspecified', 'Mild', '2024-06-30'),
-- Patient 7 diagnoses
(13, 'R06.02', 'Shortness of breath', 'Severe', '2024-03-20'),
(14, 'I21.9', 'Acute myocardial infarction, unspecified', 'Severe', '2024-09-05'),
-- Patient 8 diagnoses
(15, 'Z01.411', 'Encounter for gynecological examination (general) (routine) with abnormal findings', 'Mild', '2024-02-14'),
(16, 'K59.00', 'Constipation, unspecified', 'Mild', '2024-07-28'),
-- Patient 9 diagnoses
(17, 'G47.00', 'Insomnia, unspecified', 'Moderate', '2024-01-30'),
(18, 'G47.33', 'Obstructive sleep apnea (adult) (pediatric)', 'Moderate', '2024-08-22'),
-- Patient 10 diagnoses
(19, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-03-15'),
(20, 'L30.9', 'Dermatitis, unspecified', 'Mild', '2024-09-08'),
-- Continue with remaining diagnoses (patients 11-50)
(21, 'I10', 'Essential (primary) hypertension', 'Moderate', '2024-01-18'),
(22, 'I10', 'Essential (primary) hypertension', 'Moderate', '2024-07-02'),
(23, 'F41.1', 'Generalized anxiety disorder', 'Moderate', '2024-02-22'),
(24, 'F41.1', 'Generalized anxiety disorder', 'Moderate', '2024-08-14'),
(25, 'R73.09', 'Other abnormal glucose', 'Mild', '2024-03-05'),
(26, 'E11.9', 'Type 2 diabetes mellitus without complications', 'Moderate', '2024-09-18'),
(27, 'M79.3', 'Panniculitis, unspecified', 'Moderate', '2024-01-08'),
(28, 'M79.1', 'Myalgia', 'Moderate', '2024-06-25'),
(29, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-02-16'),
(30, 'R10.9', 'Unspecified abdominal pain', 'Severe', '2024-08-10'),
(31, 'H52.4', 'Presbyopia', 'Mild', '2024-03-12'),
(32, 'H52.4', 'Presbyopia', 'Mild', '2024-09-01'),
(33, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-01-26'),
(34, 'M54.5', 'Low back pain', 'Moderate', '2024-07-20'),
(35, 'T78.40XA', 'Allergy, unspecified, initial encounter', 'Moderate', '2024-02-08'),
(36, 'T78.40XA', 'Allergy, unspecified, initial encounter', 'Moderate', '2024-08-26'),
(37, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-03-18'),
(38, 'G43.909', 'Migraine, unspecified, not intractable, without status migrainosus', 'Moderate', '2024-09-10'),
(39, 'K21.9', 'Gastro-esophageal reflux disease without esophagitis', 'Moderate', '2024-01-05'),
(40, 'K21.9', 'Gastro-esophageal reflux disease without esophagitis', 'Moderate', '2024-06-15'),
(41, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-02-20'),
(42, 'E78.5', 'Hyperlipidemia, unspecified', 'Moderate', '2024-08-06'),
(43, 'L20.9', 'Atopic dermatitis, unspecified', 'Mild', '2024-03-25'),
(44, 'L20.9', 'Atopic dermatitis, unspecified', 'Mild', '2024-09-15'),
(45, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-01-15'),
(46, 'S72.001A', 'Fracture of unspecified part of neck of right femur, initial encounter', 'Severe', '2024-07-08'),
(47, 'J45.9', 'Asthma, unspecified', 'Moderate', '2024-02-12'),
(48, 'J45.9', 'Asthma, unspecified', 'Moderate', '2024-08-28'),
(49, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-03-02'),
(50, 'M25.50', 'Pain in unspecified joint', 'Moderate', '2024-09-22'),
(51, 'F32.9', 'Major depressive disorder, single episode, unspecified', 'Moderate', '2024-01-22'),
(52, 'F32.9', 'Major depressive disorder, single episode, unspecified', 'Moderate', '2024-07-12'),
(53, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-02-28'),
(54, 'H90.3', 'Sensorineural hearing loss, bilateral', 'Moderate', '2024-08-18'),
(55, 'N92.6', 'Irregular menstruation, unspecified', 'Moderate', '2024-03-08'),
(56, 'N92.6', 'Irregular menstruation, unspecified', 'Moderate', '2024-09-25'),
(57, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-01-18'),
(58, 'S43.006A', 'Unspecified dislocation of unspecified shoulder joint, initial encounter', 'Moderate', '2024-06-28'),
(59, 'G30.9', 'Alzheimer disease, unspecified', 'Moderate', '2024-02-05'),
(60, 'G30.9', 'Alzheimer disease, unspecified', 'Moderate', '2024-08-15'),
(61, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-03-15'),
(62, 'N39.0', 'Urinary tract infection, site not specified', 'Moderate', '2024-09-02'),
(63, 'M79.3', 'Panniculitis, unspecified', 'Moderate', '2024-01-28'),
(64, 'M79.3', 'Panniculitis, unspecified', 'Moderate', '2024-07-18'),
(65, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-02-18'),
(66, 'R53.1', 'Weakness', 'Moderate', '2024-08-08'),
(67, 'R06.00', 'Dyspnea, unspecified', 'Moderate', '2024-03-22'),
(68, 'R06.00', 'Dyspnea, unspecified', 'Moderate', '2024-09-12'),
(69, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-01-10'),
(70, 'T78.40XA', 'Allergy, unspecified, initial encounter', 'Severe', '2024-06-22'),
(71, 'E66.9', 'Obesity, unspecified', 'Moderate', '2024-02-25'),
(72, 'E66.9', 'Obesity, unspecified', 'Moderate', '2024-08-30'),
(73, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-03-10'),
(74, 'R42', 'Dizziness and giddiness', 'Moderate', '2024-09-28'),
(75, 'M62.9', 'Disorder of muscle, unspecified', 'Moderate', '2024-01-25'),
(76, 'M62.9', 'Disorder of muscle, unspecified', 'Moderate', '2024-07-05'),
(77, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-02-15'),
(78, 'L65.9', 'Nonscarring hair loss, unspecified', 'Mild', '2024-08-20'),
(79, 'K58.9', 'Irritable bowel syndrome without diarrhea', 'Moderate', '2024-03-28'),
(80, 'K58.9', 'Irritable bowel syndrome without diarrhea', 'Moderate', '2024-09-18'),
(81, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-01-12'),
(82, 'G43.909', 'Migraine, unspecified, not intractable, without status migrainosus', 'Severe', '2024-06-18'),
(83, 'G47.00', 'Insomnia, unspecified', 'Moderate', '2024-02-08'),
(84, 'G47.00', 'Insomnia, unspecified', 'Moderate', '2024-08-25'),
(85, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-03-18'),
(86, 'R25.2', 'Cramp and spasm', 'Mild', '2024-09-05'),
(87, 'I49.9', 'Cardiac arrhythmia, unspecified', 'Moderate', '2024-01-30'),
(88, 'I49.9', 'Cardiac arrhythmia, unspecified', 'Moderate', '2024-07-25'),
(89, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-02-22'),
(90, 'E03.9', 'Hypothyroidism, unspecified', 'Moderate', '2024-08-12'),
(91, 'M06.9', 'Rheumatoid arthritis, unspecified', 'Moderate', '2024-03-05'),
(92, 'M06.9', 'Rheumatoid arthritis, unspecified', 'Moderate', '2024-09-20'),
(93, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-01-18'),
(94, 'R06.02', 'Shortness of breath', 'Moderate', '2024-06-30'),
(95, 'F31.9', 'Bipolar disorder, unspecified', 'Moderate', '2024-02-12'),
(96, 'F31.9', 'Bipolar disorder, unspecified', 'Moderate', '2024-08-18'),
(97, 'Z00.00', 'Encounter for general adult medical examination without abnormal findings', 'Mild', '2024-03-25'),
(98, 'I83.90', 'Asymptomatic varicose veins of unspecified lower extremity', 'Mild', '2024-09-08'),
(99, 'R05', 'Cough', 'Moderate', '2024-01-08'),
(100, 'J20.9', 'Acute bronchitis, unspecified', 'Moderate', '2024-07-15');

-- Insert medications for each diagnosis (multiple medications per diagnosis)
INSERT INTO medications (diagnosis_id, medication_name, dosage, frequency, duration, instructions, prescribed_date) VALUES
-- Medications for Patient 1 (Hypertension)
(1, 'Lisinopril', '10mg', 'Once daily', '30 days', 'Take with or without food, preferably at the same time each day', '2024-01-15'),
(1, 'Hydrochlorothiazide', '25mg', 'Once daily', '30 days', 'Take in the morning to avoid nighttime urination', '2024-01-15'),
(2, 'Lisinopril', '10mg', 'Once daily', '30 days', 'Continue current regimen', '2024-06-20'),
(2, 'Amlodipine', '5mg', 'Once daily', '30 days', 'Take at the same time each day', '2024-06-20'),

-- Medications for Patient 2 (Upper respiratory infection, Migraine)
(3, 'Amoxicillin', '500mg', 'Three times daily', '10 days', 'Take with food to reduce stomach upset', '2024-02-10'),
(3, 'Guaifenesin', '400mg', 'Every 4 hours', '7 days', 'Drink plenty of fluids', '2024-02-10'),
(4, 'Sumatriptan', '50mg', 'As needed', '30 days', 'Take at onset of migraine, max 2 doses per day', '2024-08-05'),
(4, 'Propranolol', '40mg', 'Twice daily', '30 days', 'Take with food, do not stop abruptly', '2024-08-05'),

-- Medications for Patient 3 (Diabetes, Heart disease)
(5, 'Metformin', '500mg', 'Twice daily', '30 days', 'Take with meals to reduce GI side effects', '2024-01-25'),
(5, 'Glipizide', '5mg', 'Once daily', '30 days', 'Take 30 minutes before breakfast', '2024-01-25'),
(6, 'Atorvastatin', '20mg', 'Once daily', '30 days', 'Take in the evening', '2024-07-15'),
(6, 'Aspirin', '81mg', 'Once daily', '30 days', 'Take with food to reduce stomach irritation', '2024-07-15'),

-- Medications for Patient 4 (General exam, Depression)
(7, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-03-08'),
(8, 'Sertraline', '50mg', 'Once daily', '30 days', 'Take in the morning with food', '2024-09-12'),
(8, 'Lorazepam', '0.5mg', 'As needed', '15 days', 'For anxiety, do not exceed 2mg per day', '2024-09-12'),

-- Medications for Patient 5 (Joint pain, Rheumatoid arthritis)
(9, 'Ibuprofen', '400mg', 'Three times daily', '14 days', 'Take with food to prevent stomach upset', '2024-02-28'),
(9, 'Topical Diclofenac', '1% gel', 'Four times daily', '30 days', 'Apply to affected joints', '2024-02-28'),
(10, 'Methotrexate', '15mg', 'Once weekly', '30 days', 'Take with folic acid supplement', '2024-08-18'),
(10, 'Prednisone', '10mg', 'Once daily', '14 days', 'Take with food in the morning', '2024-08-18'),

-- Medications for Patient 6 (General exam, Hypothyroidism)
(11, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-01-12'),
(12, 'Levothyroxine', '50mcg', 'Once daily', '30 days', 'Take on empty stomach, 1 hour before breakfast', '2024-06-30'),

-- Medications for Patient 7 (Shortness of breath, Myocardial infarction)
(13, 'Albuterol inhaler', '90mcg', 'As needed', '30 days', 'Use for shortness of breath, max 8 puffs per day', '2024-03-20'),
(14, 'Clopidogrel', '75mg', 'Once daily', '30 days', 'Take with or without food', '2024-09-05'),
(14, 'Metoprolol', '25mg', 'Twice daily', '30 days', 'Take with food', '2024-09-05'),

-- Medications for Patient 8 (Gynecological exam, Constipation)
(15, 'Folic acid', '400mcg', 'Once daily', '30 days', 'Take with or without food', '2024-02-14'),
(16, 'Docusate sodium', '100mg', 'Twice daily', '14 days', 'Take with plenty of water', '2024-07-28'),
(16, 'Polyethylene glycol', '17g', 'Once daily', '30 days', 'Mix with 8oz of liquid', '2024-07-28'),

-- Medications for Patient 9 (Insomnia, Sleep apnea)
(17, 'Melatonin', '3mg', 'Once at bedtime', '30 days', 'Take 30 minutes before desired sleep time', '2024-01-30'),
(18, 'CPAP therapy', 'Nightly', 'Every night', 'Ongoing', 'Use CPAP machine every night for 6+ hours', '2024-08-22'),

-- Medications for Patient 10 (General exam, Dermatitis)
(19, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-03-15'),
(20, 'Hydrocortisone cream', '1%', 'Twice daily', '14 days', 'Apply thin layer to affected areas', '2024-09-08'),
(20, 'Cetaphil moisturizer', 'As needed', 'Daily', '30 days', 'Apply to keep skin moisturized', '2024-09-08'),

-- Continue with medications for remaining patients (11-50)
-- Patient 11 (Hypertension)
(21, 'Lisinopril', '10mg', 'Once daily', '30 days', 'Take at the same time each day', '2024-01-18'),
(22, 'Amlodipine', '5mg', 'Once daily', '30 days', 'Continue current medication', '2024-07-02'),

-- Patient 12 (Anxiety)
(23, 'Alprazolam', '0.25mg', 'Twice daily', '30 days', 'Take as needed for anxiety', '2024-02-22'),
(24, 'Buspirone', '15mg', 'Twice daily', '30 days', 'Take with food', '2024-08-14'),

-- Patient 13 (Abnormal glucose, Diabetes)
(25, 'Lifestyle modification', 'N/A', 'Daily', 'Ongoing', 'Diet and exercise program', '2024-03-05'),
(26, 'Metformin', '500mg', 'Twice daily', '30 days', 'Take with meals', '2024-09-18'),

-- Patient 14 (Panniculitis, Myalgia)
(27, 'Prednisone', '20mg', 'Once daily', '14 days', 'Take with food in morning', '2024-01-08'),
(28, 'Ibuprofen', '600mg', 'Three times daily', '14 days', 'Take with food', '2024-06-25'),

-- Patient 15 (General exam, Abdominal pain)
(29, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-02-16'),
(30, 'Omeprazole', '20mg', 'Once daily', '14 days', 'Take before breakfast', '2024-08-10'),

-- Patient 16 (Presbyopia)
(31, 'Reading glasses', '+2.00', 'As needed', 'Ongoing', 'Use for close-up work', '2024-03-12'),
(32, 'Artificial tears', '1-2 drops', 'As needed', '30 days', 'Use for dry eyes', '2024-09-01'),

-- Patient 17 (General exam, Back pain)
(33, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-01-26'),
(34, 'Naproxen', '220mg', 'Twice daily', '14 days', 'Take with food', '2024-07-20'),

-- Patient 18 (Allergies)
(35, 'Loratadine', '10mg', 'Once daily', '30 days', 'Take at the same time each day', '2024-02-08'),
(36, 'Cetirizine', '10mg', 'Once daily', '30 days', 'Continue antihistamine therapy', '2024-08-26'),

-- Patient 19 (General exam, Migraine)
(37, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-03-18'),
(38, 'Sumatriptan', '50mg', 'As needed', '30 days', 'Take at migraine onset', '2024-09-10'),

-- Patient 20 (GERD)
(39, 'Omeprazole', '20mg', 'Once daily', '30 days', 'Take before breakfast', '2024-01-05'),
(40, 'Famotidine', '20mg', 'Twice daily', '30 days', 'Take before meals', '2024-06-15'),

-- Patient 21 (General exam, Hyperlipidemia)
(41, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-02-20'),
(42, 'Simvastatin', '20mg', 'Once daily', '30 days', 'Take in the evening', '2024-08-06'),

-- Patient 22 (Atopic dermatitis)
(43, 'Triamcinolone cream', '0.1%', 'Twice daily', '14 days', 'Apply thin layer to affected areas', '2024-03-25'),
(44, 'Moisturizing lotion', 'As needed', 'Daily', '30 days', 'Apply regularly to prevent dryness', '2024-09-15'),

-- Patient 23 (General exam, Fracture)
(45, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-01-15'),
(46, 'Oxycodone', '5mg', 'Every 6 hours', '14 days', 'Take as needed for pain', '2024-07-08'),

-- Patient 24 (Asthma)
(47, 'Albuterol inhaler', '90mcg', 'As needed', '30 days', 'Use for shortness of breath', '2024-02-12'),
(48, 'Fluticasone inhaler', '44mcg', 'Twice daily', '30 days', 'Use daily for prevention', '2024-08-28'),

-- Patient 25 (General exam, Joint pain)
(49, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-03-02'),
(50, 'Acetaminophen', '650mg', 'Every 6 hours', '14 days', 'Take as needed for pain', '2024-09-22'),

-- Patient 26 (Depression)
(51, 'Fluoxetine', '20mg', 'Once daily', '30 days', 'Take in the morning', '2024-01-22'),
(52, 'Trazodone', '50mg', 'At bedtime', '30 days', 'Take for sleep aid', '2024-07-12'),

-- Patient 27 (General exam, Hearing loss)
(53, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-02-28'),
(54, 'Hearing aid consultation', 'N/A', 'As needed', 'Ongoing', 'Follow up with audiologist', '2024-08-18'),

-- Patient 28 (Menstrual irregularities)
(55, 'Norethindrone', '5mg', 'Once daily', '30 days', 'Take at the same time each day', '2024-03-08'),
(56, 'Iron supplement', '325mg', 'Once daily', '30 days', 'Take with vitamin C for absorption', '2024-09-25'),

-- Patient 29 (General exam, Sports injury)
(57, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-01-18'),
(58, 'Ibuprofen', '400mg', 'Three times daily', '14 days', 'Take with food for injury', '2024-06-28'),

-- Patient 30 (Alzheimer disease)
(59, 'Donepezil', '5mg', 'Once daily', '30 days', 'Take at bedtime', '2024-02-05'),
(60, 'Memantine', '10mg', 'Twice daily', '30 days', 'Take with or without food', '2024-08-15'),

-- Patient 31 (General exam, UTI)
(61, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-03-15'),
(62, 'Nitrofurantoin', '100mg', 'Twice daily', '7 days', 'Take with food', '2024-09-02'),

-- Patient 32 (Chronic pain)
(63, 'Gabapentin', '300mg', 'Three times daily', '30 days', 'Take with or without food', '2024-01-28'),
(64, 'Topical lidocaine', '5%', 'As needed', '30 days', 'Apply to painful areas', '2024-07-18'),

-- Patient 33 (General exam, Weakness)
(65, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-02-18'),
(66, 'Iron supplement', '325mg', 'Once daily', '30 days', 'Take with vitamin C', '2024-08-08'),

-- Patient 34 (Dyspnea)
(67, 'Albuterol inhaler', '90mcg', 'As needed', '30 days', 'Use for breathing difficulty', '2024-03-22'),
(68, 'Furosemide', '20mg', 'Once daily', '30 days', 'Take in the morning', '2024-09-12'),

-- Patient 35 (General exam, Allergic reaction)
(69, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-01-10'),
(70, 'Epinephrine auto-injector', '0.3mg', 'As needed', '30 days', 'Use for severe allergic reactions', '2024-06-22'),

-- Patient 36 (Obesity)
(71, 'Orlistat', '120mg', 'Three times daily', '30 days', 'Take with each main meal', '2024-02-25'),
(72, 'Phentermine', '37.5mg', 'Once daily', '30 days', 'Take before breakfast', '2024-08-30'),

-- Patient 37 (General exam, Dizziness)
(73, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-03-10'),
(74, 'Meclizine', '25mg', 'As needed', '30 days', 'Take for dizziness', '2024-09-28'),

-- Patient 38 (Muscle weakness)
(75, 'Physical therapy', 'N/A', '3x weekly', '6 weeks', 'Attend scheduled PT sessions', '2024-01-25'),
(76, 'Vitamin D', '2000 IU', 'Once daily', '30 days', 'Take with food', '2024-07-05'),

-- Patient 39 (General exam, Hair loss)
(77, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-02-15'),
(78, 'Minoxidil', '5%', 'Twice daily', '30 days', 'Apply to scalp', '2024-08-20'),

-- Patient 40 (IBS)
(79, 'Dicyclomine', '20mg', 'Four times daily', '30 days', 'Take before meals', '2024-03-28'),
(80, 'Fiber supplement', '1 tablespoon', 'Once daily', '30 days', 'Mix with water', '2024-09-18'),

-- Patient 41 (General exam, Severe headache)
(81, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-01-12'),
(82, 'Sumatriptan', '100mg', 'As needed', '30 days', 'Take at headache onset', '2024-06-18'),

-- Patient 42 (Insomnia)
(83, 'Zolpidem', '10mg', 'At bedtime', '14 days', 'Take just before sleep', '2024-02-08'),
(84, 'Melatonin', '5mg', 'At bedtime', '30 days', 'Take 30 minutes before bed', '2024-08-25'),

-- Patient 43 (General exam, Leg cramps)
(85, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-03-18'),
(86, 'Magnesium', '400mg', 'Once daily', '30 days', 'Take with food', '2024-09-05'),

-- Patient 44 (Cardiac arrhythmia)
(87, 'Metoprolol', '50mg', 'Twice daily', '30 days', 'Take with food', '2024-01-30'),
(88, 'Warfarin', '5mg', 'Once daily', '30 days', 'Monitor INR regularly', '2024-07-25'),

-- Patient 45 (General exam, Hypothyroidism)
(89, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-02-22'),
(90, 'Levothyroxine', '75mcg', 'Once daily', '30 days', 'Take on empty stomach', '2024-08-12'),

-- Patient 46 (Rheumatoid arthritis)
(91, 'Methotrexate', '20mg', 'Once weekly', '30 days', 'Take with folic acid', '2024-03-05'),
(92, 'Adalimumab', '40mg', 'Every other week', '30 days', 'Subcutaneous injection', '2024-09-20'),

-- Patient 47 (General exam, Shortness of breath)
(93, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-01-18'),
(94, 'Albuterol inhaler', '90mcg', 'As needed', '30 days', 'Use for breathing difficulty', '2024-06-30'),

-- Patient 48 (Bipolar disorder)
(95, 'Lithium', '300mg', 'Twice daily', '30 days', 'Monitor blood levels regularly', '2024-02-12'),
(96, 'Quetiapine', '100mg', 'At bedtime', '30 days', 'Take for mood stabilization', '2024-08-18'),

-- Patient 49 (General exam, Varicose veins)
(97, 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', '2024-03-25'),
(98, 'Compression stockings', '20-30 mmHg', 'Daily', 'Ongoing', 'Wear during day, remove at night', '2024-09-08'),

-- Patient 50 (Chronic cough, Bronchitis)
(99, 'Dextromethorphan', '15mg', 'Every 4 hours', '7 days', 'Take for cough suppression', '2024-01-08'),
(100, 'Azithromycin', '250mg', 'Once daily', '5 days', 'Take with or without food', '2024-07-15'),
(100, 'Guaifenesin', '400mg', 'Every 4 hours', '10 days', 'Take with plenty of fluids', '2024-07-15');

-- Create useful views for reporting
CREATE VIEW patient_summary AS
SELECT
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    p.date_of_birth,
    p.gender,
    COUNT(DISTINCT v.visit_id) AS total_visits,
    COUNT(DISTINCT d.diagnosis_id) AS total_diagnoses,
    COUNT(DISTINCT m.medication_id) AS total_medications
FROM patients p
LEFT JOIN visits v ON p.patient_id = v.patient_id
LEFT JOIN diagnoses d ON v.visit_id = d.visit_id
LEFT JOIN medications m ON d.diagnosis_id = m.diagnosis_id
GROUP BY p.patient_id, p.first_name, p.last_name, p.date_of_birth, p.gender;

CREATE VIEW diagnosis_medication_view AS
SELECT
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    v.visit_date,
    v.doctor_name,
    d.icd10_code,
    d.diagnosis_description,
    d.severity,
    m.medication_name,
    m.dosage,
    m.frequency,
    m.duration,
    m.instructions
FROM patients p
JOIN visits v ON p.patient_id = v.patient_id
JOIN diagnoses d ON v.visit_id = d.visit_id
JOIN medications m ON d.diagnosis_id = m.diagnosis_id
ORDER BY p.patient_id, v.visit_date;

CREATE VIEW common_diagnoses AS
SELECT
    d.icd10_code,
    d.diagnosis_description,
    COUNT(*) as frequency,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM diagnoses), 2) as percentage
FROM diagnoses d
GROUP BY d.icd10_code, d.diagnosis_description
ORDER BY frequency DESC;

-- Sample queries to demonstrate usage

-- Query 1: Get all patient information with their diagnoses and medications
/*
SELECT * FROM diagnosis_medication_view
WHERE patient_id = 1;
*/

-- Query 2: Find patients with specific ICD-10 code
/*
SELECT DISTINCT p.patient_id, CONCAT(p.first_name, ' ', p.last_name) AS patient_name
FROM patients p
JOIN visits v ON p.patient_id = v.patient_id
JOIN diagnoses d ON v.visit_id = d.visit_id
WHERE d.icd10_code = 'I10';
*/

-- Query 3: Get medication history for a specific patient
/*
SELECT
    v.visit_date,
    d.diagnosis_description,
    m.medication_name,
    m.dosage,
    m.frequency,
    m.duration
FROM patients p
JOIN visits v ON p.patient_id = v.patient_id
JOIN diagnoses d ON v.visit_id = d.visit_id
JOIN medications m ON d.diagnosis_id = m.diagnosis_id
WHERE p.patient_id = 1
ORDER BY v.visit_date;
*/

-- Query 4: Find most common diagnoses
/*
SELECT * FROM common_diagnoses LIMIT 10;
*/

-- Query 5: Get patients due for follow-up (last visit more than 6 months ago)
/*
SELECT
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    p.phone,
    MAX(v.visit_date) AS last_visit_date,
    DATEDIFF(CURDATE(), MAX(v.visit_date)) AS days_since_visit
FROM patients p
JOIN visits v ON p.patient_id = v.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name, p.phone
HAVING days_since_visit > 180
ORDER BY days_since_visit DESC;
*/