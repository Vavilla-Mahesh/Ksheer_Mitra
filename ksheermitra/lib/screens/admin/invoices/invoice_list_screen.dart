import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/invoice_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_overlay.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/pagination_controls.dart';
import '../../../utils/formatters.dart';
import '../../../utils/ui_helpers.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _dailyPage = 1;
  int _monthlyPage = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInvoices();
  }

  void _loadInvoices() {
    final provider = Provider.of<InvoiceProvider>(context, listen: false);
    provider.fetchDailyInvoices(page: _dailyPage);
    provider.fetchMonthlyInvoices(page: _monthlyPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily Invoices'),
            Tab(text: 'Monthly Invoices'),
          ],
        ),
      ),
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              UIHelpers.showErrorSnackBar(context, provider.error!);
              provider.clearError();
            });
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDailyInvoicesTab(provider),
              _buildMonthlyInvoicesTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDailyInvoicesTab(InvoiceProvider provider) {
    if (provider.isLoading && provider.dailyInvoices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.dailyInvoices.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long,
        title: 'No Daily Invoices',
        message: 'Daily invoices will appear here',
        action: ElevatedButton.icon(
          onPressed: () => _loadInvoices(),
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      );
    }

    return LoadingOverlay(
      isLoading: provider.isLoading,
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadInvoices(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.dailyInvoices.length,
                itemBuilder: (context, index) {
                  final invoice = provider.dailyInvoices[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          if (invoice.deliveryBoyName != null)
                            Text('Delivery Boy: ${invoice.deliveryBoyName}'),
                          Text('Date: ${Formatters.formatDate(invoice.invoiceDate)}'),
                          Text('Period: ${Formatters.formatDate(invoice.periodStart)} - ${Formatters.formatDate(invoice.periodEnd)}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                Formatters.formatCurrency(invoice.totalAmount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              StatusBadge(
                                status: invoice.isVerified ? 'verified' : 'pending',
                                showIcon: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) => _handleInvoiceAction(value, invoice.id),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility),
                                SizedBox(width: 8),
                                Text('View PDF'),
                              ],
                            ),
                          ),
                          if (!invoice.isVerified)
                            const PopupMenuItem(
                              value: 'verify',
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle),
                                  SizedBox(width: 8),
                                  Text('Verify'),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (provider.dailyPagination != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PaginationControls(
                currentPage: provider.dailyPagination!['page'],
                totalPages: provider.dailyPagination!['totalPages'],
                onPageChanged: (page) {
                  setState(() => _dailyPage = page);
                  provider.fetchDailyInvoices(page: page);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthlyInvoicesTab(InvoiceProvider provider) {
    if (provider.isLoading && provider.monthlyInvoices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.monthlyInvoices.isEmpty) {
      return EmptyState(
        icon: Icons.receipt,
        title: 'No Monthly Invoices',
        message: 'Monthly invoices will appear here',
        action: ElevatedButton.icon(
          onPressed: () => _loadInvoices(),
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      );
    }

    return LoadingOverlay(
      isLoading: provider.isLoading,
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadInvoices(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.monthlyInvoices.length,
                itemBuilder: (context, index) {
                  final invoice = provider.monthlyInvoices[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          if (invoice.customerName != null)
                            Text('Customer: ${invoice.customerName}'),
                          Text('Month: ${Formatters.getMonthYear(invoice.invoiceDate)}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total: ${Formatters.formatCurrency(invoice.totalAmount)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (invoice.paidAmount > 0)
                                    Text(
                                      'Paid: ${Formatters.formatCurrency(invoice.paidAmount)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                      ),
                                    ),
                                  if (invoice.balanceAmount > 0)
                                    Text(
                                      'Balance: ${Formatters.formatCurrency(invoice.balanceAmount)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          StatusBadge(
                            status: invoice.paymentStatus,
                            showIcon: true,
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) => _handleInvoiceAction(value, invoice.id),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility),
                                SizedBox(width: 8),
                                Text('View PDF'),
                              ],
                            ),
                          ),
                          if (!invoice.isPaid)
                            const PopupMenuItem(
                              value: 'record_payment',
                              child: Row(
                                children: [
                                  Icon(Icons.payment),
                                  SizedBox(width: 8),
                                  Text('Record Payment'),
                                ],
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'resend',
                            child: Row(
                              children: [
                                Icon(Icons.send),
                                SizedBox(width: 8),
                                Text('Resend WhatsApp'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (provider.monthlyPagination != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PaginationControls(
                currentPage: provider.monthlyPagination!['page'],
                totalPages: provider.monthlyPagination!['totalPages'],
                onPageChanged: (page) {
                  setState(() => _monthlyPage = page);
                  provider.fetchMonthlyInvoices(page: page);
                },
              ),
            ),
        ],
      ),
    );
  }

  void _handleInvoiceAction(String action, String invoiceId) {
    switch (action) {
      case 'view':
        _viewInvoicePdf(invoiceId);
        break;
      case 'verify':
        _verifyInvoice(invoiceId);
        break;
      case 'record_payment':
        _recordPayment(invoiceId);
        break;
      case 'resend':
        _resendInvoice(invoiceId);
        break;
    }
  }

  void _viewInvoiceDetails(String invoiceId) {
    // TODO: Navigate to invoice details screen when implemented
    // For now, we don't provide false expectations by showing incomplete functionality
  }

  Future<void> _viewInvoicePdf(String invoiceId) async {
    final provider = Provider.of<InvoiceProvider>(context, listen: false);
    final pdfUrl = await provider.getInvoicePdfUrl(invoiceId);
    
    if (pdfUrl != null && mounted) {
      UIHelpers.showInfoSnackBar(context, 'PDF viewer will be available soon. Invoice has been generated successfully.');
      // TODO: Implement PDF viewer using printing package or external viewer
      // final file = await _downloadPdf(pdfUrl);
      // await Printing.layoutPdf(onLayout: (_) => file.readAsBytes());
    } else if (mounted) {
      UIHelpers.showErrorSnackBar(context, 'Unable to load invoice PDF. Please try again.');
    }
  }

  Future<void> _verifyInvoice(String invoiceId) async {
    final confirmed = await UIHelpers.showConfirmDialog(
      context,
      title: 'Verify Invoice',
      message: 'Are you sure you want to verify this invoice?',
      confirmText: 'Verify',
    );

    if (confirmed == true) {
      final provider = Provider.of<InvoiceProvider>(context, listen: false);
      final success = await provider.verifyInvoice(invoiceId);

      if (success && mounted) {
        UIHelpers.showSuccessSnackBar(context, 'Invoice verified successfully');
      }
    }
  }

  Future<void> _recordPayment(String invoiceId) async {
    // TODO: Implement payment recording form
    // For now, show a proper dialog explaining the feature is coming
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: const Text(
          'Payment recording feature will be available in the next update. '
          'You can currently verify invoices and track payment status.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resendInvoice(String invoiceId) async {
    final confirmed = await UIHelpers.showConfirmDialog(
      context,
      title: 'Resend Invoice',
      message: 'Are you sure you want to resend this invoice via WhatsApp?',
      confirmText: 'Resend',
    );

    if (confirmed == true) {
      final provider = Provider.of<InvoiceProvider>(context, listen: false);
      final success = await provider.resendInvoice(invoiceId);

      if (success && mounted) {
        UIHelpers.showSuccessSnackBar(context, 'Invoice resent successfully');
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
