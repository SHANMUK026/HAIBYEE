import { Router } from 'express';
import prisma from '../utils/prisma.js';
import axios from 'axios';

const router = Router();

// Mock Surepass KYC initiation - will be replaced with real API
const initiateSurepassKYC = async (userId: number, idType: string, idNumber: string) => {
  // In a real implementation:
  /*
  const response = await axios.post('https://api.surepass.io/api/v1/corporate/digilocker/initiate', {
    id_type: idType,
    id_number: idNumber,
  }, {
    headers: { 'Authorization': `Bearer ${process.env.SUREPASS_API_KEY}` }
  });
  return response.data;
  */
  return { 
    id: `kyc_${Date.now()}`, 
    status: 'IN_PROGRESS', 
    url: 'https://surepass.io/mock-verification-url' 
  };
};

router.post('/start', async (req, res) => {
  try {
    const { userId, idType, idNumber } = req.body;
    if (!userId || !idType || !idNumber) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const kycResponse = await initiateSurepassKYC(userId, idType, idNumber);

    // Create a KYC record
    await prisma.kycRecord.create({
      data: {
        userId: parseInt(userId),
        idType,
        idNumber,
        status: 'IN_PROGRESS',
        result: kycResponse as any,
      },
    });

    res.status(200).json(kycResponse);
  } catch (error) {
    console.error('Start KYC Error:', error);
    res.status(500).json({ error: 'Failed to initiate KYC' });
  }
});

router.get('/status/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const kyc = await prisma.kycRecord.findFirst({
      where: { userId: parseInt(userId) },
      orderBy: { createdAt: 'desc' },
    });

    if (!kyc) return res.status(404).json({ error: 'No KYC record found' });

    res.status(200).json(kyc);
  } catch (error) {
    console.error('Check KYC Error:', error);
    res.status(500).json({ error: 'Failed to check KYC status' });
  }
});

export default router;
