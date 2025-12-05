# 🏛️ Museum Database Management System

## 📌 Project Overview
This project is a comprehensive SQL-based database solution designed to manage the core operations of a museum. It handles data related to **artworks, exhibitions, artists, employees, visitors, and storage locations**.

The system is built ensuring **3rd Normal Form (3NF)** compliance to minimize redundancy and features advanced SQL implementations such as stored procedures, triggers, and security roles.

## 📂 Repository Contents
* `Museum_Database_Script.sql`: The complete, rerunnable SQL script (Schema, DDL, DML, DCL).
* `Museum_Logical_Model.png`: Visual representation of the database schema (Logical Level).
* `Project_Documentation.pdf`: Detailed documentation regarding the database design decisions.

## ⚙️ Technical Features
The SQL script demonstrates the following technical competencies:

* **Data Integrity & Constraints:**
    * Use of `PRIMARY KEY` and `FOREIGN KEY` for relational integrity.
    * `CHECK` constraints for business logic (e.g., preventing negative capacity, validating dates).
    * `UNIQUE` constraints for email addresses.
* **Advanced SQL Constructs:**
    * **Generated Columns:** Automatic `full_name` generation from first and last names.
    * **Stored Functions:** Custom PL/PGSQL functions for updating records (`update_artwork_details`) and handling transactions (`register_visit_transaction`).
    * **Views:** Analytical view (`v_Quarterly_Exhibition_Analytics`) to track visitor trends.
* **Security:**
    * Implementation of Role-Based Access Control (RBAC).
    * Created a specific `museum_manager` role with restricted permissions (Least Privilege Principle).

## 🗂️ Database Schema
The database operates under the `MuseumDomain` schema and consists of the following entities:

1.  **Artists:** Stores artist biography and details.
2.  **Locations:** Manages exhibition halls and storage units with capacity checks.
3.  **Employees:** Tracks staff details, roles, and assigned locations.
4.  **Exhibitions:** Manages event schedules and assigned managers.
5.  **Artworks:** Inventory of all items, linked to artists and physical locations.
6.  **Visitors:** Tracks visitor logs and ticket types.
7.  **Exhibition_Artworks:** A junction table handling the Many-to-Many relationship between exhibitions and artworks.

## 🚀 How to Run
1.  Ensure you have **PostgreSQL** installed.
2.  Open your preferred SQL tool (pgAdmin, DBeaver, or PSQL CLI).
3.  Run the `Museum_Database_Script.sql` file.
    * *Note: The script is designed to be **rerunnable**. It will automatically clean up existing objects (DROP) before creating new ones.*

## 📊 Analytics Example
The project includes a view to analyze visitor traffic per quarter:

```sql
SELECT * FROM v_Quarterly_Exhibition_Analytics;
