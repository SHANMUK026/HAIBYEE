import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/auth.js';
import priceRoutes from './routes/prices.js';
import paymentRoutes from './routes/payments.js';
import kycRoutes from './routes/kyc.js';
import sipRoutes from './routes/sips.js';
import profileRoutes from './routes/profile.js';

dotenv.config();
console.log('[DEBUG] DATABASE_URL:', process.env.DATABASE_URL ? 'FOUND' : 'MISSING');

const app = express();
const port = process.env.PORT || 3000;

app.use(cors({ origin: '*' }));
app.use(express.static('public'));
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/prices', priceRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/kyc', kycRoutes);
app.use('/api/sips', sipRoutes);
app.use('/api/profile', profileRoutes);

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.listen(Number(port), '0.0.0.0', () => {
  console.log(`Server is running on port ${port} and listening on all interfaces`);
});
