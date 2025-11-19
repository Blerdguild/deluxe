const { ethers } = require('ethers');

// Your admin private key from .env
const ADMIN_PRIVATE_KEY = '0xfd708aa095a55f133ca26eb572dddab494f2fec6e5a3231bac8e440df70b1595';

// Create wallet from private key
const wallet = new ethers.Wallet(ADMIN_PRIVATE_KEY);

console.log('='.repeat(60));
console.log('ADMIN WALLET ADDRESS');
console.log('='.repeat(60));
console.log('Address:', wallet.address);
console.log('='.repeat(60));
console.log('\nTo fund this wallet with test MATIC:');
console.log('1. Go to: https://faucet.polygon.technology/');
console.log('2. Select "Polygon Amoy" network');
console.log('3. Paste the address above');
console.log('4. Click "Submit"');
console.log('='.repeat(60));
