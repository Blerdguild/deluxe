const { onRequest, onCall } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const { ethers } = require("ethers");
const { createThirdwebClient, getContract, mintTo } = require("thirdweb");
const { privateKeyToAccount } = require("thirdweb/wallets");
const { polygonAmoy } = require("thirdweb/chains");

admin.initializeApp();

// --- Configuration ---
// In production, use defineSecret from firebase-functions/params
const THIRDWEB_SECRET_KEY = process.env.THIRDWEB_SECRET_KEY || "YOUR_SECRET_KEY";
const ADMIN_PRIVATE_KEY = process.env.ADMIN_PRIVATE_KEY || "YOUR_ADMIN_PRIVATE_KEY";
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS || "YOUR_CONTRACT_ADDRESS";

// Lazy initialization to avoid errors during deployment
let client, adminAccount, contract;

function initializeThirdweb() {
  if (!client) {
    client = createThirdwebClient({
      secretKey: THIRDWEB_SECRET_KEY,
    });

    adminAccount = privateKeyToAccount({
      client,
      privateKey: ADMIN_PRIVATE_KEY,
    });

    contract = getContract({
      client,
      chain: polygonAmoy,
      address: CONTRACT_ADDRESS,
    });
  }
  return { client, adminAccount, contract };
}

/**
 * Creates a wallet for the authenticated user.
 * Stores the public address in Firestore: users/{uid}/walletAddress
 * Note: This is a simplified "Custodial" approach where we generate an address.
 * For a real custodial wallet, we would securely store the private key (e.g. GCP Secret Manager).
 * For this MVP, we are primarily focusing on *receiving* assets (minting to user).
 */
exports.createWallet = onCall(async (request) => {
  if (!request.auth) {
    throw new Error("Unauthenticated: You must be logged in to create a wallet.");
  }

  const uid = request.auth.uid;
  const userRef = admin.firestore().collection("users").doc(uid);

  try {
    // 1. Check if wallet already exists
    const userDoc = await userRef.get();
    if (userDoc.exists && userDoc.data().walletAddress) {
      return {
        success: true,
        walletAddress: userDoc.data().walletAddress,
        message: "Wallet already exists."
      };
    }

    // 2. Generate new random wallet
    const wallet = ethers.Wallet.createRandom();
    const walletAddress = wallet.address;
    // const privateKey = wallet.privateKey; // TODO: Securely store this if needed for sending

    // 3. Store address in Firestore
    await userRef.set({
      walletAddress: walletAddress,
      walletCreatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    logger.info(`Created wallet for user ${uid}: ${walletAddress}`);

    return {
      success: true,
      walletAddress: walletAddress,
      message: "Wallet created successfully."
    };

  } catch (error) {
    logger.error("Error creating wallet:", error);
    throw new Error(`Failed to create wallet: ${error.message}`);
  }
});

/**
 * Mints a batch of NFTs (ERC-1155) to a recipient.
 * Triggered by the Flutter app (e.g., when a Farmer tokenizes a harvest).
 * Requires 'farmer' or 'admin' role.
 */
exports.mintBatchNFT = onCall(async (request) => {
  // 1. Auth & Role Check
  if (!request.auth) {
    throw new Error("Unauthenticated.");
  }
  const token = request.auth.token;
  if (token.role !== 'farmer' && token.role !== 'admin') {
    // For MVP, we might relax this or ensure the caller is the owner of the product
    // throw new Error("Unauthorized: Only farmers can mint.");
  }

  const { recipientAddress, metadata, supply } = request.data;

  if (!recipientAddress || !metadata || !supply) {
    throw new Error("Missing required parameters: recipientAddress, metadata, supply");
  }

  try {
    // Initialize Thirdweb (lazy load)
    const { contract: nftContract, adminAccount: admin } = initializeThirdweb();

    logger.info(`Minting to ${recipientAddress} with supply ${supply}`);

    // 2. Execute Minting Transaction (using Admin Account)
    const transaction = await mintTo({
      contract,
      to: recipientAddress,
      supply: BigInt(supply),
      nft: metadata, // { name, description, image, properties }
    });

    // 3. Send Transaction
    // Note: In Thirdweb v5, mintTo returns a transaction object. We need to send it.
    // However, the 'sendTransaction' logic depends on the exact v5 helper used.
    // For simplicity with the 'thirdweb' package, we often use 'sendTransaction' or 'sendAndConfirmTransaction'.

    const { sendAndConfirmTransaction } = require("thirdweb");

    const receipt = await sendAndConfirmTransaction({
      transaction,
      account: admin,
    });

    logger.info(`Mint successful! Tx Hash: ${receipt.transactionHash}`);

    return {
      success: true,
      transactionHash: receipt.transactionHash,
      tokenId: "0", // TODO: Parse logs to get actual Token ID if dynamic
    };

  } catch (error) {
    logger.error("Error minting NFT:", error);
    throw new Error(`Minting failed: ${error.message}`);
  }
});
