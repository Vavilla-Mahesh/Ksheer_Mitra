import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'products/product_list_screen.dart';
import 'customers/customer_list_screen.dart';
import 'invoices/invoice_list_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CustomerListScreen(),
    const Center(child: Text('Delivery Boys - Coming Soon')),
    const ProductListScreen(),
    const Center(child: Text('Areas & Map - Coming Soon')),
    const InvoiceListScreen(),
    const Center(child: Text('Notifications - Coming Soon')),
    const Center(child: Text('Reports - Coming Soon')),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && mounted) {
                await authProvider.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, size: 40),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    authProvider.user?.name ?? 'Admin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    authProvider.user?.phone ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              index: 0,
            ),
            _buildDrawerItem(
              icon: Icons.people,
              title: 'Customers',
              index: 1,
            ),
            _buildDrawerItem(
              icon: Icons.delivery_dining,
              title: 'Delivery Boys',
              index: 2,
            ),
            _buildDrawerItem(
              icon: Icons.inventory,
              title: 'Products',
              index: 3,
            ),
            _buildDrawerItem(
              icon: Icons.map,
              title: 'Areas & Map',
              index: 4,
            ),
            _buildDrawerItem(
              icon: Icons.receipt_long,
              title: 'Invoices',
              index: 5,
            ),
            _buildDrawerItem(
              icon: Icons.notifications,
              title: 'Notifications',
              index: 6,
            ),
            _buildDrawerItem(
              icon: Icons.assessment,
              title: 'Reports',
              index: 7,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to help
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }
}
