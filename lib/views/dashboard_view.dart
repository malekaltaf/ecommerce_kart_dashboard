import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_user_model.dart';
import '../models/item_model.dart';
import '../models/order_model.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import 'login_view.dart';

/// Main dashboard shown after a successful Firebase login.
/// Displays 3 tabs: Users · Items · Orders — all fetched from Firestore.
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Trigger fetch after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Colors ─────────────────────────────────────────────────────────────────
  static const _purple = Color(0xFF6C63FF);
  static const _darkText = Color(0xFF2D2D3A);

  @override
  Widget build(BuildContext context) {
    final loginVm = context.watch<LoginViewModel>();
    final dashVm = context.watch<DashboardViewModel>();
    final user = loginVm.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _purple,
        automaticallyImplyLeading: false,
        title: const Text(
          'Ecommerce Kart Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: dashVm.state == DashboardState.loading
                ? null
                : dashVm.refresh,
          ),
          // User avatar + email
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Text(
                    _initials(user?.displayName ?? '?'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              await loginVm.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginView()),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(
              icon: const Icon(Icons.people_rounded),
              text: 'Users (${dashVm.totalUsers})',
            ),
            Tab(
              icon: const Icon(Icons.inventory_2_rounded),
              text: 'Items (${dashVm.totalItems})',
            ),
            Tab(
              icon: const Icon(Icons.receipt_long_rounded),
              text: 'Orders (${dashVm.totalOrders})',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Summary cards ───────────────────────────────────────────────────
          _SummaryBar(vm: dashVm),

          // ── Tab views ───────────────────────────────────────────────────────
          Expanded(
            child: _buildBody(dashVm),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(DashboardViewModel vm) {
    switch (vm.state) {
      case DashboardState.loading:
      case DashboardState.idle:
        return const Center(
          child: CircularProgressIndicator(color: _purple),
        );

      case DashboardState.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(vm.errorMessage,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: vm.refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );

      case DashboardState.loaded:
        return TabBarView(
          controller: _tabController,
          children: [
            _UsersTab(users: vm.users),
            _ItemsTab(items: vm.items),
            _OrdersTab(orders: vm.orders),
          ],
        );
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Summary bar — 4 stat cards
// ──────────────────────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final DashboardViewModel vm;
  const _SummaryBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _StatCard(
              label: 'Users',
              value: '${vm.totalUsers}',
              icon: Icons.people_rounded,
              color: const Color(0xFF6C63FF)),
          _StatCard(
              label: 'Items',
              value: '${vm.totalItems}',
              icon: Icons.inventory_2_rounded,
              color: const Color(0xFF48CAE4)),
          _StatCard(
              label: 'Orders',
              value: '${vm.totalOrders}',
              icon: Icons.receipt_long_rounded,
              color: const Color(0xFFFF6584)),
          _StatCard(
              label: 'Revenue',
              value: '\$${vm.totalRevenue.toStringAsFixed(0)}',
              icon: Icons.attach_money_rounded,
              color: const Color(0xFF43C59E)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D3A))),
                    Text(label,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Tab 1 — Users
// ──────────────────────────────────────────────────────────────────────────────

class _UsersTab extends StatelessWidget {
  final List<AppUserModel> users;
  const _UsersTab({required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const _EmptyState(
        icon: Icons.people_outline,
        message: 'No users found in the `users` collection.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final u = users[i];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF6C63FF).withOpacity(0.12),
              child: Text(
                _initials(u.displayName),
                style: const TextStyle(
                    color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(u.displayName,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(u.email,
                style: TextStyle(color: Colors.grey.shade600)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  u.uid.length > 10
                      ? '${u.uid.substring(0, 10)}…'
                      : u.uid,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontFamily: 'monospace'),
                ),
                if (u.createdAt != null)
                  Text(
                    _formatDate(u.createdAt!),
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';
}

// ──────────────────────────────────────────────────────────────────────────────
// Tab 2 — Items
// ──────────────────────────────────────────────────────────────────────────────

class _ItemsTab extends StatelessWidget {
  final List<ItemModel> items;
  const _ItemsTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.inventory_2_outlined,
        message: 'No items found in the `ecommerce_items` collection.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final item = items[i];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF48CAE4).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported_outlined,
                            color: Color(0xFF48CAE4)),
                      ),
                    )
                  : const Icon(Icons.inventory_2_outlined,
                      color: Color(0xFF48CAE4)),
            ),
            title: Text(item.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(item.category,
                style: TextStyle(color: Colors.grey.shade600)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF48CAE4),
                      fontSize: 15),
                ),
                Text('Stock: ${item.stock}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Tab 3 — Orders
// ──────────────────────────────────────────────────────────────────────────────

class _OrdersTab extends StatelessWidget {
  final List<OrderModel> orders;
  const _OrdersTab({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const _EmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'No orders found in the `orders` collection.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final order = orders[i];
        final statusColor = _statusColor(order.status);
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  Icon(Icons.receipt_long_rounded, color: statusColor),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'User: ${order.userId.length > 16 ? '${order.userId.substring(0, 16)}…' : order.userId}',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
                if (order.createdAt != null)
                  Text(
                    _formatDate(order.createdAt!),
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
              ],
            ),
            trailing: Text(
              order.formattedAmount,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF43C59E)),
            ),
          ),
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return const Color(0xFF43C59E);
      case 'pending':
        return const Color(0xFFFFA500);
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      case 'processing':
        return const Color(0xFF48CAE4);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}

// ──────────────────────────────────────────────────────────────────────────────
// Shared empty state widget
// ──────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
