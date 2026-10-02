import 'package:flutter/foundation.dart';
import '../models/app_user_model.dart';
import '../models/item_model.dart';
import '../models/order_model.dart';
import '../repositories/users_repository.dart';
import '../repositories/items_repository.dart';
import '../repositories/orders_repository.dart';

enum DashboardState { idle, loading, loaded, error }

/// ViewModel for the Dashboard screen.
/// Fetches all users, items and orders from Firestore concurrently.
class DashboardViewModel extends ChangeNotifier {
  final UsersRepository _usersRepo;
  final ItemsRepository _itemsRepo;
  final OrdersRepository _ordersRepo;

  DashboardViewModel({
    UsersRepository? usersRepository,
    ItemsRepository? itemsRepository,
    OrdersRepository? ordersRepository,
  })  : _usersRepo = usersRepository ?? UsersRepository(),
        _itemsRepo = itemsRepository ?? ItemsRepository(),
        _ordersRepo = ordersRepository ?? OrdersRepository();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  DashboardState _state = DashboardState.idle;
  DashboardState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<AppUserModel> _users = [];
  List<AppUserModel> get users => _users;

  List<ItemModel> _items = [];
  List<ItemModel> get items => _items;

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  // Derived counts
  int get totalUsers => _users.length;
  int get totalItems => _items.length;
  int get totalOrders => _orders.length;
  double get totalRevenue =>
      _orders.fold(0.0, (sum, o) => sum + o.totalAmount);

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Fetches all three collections concurrently.
  Future<void> loadAll() async {
    _state = DashboardState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        _usersRepo.fetchAllUsers(),
        _itemsRepo.fetchAllItems(),
        _ordersRepo.fetchAllOrders(),
      ]);

      _users = results[0] as List<AppUserModel>;
      _items = results[1] as List<ItemModel>;
      _orders = results[2] as List<OrderModel>;
      _state = DashboardState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = DashboardState.error;
    }

    notifyListeners();
  }

  /// Refreshes all data.
  Future<void> refresh() => loadAll();
}
