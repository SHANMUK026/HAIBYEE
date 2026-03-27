import { Router } from 'express';
import prisma from '../utils/prisma.js';
import { authenticateToken } from '../middleware/auth.js';
const router = Router();
// Get current user profile
router.get('/me', authenticateToken, async (req, res) => {
    const userId = req.user.userId;
    try {
        const user = await prisma.user.findUnique({
            where: { id: userId },
            include: {
                portfolio: true,
                sips: {
                    where: { status: 'ACTIVE' }
                }
            }
        });
        if (!user)
            return res.status(404).json({ error: 'User not found' });
        res.json(user);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch profile' });
    }
});
// Update user profile
router.patch('/update', authenticateToken, async (req, res) => {
    const userId = req.user.userId;
    const { name, email } = req.body;
    try {
        const user = await prisma.user.update({
            where: { id: userId },
            data: { name, email },
        });
        res.json(user);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to update profile' });
    }
});
// Get user transactions
router.get('/transactions', authenticateToken, async (req, res) => {
    const userId = req.user.userId;
    try {
        const transactions = await prisma.transaction.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
        });
        res.json(transactions);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch transactions' });
    }
});
// Process withdrawal
router.post('/withdraw', authenticateToken, async (req, res) => {
    const userId = req.user.userId;
    const { grams, assetType, bankDetails } = req.body;
    try {
        const portfolio = await prisma.portfolio.findUnique({
            where: { userId },
        });
        if (!portfolio)
            return res.status(404).json({ error: 'Portfolio not found' });
        const balance = assetType === 'GOLD' ? portfolio.goldGrams : portfolio.silverGrams;
        if (balance < grams)
            return res.status(400).json({ error: 'Insufficient balance' });
        // Get current price to calculate value
        const priceRecord = await prisma.livePrice.findFirst({
            where: { assetType },
            orderBy: { updatedAt: 'desc' },
        });
        if (!priceRecord)
            return res.status(500).json({ error: 'Price data unavailable' });
        const amountInr = grams * priceRecord.price;
        const transaction = await prisma.transaction.create({
            data: {
                userId,
                type: 'SELL',
                assetType,
                amount: amountInr,
                grams,
                status: 'PENDING',
                referenceId: `WITHDRAW-${Date.now()}`,
            },
        });
        // Option: Deduct immediately or wait for approval. Let's deduct immediately for this demo.
        await prisma.portfolio.update({
            where: { userId },
            data: {
                goldGrams: assetType === 'GOLD' ? { decrement: grams } : undefined,
                silverGrams: assetType === 'SILVER' ? { decrement: grams } : undefined,
            },
        });
        res.json({ message: 'Withdrawal initiated', transaction });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to initiate withdrawal' });
    }
});
export default router;
