import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/dashboard_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/empty_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      provider.fetchDashboardData();
      provider.startAutoRefresh(intervalMinutes: 5);
    });
  }

  @override
  void dispose() {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    provider.stopAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.stats == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.stats == null) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Error Loading Dashboard',
            message: provider.error,
            action: ElevatedButton.icon(
              onPressed: () => provider.fetchDashboardData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          );
        }

        final stats = provider.stats;
        if (stats == null) {
          return const EmptyState(
            icon: Icons.dashboard,
            title: 'No Dashboard Data',
            message: 'Unable to load dashboard statistics',
          );
        }

        return LoadingOverlay(
          isLoading: provider.isLoading,
          child: RefreshIndicator(
            onRefresh: () => provider.fetchDashboardData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildStatsGrid(stats),
                  const SizedBox(height: 24),
                  _buildAlertsSection(stats),
                  const SizedBox(height: 24),
                  _buildChartsSection(stats),
                  const SizedBox(height: 24),
                  _buildActivityFeed(provider.activities),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: [
        StatCard(
          title: 'Total Customers',
          value: '${stats.totalCustomers}',
          icon: Icons.people,
          color: Colors.blue,
        ),
        StatCard(
          title: 'Active Customers',
          value: '${stats.activeCustomers}',
          icon: Icons.person_check,
          color: Colors.green,
        ),
        StatCard(
          title: 'Delivery Boys',
          value: '${stats.activeDeliveryBoys}/${stats.totalDeliveryBoys}',
          icon: Icons.delivery_dining,
          color: Colors.orange,
        ),
        StatCard(
          title: 'Active Products',
          value: '${stats.activeProducts}',
          icon: Icons.inventory,
          color: Colors.purple,
        ),
        StatCard(
          title: 'Today\'s Deliveries',
          value: '${stats.todayDelivered}/${stats.todayDeliveries}',
          icon: Icons.local_shipping,
          color: Colors.teal,
        ),
        StatCard(
          title: 'Today\'s Revenue',
          value: Formatters.formatCurrency(stats.todayRevenue),
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        StatCard(
          title: 'Active Subscriptions',
          value: '${stats.activeSubscriptions}',
          icon: Icons.subscriptions,
          color: Colors.indigo,
        ),
        StatCard(
          title: 'Pending Payments',
          value: '${stats.pendingPayments}',
          icon: Icons.payment,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildAlertsSection(stats) {
    final alerts = <Widget>[];

    if (stats.todayMissed > 0) {
      alerts.add(_buildAlert(
        icon: Icons.error,
        color: Colors.red,
        title: 'Missed Deliveries',
        message: '${stats.todayMissed} deliveries missed today',
      ));
    }

    if (stats.overdueInvoices > 0) {
      alerts.add(_buildAlert(
        icon: Icons.receipt_long,
        color: Colors.orange,
        title: 'Overdue Invoices',
        message:
            '${stats.overdueInvoices} invoices overdue (${Formatters.formatCurrency(stats.overdueAmount)})',
      ));
    }

    if (stats.pendingPayments > 0) {
      alerts.add(_buildAlert(
        icon: Icons.pending_actions,
        color: Colors.amber,
        title: 'Pending Payments',
        message:
            '${stats.pendingPayments} payments pending (${Formatters.formatCurrency(stats.pendingAmount)})',
      ));
    }

    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alerts',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...alerts,
      ],
    );
  }

  Widget _buildAlert({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    return Card(
      color: color.withOpacity(0.1),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Text(message),
      ),
    );
  }

  Widget _buildChartsSection(stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analytics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Status Distribution',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: stats.todayDelivered.toDouble(),
                          title: 'Delivered',
                          color: Colors.green,
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: stats.todayMissed.toDouble(),
                          title: 'Missed',
                          color: Colors.red,
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: (stats.todayDeliveries -
                                  stats.todayDelivered -
                                  stats.todayMissed)
                              .toDouble(),
                          title: 'Pending',
                          color: Colors.orange,
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Revenue Overview',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRevenueItem(
                      'Today',
                      Formatters.formatCurrency(stats.todayRevenue),
                      Colors.green,
                    ),
                    _buildRevenueItem(
                      'This Month',
                      Formatters.formatCurrency(stats.monthlyRevenue),
                      Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueItem(String label, String value, Color color) {
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
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityFeed(activities) {
    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activities',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(Icons.notifications, color: Colors.blue),
                ),
                title: Text(activity.description),
                subtitle: Text(
                  Formatters.getRelativeTime(activity.timestamp),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
