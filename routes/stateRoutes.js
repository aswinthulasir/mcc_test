// Routes for states
const express = require('express');
const router = express.Router();
const { addRegionalCenter, viewRegionalCenters, viewActivities } = require('../controllers/adminController');

// Add a new regional center (State Admin Only)
router.post('/add-regional-center', addRegionalCenter);

// View all regional centers (Super Admin)
router.get('/view-regional-centers', viewRegionalCenters);

// View activities (Super Admin Only)
router.get('/view-activities', viewActivities);

module.exports = router;
