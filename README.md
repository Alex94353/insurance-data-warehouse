# insurance-data-warehouse
ETL pipeline and Data Warehouse (DWH) implementation for insurance analytics. Built to transform raw transactional data into actionable BI metrics.
# Insurance Data Warehouse

## Overview

**Insurance Data Warehouse** is a database and data warehouse modeling project for insurance analytics.

The project demonstrates how transactional insurance data can be structured in a relational database and subsequently prepared for analytical processing using a **Data Warehouse (DWH)** and **star schema** concepts.

The system models core insurance business entities such as customers, insurance products, policies, payments, claims, and claim-related payments.

The main objective is to provide a foundation for analytical reporting and Business Intelligence (BI), allowing insurance data to be analyzed by customers, insurance products, policies, dates, payment activity, and claims.

---

## Project Goals

The project has several main goals:

- Design a normalized relational database for an insurance company.
- Represent the relationships between customers, insurance products, policies, vehicles, and properties.
- Store policy payments and insurance claims.
- Model the data warehouse using fact and dimension tables.
- Separate transactional data from analytical data.
- Prepare the data model for BI reporting and analytical SQL queries.
- Demonstrate different approaches to modeling insurance facts, particularly claims and payments.

---

## Architecture

The project consists of two conceptual layers:

```text
                    Transactional Database
                             │
                             │ ETL
                             ▼
                    Data Warehouse Layer
                             │
                             ▼
                     BI / Analytical Layer
```

### Transactional layer

The transactional database is implemented in MySQL and contains normalized operational data.

The current SQL schema contains the following main entities:

```text
Client
Product
Car
Property
InsurancePolicy
Payment
Claim
ClaimPayment
```

These tables represent the source system from which analytical data can be extracted and transformed.

### Data Warehouse layer

The repository contains several analytical fact-model designs:

- `fact_claim`
- `fact_payment`
- `fact_claim-payment`

Each model represents a different analytical subject area or modeling approach.

The repository contains both editable MySQL Workbench models (`.mwb`) and exported SVG diagrams for visualization.

---

# 1. Source Database

The source database is named:

```sql
insurance_db
```

It uses:

```sql
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci
```

and the tables use the **InnoDB** storage engine.

## 1.1 Client

The `Client` table stores customer information.

| Column | Type | Description |
|---|---|---|
| `client_id` | INT | Primary key |
| `first_name` | VARCHAR(50) | Customer first name |
| `last_name` | VARCHAR(50) | Customer last name |
| `date_of_birth` | DATE | Date of birth |
| `national_id` | VARCHAR(20) | Unique national identifier |
| `email` | VARCHAR(100) | Email address |
| `phone` | VARCHAR(30) | Telephone number |
| `address` | VARCHAR(200) | Customer address |

`client_id` is an auto-incrementing primary key. `national_id` is defined as unique.

---

## 1.2 Product

The `Product` table contains insurance products offered by the company.

| Column | Type | Description |
|---|---|---|
| `product_id` | INT | Primary key |
| `name` | VARCHAR(100) | Product name |
| `description` | TEXT | Product description |
| `product_type` | VARCHAR(50) | Product category |

Examples of product categories in the sample data include:

- Auto
- Property
- Travel
- Liability
- Life
- Investment
- Pension
- Business

The actual SQL script contains ten sample insurance products.

---

## 1.3 Car

The `Car` table represents vehicles owned by customers.

| Column | Type | Description |
|---|---|---|
| `car_id` | INT | Primary key |
| `client_id` | INT | Customer reference |
| `make` | VARCHAR(50) | Vehicle manufacturer |
| `model` | VARCHAR(50) | Vehicle model |
| `production_year` | YEAR | Production year |
| `license_plate` | VARCHAR(20) | Registration number |
| `vin` | VARCHAR(50) | Vehicle identification number |

Relationship:

```text
Client 1 ───── N Car
```

A foreign key connects `Car.client_id` to `Client.client_id`.

The relationship uses `ON DELETE RESTRICT` and `ON UPDATE CASCADE`.

---

## 1.4 Property

The `Property` table stores insured or potentially insurable properties.

| Column | Type | Description |
|---|---|---|
| `property_id` | INT | Primary key |
| `client_id` | INT | Customer reference |
| `address` | VARCHAR(200) | Property address |
| `property_type` | VARCHAR(50) | Type of property |
| `area` | DECIMAL(10,2) | Property area |
| `value` | DECIMAL(12,2) | Estimated property value |

Relationship:

```text
Client 1 ───── N Property
```

The foreign key references `Client(client_id)`.

---

# 2. Insurance Policy

The `InsurancePolicy` table is the central transactional entity.

It connects the customer with an insurance product and, where applicable, with an insured vehicle or property.

| Column | Type | Description |
|---|---|---|
| `policy_id` | INT | Primary key |
| `client_id` | INT | Customer reference |
| `product_id` | INT | Insurance product reference |
| `car_id` | INT, nullable | Insured vehicle |
| `property_id` | INT, nullable | Insured property |
| `policy_number` | VARCHAR(30) | Unique policy number |
| `valid_from` | DATE | Start date |
| `valid_to` | DATE, nullable | End date |
| `status` | VARCHAR(30) | Policy status |
| `premium` | DECIMAL(10,2) | Policy premium |

The policy has foreign keys to:

```text
Client
Product
Car
Property
```

`car_id` and `property_id` are nullable because not every insurance product requires a vehicle or a property.

For example, a travel insurance policy may not require either reference.

The resulting logical relationships are:

```text
Client   1 ───── N InsurancePolicy
Product  1 ───── N InsurancePolicy
Car      1 ───── N InsurancePolicy
Property 1 ───── N InsurancePolicy
```

---

# 3. Payment

The `Payment` table stores payments made for insurance policies.

| Column | Type | Description |
|---|---|---|
| `payment_id` | INT | Primary key |
| `policy_id` | INT | Related policy |
| `payment_date` | DATETIME | Date and time of payment |
| `amount` | DECIMAL(10,2) | Payment amount |
| `payment_method` | VARCHAR(30) | Payment method |
| `status` | VARCHAR(30) | Payment status |
| `transaction_id` | VARCHAR(100) | External transaction identifier |

Relationship:

```text
InsurancePolicy 1 ───── N Payment
```

A single insurance policy can therefore have multiple payment transactions.

Typical analytical measures derived from this table include:

- total payment amount;
- number of payments;
- average payment amount;
- successful payments;
- payments by payment method;
- payments by month or year.

---

# 4. Claim

The `Claim` table stores insurance claims reported by customers.

| Column | Type | Description |
|---|---|---|
| `claim_id` | INT | Primary key |
| `policy_id` | INT | Related insurance policy |
| `reported_date` | DATE | Date when the claim was reported |
| `incident_date` | DATE | Date of the incident |
| `claim_type` | VARCHAR(100) | Type of claim |
| `description` | TEXT | Claim description |
| `amount` | DECIMAL(12,2) | Claimed amount |
| `status` | VARCHAR(30) | Claim status |

Relationship:

```text
InsurancePolicy 1 ───── N Claim
```

The claim is therefore always associated with a specific insurance policy.

Possible analytical measures include:

- number of claims;
- total claimed amount;
- average claim amount;
- claims by type;
- claims by status;
- claims by product;
- claims by reporting period.

---

# 5. Claim Payment

The `ClaimPayment` table stores payments made in settlement of insurance claims.

| Column | Type | Description |
|---|---|---|
| `payment_id` | INT | Primary key |
| `claim_id` | INT | Related claim |
| `payment_date` | DATE | Settlement payment date |
| `amount` | DECIMAL(12,2) | Paid amount |

Relationship:

```text
Claim 1 ───── N ClaimPayment
```

This relationship is important because one insurance claim can potentially be settled through multiple payments.

For example:

```text
Claim
 ├── ClaimPayment 1
 ├── ClaimPayment 2
 └── ClaimPayment 3
```

The current sample data also demonstrates a claim where the paid amount can differ from the original claim amount.

---

# 6. Source Database Relationships

The main transactional relationships can be summarized as follows:

```text
                   ┌──────────────┐
                   │    Client    │
                   └──────┬───────┘
                          │
              ┌───────────┼───────────┐
              │                       │
              ▼                       ▼
        ┌───────────┐           ┌───────────┐
        │    Car    │           │  Property │
        └─────┬─────┘           └──────┬────┘
              │                        │
              └──────────┬─────────────┘
                         ▼
                ┌──────────────────┐
                │ InsurancePolicy  │
                └───────┬──────────┘
                        │
             ┌──────────┴───────────┐
             ▼                      ▼
       ┌───────────┐          ┌───────────┐
       │  Payment  │          │   Claim   │
       └───────────┘          └─────┬─────┘
                                    │
                                    ▼
                              ┌──────────────┐
                              │ ClaimPayment │
                              └──────────────┘

                Product
                   │
                   ▼
           InsurancePolicy
```

The complete source ER model is available in `insurance_model.mwb` and `insurance.svg`.

---

# 7. Data Warehouse Design

The analytical part of the project is based on the **star schema** concept.

A star schema separates:

- **fact tables** — measurable business events;
- **dimension tables** — descriptive information used to analyze those events.

Typical analytical structure:

```text
                    Dimension
                       │
                       │
Dimension ─────── Fact Table ─────── Dimension
                       │
                       │
                    Dimension
```

The project contains three analytical modeling variants:

```text
fact_claim
fact_payment
fact_claim-payment
```

Each model focuses on a different business process.

---

# 8. Fact: Claim

## Business process

The claim fact represents an insurance claim event.

### Grain

The recommended grain is:

> **One row represents one insurance claim.**

This means that a row in the claim fact should correspond to a unique `claim_id`.

### Typical measures

The main numerical measure is:

```text
claim_amount
```

Other derived measures can include:

```text
claim_count = 1
```

This allows simple aggregation:

```sql
SUM(claim_amount)
COUNT(*)
```

### Possible analytical dimensions

A claim fact can be analyzed by:

- customer;
- insurance policy;
- insurance product;
- claim type;
- claim status;
- incident date;
- reported date.

This allows questions such as:

```text
How many claims were reported each month?

What is the total claim amount by insurance product?

Which claim types generate the highest costs?

How many claims are still in progress?
```

---

# 9. Fact: Payment

## Business process

The payment fact represents financial transactions associated with insurance policies.

### Grain

The recommended grain is:

> **One row represents one policy payment transaction.**

The natural business identifier is the source payment transaction represented by `payment_id`.

### Measures

The main measure is:

```text
payment_amount
```

A derived count measure can be represented as:

```text
payment_count = 1
```

### Possible dimensions

Payments can be analyzed by:

- payment date;
- customer;
- insurance policy;
- insurance product;
- payment method;
- payment status.

Example analytical questions:

```text
What was the total amount collected per month?

Which payment methods are used most often?

How much premium was collected for each insurance product?

How many successful transactions were processed?
```

---

# 10. Fact: Claim Payment

The `fact_claim-payment` model represents the settlement side of the claims process.

Its business process is different from the claim itself.

The important distinction is:

```text
Claim
     │
     ├── ClaimPayment
     ├── ClaimPayment
     └── ClaimPayment
```

A claim describes the **loss or requested compensation**, while claim payments describe the **actual money paid to settle the claim**.

Therefore, the two processes should not automatically be treated as the same fact.

### Grain

The recommended grain is:

> **One row represents one payment made against one insurance claim.**

### Measure

The central measure is:

```text
claim_payment_amount
```

Possible analytical questions:

```text
How much money was paid for claims?

How much was paid by month?

How much has been paid compared with the original claim amount?

Which insurance products have the highest settlement costs?
```

---

# 11. Why Separate Claim and Claim Payment Facts?

Claim and claim payment have different grains.

For example:

```text
Claim #100
    Claim amount = 10,000

    Payment #1 = 4,000
    Payment #2 = 3,000
    Payment #3 = 2,000
```

The claim exists once, while the settlement can contain multiple payment transactions.

Therefore:

```text
FactClaim
    1 row = 1 claim

FactClaimPayment
    1 row = 1 claim payment
```

This preserves transaction-level detail and avoids incorrectly duplicating claim amounts during aggregation.

---

# 12. Alternative Analytical Models

The repository intentionally contains three separate models:

```text
fact_claim.mwb
fact_payment.mwb
fact_claim-payment.mwb
```

and corresponding SVG diagrams:

```text
fact_claim.svg
fact_payment.svg
fact_claim-payment.svg
```

These files provide visual representations of the proposed warehouse structures and can be opened using MySQL Workbench or an SVG-compatible viewer.

The models can be used to compare different approaches before selecting the final warehouse architecture.

---

# 13. ETL Concept

The conceptual ETL process is:

```text
         Source Database
               │
               ▼
          Extract
               │
               ▼
         Transform
               │
               ▼
            Load
               │
               ▼
        Data Warehouse
               │
               ▼
        BI / Reporting
```

## Extract

Data is extracted from the normalized transactional tables:

```text
Client
Product
InsurancePolicy
Payment
Claim
ClaimPayment
Car
Property
```

## Transform

The transformation phase can include:

- converting source identifiers into warehouse surrogate keys;
- standardizing statuses;
- standardizing payment methods;
- creating date attributes;
- validating relationships;
- calculating derived measures;
- preparing dimension records;
- aggregating or enriching source data where appropriate.

## Load

The transformed data is loaded into the dimension and fact tables.

A typical load dependency is:

```text
Dimensions
    │
    ▼
Fact tables
```

Dimensions should normally be loaded before facts because fact records reference dimension keys.

---

# 14. Example Analytical Metrics

The warehouse can support metrics such as:

### Premium Revenue

```text
Total Premium Collected
=
SUM(Payment Amount)
```

### Number of Claims

```text
Total Claims
=
COUNT(Claim)
```

### Total Claimed Amount

```text
Total Claim Amount
=
SUM(Claim Amount)
```

### Total Claim Payments

```text
Total Settlement Cost
=
SUM(Claim Payment Amount)
```

### Average Claim

```text
Average Claim Amount
=
AVG(Claim Amount)
```

### Claim Settlement Ratio

One possible analytical KPI is:

```text
Settlement Ratio =
Total Claim Payments / Total Claim Amount
```

This ratio can be analyzed by product, customer segment, year, or claim type.

---

# 15. Example BI Questions

The final DWH can support reporting questions such as:

### Customer analytics

- How many active policies does each customer have?
- Which customers generate the highest premium revenue?
- Which customers have filed the most claims?

### Product analytics

- Which insurance product generates the highest premium?
- Which product has the highest claim frequency?
- Which product has the highest claim cost?

### Payment analytics

- What is the total premium collected each month?
- Which payment method is most frequently used?
- How many failed or unsuccessful transactions occurred?

### Claims analytics

- How many claims were reported in each month?
- Which claim type has the highest average amount?
- What is the total outstanding claim value?
- How much has already been paid for each claim?

### Profitability / risk analytics

A future BI layer could combine:

```text
Premium Revenue
        +
Claim Frequency
        +
Claim Amount
        +
Claim Payments
```

to estimate the financial performance and risk profile of insurance products.

---

# 16. Technology

The current project is based primarily on:

| Technology | Purpose |
|---|---|
| MySQL | Transactional database |
| SQL | DDL and sample data |
| MySQL Workbench | Data modeling |
| SVG | Database and DWH diagrams |
| Star Schema | Data warehouse design |
| ETL | Conceptual data integration process |
| BI | Target analytical use case |

The SQL script creates the database, tables, constraints, and sample records.

---

# 17. Repository Structure

```text
insurance-data-warehouse/
│
├── README.md
│
├── insurance_db.sql
│
├── insurance_model.mwb
├── insurance.svg
│
├── fact_claim.mwb
├── fact_claim.svg
│
├── fact_payment.mwb
├── fact_payment.svg
│
├── fact_claim-payment.mwb
└── fact_claim-payment.svg
```

### File descriptions

| File | Description |
|---|---|
| `insurance_db.sql` | Creates the transactional database and inserts sample data |
| `insurance_model.mwb` | Editable source ER model |
| `insurance.svg` | Exported ER diagram |
| `fact_claim.mwb` | Editable claim fact model |
| `fact_claim.svg` | Claim fact diagram |
| `fact_payment.mwb` | Editable payment fact model |
| `fact_payment.svg` | Payment fact diagram |
| `fact_claim-payment.mwb` | Editable claim-payment fact model |
| `fact_claim-payment.svg` | Claim-payment fact diagram |

The repository currently contains four commits and consists primarily of these SQL and data-modeling artifacts.

---

# 18. Installation

## Requirements

The current SQL implementation requires a MySQL-compatible environment.

Recommended:

```text
MySQL 8.x
MySQL Workbench
```

## Step 1 — Create the database

Open:

```text
insurance_db.sql
```

in MySQL Workbench.

## Step 2 — Execute the script

Run the complete SQL script.

The script creates:

```text
insurance_db
```

and all source tables.

## Step 3 — Verify the schema

Execute:

```sql
USE insurance_db;

SHOW TABLES;
```

Expected tables:

```text
Client
Product
Car
Property
InsurancePolicy
Payment
Claim
ClaimPayment
```

## Step 4 — Inspect the data

Example:

```sql
SELECT *
FROM InsurancePolicy;
```

or:

```sql
SELECT *
FROM Claim;
```

The provided SQL script also contains sample records for testing the model.

---

# 19. Data Integrity

The transactional schema uses primary keys, unique constraints, and foreign keys.

Examples include:

```text
Client
   │
   └── Car.client_id

Client
   │
   └── Property.client_id

Client
   │
   └── InsurancePolicy.client_id

Product
   │
   └── InsurancePolicy.product_id

InsurancePolicy
   │
   ├── Payment.policy_id
   └── Claim.policy_id

Claim
   │
   └── ClaimPayment.claim_id
```

Foreign key constraints help prevent orphan records and preserve referential integrity. The source schema also uses `ON DELETE RESTRICT` and `ON UPDATE CASCADE` on its main relationships.

---

# 20. Current Project Status

The current repository represents the **database and data warehouse modeling stage** of the project.

Implemented:

- normalized insurance source database;
- relational constraints;
- sample insurance data;
- source ER model;
- claim fact model;
- payment fact model;
- claim-payment fact model;
- SVG diagrams.

The repository description presents the project as an ETL and DWH implementation, but the current files do not yet contain a separate executable ETL pipeline or BI dashboard. The ETL process should therefore currently be understood as the architectural target rather than a fully implemented pipeline.

---

# 21. Possible Future Development

The next development stages could include:

### ETL implementation

Implement an actual ETL pipeline using Python or SQL:

```text
Source DB
    ↓
Extract
    ↓
Transform
    ↓
Load
    ↓
DWH
```

### Date Dimension

Introduce a dedicated:

```text
DimDate
```

to support:

- year;
- quarter;
- month;
- week;
- day;
- weekday;
- reporting period.

### Additional Dimensions

Possible dimensions include:

```text
DimClient
DimProduct
DimPolicy
DimVehicle
DimProperty
DimClaimType
DimPaymentMethod
DimDate
```

### BI Layer

The warehouse can later be connected to:

```text
Power BI
Tableau
Looker Studio
Metabase
```

to create dashboards for insurance management and financial analysis.

---

# 22. Recommended Final DWH Concept

For a practical final version, the analytical architecture can be organized around separate business processes:

```text
                    ┌────────────┐
                    │  DimDate   │
                    └─────┬──────┘
                          │
        ┌─────────────────┼──────────────────┐
        │                 │                  │
        ▼                 ▼                  ▼
 ┌─────────────┐   ┌─────────────┐   ┌───────────────┐
 │ DimClient   │   │ DimProduct  │   │ DimPolicy     │
 └──────┬──────┘   └──────┬──────┘   └───────┬───────┘
        │                 │                  │
        └─────────────────┼──────────────────┘
                          │
             ┌────────────┴────────────┐
             │                         │
             ▼                         ▼
       ┌─────────────┐         ┌──────────────────┐
       │ FactPayment │         │   FactClaim      │
       └──────┬──────┘         └────────┬─────────┘
              │                         │
              │                         ▼
              │                 ┌──────────────────┐
              │                 │ FactClaimPayment │
              │                 └──────────────────┘
              │
              ▼
       Payment Analytics
```

This architecture keeps the business processes at their natural grain and avoids mixing policy payments with claim settlement payments.

---

# Conclusion

The **Insurance Data Warehouse** project provides a foundation for insurance analytics by separating operational data modeling from analytical warehouse modeling.

The transactional database captures the operational business processes of customers, policies, payments, claims, and claim settlements. The DWH models then transform these processes into analytical facts that can be aggregated and analyzed using BI tools.

The most important modeling principle in the project is maintaining the correct **fact grain**:

```text
FactClaim
    → one row per insurance claim

FactPayment
    → one row per policy payment

FactClaimPayment
    → one row per claim settlement payment
```

Maintaining these grains makes it possible to calculate reliable analytical metrics without double-counting claims or payments.
