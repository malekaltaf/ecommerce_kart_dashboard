import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';
import '../models/order_model.dart';
import '../repositories/items_repository.dart';
import '../repositories/orders_repository.dart';

enum DashboardState { idle, loading, loaded, error }

/// ViewModel for the Dashboard screen.
/// Fetches ecommerce_items and orders from Firestore concurrently.
class DashboardViewModel extends ChangeNotifier {
  final ItemsRepository _itemsRepo;
  final OrdersRepository _ordersRepo;

  DashboardViewModel({
    ItemsRepository? itemsRepository,
    OrdersRepository? ordersRepository,
  })  : _itemsRepo = itemsRepository ?? ItemsRepository(),
        _ordersRepo = ordersRepository ?? OrdersRepository();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  DashboardState _state = DashboardState.idle;
  DashboardState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<ItemModel> _items = [];
  List<ItemModel> get items => _items;

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  // Derived counts
  int get totalItems => _items.length;
  int get totalOrders => _orders.length;
  double get totalRevenue =>
      _orders.fold(0.0, (sum, o) => sum + o.totalAmount);

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Fetches both collections concurrently.
  Future<void> loadAll() async {
    _state = DashboardState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        _itemsRepo.fetchAllItems(),
        _ordersRepo.fetchAllOrders(),
      ]);

      _items = results[0] as List<ItemModel>;
      _orders = results[1] as List<OrderModel>;
      _state = DashboardState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = DashboardState.error;
    }

    notifyListeners();
  }

  /// Refreshes all data.
  Future<void> refresh() => loadAll();

  // ---------------------------------------------------------------------------
  // Item CRUD
  // ---------------------------------------------------------------------------

  Future<void> addItem(String name, String description, int stock, String imageUrl, double price) async {
    await _itemsRepo.addItem({
      'name': name,
      'description': description,
      'stock': stock,
      'imageUrl': imageUrl,
      'price': price,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await loadAll();
  }

  Future<void> updateItem(String id, String name, String description, int stock, String imageUrl, double price) async {
    await _itemsRepo.updateItem(id, {
      'name': name,
      'description': description,
      'stock': stock,
      'imageUrl': imageUrl,
      'price': price,
    });
    await loadAll();
  }

  Future<void> deleteItem(String id) async {
    await _itemsRepo.deleteItem(id);
    await loadAll();
  }

  // ---------------------------------------------------------------------------
  // Order CRUD
  // ---------------------------------------------------------------------------

  Future<void> updateOrderStatus(String id, String status) async {
    await _ordersRepo.updateOrderStatus(id, status);
    await loadAll();
  }
}

