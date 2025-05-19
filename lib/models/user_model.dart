import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String uid;
  final String name;
  final String email;
  final double walletBalance;
  final int rewardPoints;
  final String? profileImageUrl;
  final List<String> wishlist;
  final List<Map<String, dynamic>> orderHistory;
  final List<Map<String, dynamic>> transactionHistory;
  final List<Map<String, dynamic>> rewardHistory;
  final DateTime joinedAt;
  final bool isBanned; // New field for banning users

  Users({
    required this.uid,
    required this.name,
    required this.email,
    this.walletBalance = 0,
    this.rewardPoints = 0,
    this.profileImageUrl,
    this.wishlist = const [],
    this.orderHistory = const [],
    this.transactionHistory = const [],
    this.rewardHistory = const [],
    required this.joinedAt,
    this.isBanned = false, // Default to not banned
  });

  factory Users.fromFirestore(Map<String, dynamic> data, String userId) {
    return Users(
      uid: userId,
      name: data['name'],
      email: data['email'],
      walletBalance: (data['walletBalance'] as num?)?.toDouble() ?? 0.0,
      rewardPoints: (data['rewardPoints'] ?? 0).toInt(),
      profileImageUrl: data['profileImageUrl'],
      wishlist: List<String>.from(data['wishlist'] ?? []),
      orderHistory: List<Map<String, dynamic>>.from(data['orderHistory'] ?? []),
      transactionHistory: List<Map<String, dynamic>>.from(data['transactionHistory'] ?? []),
      rewardHistory: List<Map<String, dynamic>>.from(data['rewardHistory'] ?? []),
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      isBanned: data['isBanned'] ?? false,
    );
  }


  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "email": email,
      "walletBalance": walletBalance,
      "rewardPoints": rewardPoints,
      "profileImageUrl": profileImageUrl,
      "wishlist": wishlist,
      "orderHistory": orderHistory,
      "transactionHistory": transactionHistory,
      "rewardHistory": rewardHistory,
      "joinedAt": Timestamp.fromDate(joinedAt),
      "isBanned": isBanned, // Added 'isBanned' field
    };
  }
}
