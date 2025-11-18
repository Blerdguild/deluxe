import 'package:cloud_firestore/cloud_firestore.dart';

class Dispensary {
  final String id;
  final String name;
  final String location;
  final String imageUrl;

  Dispensary({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
  });

  factory Dispensary.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Dispensary(
      id: snap.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'imageUrl': imageUrl,
    };
  }
}
