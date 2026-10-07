CREATE DATABASE IF NOT EXISTS insurance_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE insurance_db;


-- =========================================================
-- 1. CLIENT
-- =========================================================

CREATE TABLE Client (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    national_id VARCHAR(20) UNIQUE,
    email VARCHAR(100),
    phone VARCHAR(30),
    address VARCHAR(200)
) ENGINE=InnoDB;


-- =========================================================
-- 2. PRODUCT
-- =========================================================

CREATE TABLE Product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    product_type VARCHAR(50) NOT NULL
) ENGINE=InnoDB;


-- =========================================================
-- 3. CAR
-- =========================================================

CREATE TABLE Car (
    car_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    production_year YEAR,
    license_plate VARCHAR(20) UNIQUE,
    vin VARCHAR(50) UNIQUE,

    CONSTRAINT fk_car_client
        FOREIGN KEY (client_id)
        REFERENCES Client(client_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- =========================================================
-- 4. PROPERTY
-- =========================================================

CREATE TABLE Property (
    property_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    address VARCHAR(200) NOT NULL,
    property_type VARCHAR(50),
    area DECIMAL(10,2),
    value DECIMAL(12,2),

    CONSTRAINT fk_property_client
        FOREIGN KEY (client_id)
        REFERENCES Client(client_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- =========================================================
-- 5. INSURANCE POLICY
-- =========================================================

CREATE TABLE InsurancePolicy (
    policy_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    product_id INT NOT NULL,

    car_id INT NULL,
    property_id INT NULL,

    policy_number VARCHAR(30) NOT NULL UNIQUE,
    valid_from DATE NOT NULL,
    valid_to DATE NULL,
    status VARCHAR(30) NOT NULL,
    premium DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_policy_client
        FOREIGN KEY (client_id)
        REFERENCES Client(client_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_policy_product
        FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_policy_car
        FOREIGN KEY (car_id)
        REFERENCES Car(car_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_policy_property
        FOREIGN KEY (property_id)
        REFERENCES Property(property_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- =========================================================
-- 6. PAYMENT
-- =========================================================

CREATE TABLE Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_id INT NOT NULL,
    payment_date DATETIME NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL,
    transaction_id VARCHAR(100) UNIQUE,

    CONSTRAINT fk_payment_policy
        FOREIGN KEY (policy_id)
        REFERENCES InsurancePolicy(policy_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- =========================================================
-- 7. CLAIM
-- =========================================================

CREATE TABLE Claim (
    claim_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_id INT NOT NULL,
    reported_date DATE NOT NULL,
    incident_date DATE NOT NULL,
    claim_type VARCHAR(100),
    description TEXT,
    amount DECIMAL(12,2),
    status VARCHAR(30),

    CONSTRAINT fk_claim_policy
        FOREIGN KEY (policy_id)
        REFERENCES InsurancePolicy(policy_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- =========================================================
-- 8. CLAIM PAYMENT
-- =========================================================

CREATE TABLE ClaimPayment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    claim_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,

    CONSTRAINT fk_claim_payment_claim
        FOREIGN KEY (claim_id)
        REFERENCES Claim(claim_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- =========================================================
-- SAMPLE DATA
-- =========================================================

INSERT INTO Product (name, description, product_type) VALUES
('Travel Insurance', 'Insurance for domestic and international travel', 'Travel'),
('Mandatory Motor Insurance', 'Mandatory liability insurance for motor vehicles', 'Auto'),
('Comprehensive Car Insurance', 'Insurance against damage to the vehicle', 'Auto'),
('Property Insurance', 'Insurance for houses and apartments', 'Property'),
('Household Insurance', 'Insurance for household contents and equipment', 'Property'),
('Liability Insurance', 'Insurance against liability for damage', 'Liability'),
('Life Insurance', 'Risk and investment life insurance', 'Life'),
('Investment', 'Investment products', 'Investment'),
('Pension', 'Products for retirement savings', 'Pension'),
('Business Insurance', 'Insurance for companies and entrepreneurs', 'Business');


INSERT INTO Client
(first_name, last_name, date_of_birth, national_id, email, phone, address)
VALUES
('Aleksei', 'Bykov', '1998-05-12', '9805121234',
 'aleksei@example.com', '+421900111222', 'Bratislava'),
('Martin', 'Novak', '1995-08-20', '9508205678',
 'martin@example.com', '+421900333444', 'Nitra'),
('Peter', 'Kovac', '1987-03-10', '8703107890',
 'peter@example.com', '+421900555666', 'Trnava');


INSERT INTO Car
(client_id, make, model, production_year, license_plate, vin)
VALUES
(1, 'Škoda', 'Octavia', 2020, 'BA123AB', 'TMB12345678900001'),
(2, 'Volkswagen', 'Golf', 2019, 'NR456CD', 'WVW12345678900002'),
(3, 'Toyota', 'Corolla', 2021, 'TT789EF', 'JT12345678900003');


INSERT INTO Property
(client_id, address, property_type, area, value)
VALUES
(1, 'Bratislava, Ružinov', 'Apartment', 55.50, 150000.00),
(2, 'Nitra, City Center', 'House', 120.00, 250000.00),
(3, 'Trnava, Suburbs', 'Apartment', 70.00, 180000.00);


INSERT INTO InsurancePolicy
(client_id, product_id, car_id, property_id,
 policy_number, valid_from, valid_to, status, premium)
VALUES
(1, 2, 1, NULL,
 'PZP-2026-0001', '2026-01-01', '2027-01-01', 'Active', 120.00),
(1, 3, 1, NULL,
 'HAV-2026-0001', '2026-01-01', '2027-01-01', 'Active', 450.00),
(2, 4, NULL, 2,
 'PROP-2026-0001', '2026-02-01', '2027-02-01', 'Active', 210.00),
(3, 1, NULL, NULL,
 'TRAVEL-2026-0001', '2026-05-01', '2026-06-01', 'Expired', 35.00);


INSERT INTO Payment
(policy_id, payment_date, amount, payment_method, status, transaction_id)
VALUES
(1, '2026-01-02 10:30:00', 120.00, 'CARD', 'Successful', 'TXN-000001'),
(2, '2026-01-02 11:00:00', 450.00, 'BANK_TRANSFER', 'Successful', 'TXN-000002'),
(3, '2026-02-02 09:15:00', 210.00, 'CARD', 'Successful', 'TXN-000003'),
(4, '2026-05-01 12:00:00', 35.00, 'CASH', 'Successful', NULL);


INSERT INTO Claim
(policy_id, reported_date, incident_date, claim_type, description, amount, status)
VALUES
(2, '2026-07-10', '2026-07-09',
 'Traffic Accident',
 'Damage to the front part of the vehicle',
 3500.00, 'In Progress'),
(3, '2026-08-05', '2026-08-04',
 'Property Damage',
 'Damage to the roof of the house',
 1200.00, 'Closed');


INSERT INTO ClaimPayment
(claim_id, payment_date, amount)
VALUES
(1, '2026-08-01', 2500.00),
(2, '2026-08-15', 1200.00);
