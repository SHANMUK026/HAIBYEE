import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const normalizePhone = (phone: string) => {
  const clean = phone.replace(/\D/g, '');
  return clean.length >= 10 ? clean.slice(-10) : clean;
};

async function main() {
  console.log('🚀 Starting Phone Number Normalization Migration...');

  // 1. Migrate Users
  const users = await prisma.user.findMany();
  console.log(`Found ${users.length} users in the database.`);

  for (const user of users) {
    const normalizedPhone = normalizePhone(user.phone);
    const normalizedReferredBy = user.referredBy ? normalizePhone(user.referredBy) : null;

    if (normalizedPhone !== user.phone || normalizedReferredBy !== user.referredBy) {
      try {
        await prisma.user.update({
          where: { id: user.id },
          data: {
            phone: normalizedPhone,
            referredBy: normalizedReferredBy,
          },
        });
        console.log(`✅ Updated User ${user.id}: ${user.phone} -> ${normalizedPhone}`);
      } catch (error) {
        console.error(`❌ Failed to update User ${user.id} (${user.phone}):`, error);
      }
    } else {
      console.log(`ℹ️ User ${user.id} (${user.phone}) already normalized.`);
    }
  }

  // 2. Migrate OTPs
  const otps = await prisma.otp.findMany();
  console.log(`Found ${otps.length} OTP records.`);

  for (const otp of otps) {
    const normalizedPhone = normalizePhone(otp.phone);
    if (normalizedPhone !== otp.phone) {
      try {
        await prisma.otp.update({
          where: { id: otp.id },
          data: { phone: normalizedPhone },
        });
        console.log(`✅ Updated OTP ${otp.id}: ${otp.phone} -> ${normalizedPhone}`);
      } catch (error) {
        console.error(`❌ Failed to update OTP ${otp.id} (${otp.phone}):`, error);
      }
    }
  }

  console.log('🏁 Migration finished.');
}

main()
  .catch((e) => {
    console.error('Fatal Error during migration:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
