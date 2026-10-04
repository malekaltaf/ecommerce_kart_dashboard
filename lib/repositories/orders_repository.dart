import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

/// Fetches order records from the Firestore `orders` collection.
class OrdersRepository {
  final FirebaseFirestore _db;

  OrdersRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Returns all documents from the `orders` collection, newest first.
  Future<List<OrderModel>> fetchAllOrders() async {
    final snapshot = await _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(OrderModel.fromDoc).toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status,
    });
  }
}
