import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class CloudFunctionsService {
  final FirebaseFunctions _functions;

  CloudFunctionsService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  /// Calls the 'createWallet' Cloud Function to generate a custodial wallet for the user.
  Future<String?> createWallet() async {
    try {
      final result = await _functions.httpsCallable('createWallet').call();
      final data = result.data as Map<String, dynamic>;

      if (data['success'] == true) {
        debugPrint('Wallet created/retrieved: ${data['walletAddress']}');
        return data['walletAddress'] as String;
      } else {
        throw Exception(data['message'] ?? 'Unknown error creating wallet');
      }
    } catch (e) {
      debugPrint('Error calling createWallet: $e');
      rethrow;
    }
  }

  /// Calls the 'mintBatchNFT' Cloud Function to mint tokens to a recipient.
  Future<String> mintBatchNFT({
    required String recipientAddress,
    required Map<String, dynamic> metadata,
    required int supply,
  }) async {
    try {
      final result = await _functions.httpsCallable('mintBatchNFT').call({
        'recipientAddress': recipientAddress,
        'metadata': metadata,
        'supply': supply,
      });

      final data = result.data as Map<String, dynamic>;

      if (data['success'] == true) {
        debugPrint('Mint successful. Tx Hash: ${data['transactionHash']}');
        return data['transactionHash'] as String;
      } else {
        throw Exception(data['message'] ?? 'Unknown error minting NFT');
      }
    } catch (e) {
      debugPrint('Error calling mintBatchNFT: $e');
      rethrow;
    }
  }
}
