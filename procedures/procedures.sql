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
