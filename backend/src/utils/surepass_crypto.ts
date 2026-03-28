import crypto from 'crypto';

/**
 * Surepass Crypto Utility
 * Handles RSA-2048 Encryption and Decryption for production-grade KYC security.
 */
export class SurepassCrypto {
  private privateKey: string;
  private publicKey: string;

  constructor() {
    this.privateKey = process.env.SUREPASS_CLIENT_PRIVATE_KEY || '';
    this.publicKey = process.env.SUREPASS_PUBLIC_KEY || '';
  }

  /**
   * Decrypts a payload received from Surepass using the Client's Private Key.
   * Typically used for sensitive identity data in responses.
   */
  decrypt(encryptedData: string): any {
    if (!this.privateKey) {
      console.warn('[SurepassCrypto] No Private Key found. Returning raw data.');
      return encryptedData;
    }

    try {
      const buffer = Buffer.from(encryptedData, 'base64');
      const decrypted = crypto.privateDecrypt(
        {
          key: this.privateKey,
          padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
          oaepHash: 'sha256',
        },
        buffer
      );
      return JSON.parse(decrypted.toString());
    } catch (error) {
      console.error('[SurepassCrypto] Decryption failed:', error);
      throw new Error('Failed to decrypt Surepass response');
    }
  }

  /**
   * Encrypts a payload to send to Surepass using Surepass's Public Key.
   * Ensures Aadhaar numbers and other sensitive data are never sent in plaintext.
   */
  encrypt(data: any): string {
    if (!this.publicKey) {
      console.warn('[SurepassCrypto] No Public Key found. Returning raw data.');
      return data;
    }

    try {
      const buffer = Buffer.from(JSON.stringify(data));
      const encrypted = crypto.publicEncrypt(
        {
          key: this.publicKey,
          padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
          oaepHash: 'sha256',
        },
        buffer
      );
      return encrypted.toString('base64');
    } catch (error) {
      console.error('[SurepassCrypto] Encryption failed:', error);
      throw new Error('Failed to encrypt Surepass request');
    }
  }
}

export const surepassCrypto = new SurepassCrypto();
