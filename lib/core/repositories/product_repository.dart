import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deluxe/shared/models/product_model.dart';

abstract class ProductRepository {
  Future<void> createProduct(Product product);
  Stream<List<Product>> getProducts();
  Stream<List<Product>> getProductsByFarmer(String farmerId);
  Future<void> updateProduct(Product product);
}

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .set(product.toJson());
  }

  @override
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromSnapshot(doc)).toList();
    });
  }

  @override
  Stream<List<Product>> getProductsByFarmer(String farmerId) {
    return _firestore
        .collection('products')
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromSnapshot(doc)).toList();
    });
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toJson());
  }
}
