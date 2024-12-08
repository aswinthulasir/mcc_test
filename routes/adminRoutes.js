const express = require('express');
const router = express.Router();
const { addState, viewActivities } = require('../controllers/adminController');

// Add a new state
router.post('/add-state', addState);

// View activities
router.get('/view-activities', viewActivities);

module.exports = router;
