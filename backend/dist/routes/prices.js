import { Router } from 'express';
import axios from 'axios';
import prisma from '../utils/prisma.js';
const router = Router();
const getPrice = async (symbol) => {
    const url = `https://www.goldapi.io/api/${symbol}/INR`;
    try {
        const response = await axios.get(url, {
            headers: {
                'x-access-token': process.env.PRICE_API_KEY,
                'Content-Type': 'application/json'
            }
        });
        // GoldAPI returns price per ounce by default, so we divide by 31.1035 for price per gram
        // Actually, GoldAPI has a "price_gram_24k" field for gold and similar for others
        return response.data.price_gram_24k || (response.data.price / 31.1035);
    }
    catch (error) {
        console.error(`Error fetching ${symbol} price:`, error);
        return null;
    }
};
router.get('/live', async (req, res) => {
    try {
        const goldPrice = await getPrice('XAU');
        const silverPrice = await getPrice('XAG');
        if (!goldPrice || !silverPrice) {
            // Fallback to DB if API fails
            const lastGold = await prisma.livePrice.findFirst({ where: { assetType: 'GOLD' } });
            const lastSilver = await prisma.livePrice.findFirst({ where: { assetType: 'SILVER' } });
            return res.status(200).json({
                gold: { price: lastGold?.price || 7200, unit: 'gram', currency: 'INR' },
                silver: { price: lastSilver?.price || 92, unit: 'gram', currency: 'INR' },
                timestamp: new Date().toISOString(),
                isMock: !goldPrice || !silverPrice
            });
        }
        // Update in DB for caching
        await prisma.livePrice.upsert({
            where: { id: 1 },
            update: { price: goldPrice },
            create: { id: 1, assetType: 'GOLD', price: goldPrice },
        });
        await prisma.livePrice.upsert({
            where: { id: 2 },
            update: { price: silverPrice },
            create: { id: 2, assetType: 'SILVER', price: silverPrice },
        });
        res.status(200).json({
            gold: { price: goldPrice, unit: 'gram', currency: 'INR' },
            silver: { price: silverPrice, unit: 'gram', currency: 'INR' },
            timestamp: new Date().toISOString()
        });
    }
    catch (error) {
        console.error('Fetch Prices Error:', error);
        res.status(500).json({ error: 'Failed to fetch live prices' });
    }
});
export default router;
