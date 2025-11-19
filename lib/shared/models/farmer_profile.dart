import 'package:cloud_firestore/cloud_firestore.dart';

/// Extended model for farmer-specific profile data
class FarmerProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String role;

  // Farmer-specific fields
  final String? farmName;
  final String? phoneNumber;
  final String? location;
  final String? bio;
  final String? farmType;
  final double? farmSize;
  final int? yearsInBusiness;
  final List<String>? certifications;
  final String? walletAddress;

  // Business Information
  final String? businessLicense;
  final String? taxId;

  // Preferences
  final bool notificationsEnabled;
  final bool autoAcceptOrders;

  const FarmerProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.role,
    this.farmName,
    this.phoneNumber,
    this.location,
    this.bio,
    this.farmType,
    this.farmSize,
    this.yearsInBusiness,
    this.certifications,
    this.walletAddress,
    this.businessLicense,
    this.taxId,
    this.notificationsEnabled = true,
    this.autoAcceptOrders = false,
  });

  factory FarmerProfile.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return FarmerProfile(
      uid: doc.id,
      email: data?['email'] as String? ?? '',
      displayName: data?['displayName'] as String?,
      photoURL: data?['photoURL'] as String?,
      role: data?['role'] as String? ?? 'farmer',
      farmName: data?['farmName'] as String?,
      phoneNumber: data?['phoneNumber'] as String?,
      location: data?['location'] as String?,
      bio: data?['bio'] as String?,
      farmType: data?['farmType'] as String?,
      farmSize: (data?['farmSize'] as num?)?.toDouble(),
      yearsInBusiness: data?['yearsInBusiness'] as int?,
      certifications: (data?['certifications'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      walletAddress: data?['walletAddress'] as String?,
      businessLicense: data?['businessLicense'] as String?,
      taxId: data?['taxId'] as String?,
      notificationsEnabled: data?['notificationsEnabled'] as bool? ?? true,
      autoAcceptOrders: data?['autoAcceptOrders'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role,
      'farmName': farmName,
      'phoneNumber': phoneNumber,
      'location': location,
      'bio': bio,
      'farmType': farmType,
      'farmSize': farmSize,
      'yearsInBusiness': yearsInBusiness,
      'certifications': certifications,
      'walletAddress': walletAddress,
      'businessLicense': businessLicense,
      'taxId': taxId,
      'notificationsEnabled': notificationsEnabled,
      'autoAcceptOrders': autoAcceptOrders,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  FarmerProfile copyWith({
    String? displayName,
    String? photoURL,
    String? farmName,
    String? phoneNumber,
    String? location,
    String? bio,
    String? farmType,
    double? farmSize,
    int? yearsInBusiness,
    List<String>? certifications,
    String? walletAddress,
    String? businessLicense,
    String? taxId,
    bool? notificationsEnabled,
    bool? autoAcceptOrders,
  }) {
    return FarmerProfile(
      uid: uid,
      email: email,
      role: role,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      farmName: farmName ?? this.farmName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      farmType: farmType ?? this.farmType,
      farmSize: farmSize ?? this.farmSize,
      yearsInBusiness: yearsInBusiness ?? this.yearsInBusiness,
      certifications: certifications ?? this.certifications,
      walletAddress: walletAddress ?? this.walletAddress,
      businessLicense: businessLicense ?? this.businessLicense,
      taxId: taxId ?? this.taxId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoAcceptOrders: autoAcceptOrders ?? this.autoAcceptOrders,
    );
  }
}
