import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a document from the Firestore `ecommerce_items` collection.
class ItemModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String? imageUrl;
  final String? description;

  ItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.description,
  });

  factory ItemModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ItemModel(
      id: doc.id,
      name: data['name'] as String? ?? data['title'] as String? ?? '—',
      category: data['category'] as String? ?? '—',
      price: ((data['price'] ?? data['amount'] ?? 0) as num).toDouble(),
      stock: (data['stock'] ?? data['quantity'] ?? 0) as int,
      imageUrl: data['imageUrl'] as String? ?? data['image'] as String?,
      description: data['description'] as String?,
    );
  }
}
