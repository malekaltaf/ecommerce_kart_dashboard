import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

/// Fetches product records from the Firestore `ecommerce_items` collection.
class ItemsRepository {
  final FirebaseFirestore _db;

  ItemsRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Returns all documents from the `ecommerce_items` collection.
  Future<List<ItemModel>> fetchAllItems() async {
    final snapshot = await _db.collection('ecommerce_items').get();
    return snapshot.docs.map(ItemModel.fromDoc).toList();
  }
}
