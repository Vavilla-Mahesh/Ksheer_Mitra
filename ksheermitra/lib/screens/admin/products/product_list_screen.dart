import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_overlay.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/pagination_controls.dart';
import '../../../utils/formatters.dart';
import '../../../utils/ui_helpers.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _searchQuery;
  bool? _isActiveFilter;
  String? _sortBy = 'name';
  String? _sortOrder = 'asc';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.fetchProducts(
      page: _currentPage,
      search: _searchQuery,
      isActive: _isActiveFilter,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToProductForm(null),
        child: const Icon(Icons.add),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              UIHelpers.showErrorSnackBar(context, provider.error!);
              provider.clearError();
            });
          }

          if (provider.isLoading && provider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.products.isEmpty) {
            return EmptyState(
              icon: Icons.inventory,
              title: 'No Products Found',
              message: _searchQuery != null
                  ? 'Try adjusting your search or filters'
                  : 'Add your first product to get started',
              action: ElevatedButton.icon(
                onPressed: () => _navigateToProductForm(null),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
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
                      hintText: 'Search products...',
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
                                _loadProducts();
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
                      _loadProducts();
                    },
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _loadProducts(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.products.length,
                      itemBuilder: (context, index) {
                        final product = provider.products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                if (product.description != null)
                                  Text(
                                    Formatters.truncate(product.description!, 60),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      '${Formatters.formatCurrency(product.pricePerUnit)}/${product.unit}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Stock: ${product.stock}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: product.stock > 0
                                            ? Colors.grey[700]
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                StatusBadge(
                                  status: product.isActive ? 'active' : 'inactive',
                                  showIcon: false,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () =>
                                          _navigateToProductForm(product.id),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () => _deleteProduct(product.id),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () => _navigateToProductForm(product.id),
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
                        _loadProducts();
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
        String? tempSortBy = _sortBy;
        String? tempSortOrder = _sortOrder;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter & Sort'),
              content: Column(
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
                  const Text('Sort By:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: tempSortBy,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'name', child: Text('Name')),
                      DropdownMenuItem(value: 'pricePerUnit', child: Text('Price')),
                      DropdownMenuItem(value: 'createdAt', child: Text('Date Added')),
                    ],
                    onChanged: (value) => setState(() => tempSortBy = value),
                  ),
                  const SizedBox(height: 8),
                  const Text('Order:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: tempSortOrder,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'asc', child: Text('Ascending')),
                      DropdownMenuItem(value: 'desc', child: Text('Descending')),
                    ],
                    onChanged: (value) => setState(() => tempSortOrder = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    this.setState(() {
                      _isActiveFilter = null;
                      _sortBy = 'name';
                      _sortOrder = 'asc';
                      _currentPage = 1;
                    });
                    _loadProducts();
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
                      _sortBy = tempSortBy;
                      _sortOrder = tempSortOrder;
                      _currentPage = 1;
                    });
                    _loadProducts();
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

  void _navigateToProductForm(String? productId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(productId: productId),
      ),
    );

    if (result == true) {
      _loadProducts();
    }
  }

  Future<void> _deleteProduct(String productId) async {
    final confirmed = await UIHelpers.showConfirmDialog(
      context,
      title: 'Delete Product',
      message: 'Are you sure you want to delete this product? This action cannot be undone.',
      confirmText: 'Delete',
    );

    if (confirmed == true) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final success = await provider.deleteProduct(productId);

      if (success && mounted) {
        UIHelpers.showSuccessSnackBar(context, 'Product deleted successfully');
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
