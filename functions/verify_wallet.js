const { ethers } = require('ethers');

// The private key you just provided
const privateKey = '0xfd708aa095a55f133ca26eb572dddab494f2fec6e5a3231bac8e440df70b1595';

// Create wallet from private key
const wallet = new ethers.Wallet(privateKey);

console.log('='.repeat(60));
console.log('WALLET INFO');
console.log('='.repeat(60));
console.log('Private Key:', privateKey);
console.log('Derived Address:', wallet.address);
console.log('='.repeat(60));
console.log('\nYour MetaMask Address: 0x60f600b41e6c70c99449c8e3a896567cf326a786');
console.log('Match:', wallet.address.toLowerCase() === '0x60f600b41e6c70c99449c8e3a896567cf326a786'.toLowerCase() ? '✅ YES' : '❌ NO');
console.log('='.repeat(60));
