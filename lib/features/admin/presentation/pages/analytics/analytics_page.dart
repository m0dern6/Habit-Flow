import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/admin_bloc.dart';
import '../../bloc/admin_event.dart';
import '../../bloc/admin_state.dart';
import '../../widgets/responsive_layout.dart';
import '../widgets/stats_card.dart';
import '../widgets/chart_card.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedPeriod = 'Last 30 Days';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
    });
  }

  void _loadAnalytics() {
    context.read<AdminBloc>().add(
          LoadAllAnalyticsRequested(
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header with date picker
          Container(
            padding: AdminBreakpoints.getPadding(context),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Analytics Dashboard',
                    style: TextStyle(
                      fontSize: AdminBreakpoints.isDesktop(context) ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildDateRangePicker(),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context
                        .read<AdminBloc>()
                        .add(const ExportUsersDataRequested());
                    context
                        .read<AdminBloc>()
                        .add(const ExportHabitsDataRequested());
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Export'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Analytics content
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadAnalytics();
                  },
                  child: SingleChildScrollView(
                    padding: AdminBreakpoints.getPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overview metrics
                        _buildOverviewSection(state),
                        const SizedBox(height: 24),

                        // Charts section
                        if (AdminBreakpoints.isDesktop(context))
                          _buildDesktopChartsLayout(state)
                        else
                          _buildMobileChartsLayout(state),

                        const SizedBox(height: 24),

                        // Detailed analytics
                        _buildDetailedAnalytics(state),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 8),
            Text(_selectedPeriod),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      onSelected: (value) {
        setState(() {
          _selectedPeriod = value;
          switch (value) {
            case 'Last 7 Days':
              _startDate = DateTime.now().subtract(const Duration(days: 7));
              _endDate = DateTime.now();
              break;
            case 'Last 30 Days':
              _startDate = DateTime.now().subtract(const Duration(days: 30));
              _endDate = DateTime.now();
              break;
            case 'Last 3 Months':
              _startDate = DateTime.now().subtract(const Duration(days: 90));
              _endDate = DateTime.now();
              break;
            case 'Custom Range':
              _showCustomDateRangePicker();
              return;
          }
        });
        _loadAnalytics();
      },
      itemBuilder: (context) => [
        'Last 7 Days',
        'Last 30 Days',
        'Last 3 Months',
        'Custom Range',
      ]
          .map((period) => PopupMenuItem(value: period, child: Text(period)))
          .toList(),
    );
  }

  void _showCustomDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPeriod = 'Custom Range';
      });
      _loadAnalytics();
    }
  }

  Widget _buildOverviewSection(AdminState state) {
    final userAnalytics = state.userAnalytics;
    final habitAnalytics = state.habitAnalytics;
    final systemAnalytics = state.systemAnalytics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
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
                  trendLabel: 'Active this week',
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
                  title: 'Completion Rate',
                  value:
                      '${(habitAnalytics?.averageCompletionRate ?? 0).toStringAsFixed(1)}%',
                  icon: Icons.check_circle,
                  color: Colors.orange,
                  trend: 0,
                  trendLabel: 'Average',
                ),
                if (AdminBreakpoints.isDesktop(context)) ...[
                  StatsCard(
                    title: 'API Calls',
                    value: '${systemAnalytics?.totalApiCalls ?? 0}',
                    icon: Icons.api,
                    color: Colors.teal,
                    trend: 0,
                    trendLabel: 'Total calls',
                  ),
                  StatsCard(
                    title: 'System Uptime',
                    value:
                        '${systemAnalytics?.uptime.toStringAsFixed(1) ?? "99.9"}%',
                    icon: Icons.cloud_done,
                    color: Colors.indigo,
                    trend: 0,
                    trendLabel: 'Uptime',
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDesktopChartsLayout(AdminState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analytics Charts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  ChartCard(
                    title: 'User Growth Trend',
                    chart: _buildUserGrowthChart(state),
                    action: _buildChartAction('users'),
                  ),
                  const SizedBox(height: 16),
                  ChartCard(
                    title: 'Habit Completion Trends',
                    chart: _buildHabitCompletionChart(state),
                    action: _buildChartAction('habits'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  ChartCard(
                    title: 'Popular Habit Categories',
                    chart: _buildHabitCategoriesChart(state),
                  ),
                  const SizedBox(height: 16),
                  ChartCard(
                    title: 'System Performance',
                    chart: _buildSystemPerformanceChart(state),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileChartsLayout(AdminState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analytics Charts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ChartCard(
          title: 'User Growth Trend',
          chart: _buildUserGrowthChart(state),
          action: _buildChartAction('users'),
        ),
        const SizedBox(height: 16),
        ChartCard(
          title: 'Habit Completion Trends',
          chart: _buildHabitCompletionChart(state),
          action: _buildChartAction('habits'),
        ),
        const SizedBox(height: 16),
        ChartCard(
          title: 'Popular Habit Categories',
          chart: _buildHabitCategoriesChart(state),
        ),
        const SizedBox(height: 16),
        ChartCard(
          title: 'System Performance',
          chart: _buildSystemPerformanceChart(state),
        ),
      ],
    );
  }

  Widget _buildChartAction(String type) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'export':
            if (type == 'users') {
              context.read<AdminBloc>().add(const ExportUsersDataRequested());
            } else {
              context.read<AdminBloc>().add(const ExportHabitsDataRequested());
            }
            break;
          case 'fullscreen':
            // TODO: Show fullscreen chart
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'export',
          child: ListTile(
            leading: Icon(Icons.download),
            title: Text('Export Data'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'fullscreen',
          child: ListTile(
            leading: Icon(Icons.fullscreen),
            title: Text('View Fullscreen'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildUserGrowthChart(AdminState state) {
    return Container(
      height: 300,
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
            Text('Chart library integration pending',
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCompletionChart(AdminState state) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
            SizedBox(height: 8),
            Text('Habit Completion Chart'),
            Text('Chart library integration pending',
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCategoriesChart(AdminState state) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 48, color: Colors.purple),
            SizedBox(height: 8),
            Text('Categories Distribution'),
            Text('Chart library integration pending',
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemPerformanceChart(AdminState state) {
    final systemAnalytics = state.systemAnalytics;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformanceMetric(
            'Response Time',
            '${systemAnalytics?.averageResponseTime ?? 0}ms',
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildPerformanceMetric(
            'Error Rate',
            '${systemAnalytics?.errorCount ?? 0}',
            Colors.red,
          ),
          const SizedBox(height: 16),
          _buildPerformanceMetric(
            'API Calls',
            '${systemAnalytics?.totalApiCalls ?? 0}',
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildPerformanceMetric(
            'Uptime',
            '${systemAnalytics?.uptime.toStringAsFixed(1) ?? "99.9"}%',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedAnalytics(AdminState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (AdminBreakpoints.isDesktop(context))
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildUsersByCountryCard(state),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPopularHabitsCard(state),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildUsersByCountryCard(state),
              const SizedBox(height: 16),
              _buildPopularHabitsCard(state),
            ],
          ),
      ],
    );
  }

  Widget _buildUsersByCountryCard(AdminState state) {
    final usersByCountry = state.userAnalytics?.usersByCountry ?? {};

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Users by Country',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (usersByCountry.isEmpty)
              const Center(
                child: Text('No country data available'),
              )
            else
              ...usersByCountry.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text('${entry.value}'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularHabitsCard(AdminState state) {
    final popularHabits = state.habitAnalytics?.popularHabits ?? {};

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Popular Habits',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (popularHabits.isEmpty)
              const Center(
                child: Text('No habit data available'),
              )
            else
              ...popularHabits.entries.take(5).map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(entry.key)),
                          Text('${entry.value}'),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
