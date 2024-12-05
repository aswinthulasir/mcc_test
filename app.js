const express = require('express');
const app = express();
app.use(express.json());
require('./config/db')
const morgan=require('morgan');
app.use(morgan('dev'));
require('dotenv').config();
const PORT=process.env.PORT
const user=require('./routes/userRoutes');
app.use('/api',user);




app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
 