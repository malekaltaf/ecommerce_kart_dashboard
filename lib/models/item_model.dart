import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a document from the Firestore `ecommerce_items` collection.
/// Field names match your Firestore schema: product_name, product_price, product_description.
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
      // Firestore fields: product_name, fallback to name/title
      name: data['product_name'] as String? ??
          data['name'] as String? ??
          data['title'] as String? ??
          '—',
      // Firestore fields: product_category, fallback to category
      category: data['product_category'] as String? ??
          data['category'] as String? ??
          '—',
      // Firestore fields: product_price, fallback to price/amount
      price: ((data['product_price'] ??
                  data['price'] ??
                  data['amount'] ??
                  0) as num)
          .toDouble(),
      // Firestore fields: product_stock, fallback to stock/quantity
      stock: (data['product_stock'] ??
              data['stock'] ??
              data['quantity'] ??
              0) as int,
      // Firestore fields: product_image / imageUrl / image
      imageUrl: data['product_image'] as String? ??
          data['imageUrl'] as String? ??
          data['image'] as String?,
      // Firestore fields: product_description / description
      description: data['product_description'] as String? ??
          data['description'] as String?,
    );
  }
}
