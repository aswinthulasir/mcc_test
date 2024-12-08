// Controller for state-related logic
const pool = require('../config/db');

// Add regional center by state
const addRegionalCenter = async (req, res) => {
    const { state_admin_id, center_name, type, region_id, admin_id } = req.body;

    try {
        // procedure call
        const [results] = await pool.query('CALL AddRegionalCenter(?, ?, ?, ?, ?, @success)', 
            [state_admin_id, center_name, type, region_id, admin_id]);
        const [[output]] = await pool.query('SELECT @success AS success');

        if (output.success) {
            res.status(201).send({ message: 'Regional center added successfully' });
        } else {
            res.status(403).send({ error: 'Only state admins can add regional centers' });
        }
    } catch (error) {
        res.status(500).send({ error: error.message });
    }
};

// View Regional Centers by admin
const viewRegionalCenters = async (req, res) => {
    try {
        const [centers] = await pool.query('SELECT * FROM centers ORDER BY center_name');
        res.status(200).send(centers);
    } catch (error) {
        res.status(500).send({ error: error.message });
    }
};


const viewActivities = async (req, res) => {
    const { super_admin_id } = req.body;

    try {
        
        const [adminCheck] = await pool.query('SELECT role_id FROM users WHERE id = ?', [super_admin_id]);

        if (adminCheck.length === 0 || adminCheck[0].role_id !== 1) {
            return res.status(403).send({ error: 'Access denied' });
        }

        const [logs] = await pool.query('SELECT * FROM activity_logs ORDER BY timestamp DESC');
        res.status(200).send(logs);
    } catch (error) {
        res.status(500).send({ error: error.message });
    }
};

module.exports = { addRegionalCenter, viewRegionalCenters, viewActivities };
