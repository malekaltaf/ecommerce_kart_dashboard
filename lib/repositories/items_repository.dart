import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

/// Fetches product records from the Firestore `products` collection.
class ItemsRepository {
  final FirebaseFirestore _db;

  ItemsRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final String _collection = 'products';

  /// Returns all documents from the `products` collection.
  Future<List<ItemModel>> fetchAllItems() async {
    final snapshot = await _db.collection(_collection).get();
    return snapshot.docs.map(ItemModel.fromDoc).toList();
  }

  Future<void> addItem(Map<String, dynamic> data) async {
    await _db.collection(_collection).add(data);
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    await _db.collection(_collection).doc(id).update(data);
  }

  Future<void> deleteItem(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
