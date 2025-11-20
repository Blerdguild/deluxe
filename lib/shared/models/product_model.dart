import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String type;
  final double price;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String description;
  final String dispensaryId;
  final String farmerId;
  final String farmerName;
  final double weight;
  final int quantity;

  Product({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.description,
    required this.dispensaryId,
    required this.farmerId,
    required this.farmerName,
    required this.weight,
    this.quantity = 1,
  });

  factory Product.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? 'No description available.',
      dispensaryId: data['dispensaryId'] ?? '',
      farmerId: data['farmerId'] ?? '',
      farmerName: data['farmerName'] ?? '',
      weight: (data['weight'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'description': description,
      'dispensaryId': dispensaryId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'weight': weight,
      'quantity': quantity,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? type,
    double? price,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    String? description,
    String? dispensaryId,
    String? farmerId,
    String? farmerName,
    double? weight,
    int? quantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      dispensaryId: dispensaryId ?? this.dispensaryId,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      weight: weight ?? this.weight,
      quantity: quantity ?? this.quantity,
    );
  }
}
