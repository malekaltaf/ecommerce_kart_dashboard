import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../models/order_model.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import 'login_view.dart';

/// Main dashboard shown after a successful Firebase login.
/// Displays 2 tabs: Items · Orders — fetched from Firestore.
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
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index == 0 || _tabController.index == 1) {
        setState(() {}); // Rebuild for FAB visibility
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<LoginViewModel>().user;
      if (user != null) {
        context.read<DashboardViewModel>().initialize(user);
      } else {
        context.read<DashboardViewModel>().loadAll();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginVm = context.watch<LoginViewModel>();
    final dashVm = context.watch<DashboardViewModel>();
    final user = loginVm.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
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
          // Logged-in user
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
          _SummaryBar(vm: dashVm),
          Expanded(child: _buildBody(dashVm)),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () => _showItemForm(context, dashVm),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(DashboardViewModel vm) {
    switch (vm.state) {
      case DashboardState.loading:
      case DashboardState.idle:
        return Center(
          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
        );

      case DashboardState.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(vm.errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red)),
              ),
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
            _ItemsTab(
              items: vm.items,
              onEdit: (item) => _showItemForm(context, vm, item),
              onDelete: (id) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Item'),
                    content: const Text('Are you sure you want to delete this item?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          vm.deleteItem(id);
                          Navigator.pop(ctx);
                        }, 
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
            _OrdersTab(
              orders: vm.orders,
              onUpdateStatus: vm.updateOrderStatus,
            ),
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

  void _showItemForm(BuildContext context, DashboardViewModel vm, [ItemModel? item]) {
    final isEdit = item != null;
    final nameCtrl = TextEditingController(text: item?.name);
    final descCtrl = TextEditingController(text: item?.description);
    final qtyCtrl = TextEditingController(text: item?.stock.toString());
    final priceCtrl = TextEditingController(text: item?.price.toString());
    final imageCtrl = TextEditingController(text: item?.imageUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isEdit ? 'Edit Item' : 'Add New Item', 
                         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name'), enabled: !isSaving),
                    const SizedBox(height: 12),
                    TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3, enabled: !isSaving),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number, enabled: !isSaving)),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price'), keyboardType: const TextInputType.numberWithOptions(decimal: true), enabled: !isSaving)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'Image URL'), enabled: !isSaving),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(ctx).colorScheme.primary, 
                          foregroundColor: Theme.of(ctx).colorScheme.onPrimary,
                        ),
                        onPressed: isSaving ? null : () async {
                          final name = nameCtrl.text.trim();
                          final desc = descCtrl.text.trim();
                          final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
                          final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                          final imageUrl = imageCtrl.text.trim();
    
                          if (name.isEmpty) return;
    
                          setState(() => isSaving = true);
                          
                          try {
                            if (isEdit) {
                              await vm.updateItem(item.id, name, desc, qty, imageUrl, price);
                            } else {
                              await vm.addItem(name, desc, qty, imageUrl, price);
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                          } catch (e) {
                            // If an error happens (like permission denied), stop loading
                            if (ctx.mounted) {
                              setState(() => isSaving = false);
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text('Error saving: $e')),
                              );
                            }
                          }
                        },
                        child: isSaving 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(isEdit ? 'Save Changes' : 'Add Item'),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Summary bar — 3 stat cards (Items · Orders · Revenue)
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
            label: 'Total Items',
            value: '${vm.totalItems}',
            icon: Icons.inventory_2_rounded,
            color: const Color(0xFF48CAE4),
          ),
          _StatCard(
            label: 'Total Orders',
            value: '${vm.totalOrders}',
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFFFF6584),
          ),
          _StatCard(
            label: 'Revenue',
            value: '\$${vm.totalRevenue.toStringAsFixed(0)}',
            icon: Icons.attach_money_rounded,
            color: const Color(0xFF43C59E),
          ),
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

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: const TextStyle(
                            fontSize: 20,
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
// Tab 1 — Items
// ──────────────────────────────────────────────────────────────────────────────

class _ItemsTab extends StatelessWidget {
  final List<ItemModel> items;
  final void Function(ItemModel) onEdit;
  final void Function(String) onDelete;

  const _ItemsTab({
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.inventory_2_outlined,
        message: 'No items found in the `products` collection.',
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
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF48CAE4).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.category != '—')
                  Text(item.category,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12)),
                if (item.description != null && item.description!.isNotEmpty)
                  Text(
                    item.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 11),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF48CAE4),
                          fontSize: 16),
                    ),
                    if (item.stock > 0)
                      Text('Qty: ${item.stock}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => onEdit(item),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(item.id),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Tab 2 — Orders
// ──────────────────────────────────────────────────────────────────────────────

class _OrdersTab extends StatelessWidget {
  final List<OrderModel> orders;
  final void Function(String id, String status) onUpdateStatus;

  const _OrdersTab({
    required this.orders,
    required this.onUpdateStatus,
  });

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
          child: Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.receipt_long_rounded, color: statusColor),
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
              if (order.status.toLowerCase() == 'pending') ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => onUpdateStatus(order.id, 'rejected'),
                        child: const Text('Reject', style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        onPressed: () => onUpdateStatus(order.id, 'approved'),
                        child: const Text('Approve'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
      case 'approved':
        return const Color(0xFF43C59E);
      case 'pending':
        return const Color(0xFFFFA500);
      case 'cancelled':
      case 'canceled':
      case 'rejected':
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
// Shared empty state
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
