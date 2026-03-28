import { Router } from 'express';
import prisma from '../utils/prisma.js';
import { surepassClient } from '../utils/surepass_client.js';

const router = Router();

router.post('/aadhaar-otp', async (req, res) => {
  try {
    const { id_number } = req.body;
    if (!id_number || id_number.length !== 12) {
      return res.status(400).json({ error: 'Valid 12-digit Aadhaar number required' });
    }

    const response = await surepassClient.post('/aadhaar/otp', { id_number });
    res.status(200).json(response.data);
  } catch (error) {
    console.error('Surepass OTP Error:', error);
    res.status(500).json({ error: 'Failed to generate Aadhaar OTP' });
  }
});

router.post('/aadhaar-verify', async (req, res) => {
  try {
    const { client_id, otp, userId } = req.body;
    if (!client_id || !otp || !userId) {
      return res.status(400).json({ error: 'Missing client_id, otp, or userId' });
    }

    const result = await surepassClient.verifyAadhaarOtp(client_id, otp);

    if (result.success) {
      // Update User KYC status atomically
      await prisma.user.update({
        where: { id: parseInt(userId) },
        data: { kycStatus: 'Verified' }
      });

      // Create a final KYC record
      await prisma.kycRecord.create({
        data: {
          userId: parseInt(userId),
          idType: 'AADHAAR',
          idNumber: 'XXXXXXXX' + result.data.aadhaar_number.slice(-4),
          status: 'COMPLETED',
          result: result as any,
        },
      });
    }

    res.status(200).json(result);
  } catch (error) {
    console.error('Surepass Verify Error:', error);
    res.status(500).json({ error: 'Failed to verify Aadhaar OTP' });
  }
});

router.post('/digilocker-init', async (req, res) => {
  try {
    console.log('[KYC] DigiLocker Init Hit');
    
    // SDK Docs specify nested data object for initialization
    const body = {
      data: {
        signup_flow: true,
        skip_main_screen: false
      }
    };

    const response = await surepassClient.post('/digilocker/initialize', body);
    res.status(200).json(response.data);
  } catch (error: any) {
    console.error('DigiLocker Init Error:', error.response?.data || error.message);
    res.status(500).json({ 
      error: 'Failed to initialize DigiLocker',
      details: error.response?.data || error.message 
    });
  }
});

// Download Aadhaar XML and sync profile after successful SDK verification
router.get('/digilocker-verify/:clientId', async (req, res) => {
  try {
    const { clientId } = req.params;
    console.log('[KYC] Finalizing DigiLocker for:', clientId);

    const response = await surepassClient.get(`/digilocker/download-aadhaar/${clientId}`);
    const idData = response.data.data.aadhaar_xml_data;

    // TODO: Update user in database with idData.full_name, idData.dob, etc.
    // For now, return the data to the frontend
    res.status(200).json({
      success: true,
      data: idData
    });
  } catch (error: any) {
    console.error('DigiLocker Verify Error:', error.response?.data || error.message);
    res.status(500).json({ error: 'Failed to finalize verification' });
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
