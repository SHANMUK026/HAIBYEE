import { Router } from 'express';
import prisma from '../utils/prisma.js';
import Razorpay from 'razorpay';
import crypto from 'crypto';

const router = Router();

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID || 'rzp_test_placeholder',
  key_secret: process.env.RAZORPAY_KEY_SECRET || 'placeholder_secret',
});

router.post('/create-order', async (req, res) => {
  try {
    const { amount, assetType, grams, userId } = req.body;
    if (!amount || !assetType || !grams || !userId) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const options = {
      amount: Math.round(amount * 100), // amount in the smallest currency unit (paise)
      currency: "INR",
      receipt: `receipt_${Date.now()}`,
    };

    const order = await razorpay.orders.create(options);

    // Create a pending transaction record
    await prisma.transaction.create({
      data: {
        userId: parseInt(userId),
        type: 'BUY',
        assetType,
        amount: parseFloat(amount),
        grams: parseFloat(grams),
        status: 'PENDING',
        referenceId: order.id,
      },
    });

    res.status(200).json(order);
  } catch (error) {
    console.error('Create Order Error:', error);
    res.status(500).json({ error: 'Failed to create payment order' });
  }
});

router.post('/verify-payment', async (req, res) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;

    const sign = razorpay_order_id + "|" + razorpay_payment_id;
    const expectedSign = crypto
      .createHmac("sha256", process.env.RAZORPAY_KEY_SECRET || 'placeholder_secret')
      .update(sign.toString())
      .digest("hex");

    if (razorpay_signature === expectedSign) {
      // Payment verified, update transaction and user portfolio atomically
      await prisma.$transaction(async (tx) => {
        const transaction = await tx.transaction.update({
          where: { referenceId: razorpay_order_id },
          data: { status: 'COMPLETED' },
        });

        const gramsField = transaction.assetType === 'GOLD' ? 'goldGrams' : 'silverGrams';
        
        await tx.portfolio.update({
          where: { userId: transaction.userId },
          data: {
            [gramsField]: { increment: transaction.grams }
          }
        });
      });

      return res.status(200).json({ message: "Payment verified successfully" });
    } else {
      return res.status(400).json({ error: "Invalid signature" });
    }
  } catch (error) {
    console.error('Verify Payment Error:', error);
    res.status(500).json({ error: "Failed to verify payment" });
  }
});

export default router;
