const pool = require('../config/db');

// Add a new state (Super Admin Only)
const addState = async (req, res) => {
    const { super_admin_id, state_name } = req.body;

    try {
        //procedure call
        const [results] = await pool.query('CALL AddState(?, ?, @success)', [super_admin_id, state_name]);
        const [[output]] = await pool.query('SELECT @success AS success');

        if (output.success) {
            // activity log
            await pool.query('CALL LogActivity(?, ?)', [super_admin_id, `Added state: ${state_name}`]);
            res.status(201).send({ message: 'State added successfully' });
        } else {
            res.status(403).send({ error: 'Only the super admin can add states' });
        }
    } catch (error) {
        res.status(500).send({ error: error.message });
    }
};

// View Activities Performed by Other Levels
const viewActivities = async (req, res) => {
    const { super_admin_id } = req.body;

    try {
        // Verify if the user is super admin
        const [adminCheck] = await pool.query('SELECT role_id FROM users WHERE id = ?', [super_admin_id]);

        if (adminCheck.length === 0 || adminCheck[0].role_id !== 1) {
            return res.status(403).send({ error: 'Access denied' });
        }

        // Fetch all activity logs
        const [logs] = await pool.query('SELECT * FROM activity_logs ORDER BY timestamp DESC');
        res.status(200).send(logs);
    } catch (error) {
        res.status(500).send({ error: error.message });
    }
};

module.exports = { addState, viewActivities };
