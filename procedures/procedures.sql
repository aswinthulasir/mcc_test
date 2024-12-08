DELIMITER $$

CREATE PROCEDURE LoginUser(
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255),
    OUT p_is_valid BOOLEAN,
    OUT p_role_id INT
)
BEGIN
    DECLARE stored_hash VARCHAR(255);
    DECLARE stored_salt VARCHAR(255);

    -- Retrieve password hash and salt for the given email
    SELECT p.password_hash, p.salt, u.role_id
    INTO stored_hash, stored_salt, p_role_id
    FROM users u
    JOIN passwords p ON u.id = p.user_id
    WHERE u.email = p_email;

    -- Validate the provided password
    IF SHA2(CONCAT(p_password, stored_salt), 256) = stored_hash THEN
        SET p_is_valid = TRUE;
    ELSE
        SET p_is_valid = FALSE;
    END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE RegisterUser(
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_role_id INT
)
BEGIN
    DECLARE hashed_id VARCHAR(255);
    DECLARE salt VARCHAR(255);
    DECLARE password_hash VARCHAR(255);

    -- Generate a unique user ID
    SET hashed_id = SHA2(UUID(), 256);

    -- Generate a random salt (first 16 characters of UUID)
    SET salt = LEFT(UUID(), 16);

    -- Hash the password with the salt
    SET password_hash = SHA2(CONCAT(p_password, salt), 256);

    -- Insert user into the users table
    INSERT INTO users (id, email, role_id) 
    VALUES (hashed_id, p_email, p_role_id);

    -- Insert password and salt into the passwords table
    INSERT INTO passwords (user_id, password_hash, salt) 
    VALUES (hashed_id, password_hash, salt);
END$$

DELIMITER ;


-- add state procedure


DELIMITER $$

CREATE PROCEDURE AddState(
    IN p_super_admin_id VARCHAR(255),
    IN p_state_name VARCHAR(100),
    OUT p_success BOOLEAN
)
BEGIN
    DECLARE admin_role INT;

    -- Check super admin == true
    SELECT role_id INTO admin_role
    FROM users
    WHERE id = p_super_admin_id;

    IF admin_role = 1 THEN
        -- add state
        INSERT INTO states (state_name, created_by)
        VALUES (p_state_name, p_super_admin_id);
        SET p_success = TRUE;
    ELSE
        -- If not super admin, set to FALSE
        SET p_success = FALSE;
    END IF;
END$$

DELIMITER ;



-- Add regional centers


DELIMITER $$

CREATE PROCEDURE AddRegionalCenter(
    IN p_state_admin_id VARCHAR(255),
    IN p_center_name VARCHAR(255),
    IN p_type ENUM('Government Hospital', 'Private Hospital', 'PHC', 'Clinic', 'Diagnostic Center', 'Community Health Center', 'Dispensary', 'Specialized Hospital', 'Nursing Home', 'Rehabilitation Center', 'Mobile Health Unit', 'Telemedicine Center', 'Urban Health Post'),
    IN p_region_id VARCHAR(255),
    IN p_admin_id VARCHAR(255),
    OUT p_success BOOLEAN
)
BEGIN
    DECLARE admin_role INT;

    -- Check if the user is a state admin (assuming role_id for state admin is 2)
    SELECT role_id INTO admin_role
    FROM users
    WHERE id = p_state_admin_id;

    IF admin_role = 2 THEN
        -- Insert the new regional center
        INSERT INTO centers (center_name, type, region_id, admin_id)
        VALUES (p_center_name, p_type, p_region_id, p_admin_id);
        
        -- Log activity
        CALL LogActivity(p_state_admin_id, CONCAT('Added regional center: ', p_center_name));
        
        SET p_success = TRUE;
    ELSE
        -- If not a state admin, set success to FALSE
        SET p_success = FALSE;
    END IF;
END$$

DELIMITER ;


-- State log activity for viewing by admin

DELIMITER $$

CREATE PROCEDURE LogActivity(
    IN p_user_id VARCHAR(255),
    IN p_action VARCHAR(255)
)
BEGIN
    INSERT INTO activity_logs (performed_by, action)
    VALUES (p_user_id, p_action);
END$$

DELIMITER ;



-- Final users

DELIMITER $$

CREATE PROCEDURE AddUser(
    IN p_region_admin_id VARCHAR(255), 
    IN p_name VARCHAR(255), 
    IN p_email VARCHAR(255),
    IN p_role_id INT, 
    IN p_category_ids JSON, -- List of category IDs (Hospitals, PHCs, etc.)
    OUT p_success BOOLEAN
)
BEGIN
    DECLARE new_user_id VARCHAR(255);

    -- Check if the user has the necessary permission (Region Admin role)
    DECLARE region_admin_role INT;
    SELECT role_id INTO region_admin_role FROM users WHERE id = p_region_admin_id;
    IF region_admin_role != 2 THEN
        SET p_success = FALSE;
        LEAVE;
    END IF;

    -- Insert new user
    SET new_user_id = SHA2(UUID(), 256);  -- Generate a unique user ID
    INSERT INTO users (id, name, email, role_id) VALUES (new_user_id, p_name, p_email, p_role_id);

    -- Insert user-category relationships
    SET @categories = JSON_UNQUOTE(p_category_ids);
    SET @category_count = JSON_LENGTH(@categories);

    -- Loop through the categories and associate them with the user
    DECLARE i INT DEFAULT 0;
    WHILE i < @category_count DO
        INSERT INTO user_category (user_id, category_id) 
        VALUES (new_user_id, JSON_UNQUOTE(JSON_EXTRACT(@categories, CONCAT('$[', i, ']'))));
        SET i = i + 1;
    END WHILE;

    -- Log the activity
    CALL LogActivity(p_region_admin_id, CONCAT('Added user: ', p_name));

    SET p_success = TRUE;
END$$

DELIMITER ;


-- Dlte user

DELIMITER $$

CREATE PROCEDURE DeleteUser(
    IN p_region_admin_id VARCHAR(255), 
    IN p_user_id VARCHAR(255), 
    OUT p_success BOOLEAN
)
BEGIN
    -- Check if the user has the necessary permission (Region Admin role)
    DECLARE region_admin_role INT;
    SELECT role_id INTO region_admin_role FROM users WHERE id = p_region_admin_id;
    IF region_admin_role != 2 THEN
        SET p_success = FALSE;
        LEAVE;
    END IF;

    -- Delete user-category relationships
    DELETE FROM user_category WHERE user_id = p_user_id;

    -- Delete user
    DELETE FROM users WHERE id = p_user_id;

    -- Log the activity
    CALL LogActivity(p_region_admin_id, CONCAT('Deleted user: ', p_user_id));

    SET p_success = TRUE;
END$$

DELIMITER ;


-- Activity log for add/dlt

DELIMITER $$

CREATE PROCEDURE LogActivity(
    IN p_user_id VARCHAR(255), 
    IN p_action VARCHAR(255)
)
BEGIN
    INSERT INTO activity_logs (performed_by, action)
    VALUES (p_user_id, p_action);
END$$

DELIMITER ;
