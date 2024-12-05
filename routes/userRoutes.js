const express = require('express');
const router = express.Router();
const pool = require('../config/db');
const jwt = require('jsonwebtoken');


// Register a user
router.post('/register', async (req, res) => {
    const { email, password, role_id } = req.body;

    try {
        // Call the stored procedure to register the user
        await pool.query('CALL  RegisterUser(?, ?, ?)', [email, password, role_id]);

        res.status(201).send({ message: 'User registered successfully' });
    } catch (error) {
        console.error(error.message);
        res.status(500).send({ error: 'An error occurred while registering the user.' });
    }
});
router.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        // Call the stored procedure to validate the user
        await pool.query('CALL LoginUser(?, ?, @is_valid, @role_id);', [email, password]);

        // Retrieve the output values of the procedure
        const [result] = await pool.query('SELECT @is_valid AS is_valid, @role_id AS role_id;');

        const loginResult = result[0]; // Access the first row
        if (!loginResult || !loginResult.is_valid) {
            return res.status(401).send({ error: 'Invalid credentials' });
        }

        // Generate JWT token
        const token = jwt.sign({ email, role_id: loginResult.role_id }, process.env.JWT_SECRET, { expiresIn: '1h' });
        res.status(200).send({ message: 'Login successful', token });
    } catch (error) {
        console.error(error.message);
        res.status(500).send({ error: 'An error occurred while logging in.' });
    }
});

module.exports = router;
