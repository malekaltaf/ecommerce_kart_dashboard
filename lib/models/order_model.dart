import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a document from the Firestore `orders` collection.
class OrderModel {
  final String id;
  final String userId;
  final String status;
  final double totalAmount;
  final DateTime? createdAt;
  final List<Map<String, dynamic>> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    this.createdAt,
    this.items = const [],
  });

  factory OrderModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel(
      id: doc.id,
      userId: data['userId'] as String? ??
          data['user_id'] as String? ??
          data['uid'] as String? ??
          '—',
      status: data['status'] as String? ?? 'pending',
      totalAmount:
          ((data['totalAmount'] ?? data['total'] ?? data['amount'] ?? 0)
                  as num)
              .toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          (data['created_at'] as Timestamp?)?.toDate(),
      items: List<Map<String, dynamic>>.from(
        (data['items'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map)),
      ),
    );
  }

  String get formattedAmount => '\$${totalAmount.toStringAsFixed(2)}';

  String get statusLabel => status[0].toUpperCase() + status.substring(1);
}
