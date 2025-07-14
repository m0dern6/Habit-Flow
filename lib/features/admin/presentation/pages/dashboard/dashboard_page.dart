import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/admin_bloc.dart';
import '../../bloc/admin_event.dart';
import '../../bloc/admin_state.dart';
import '../../widgets/responsive_layout.dart';
import '../widgets/stats_card.dart';
import '../widgets/chart_card.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminBloc>().add(const LoadAllAnalyticsRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<AdminBloc>().add(RefreshDashboard());
            },
            child: SingleChildScrollView(
              padding: AdminBreakpoints.getPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  _buildWelcomeSection(state),
                  const SizedBox(height: 24),

                  // Quick stats
                  _buildQuickStats(state),
                  const SizedBox(height: 24),

                  // Charts and analytics
                  if (AdminBreakpoints.isDesktop(context))
                    _buildDesktopChartsLayout(state)
                  else
                    _buildMobileChartsLayout(state),

                  const SizedBox(height: 24),

                  // Recent activity
                  _buildRecentActivity(state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(AdminState state) {
    final admin = state.currentAdmin;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[600]!, Colors.blue[800]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${admin?.firstName ?? 'Admin'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Here\'s what\'s happening with your app today.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildQuickAction(
                  icon: Icons.refresh,
                  label: 'Refresh Data',
                  onTap: () {
                    context.read<AdminBloc>().add(RefreshDashboard());
                  },
                ),
                const SizedBox(width: 16),
                _buildQuickAction(
                  icon: Icons.download,
                  label: 'Export Data',
                  onTap: () {
                    _showExportDialog(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(AdminState state) {
    final userAnalytics = state.userAnalytics;
    final habitAnalytics = state.habitAnalytics;
    final systemAnalytics = state.systemAnalytics;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = AdminBreakpoints.getGridColumns(context);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            StatsCard(
              title: 'Total Users',
              value: '${userAnalytics?.totalUsers ?? 0}',
              icon: Icons.people,
              color: Colors.blue,
              trend: userAnalytics?.newUsersToday ?? 0,
              trendLabel: 'New today',
            ),
            StatsCard(
              title: 'Active Users',
              value: '${userAnalytics?.activeUsers ?? 0}',
              icon: Icons.people_alt,
              color: Colors.green,
              trend: 0,
              trendLabel: 'This week',
            ),
            StatsCard(
              title: 'Total Habits',
              value: '${habitAnalytics?.totalHabits ?? 0}',
              icon: Icons.track_changes,
              color: Colors.purple,
              trend: habitAnalytics?.completedHabitsToday ?? 0,
              trendLabel: 'Completed today',
            ),
            StatsCard(
              title: 'System Health',
              value: '${systemAnalytics?.uptime.toStringAsFixed(1) ?? "99.9"}%',
              icon: Icons.health_and_safety,
              color: Colors.orange,
              trend: 0,
              trendLabel: 'Uptime',
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopChartsLayout(AdminState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              ChartCard(
                title: 'User Growth',
                chart: _buildUserGrowthChart(state),
              ),
              const SizedBox(height: 16),
              ChartCard(
                title: 'Habit Completion Rate',
                chart: _buildHabitCompletionChart(state),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              ChartCard(
                title: 'Popular Habits',
                chart: _buildPopularHabitsChart(state),
              ),
              const SizedBox(height: 16),
              ChartCard(
                title: 'System Metrics',
                chart: _buildSystemMetricsChart(state),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileChartsLayout(AdminState state) {
    return Column(
      children: [
        ChartCard(
          title: 'User Growth',
          chart: _buildUserGrowthChart(state),
        ),
        const SizedBox(height: 16),
        ChartCard(
          title: 'Habit Completion Rate',
          chart: _buildHabitCompletionChart(state),
        ),
        const SizedBox(height: 16),
        ChartCard(
          title: 'Popular Habits',
          chart: _buildPopularHabitsChart(state),
        ),
        const SizedBox(height: 16),
        ChartCard(
          title: 'System Metrics',
          chart: _buildSystemMetricsChart(state),
        ),
      ],
    );
  }

  Widget _buildUserGrowthChart(AdminState state) {
    // For now, show a placeholder
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 48, color: Colors.blue),
            SizedBox(height: 8),
            Text('User Growth Chart'),
            Text('Chart implementation pending',
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCompletionChart(AdminState state) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 48, color: Colors.green),
            SizedBox(height: 8),
            Text('Habit Completion Chart'),
            Text('Chart implementation pending',
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularHabitsChart(AdminState state) {
    final popularHabits = state.habitAnalytics?.popularHabits ?? {};

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: popularHabits.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 48, color: Colors.purple),
                  SizedBox(height: 8),
                  Text('Popular Habits'),
                  Text('No data available', style: TextStyle(fontSize: 12)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: popularHabits.length,
              itemBuilder: (context, index) {
                final habit = popularHabits.entries.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(habit.key)),
                      Text('${habit.value}'),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSystemMetricsChart(AdminState state) {
    final systemAnalytics = state.systemAnalytics;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricRow(
              'API Calls', '${systemAnalytics?.totalApiCalls ?? 0}'),
          _buildMetricRow(
              'Avg Response', '${systemAnalytics?.averageResponseTime ?? 0}ms'),
          _buildMetricRow('Errors', '${systemAnalytics?.errorCount ?? 0}'),
          _buildMetricRow('Uptime', '${systemAnalytics?.uptime ?? 99.9}%'),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(AdminState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.person_add, color: Colors.blue[800]),
                  ),
                  title: Text('New user registered'),
                  subtitle: Text('User #${index + 1} joined the platform'),
                  trailing: Text('${index + 1}h ago'),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Export Users Data'),
              subtitle: Text('Download user information as CSV'),
            ),
            ListTile(
              leading: Icon(Icons.track_changes),
              title: Text('Export Habits Data'),
              subtitle: Text('Download habits and entries as CSV'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminBloc>().add(const ExportUsersDataRequested());
              context.read<AdminBloc>().add(const ExportHabitsDataRequested());
            },
            child: const Text('Export All'),
          ),
        ],
      ),
    );
  }
}
