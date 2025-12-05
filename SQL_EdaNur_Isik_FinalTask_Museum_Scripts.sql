/* ===================================================
   FINAL INTEGRATED SCRIPT: MUSEUM DATABASE
   Status: Rerunnable, 3NF, Secure
   =================================================== */

-- 1. TRANSACTION SETUP & SCHEMA
-- Start fresh. 
-- Note: Roles are global, Schema is local.

CREATE SCHEMA IF NOT EXISTS MuseumDomain;
SET search_path TO MuseumDomain;

-- 2. CLEANUP (Drop Objects in correct order)
-- We use CASCADE to clean dependencies automatically.
DROP TABLE IF EXISTS Exhibition_Artworks CASCADE;
DROP TABLE IF EXISTS Visitors CASCADE;
DROP TABLE IF EXISTS Artworks CASCADE;
DROP TABLE IF EXISTS Exhibitions CASCADE;
DROP TABLE IF EXISTS Employees CASCADE;
DROP TABLE IF EXISTS Locations CASCADE;
DROP TABLE IF EXISTS Artists CASCADE;
DROP VIEW IF EXISTS v_Quarterly_Exhibition_Analytics CASCADE;

-- Cleanup Functions
DROP FUNCTION IF EXISTS update_artwork_details CASCADE;
DROP FUNCTION IF EXISTS register_visit_transaction CASCADE;


-- 3. DDL: CREATE TABLES
-- Note: Parent tables first, then Child tables.

-- Table: Artists
CREATE TABLE Artists (
    artist_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_year INT,
    bio TEXT
);

-- Table: Locations
CREATE TABLE Locations (
    location_id SERIAL PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL,
    floor_number INT,
    capacity INT DEFAULT 0
);

-- Table: Employees
CREATE TABLE Employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    
    -- Generated Column
    full_name VARCHAR(101) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    
    email VARCHAR(100) NOT NULL,
    hire_date DATE DEFAULT CURRENT_DATE,
    role VARCHAR(50),
    assigned_location_id INT,
    
    CONSTRAINT fk_emp_location
        FOREIGN KEY (assigned_location_id) REFERENCES Locations(location_id) ON DELETE SET NULL
);

-- Table: Exhibitions
CREATE TABLE Exhibitions (
    exhibition_id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    start_date DATE,
    end_date DATE,
    description TEXT,
    manager_id INT,
    
    CONSTRAINT fk_exh_manager
        FOREIGN KEY (manager_id) REFERENCES Employees(employee_id) ON DELETE SET NULL
);

-- Table: Artworks
CREATE TABLE Artworks (
    artwork_id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    creation_year INT,
    category VARCHAR(50),
    artist_id INT,
    location_id INT, 
    
    CONSTRAINT fk_art_artist
        FOREIGN KEY (artist_id) REFERENCES Artists(artist_id) ON DELETE SET NULL,
    CONSTRAINT fk_art_location
        FOREIGN KEY (location_id) REFERENCES Locations(location_id) ON DELETE SET NULL
);

-- Table: Visitors
CREATE TABLE Visitors (
    visitor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    ticket_type VARCHAR(20),
    visit_date DATE DEFAULT CURRENT_DATE,
    visited_exhibition_id INT,
    
    CONSTRAINT fk_vis_exhibition
        FOREIGN KEY (visited_exhibition_id) REFERENCES Exhibitions(exhibition_id) ON DELETE SET NULL
);

-- Table: Exhibition_Artworks
CREATE TABLE Exhibition_Artworks (
    exhibition_id INT NOT NULL,
    artwork_id INT NOT NULL,
    
    PRIMARY KEY (exhibition_id, artwork_id), 
    
    CONSTRAINT fk_link_exh
        FOREIGN KEY (exhibition_id) REFERENCES Exhibitions(exhibition_id) ON DELETE CASCADE,
    CONSTRAINT fk_link_art
        FOREIGN KEY (artwork_id) REFERENCES Artworks(artwork_id) ON DELETE CASCADE
);


-- 4. CONSTRAINTS (ALTER TABLE)
-- Applying business rules.

ALTER TABLE Visitors
    ADD CONSTRAINT chk_visit_date_valid CHECK (visit_date >= '2024-01-01');

ALTER TABLE Locations
    ADD CONSTRAINT chk_capacity_positive CHECK (capacity >= 0);

ALTER TABLE Employees
    ADD CONSTRAINT chk_employee_role CHECK (role IN ('Curator', 'Security', 'Manager', 'Guide', 'Intern'));

ALTER TABLE Exhibitions
    ADD CONSTRAINT chk_exhibition_dates CHECK (end_date >= start_date);

ALTER TABLE Artworks
    ADD CONSTRAINT chk_creation_year CHECK (creation_year <= 2026); 

ALTER TABLE Employees
    ADD CONSTRAINT uq_employee_email UNIQUE (email);


-- 5. DML: POPULATE DATA
-- Truncate is strictly not needed here since we just dropped tables, but kept for "rerunnable" logic in DML context.
TRUNCATE TABLE Artists, Locations, Employees, Exhibitions, Artworks, Visitors, Exhibition_Artworks RESTART IDENTITY CASCADE;

-- Locations
INSERT INTO Locations (location_name, floor_number, capacity) VALUES
('Main Exhibition Hall', 1, 200),
('Renaissance Gallery', 2, 100),
('Modern Art Wing', 3, 150),
('Secure Storage A', -1, 500), 
('Restoration Lab', -1, 20),
('Entrance Lobby', 1, 300);

-- Artists
INSERT INTO Artists (first_name, last_name, birth_year, bio) VALUES
('Osman Hamdi', 'Bey', 1842, 'Ottoman administrator, painter.'),
('Vincent', 'van Gogh', 1853, 'Dutch Post-Impressionist painter.'),
('Leonardo', 'da Vinci', 1452, 'Italian polymath.'),
('Frida', 'Kahlo', 1907, 'Mexican painter.'),
('Salvador', 'Dali', 1904, 'Spanish surrealist.'),
('Yayoi', 'Kusama', 1929, 'Japanese contemporary artist.');

-- Employees
INSERT INTO Employees (first_name, last_name, email, hire_date, role, assigned_location_id) VALUES
('Ahmet', 'Yilmaz', 'ahmet.y@museum.com', '2024-05-10', 'Manager', (SELECT location_id FROM Locations WHERE location_name = 'Main Exhibition Hall')),
('Ayse', 'Demir', 'ayse.d@museum.com', '2025-01-15', 'Curator', (SELECT location_id FROM Locations WHERE location_name = 'Renaissance Gallery')),
('Mehmet', 'Oz', 'mehmet.o@museum.com', '2025-08-20', 'Security', (SELECT location_id FROM Locations WHERE location_name = 'Secure Storage A')),
('Zeynep', 'Kaya', 'zeynep.k@museum.com', '2024-11-01', 'Guide', (SELECT location_id FROM Locations WHERE location_name = 'Modern Art Wing')),
('Can', 'Celik', 'can.c@museum.com', '2025-10-05', 'Intern', (SELECT location_id FROM Locations WHERE location_name = 'Restoration Lab')),
('Elif', 'Sari', 'elif.s@museum.com', '2024-03-12', 'Security', (SELECT location_id FROM Locations WHERE location_name = 'Entrance Lobby'));

-- Exhibitions
INSERT INTO Exhibitions (title, start_date, end_date, description, manager_id) VALUES
('Ottoman Era Masterpieces', '2025-10-01', '2025-12-30', 'Late Ottoman art period.', (SELECT employee_id FROM Employees WHERE email = 'ayse.d@museum.com')),
('Surrealism Dreams', '2025-11-01', '2026-01-15', 'Subconscious mind.', (SELECT employee_id FROM Employees WHERE email = 'ahmet.y@museum.com')),
('Modern Abstract', '2025-10-15', '2025-11-30', 'Contemporary abstract.', (SELECT employee_id FROM Employees WHERE email = 'ahmet.y@museum.com')),
('Renaissance Revival', '2025-12-01', '2026-02-28', 'Rebirth of art.', (SELECT employee_id FROM Employees WHERE email = 'ayse.d@museum.com')),
('Nature and Artifacts', '2025-09-01', '2025-10-30', 'Mexican nature.', (SELECT employee_id FROM Employees WHERE email = 'ahmet.y@museum.com')),
('Interactive Sculpture', '2025-11-10', '2025-12-20', 'Touch and feel.', (SELECT employee_id FROM Employees WHERE email = 'ayse.d@museum.com'));

-- Artworks
INSERT INTO Artworks (title, creation_year, category, artist_id, location_id) VALUES
('The Tortoise Trainer', 1906, 'Painting', (SELECT artist_id FROM Artists WHERE last_name = 'Bey'), (SELECT location_id FROM Locations WHERE location_name = 'Main Exhibition Hall')),
('Starry Night', 1889, 'Painting', (SELECT artist_id FROM Artists WHERE last_name = 'van Gogh'), (SELECT location_id FROM Locations WHERE location_name = 'Secure Storage A')),
('Mona Lisa', 1503, 'Painting', (SELECT artist_id FROM Artists WHERE last_name = 'da Vinci'), (SELECT location_id FROM Locations WHERE location_name = 'Renaissance Gallery')),
('The Two Fridas', 1939, 'Painting', (SELECT artist_id FROM Artists WHERE last_name = 'Kahlo'), (SELECT location_id FROM Locations WHERE location_name = 'Main Exhibition Hall')),
('The Persistence of Memory', 1931, 'Painting', (SELECT artist_id FROM Artists WHERE last_name = 'Dali'), (SELECT location_id FROM Locations WHERE location_name = 'Modern Art Wing')),
('Pumpkin', 1994, 'Sculpture', (SELECT artist_id FROM Artists WHERE last_name = 'Kusama'), (SELECT location_id FROM Locations WHERE location_name = 'Entrance Lobby'));

-- Visitors
INSERT INTO Visitors (first_name, last_name, ticket_type, visit_date, visited_exhibition_id) VALUES
('John', 'Doe', 'Adult', '2025-10-10', (SELECT exhibition_id FROM Exhibitions WHERE title = 'Ottoman Era Masterpieces')),
('Jane', 'Smith', 'Student', '2025-11-05', (SELECT exhibition_id FROM Exhibitions WHERE title = 'Surrealism Dreams')),
('Ali', 'Veli', 'Student', '2025-12-01', (SELECT exhibition_id FROM Exhibitions WHERE title = 'Renaissance Revival')),
('Ayse', 'Fatma', 'Adult', '2025-10-20', (SELECT exhibition_id FROM Exhibitions WHERE title = 'Modern Abstract')),
('Michael', 'Jordan', 'Senior', '2025-11-15', (SELECT exhibition_id FROM Exhibitions WHERE title = 'Surrealism Dreams')),
('Serena', 'Williams', 'Adult', '2025-12-04', (SELECT exhibition_id FROM Exhibitions WHERE title = 'Ottoman Era Masterpieces'));

-- Exhibition_Artworks
INSERT INTO Exhibition_Artworks (exhibition_id, artwork_id) VALUES
((SELECT exhibition_id FROM Exhibitions WHERE title = 'Ottoman Era Masterpieces'), (SELECT artwork_id FROM Artworks WHERE title = 'The Tortoise Trainer')),
((SELECT exhibition_id FROM Exhibitions WHERE title = 'Renaissance Revival'), (SELECT artwork_id FROM Artworks WHERE title = 'Mona Lisa')),
((SELECT exhibition_id FROM Exhibitions WHERE title = 'Surrealism Dreams'), (SELECT artwork_id FROM Artworks WHERE title = 'The Persistence of Memory')),
((SELECT exhibition_id FROM Exhibitions WHERE title = 'Nature and Artifacts'), (SELECT artwork_id FROM Artworks WHERE title = 'The Two Fridas')),
((SELECT exhibition_id FROM Exhibitions WHERE title = 'Modern Abstract'), (SELECT artwork_id FROM Artworks WHERE title = 'Pumpkin')),
((SELECT exhibition_id FROM Exhibitions WHERE title = 'Modern Abstract'), (SELECT artwork_id FROM Artworks WHERE title = 'Starry Night'));


-- 6. FUNCTIONS & PROCEDURES

-- Update Function
CREATE OR REPLACE FUNCTION update_artwork_details(
    p_artwork_id INT,
    p_column_name TEXT,
    p_new_value TEXT
)
RETURNS VOID AS $$
DECLARE
    v_query TEXT;
BEGIN
    IF p_column_name NOT IN ('title', 'category', 'creation_year') THEN
        RAISE EXCEPTION 'Invalid column name allowed for update: %', p_column_name;
    END IF;

    v_query := format(
        'UPDATE Artworks SET %I = %L WHERE artwork_id = %s',
        p_column_name,
        p_new_value,
        p_artwork_id
    );

    EXECUTE v_query;
    RAISE NOTICE 'Artwork updated.';
END;
$$ LANGUAGE plpgsql;

-- Transaction Function
CREATE OR REPLACE FUNCTION register_visit_transaction(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_ticket_type VARCHAR,
    p_exhibition_title VARCHAR
)
RETURNS VOID AS $$
DECLARE
    v_exhibition_id INT;
BEGIN
    SELECT exhibition_id INTO v_exhibition_id
    FROM Exhibitions
    WHERE title = p_exhibition_title;

    IF v_exhibition_id IS NULL THEN
        RAISE EXCEPTION 'Exhibition not found: %', p_exhibition_title;
    END IF;

    INSERT INTO Visitors (first_name, last_name, ticket_type, visit_date, visited_exhibition_id)
    VALUES (p_first_name, p_last_name, p_ticket_type, CURRENT_DATE, v_exhibition_id);

    RAISE NOTICE 'Visitor transaction added.';
END;
$$ LANGUAGE plpgsql;


-- 7. VIEWS

CREATE VIEW v_Quarterly_Exhibition_Analytics AS
SELECT 
    e.title AS Exhibition_Name,
    TO_CHAR(v.visit_date, 'YYYY-"Q"Q') AS Quarter_Period,
    v.ticket_type AS Visitor_Category,
    COUNT(v.visitor_id) AS Total_Visitors
FROM 
    Visitors v
JOIN 
    Exhibitions e ON v.visited_exhibition_id = e.exhibition_id
WHERE 
    v.visit_date >= DATE_TRUNC('quarter', CURRENT_DATE)
GROUP BY 
    e.title, 
    TO_CHAR(v.visit_date, 'YYYY-"Q"Q'), 
    v.ticket_type
ORDER BY 
    Total_Visitors DESC;


-- 8. SECURITY (ROLE MANAGEMENT)
-- This part ensures we can drop the user even if they have permissions.

DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'museum_manager') THEN
        REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA MuseumDomain FROM museum_manager;
        REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA MuseumDomain FROM museum_manager;
        REVOKE USAGE ON SCHEMA MuseumDomain FROM museum_manager;
    END IF;
END
$$;

DROP ROLE IF EXISTS museum_manager;

CREATE ROLE museum_manager WITH 
    LOGIN 
    PASSWORD 'Manager123!' 
    NOSUPERUSER     
    NOCREATEDB      
    NOCREATEROLE    
    NOINHERIT;      

GRANT USAGE ON SCHEMA MuseumDomain TO museum_manager;
GRANT SELECT ON ALL TABLES IN SCHEMA MuseumDomain TO museum_manager;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA MuseumDomain TO museum_manager;

-- Final Message
DO $$ BEGIN RAISE NOTICE 'Database built correctly.'; END $$;