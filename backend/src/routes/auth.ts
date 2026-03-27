import { Router } from 'express';
import prisma from '../utils/prisma.js';
import jwt from 'jsonwebtoken';

const router = Router();

// Mock OTP sending function - will be replaced with real API
const sendOTPViaAPI = async (phone: string, otp: string) => {
  try {
    // Remove all non-digit characters
    const cleanPhone = phone.replace(/\D/g, '');
    // Ensure phone number has '91' prefix
    const formattedPhone = cleanPhone.length === 10 ? `91${cleanPhone}` : cleanPhone;
    
    const response = await fetch(
      process.env.MSG91_OTP_URL || "https://control.msg91.com/api/v5/oneapi/api/flow/otp-login/run",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "authkey": process.env.MSG91_AUTH_KEY || ""
        },
        body: JSON.stringify({
          data: {
            sendTo: [
              {
                to: [
                  {
                    mobiles: formattedPhone,
                    variables: {
                      numeric: {
                        type: "number",
                        value: otp
                      }
                    }
                  }
                ]
              }
            ]
          }
        })
      }
    );

    const result = await response.json();
    console.log('[OTP API Response]', result);
    return response.ok;
  } catch (error) {
    console.error('[OTP API Error]', error);
    return false;
  }
};

router.post('/send-otp', async (req, res) => {
  try {
    const { phone } = req.body;
    if (!phone) return res.status(400).json({ error: 'Phone number is required' });

    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    await prisma.otp.upsert({
      where: { phone },
      update: { code, expiresAt },
      create: { phone, code, expiresAt },
    });

    await sendOTPViaAPI(phone, code);

    res.status(200).json({ message: 'OTP sent successfully' });
  } catch (error) {
    console.error('Send OTP Error:', error);
    res.status(500).json({ error: 'Failed to send OTP' });
  }
});

router.post('/verify-otp', async (req, res) => {
  try {
    const { phone, code } = req.body;
    if (!phone || !code) return res.status(400).json({ error: 'Phone and code are required' });

    const otp = await prisma.otp.findUnique({ where: { phone } });

    if (!otp || otp.code !== code || otp.expiresAt < new Date()) {
      return res.status(400).json({ error: 'Invalid or expired OTP' });
    }

    // Clear OTP after verification
    await prisma.otp.delete({ where: { phone } });

    // Find or create user
    let user = await prisma.user.findUnique({ where: { phone } });
    if (!user) {
      const referralCode = `SILVRA${Math.random().toString(36).substring(2, 8).toUpperCase()}`;
      const { referredBy, name, email } = req.body;

      user = await prisma.user.create({
        data: { 
          phone, 
          name: name || null,
          email: email || null,
          kycStatus: 'PENDING',
          referralCode,
          referredBy: referredBy || null
        },
      });

      // Initialize portfolio for new user
      await prisma.portfolio.create({
        data: { userId: user.id, goldGrams: 0, silverGrams: 0 },
      });
    }

    const token = jwt.sign({ userId: user.id, phone: user.phone }, process.env.JWT_SECRET || 'secret', {
      expiresIn: '7d',
    });

    res.status(200).json({ token, user });
  } catch (error) {
    console.error('Verify OTP Error:', error);
    res.status(500).json({ error: 'Failed to verify OTP' });
  }
});

export default router;
