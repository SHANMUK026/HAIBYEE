# 🏦 Silvra Backend Flow Audit (A-Z Logic)

This document provides a comprehensive scenario-by-scenario audit of the Silvra application backend logic, ensuring production-grade stability and security for a "Real Fintech" experience.

---

## 1. Authentication & Identity (`auth.ts`)

### **Scenario A: User Registration**
1. **OTP Request**: User submits 10-digit phone. Backend sends a real SMS via MSG91 (prepending +91).
2. **Verification**: 
    - The phone number is **normalized** to exactly 10 digits in the database.
    - Password is hashed using **bcrypt**.
    - An atomic **Portfolio** is created for the user (0.00g Gold/Silver).
    - **Referral Normalization**: If the user is referred, the `referredBy` code is also cleaned to 10 digits to ensure tracking works regardless of input format.

### **Scenario B: Password Login**
1. User provides Phone + Password.
2. Backend normalizes phone and compares the bcrypt hash.
3. A secure **JWT Token** (7-day expiry) is returned for persistent sessions.

### **Scenario C: Account Upgrade (Login with OTP)**
1. **Problem**: User previously registered via OTP but never set a password.
2. **Fintech Logic**: When the user performs a "Login with OTP" and provides a password in the UI, the `verify-otp` route checks if the user's password field is empty.
3. **Upgrade**: If empty, it securely hashes and saves the new password. The user is now "Upgraded" to a full account.

---

## 2. Real-Time Market Data (`prices.ts`)

### **Scenario D: Live Price Syncing**
1. **API Integration**: Connects to `goldapi.io` using your real API key.
2. **Data Transformation**: Converts Ounce-based global rates into **Gram-based INR prices**.
3. **Redundancy/Persistence**:
    - Every successful fetch **upserts** (updates or inserts) the price into the `LivePrice` table.
    - If the GoldAPI is down or the key expires, the backend automatically falls back to the last recorded successful price, ensuring the app never shows a '0' price.

---

## 3. Payments & Asset Acquisition (`payments.ts`)

### **Scenario E: Buying Gold/Silver**
1. **Order Creation**: Backend initiates a Razorpay Order and records a **PENDING** transaction.
2. **Signature Verification**: Uses `crypto.createHmac` with your `RAZORPAY_KEY_SECRET` to verify the payment's authenticity.
3. **Atomic Execution (Fintech Grade)**:
    - We use a **Prisma $transaction**.
    - **Step 1**: Mark transaction as `COMPLETED`.
    - **Step 2**: Increment the user's `Portfolio` grams.
    - If either step fails, **both are rolled back**. User money is never "lost" without a corresponding asset update.

---

## 4. Rewards Hub & Gamification (`profile.ts`)

### **Scenario F: Daily Spin & Win**
1. **Atomic Points Update**: When the user spins, the backend increments `auraPoints` in the `User` table to prevent "double-spending" or race conditions.
2. **Synchronized Outcome**: The backend returns the `wonPoints` to the frontend, which uses a calibrated rotation formula to land the wheel on exactly the right segment.

---

## 5. Security & Session Management

- **Data Privacy**: Passwords and sensitive identifiers are never returned in search results or plain logging.
- **Normalization**: Every database lookup (Referrals, Login, Profile) uses the **Global 10-Digit Standard**, preventing duplicate accounts and lookup failures.
- **Clean Logout**: Frontend `ApiService` and `AppState` are wiped clean on logout to prevent state leakage between sessions.

---
> [!IMPORTANT]
> This logic is now structurally ready for deployment. The next step is simply to substitute the placeholder constants in `auth.ts` and `payments.ts` with your finalized production secrets.
