import { Router } from 'express';
import prisma from '../utils/prisma.js';
import { authenticateToken } from '../middleware/auth.js';

const router = Router();

// Create a new SIP
router.post('/', authenticateToken, async (req: any, res) => {
  const { assetType, amount, frequency } = req.body;
  const userId = req.user.userId;

  try {
    // Calculate nextRunAt based on frequency
    const nextRunAt = new Date();
    if (frequency === 'DAILY') nextRunAt.setDate(nextRunAt.getDate() + 1);
    else if (frequency === 'WEEKLY') nextRunAt.setDate(nextRunAt.getDate() + 7);
    else if (frequency === 'MONTHLY') nextRunAt.setMonth(nextRunAt.getMonth() + 1);

    const sip = await prisma.sip.create({
      data: {
        userId,
        assetType,
        amount,
        frequency,
        nextRunAt,
      },
    });

    res.status(201).json(sip);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create SIP' });
  }
});

// Get user's SIPs
router.get('/', authenticateToken, async (req: any, res) => {
  const userId = req.user.userId;

  try {
    const sips = await prisma.sip.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
    res.json(sips);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch SIPs' });
  }
});

// Pause/Cancel SIP
router.patch('/:id', authenticateToken, async (req: any, res) => {
  const { id } = req.params;
  const { status } = req.body; // ACTIVE, PAUSED, CANCELLED
  const userId = req.user.userId;

  try {
    const sip = await prisma.sip.updateMany({
      where: { id: parseInt(id), userId },
      data: { status },
    });
    res.json({ message: 'SIP updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update SIP' });
  }
});

// Process due SIPs (Simplified simulation)
router.post('/process', async (req, res) => {
  try {
    const dueSips = await prisma.sip.findMany({
      where: {
        status: 'ACTIVE',
        nextRunAt: { lte: new Date() },
      },
    });

    for (const sip of dueSips) {
      // 1. Create a transaction
      // In a real app, this would trigger a payment or use a wallet balance
      const priceRecord = await prisma.livePrice.findFirst({
        where: { assetType: sip.assetType },
        orderBy: { updatedAt: 'desc' },
      });

      if (priceRecord) {
        const grams = sip.amount / priceRecord.price;

        await prisma.$transaction([
          prisma.transaction.create({
            data: {
              userId: sip.userId,
              type: 'BUY',
              assetType: sip.assetType,
              amount: sip.amount,
              grams,
              status: 'COMPLETED',
              referenceId: `SIP-${sip.id}-${Date.now()}`,
            },
          }),
          prisma.portfolio.update({
            where: { userId: sip.userId },
            data: {
              goldGrams: sip.assetType === 'GOLD' ? { increment: grams } : undefined,
              silverGrams: sip.assetType === 'SILVER' ? { increment: grams } : undefined,
            },
          }),
          prisma.sip.update({
            where: { id: sip.id },
            data: {
              nextRunAt: calculateNextRun(sip.frequency, sip.nextRunAt),
            },
          }),
        ]);
      }
    }

    res.json({ message: `Processed ${dueSips.length} SIPs` });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to process SIPs' });
  }
});

function calculateNextRun(frequency: string, currentRun: Date): Date {
  const next = new Date(currentRun);
  if (frequency === 'DAILY') next.setDate(next.getDate() + 1);
  else if (frequency === 'WEEKLY') next.setDate(next.getDate() + 7);
  else if (frequency === 'MONTHLY') next.setMonth(next.getMonth() + 1);
  return next;
}

export default router;
