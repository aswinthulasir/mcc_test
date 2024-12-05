

CREATE TABLE users (
    ->     id VARCHAR(255) PRIMARY KEY,
    ->     email VARCHAR(255) UNIQUE NOT NULL,
    ->     role_id INT NOT NULL,
    ->     state_id INT NULL,
    ->     region_id INT NULL
    -> );
ALTER TABLE users
    -> ADD CONSTRAINT fk_roles
    -> FOREIGN KEY (role_id) REFERENCES roles(id);

 CREATE TABLE passwords (
    ->     user_id VARCHAR(255) PRIMARY KEY,
    ->     password_hash VARCHAR(255) NOT NULL,
    ->     salt VARCHAR(255) NOT NULL
    -> );

 CREATE TABLE states (
    ->     id INT AUTO_INCREMENT PRIMARY KEY,
    ->     state_name VARCHAR(100) UNIQUE NOT NULL
    -> );

CREATE TABLE regions (
    ->     id VARCHAR(255) PRIMARY KEY,
    ->     region_name VARCHAR(100) NOT NULL,
    ->     state_id INT NOT NULL,
    ->     admin_id VARCHAR(255) NOT NULL
    -> );

CREATE TABLE centers (
    ->     id INT AUTO_INCREMENT PRIMARY KEY,
    ->     center_name VARCHAR(255) NOT NULL,
    ->     type ENUM(
    ->         'Government Hospital',
    ->         'Private Hospital',
    ->         'PHC',
    ->         'Clinic',
    ->         'Diagnostic Center',
    ->         'Community Health Center',
    ->         'Dispensary',
    ->         'Specialized Hospital',
    ->         'Nursing Home',
    ->         'Rehabilitation Center',
    ->         'Mobile Health Unit',
    ->         'Telemedicine Center',
    ->         'Urban Health Post'
    ->     ) NOT NULL,
    ->     region_id VARCHAR(255) NOT NULL,
    ->     admin_id VARCHAR(255) NOT NULL
    -> );

CREATE TABLE roles (
    ->     id INT AUTO_INCREMENT PRIMARY KEY,         -- Unique identifier for each role
    ->     role_name VARCHAR(50) UNIQUE NOT NULL,     -- Name of the role (e.g., Superadmin, Regional Admin)
    ->     created_by VARCHAR(255),                  -- ID of the user who created the role (nullable for default roles)

    ->     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of role creation
    ->     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- Timestamp of the last update
    -> );

INSERT INTO roles (role_name) VALUES
    -> ('Superadmin'),
    -> ('Regional Admin'),
    -> ('User');



