
note: create database with name mcc_ict
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
    ->
    );

INSERT INTO roles (role_name) VALUES
    -> ('Superadmin'),
    -> ('Regional Admin'),
    -> ('User');




-- log table for admin view- he can view all the tables for viewing multi level activities

CREATE TABLE activity_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    performed_by VARCHAR(255) NOT NULL, -- ID of the user who performed the action
    action VARCHAR(255) NOT NULL,      -- Description of the action
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (performed_by) REFERENCES users(id) ON DELETE CASCADE
);




-- Create table for user categories (Hospitals, PHCs, etc.)
CREATE TABLE user_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) UNIQUE NOT NULL
);

-- Insert user categories (Hospitals, PHCs, Laboratories, etc.)
INSERT INTO user_types (type_name) VALUES
('Hospital'),
('PHC'),
('Laboratory'),
('UserX'),
('Volunteers');

-- Create the user(Here it refer to the types of users in the last level) table
CREATE TABLE user (
    id VARCHAR(255) PRIMARY KEY, 
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role_id INT NOT NULL, -- reference to roles
    state_id INT,         -- optional, for association with states
    region_id VARCHAR(255) -- optional, for regional association
);

-- User category relationship table (to associate users with categories)
CREATE TABLE user_category (
    user_id VARCHAR(255),
    category_id INT,
    PRIMARY KEY (user_id, category_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES user_types(id) ON DELETE CASCADE
);

-- Activity logs to track actions like adding/deleting users
CREATE TABLE activity_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    performed_by VARCHAR(255) NOT NULL,  -- User ID who performed the action (Regional Center Admin)
    action VARCHAR(255) NOT NULL,        -- Action description (Add/Delete)
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (performed_by) REFERENCES users(id) ON DELETE CASCADE
);
