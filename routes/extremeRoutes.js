const express = require('express');
const router = express.Router();
const { addUser, deleteUser, viewAllUsers } = require('../controllers/userController');

// Add a new user (Regional Center Only)
router.post('/add-user', addUser);

// Delete a user (Regional Center Only)
router.post('/delete-user', deleteUser);

// View all users (Super Admin Only)
router.get('/view-all-users', viewAllUsers);

module.exports = router;
