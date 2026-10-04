import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

/// Fetches order records from the Firestore `orders` collection.
class OrdersRepository {
  final FirebaseFirestore _db;

  OrdersRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Returns all documents from the `orders` collection, newest first.
  Future<List<OrderModel>> fetchAllOrders() async {
    final snapshot = await _db.collection('orders').get();
    final list = snapshot.docs.map(OrderModel.fromDoc).toList();
    list.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
    return list;
  }

  /// Returns orders for a specific user.
  Future<List<OrderModel>> fetchUserOrders(String userId) async {
    final snapshot = await _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();
    final list = snapshot.docs.map(OrderModel.fromDoc).toList();
    list.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
    return list;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status,
    });
  }
}
