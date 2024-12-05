
DELIMITER $$

CREATE PROCEDURE InsertUser(
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_salt VARCHAR(255),
    IN p_role_id INT
)
BEGIN
    DECLARE hashed_id VARCHAR(255);
    SET hashed_id = SHA2(UUID(), 256);
    INSERT INTO users (id, email, role_id) VALUES (hashed_id, p_email, p_role_id);
    INSERT INTO passwords (user_id, password_hash, salt) VALUES (hashed_id, SHA2(CONCAT(p_password, p_salt), 256), p_salt);
END$$

CREATE TRIGGER HashRegionID
BEFORE INSERT ON regions
FOR EACH ROW
BEGIN
    SET NEW.id = SHA2(UUID(), 256);
END$$

DELIMITER ;
