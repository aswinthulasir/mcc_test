const pool = require('../config/db');

// Add a user (Regional Center Only)
const addUser = async (req, res) => {
    const { region_admin_id, name, email, role_id, category_ids } = req.body;

    try {
        const [results] = await pool.query('CALL AddUser(?, ?, ?, ?, ?, @success)', 
            [region_admin_id, name, email, role_id, JSON.stringify(category_ids)]);
        const [[output]] = await pool.query('SELECT @success AS success');

        if (output.success) {
            res.status(201).send({ message: 'User added successfully' });
        } else {
            res.status(403).send({ error: 'Only regional center admins can add users' });
        }
    } catch (error) {
        res.status(500).send({ error: error.message });
    }
};

// Delete a user (Regional Center Only)
const deleteUser = async (req, res) => {
    const { region_admin_id, user_id } = req.body;

    try {
        const [results] = await pool.query('CALL DeleteUser(?, ?, @success)', 
            [region_admin_id, user_id]);
        const [[output]] = await pool.query('SELECT @success AS success');

        if (output.success) {
            res.status(200).send({ message: 'User deleted successfully' });
        } else {
            res.status(403).send({ error: 'Only regional center admins can delete users' });
        }
    } catch (error) {
        res.status(500).send({ error: error.message });
    }
};

// View all users (Super Admin Only)
const viewAllUsers = async (req, res) => {
    const { super_admin_id } = req.body;

    try {
        // Check if super admin
        const [adminCheck] = await pool.query('SELECT role_id FROM users WHERE id = ?', [super_admin_id]);

        if (adminCheck.length === 0 || adminCheck[0].role_id !== 1) {
            return res.status(403).send({ error: 'Access denied' });
        }

        // Fetch all users
        const [users] = await pool.query('SELECT * FROM users');
        res.status(200).send(users);
    } catch (error) {
        res.status(500).send({ error: error.message });
    }
};

module.exports = { addUser, deleteUser, viewAllUsers };
