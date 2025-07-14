import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/admin_bloc.dart';
import '../../bloc/admin_event.dart';
import '../../bloc/admin_state.dart';
import '../../widgets/responsive_layout.dart';
import '../widgets/user_card.dart';

class AdminUsersManagementPage extends StatefulWidget {
  const AdminUsersManagementPage({super.key});

  @override
  State<AdminUsersManagementPage> createState() =>
      _AdminUsersManagementPageState();
}

class _AdminUsersManagementPageState extends State<AdminUsersManagementPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load users data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminBloc>().add(const LoadAllUsersRequested(limit: 50));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header and search
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
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search users by name or email...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          // Debounce search
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (_searchQuery == value) {
                              context.read<AdminBloc>().add(
                                    LoadAllUsersRequested(
                                      searchQuery: value.isEmpty ? null : value,
                                      limit: 50,
                                    ),
                                  );
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<AdminBloc>()
                            .add(const ExportUsersDataRequested());
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Export'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFilters(),
              ],
            ),
          ),

          // Users list
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state.isLoading && state.users.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.users.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<AdminBloc>().add(
                          LoadAllUsersRequested(
                            searchQuery:
                                _searchQuery.isEmpty ? null : _searchQuery,
                            limit: 50,
                          ),
                        );
                  },
                  child: AdminBreakpoints.isDesktop(context)
                      ? _buildDesktopUsersList(state)
                      : _buildMobileUsersList(state),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _buildFilterChip('All Users', true),
        const SizedBox(width: 8),
        _buildFilterChip('Active', false),
        const SizedBox(width: 8),
        _buildFilterChip('Inactive', false),
        const SizedBox(width: 8),
        _buildFilterChip('New This Week', false),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // TODO: Implement filtering
      },
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[800],
    );
  }

  Widget _buildDesktopUsersList(AdminState state) {
    return SingleChildScrollView(
      padding: AdminBreakpoints.getPadding(context),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 50), // Avatar space
                  Expanded(
                      flex: 2,
                      child: Text('Name',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 2,
                      child: Text('Email',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('Habits',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('Status',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('Joined',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(
                      width: 100,
                      child: Text('Actions',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            // Table rows
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.users.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = state.users[index];
                return _buildUserRow(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRow(user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundImage:
                user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            backgroundColor: Colors.blue[100],
            child: user.photoUrl == null
                ? Icon(Icons.person, color: Colors.blue[800])
                : null,
          ),
          const SizedBox(width: 16),

          // Name
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (user.phone != null)
                  Text(
                    user.phone!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),

          // Email
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email),
                Row(
                  children: [
                    Icon(
                      user.isEmailVerified ? Icons.verified : Icons.warning,
                      size: 12,
                      color:
                          user.isEmailVerified ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.isEmailVerified ? 'Verified' : 'Not verified',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            user.isEmailVerified ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Habits
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${user.totalHabits} total'),
                Text(
                  '${user.activeHabits} active',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Status
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user.isActive ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 12,
                  color: user.isActive ? Colors.green[800] : Colors.red[800],
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Joined date
          Expanded(
            child: Text(
              '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),

          // Actions
          SizedBox(
            width: 100,
            child: PopupMenuButton<String>(
              onSelected: (value) => _handleUserAction(value, user),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('View Details'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: user.isActive ? 'ban' : 'unban',
                  child: ListTile(
                    leading: Icon(
                      user.isActive ? Icons.block : Icons.check_circle,
                      color: user.isActive ? Colors.red : Colors.green,
                    ),
                    title: Text(user.isActive ? 'Ban User' : 'Unban User'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete User',
                        style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileUsersList(AdminState state) {
    return ListView.builder(
      padding: AdminBreakpoints.getPadding(context),
      itemCount: state.users.length,
      itemBuilder: (context, index) {
        final user = state.users[index];
        return UserCard(
          user: user,
          onAction: (action) => _handleUserAction(action, user),
        );
      },
    );
  }

  void _handleUserAction(String action, user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'ban':
        _confirmBanUser(user);
        break;
      case 'unban':
        context.read<AdminBloc>().add(UnbanUserRequested(userId: user.id));
        break;
      case 'delete':
        _confirmDeleteUser(user);
        break;
    }
  }

  void _showUserDetails(user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    backgroundColor: Colors.blue[100],
                    child: user.photoUrl == null
                        ? Icon(Icons.person, color: Colors.blue[800], size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Phone', user.phone ?? 'Not provided'),
              _buildDetailRow(
                  'Email Verified', user.isEmailVerified ? 'Yes' : 'No'),
              _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Total Habits', '${user.totalHabits}'),
              _buildDetailRow('Active Habits', '${user.activeHabits}'),
              _buildDetailRow('Completion Rate',
                  '${(user.averageCompletionRate * 100).toStringAsFixed(1)}%'),
              _buildDetailRow('Joined',
                  '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
              if (user.lastLoginAt != null)
                _buildDetailRow('Last Login',
                    '${user.lastLoginAt!.day}/${user.lastLoginAt!.month}/${user.lastLoginAt!.year}'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmBanUser(user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ban User'),
        content: Text(
            'Are you sure you want to ban ${user.fullName}? They will no longer be able to access the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminBloc>().add(BanUserRequested(userId: user.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ban User'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to permanently delete ${user.fullName}? This action cannot be undone and will remove all their data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<AdminBloc>()
                  .add(DeleteUserRequested(userId: user.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete User'),
          ),
        ],
      ),
    );
  }
}
