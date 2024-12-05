
const pool = require('../config/db');

const createUser = async (req, res) => {
  const { email, password, salt, role_id } = req.body;
  try {
    await pool.query('CALL InsertUser(?, ?, ?, ?)', [email, password, salt, role_id]);
    res.status(201).send({ message: 'User created successfully' });
  } catch (error) {
    res.status(500).send({ error: error.message });
  }
};

module.exports = { createUser };
