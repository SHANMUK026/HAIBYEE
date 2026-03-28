import { Router } from 'express';
import prisma from '../utils/prisma.js';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';

const router = Router();

// Standardizes phone numbers to 10 digits for DB consistency
const normalizePhone = (phone: string) => {
  const clean = phone.replace(/\D/g, '');
  return clean.length >= 10 ? clean.slice(-10) : clean;
};

// Mock OTP sending function - will be replaced with real API
const sendOTPViaAPI = async (phone: string, otp: string) => {
  try {
    // Remove all non-digit characters
    const cleanPhone = phone.replace(/\D/g, '');
    // Ensure phone number has '91' prefix
    const formattedPhone = cleanPhone.length === 10 ? `91${cleanPhone}` : cleanPhone;
    
    const response = await fetch(
      process.env.MSG91_OTP_URL || "https://control.msg91.com/api/flow/otp-login/run",
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
                      numeric: otp
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
    
    if (!response.ok) {
      console.warn('[OTP API] External provider error:', result);
    }
    return true;
  } catch (error) {
    console.error('[OTP API Error]', error);
    return true; // Return true to allow development/testing even if API fails
  }
};

router.post('/login', async (req, res) => {
  try {
    const { phone: identifier, password } = req.body;
    if (!identifier || !password) {
      return res.status(400).json({ error: 'Identifier and password are required' });
    }

    let user;
    if (identifier.includes('@')) {
      // Login via Email
      user = await prisma.user.findUnique({
        where: { email: identifier.toLowerCase().trim() },
        include: { portfolio: true }
      });
    } else {
      // Login via Phone
      const normalizedPhone = normalizePhone(identifier);
      user = await prisma.user.findUnique({
        where: { phone: normalizedPhone },
        include: { portfolio: true }
      });
    }

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (!(user as any).password) {
      return res.status(400).json({ error: 'Password not set for this account. Please login via OTP first.' });
    }

    const isMatch = await bcrypt.compare(password, (user as any).password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid password' });
    }

    const token = jwt.sign({ userId: user.id, phone: user.phone }, process.env.JWT_SECRET || 'secret', {
      expiresIn: '7d',
    });

    res.status(200).json({ token, user: user as any });
  } catch (error) {
    console.error('Login Error:', error);
    res.status(500).json({ error: 'Failed to login' });
  }
});

router.post('/send-otp', async (req, res) => {
  try {
    const { phone, intent } = req.body;
    if (!phone) return res.status(400).json({ error: 'Phone number is required' });
    if (!intent) return res.status(400).json({ error: 'Intent (REGISTER/LOGIN/FORGOT_PASSWORD) is required' });

    // Fintech Security: Check existence based on intent
    const normalizedPhone = normalizePhone(phone);
    const existingUser = await prisma.user.findUnique({ where: { phone: normalizedPhone } });
    
    if (intent === 'REGISTER' && existingUser) {
      return res.status(400).json({ error: 'User already exists. Please login.' });
    }
    
    if ((intent === 'LOGIN' || intent === 'FORGOT_PASSWORD') && !existingUser) {
      return res.status(404).json({ error: 'User not found. Please register first.' });
    }

    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    await prisma.otp.upsert({
      where: { phone: normalizedPhone },
      update: { code, expiresAt },
      create: { phone: normalizedPhone, code, expiresAt },
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
    const { phone, code, intent, password } = req.body;
    if (!phone || !code) return res.status(400).json({ error: 'Phone and code are required' });
    if (!intent) return res.status(400).json({ error: 'Intent is required' });

    const normalizedPhone = normalizePhone(phone);
    const otp = await prisma.otp.findUnique({ where: { phone: normalizedPhone } });

    if (!otp || otp.code !== code || otp.expiresAt < new Date()) {
      return res.status(400).json({ error: 'Invalid or expired OTP' });
    }

    // Clear OTP after verification
    await prisma.otp.delete({ where: { phone: normalizedPhone } });

    // Find user
    let user = await prisma.user.findUnique({ 
      where: { phone: normalizedPhone },
      include: { portfolio: true }
    });
    
    if (intent === 'REGISTER' && user) {
      return res.status(400).json({ error: 'User already exists. Cannot register again.' });
    }

    if ((intent === 'LOGIN' || intent === 'FORGOT_PASSWORD') && !user) {
      return res.status(404).json({ error: 'User not found. Please register first.' });
    }

    if (intent === 'REGISTER') {
      if (!password) {
        return res.status(400).json({ error: 'Password is required for registration' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      const referralCode = `SILVRA${Math.random().toString(36).substring(2, 8).toUpperCase()}`;
      const { referredBy, name, email } = req.body;
      const normalizedReferredBy = referredBy ? normalizePhone(referredBy) : null;

      user = await (prisma.user as any).create({
        data: { 
          phone: normalizedPhone, 
          password: hashedPassword,
          name: name || null,
          email: email || null,
          kycStatus: 'PENDING',
          referralCode,
          referredBy: normalizedReferredBy
        } as any,
        include: { portfolio: true }
      });

      // Initialize portfolio for new user
      await prisma.portfolio.create({
        data: { userId: (user as any).id, goldGrams: 0, silverGrams: 0 },
      });
      
      // Refresh user with portfolio
      user = await prisma.user.findUnique({
        where: { id: (user as any).id },
        include: { portfolio: true }
      }) as any;
    } else if (intent === 'FORGOT_PASSWORD' && user) {
        // Allow updating password via OTP
        if (password) {
            const hashedPassword = await bcrypt.hash(password, 10);
            user = await prisma.user.update({
                where: { phone: normalizedPhone },
                data: { password: hashedPassword } as any,
                include: { portfolio: true }
            }) as any;
        }
    } else if (intent === 'LOGIN' && user) {
        // Migration/Upgrade: If user logs in via OTP and doesn't have a password yet, save it if provided
        if (password && !(user as any).password) {
            const hashedPassword = await bcrypt.hash(password, 10);
            user = await prisma.user.update({
                where: { phone: normalizedPhone },
                data: { password: hashedPassword } as any,
                include: { portfolio: true }
            }) as any;
        }
    }

    if (!user) {
      return res.status(500).json({ error: 'Failed to find/create user' });
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
