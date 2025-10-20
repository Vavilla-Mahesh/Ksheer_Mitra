import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';
import '../../../models/product.dart';
import '../../../utils/validators.dart';
import '../../../utils/constants.dart';
import '../../../utils/ui_helpers.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/loading_overlay.dart';

class ProductFormScreen extends StatefulWidget {
  final String? productId;

  const ProductFormScreen({super.key, this.productId});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  String _selectedUnit = 'liter';
  bool _isActive = true;
  bool _isLoading = false;
  Product? _product;

  bool get _isEditMode => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);

    final provider = Provider.of<ProductProvider>(context, listen: false);
    _product = await provider.getProductById(widget.productId!);

    if (_product != null) {
      _nameController.text = _product!.name;
      _descriptionController.text = _product!.description ?? '';
      _priceController.text = _product!.pricePerUnit.toString();
      _stockController.text = _product!.stock.toString();
      _selectedUnit = _product!.unit;
      _isActive = _product!.isActive;
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Product' : 'Add Product'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _nameController,
                  label: 'Product Name',
                  hint: 'e.g., Full Cream Milk',
                  prefixIcon: Icons.inventory,
                  validator: Validators.validateProductName,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description (Optional)',
                  hint: 'Brief description of the product',
                  prefixIcon: Icons.description,
                  maxLines: 3,
                  validator: (value) => Validators.validateMaxLength(
                    value,
                    500,
                    'Description',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _priceController,
                        label: 'Price per Unit',
                        hint: '0.00',
                        prefixIcon: Icons.currency_rupee,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: Validators.validatePrice,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedUnit,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          prefixIcon: Icon(Icons.straighten),
                        ),
                        items: Constants.productUnits
                            .map((unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedUnit = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _stockController,
                  label: 'Stock',
                  hint: '0',
                  prefixIcon: Icons.inventory_2,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Stock is required';
                    }
                    final stock = int.tryParse(value);
                    if (stock == null || stock < 0) {
                      return 'Please enter a valid stock amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  child: SwitchListTile(
                    title: const Text('Active'),
                    subtitle: Text(
                      _isActive
                          ? 'Product is available for subscription'
                          : 'Product is hidden from customers',
                    ),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _isEditMode ? 'Update Product' : 'Create Product',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'unit': _selectedUnit,
      'pricePerUnit': double.parse(_priceController.text),
      'stock': int.parse(_stockController.text),
      'isActive': _isActive,
    };

    final provider = Provider.of<ProductProvider>(context, listen: false);
    bool success;

    if (_isEditMode) {
      success = await provider.updateProduct(widget.productId!, data);
    } else {
      success = await provider.createProduct(data);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      UIHelpers.showSuccessSnackBar(
        context,
        _isEditMode
            ? 'Product updated successfully'
            : 'Product created successfully',
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      final error = provider.error ?? 'Failed to save product';
      UIHelpers.showErrorSnackBar(context, error);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}
