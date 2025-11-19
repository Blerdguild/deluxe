import 'package:cloud_firestore/cloud_firestore.dart';

class DispensaryProfile {
  final String uid;
  final String dispensaryName;
  final String ownerName;
  final String email;
  final String phoneNumber;
  final String address;
  final String? businessLicense;
  final String? taxId;
  final String? logoURL;
  final String? walletAddress;
  final Map<String, String> operatingHours;
  final bool deliveryAvailable;
  final bool pickupAvailable;
  final List<String> certifications;
  final bool notificationsEnabled;
  final bool autoAcceptOrders;
  final DateTime createdAt;
  final DateTime updatedAt;

  DispensaryProfile({
    required this.uid,
    required this.dispensaryName,
    required this.ownerName,
    required this.email,
    this.phoneNumber = '',
    this.address = '',
    this.businessLicense,
    this.taxId,
    this.logoURL,
    this.walletAddress,
    this.operatingHours = const {},
    this.deliveryAvailable = false,
    this.pickupAvailable = true,
    this.certifications = const [],
    this.notificationsEnabled = true,
    this.autoAcceptOrders = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DispensaryProfile.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DispensaryProfile(
      uid: doc.id,
      dispensaryName: data['dispensaryName'] ?? '',
      ownerName: data['ownerName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      businessLicense: data['businessLicense'],
      taxId: data['taxId'],
      logoURL: data['logoURL'],
      walletAddress: data['walletAddress'],
      operatingHours: Map<String, String>.from(data['operatingHours'] ?? {}),
      deliveryAvailable: data['deliveryAvailable'] ?? false,
      pickupAvailable: data['pickupAvailable'] ?? true,
      certifications: List<String>.from(data['certifications'] ?? []),
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      autoAcceptOrders: data['autoAcceptOrders'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dispensaryName': dispensaryName,
      'ownerName': ownerName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'businessLicense': businessLicense,
      'taxId': taxId,
      'logoURL': logoURL,
      'walletAddress': walletAddress,
      'operatingHours': operatingHours,
      'deliveryAvailable': deliveryAvailable,
      'pickupAvailable': pickupAvailable,
      'certifications': certifications,
      'notificationsEnabled': notificationsEnabled,
      'autoAcceptOrders': autoAcceptOrders,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  DispensaryProfile copyWith({
    String? dispensaryName,
    String? ownerName,
    String? email,
    String? phoneNumber,
    String? address,
    String? businessLicense,
    String? taxId,
    String? logoURL,
    String? walletAddress,
    Map<String, String>? operatingHours,
    bool? deliveryAvailable,
    bool? pickupAvailable,
    List<String>? certifications,
    bool? notificationsEnabled,
    bool? autoAcceptOrders,
  }) {
    return DispensaryProfile(
      uid: uid,
      dispensaryName: dispensaryName ?? this.dispensaryName,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      businessLicense: businessLicense ?? this.businessLicense,
      taxId: taxId ?? this.taxId,
      logoURL: logoURL ?? this.logoURL,
      walletAddress: walletAddress ?? this.walletAddress,
      operatingHours: operatingHours ?? this.operatingHours,
      deliveryAvailable: deliveryAvailable ?? this.deliveryAvailable,
      pickupAvailable: pickupAvailable ?? this.pickupAvailable,
      certifications: certifications ?? this.certifications,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoAcceptOrders: autoAcceptOrders ?? this.autoAcceptOrders,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
