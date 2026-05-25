import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../injection/injection_container.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String? _error;
  String _userSearch = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() { _loading = true; _error = null; });
    try {
      final response = await sl<ApiClient>().dio.get('/admin/users');
      _users = (response.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _error = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString() ?? 'Failed to load users'
          : 'Failed to load users';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addUser(Map<String, dynamic> data) async {
    try {
      final response = await sl<ApiClient>().dio.post('/admin/users', data: data);
      if (mounted) {
        _users.add(response.data as Map<String, dynamic>);
        setState(() {});
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString() ?? 'Failed to add user'
          : 'Failed to add user';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(),
          _buildUsersTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people_rounded),
            label: 'Users',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    final totalStudents = _users.where((u) => u['role'] == 'student').length;
    final totalTeachers = _users.where((u) => u['role'] == 'teacher').length;
    final totalAdmins = _users.where((u) => u['role'] == 'admin').length;

    return SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppColors.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadUsers, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Panel',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                ),
                                Text(
                                  'Adama Science and Technology University',
                                  style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.4,
                          children: [
                            _buildStatCard('Students', '$totalStudents', Icons.school_rounded, AppColors.primary),
                            _buildStatCard('Teachers', '$totalTeachers', Icons.person_rounded, AppColors.success),
                            _buildStatCard('Admins', '$totalAdmins', Icons.admin_panel_settings_rounded, AppColors.accent),
                            _buildStatCard('Total Users', '${_users.length}', Icons.people_rounded, AppColors.warning),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'All Users',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 12),
                        ..._users.take(5).map((user) => _buildUserListItem(user)),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    final filtered = _users.where((u) =>
        (u['name'] ?? '').toString().toLowerCase().contains(_userSearch.toLowerCase()) ||
        (u['email'] ?? '').toString().toLowerCase().contains(_userSearch.toLowerCase())).toList();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _userSearch = v),
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                      filled: true, fillColor: AppColors.card,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _showAddUserDialog(),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _buildUserListItem(filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> user) {
    final role = (user['role'] ?? '').toString();
    final name = (user['name'] ?? '').toString();
    final email = (user['email'] ?? '').toString();
    Color roleColor = role == 'teacher' ? AppColors.success : role == 'admin' ? AppColors.accent : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: roleColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Center(child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: roleColor),
            )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(email, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(role, style: TextStyle(fontSize: 11, color: roleColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'student';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.65,
            decoration: const BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                const Text('Add New User', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'First Last',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                            filled: true, fillColor: AppColors.background,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('University Email', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'first.last@astu.edu.et',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                            filled: true, fillColor: AppColors.background,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Role', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        Row(
                          children: ['student', 'teacher', 'admin'].map((role) {
                            final isSelected = selectedRole == role;
                            return GestureDetector(
                              onTap: () => setModalState(() => selectedRole = role),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.background,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                                ),
                                child: Text(role, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : AppColors.textGrey)),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                        _addUser({
                          'name': nameController.text,
                          'email': emailController.text,
                          'password': 'password123',
                          'role': selectedRole,
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User added successfully!'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
                        );
                      }
                    },
                    child: const Text('Add User'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
