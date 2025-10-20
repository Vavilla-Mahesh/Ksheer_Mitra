import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/area_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_overlay.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/pagination_controls.dart';
import '../../../utils/formatters.dart';
import '../../../utils/ui_helpers.dart';
import 'customer_details_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _searchQuery;
  String? _areaFilter;
  bool? _isActiveFilter;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _loadAreas();
  }

  void _loadCustomers() {
    final provider = Provider.of<CustomerProvider>(context, listen: false);
    provider.fetchCustomers(
      page: _currentPage,
      search: _searchQuery,
      areaId: _areaFilter,
      isActive: _isActiveFilter,
    );
  }

  void _loadAreas() {
    final provider = Provider.of<AreaProvider>(context, listen: false);
    provider.fetchAreas(isActive: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              // Navigate to map view
            },
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              UIHelpers.showErrorSnackBar(context, provider.error!);
              provider.clearError();
            });
          }

          if (provider.isLoading && provider.customers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.customers.isEmpty) {
            return EmptyState(
              icon: Icons.people,
              title: 'No Customers Found',
              message: _searchQuery != null
                  ? 'Try adjusting your search or filters'
                  : 'Customers will appear here',
            );
          }

          return LoadingOverlay(
            isLoading: provider.isLoading,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search customers by name or phone...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = null;
                                  _currentPage = 1;
                                });
                                _loadCustomers();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        _searchQuery = value.isNotEmpty ? value : null;
                        _currentPage = 1;
                      });
                      _loadCustomers();
                    },
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _loadCustomers(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.customers.length,
                      itemBuilder: (context, index) {
                        final customer = provider.customers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              child: Text(
                                customer.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              customer.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.phone, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(Formatters.formatPhone(customer.phone)),
                                  ],
                                ),
                                if (customer.address != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          Formatters.truncate(customer.address!, 40),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (customer.areaName != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.map, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Area: ${customer.areaName}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                                if (customer.deliveryBoyName != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.delivery_dining, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        'DB: ${customer.deliveryBoyName}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                StatusBadge(
                                  status: customer.isActive ? 'active' : 'inactive',
                                  showIcon: false,
                                ),
                                if (customer.activeSubscriptions != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${customer.activeSubscriptions} subs',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            onTap: () => _navigateToCustomerDetails(customer.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (provider.pagination != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PaginationControls(
                      currentPage: provider.pagination!['page'],
                      totalPages: provider.pagination!['totalPages'],
                      onPageChanged: (page) {
                        setState(() => _currentPage = page);
                        _loadCustomers();
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        bool? tempActiveFilter = _isActiveFilter;
        String? tempAreaFilter = _areaFilter;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Customers'),
              content: Consumer<AreaProvider>(
                builder: (context, areaProvider, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                      RadioListTile<bool?>(
                        title: const Text('All'),
                        value: null,
                        groupValue: tempActiveFilter,
                        onChanged: (value) => setState(() => tempActiveFilter = value),
                      ),
                      RadioListTile<bool?>(
                        title: const Text('Active'),
                        value: true,
                        groupValue: tempActiveFilter,
                        onChanged: (value) => setState(() => tempActiveFilter = value),
                      ),
                      RadioListTile<bool?>(
                        title: const Text('Inactive'),
                        value: false,
                        groupValue: tempActiveFilter,
                        onChanged: (value) => setState(() => tempActiveFilter = value),
                      ),
                      const Divider(),
                      const Text('Area:', style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<String?>(
                        value: tempAreaFilter,
                        isExpanded: true,
                        hint: const Text('All Areas'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Areas')),
                          ...areaProvider.areas.map((area) =>
                              DropdownMenuItem(value: area.id, child: Text(area.name))),
                        ],
                        onChanged: (value) => setState(() => tempAreaFilter = value),
                      ),
                    ],
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    this.setState(() {
                      _isActiveFilter = null;
                      _areaFilter = null;
                      _currentPage = 1;
                    });
                    _loadCustomers();
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() {
                      _isActiveFilter = tempActiveFilter;
                      _areaFilter = tempAreaFilter;
                      _currentPage = 1;
                    });
                    _loadCustomers();
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateToCustomerDetails(String customerId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailsScreen(customerId: customerId),
      ),
    );
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
