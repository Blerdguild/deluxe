import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deluxe/shared/models/product_model.dart';

class OrderModel {
  final String id;
  final String consumerId;
  final String sellerId; // Farmer or Dispensary ID
  final List<Product> items;
  final double totalPrice;
  final String status; // Pending, Accepted, Shipped, Delivered, Cancelled
  final DateTime createdAt;
  final String
      dispensaryName; // For display purposes if seller is dispensary, or buyer name if seller is farmer

  OrderModel({
    required this.id,
    required this.consumerId,
    required this.sellerId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.dispensaryName,
  });

  factory OrderModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      consumerId: data['consumerId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => Product(
                    id: item['id'] ?? '',
                    name: item['name'] ?? '',
                    type: item['type'] ?? '',
                    price: (item['price'] ?? 0.0).toDouble(),
                    rating: (item['rating'] ?? 0.0).toDouble(),
                    reviewCount: item['reviewCount'] ?? 0,
                    imageUrl: item['imageUrl'] ?? '',
                    description: item['description'] ?? '',
                    dispensaryId: item['dispensaryId'] ?? '',
                    farmerId: item['farmerId'] ?? '',
                    farmerName: item['farmerName'] ?? '',
                  ))
              .toList() ??
          [],
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dispensaryName: data['dispensaryName'] ?? 'Unknown Buyer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consumerId': consumerId,
      'sellerId': sellerId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'dispensaryName': dispensaryName,
    };
  }
}
