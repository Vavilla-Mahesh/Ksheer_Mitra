import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/customer_provider.dart';
import '../../../models/customer.dart';
import '../../../widgets/loading_overlay.dart';
import '../../../widgets/status_badge.dart';
import '../../../utils/formatters.dart';
import '../../../utils/ui_helpers.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailsScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  Customer? _customer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    setState(() => _isLoading = true);

    final provider = Provider.of<CustomerProvider>(context, listen: false);
    _customer = await provider.getCustomerById(widget.customerId);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _customer != null ? () => _editCustomer() : null,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'whatsapp':
                  _sendWhatsApp();
                  break;
                case 'export':
                  _exportData();
                  break;
                case 'deactivate':
                  _deactivateCustomer();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'whatsapp',
                child: Row(
                  children: [
                    Icon(Icons.message),
                    SizedBox(width: 8),
                    Text('Send WhatsApp'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              if (_customer?.isActive == true)
                const PopupMenuItem(
                  value: 'deactivate',
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Deactivate', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _customer == null
            ? const Center(
                child: Text('Customer not found'),
              )
            : RefreshIndicator(
                onRefresh: _loadCustomer,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: 16),
                      _buildInfoSection(),
                      const SizedBox(height: 16),
                      _buildSubscriptionsSection(),
                      const SizedBox(height: 16),
                      _buildDeliveryHistorySection(),
                      const SizedBox(height: 16),
                      _buildInvoicesSection(),
                      const SizedBox(height: 16),
                      _buildStatisticsSection(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Text(
                _customer!.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _customer!.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatPhone(_customer!.phone),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  StatusBadge(
                    status: _customer!.isActive ? 'active' : 'inactive',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow(Icons.email, 'Email', _customer!.email ?? 'Not provided'),
            _buildInfoRow(Icons.phone, 'Phone', Formatters.formatPhone(_customer!.phone)),
            _buildInfoRow(Icons.location_on, 'Address', _customer!.address ?? 'Not provided'),
            if (_customer!.areaName != null)
              _buildInfoRow(Icons.map, 'Area', _customer!.areaName!),
            if (_customer!.deliveryBoyName != null)
              _buildInfoRow(Icons.delivery_dining, 'Delivery Boy', _customer!.deliveryBoyName!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subscriptions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to subscriptions list
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View All'),
                ),
              ],
            ),
            const Divider(),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Subscription details coming soon',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryHistorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delivery History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to delivery history
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View All'),
                ),
              ],
            ),
            const Divider(),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Delivery history coming soon',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Invoices',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to invoices list
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View All'),
                ),
              ],
            ),
            const Divider(),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Invoice details coming soon',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Active\nSubscriptions', '${_customer!.activeSubscriptions ?? 0}', Colors.green),
                _buildStatItem('Total\nOrders', '0', Colors.blue),
                _buildStatItem('Payment\nStatus', _customer!.paymentStatus ?? 'N/A', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _editCustomer() {
    // TODO: Navigate to edit customer screen
    UIHelpers.showInfoSnackBar(context, 'Edit customer feature coming soon');
  }

  void _sendWhatsApp() {
    // TODO: Implement WhatsApp messaging
    UIHelpers.showInfoSnackBar(context, 'WhatsApp messaging feature coming soon');
  }

  void _exportData() {
    // TODO: Implement data export
    UIHelpers.showInfoSnackBar(context, 'Export feature coming soon');
  }

  Future<void> _deactivateCustomer() async {
    final confirmed = await UIHelpers.showConfirmDialog(
      context,
      title: 'Deactivate Customer',
      message: 'Are you sure you want to deactivate ${_customer!.name}? This will pause all active subscriptions.',
      confirmText: 'Deactivate',
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      final provider = Provider.of<CustomerProvider>(context, listen: false);
      final success = await provider.deactivateCustomer(widget.customerId);

      if (success && mounted) {
        UIHelpers.showSuccessSnackBar(context, 'Customer deactivated successfully');
        _loadCustomer();
      } else if (mounted) {
        final error = provider.error ?? 'Failed to deactivate customer';
        UIHelpers.showErrorSnackBar(context, error);
        setState(() => _isLoading = false);
      }
    }
  }
}
