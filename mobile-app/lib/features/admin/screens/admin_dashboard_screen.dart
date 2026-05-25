import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/models/department_model.dart';
import '../data/models/section_model.dart';
import '../data/repositories/admin_repository.dart';
import '../../../injection/injection_container.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _repo = sl<AdminRepository>();

  int _currentIndex = 0;
  List<Map<String, dynamic>> _users = [];
  List<DepartmentModel> _departments = [];
  List<SectionModel> _sections = [];
  bool _loading = true;
  String? _error;
  String _userSearch = '';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _repo.getUsers(),
        _repo.getDepartments(),
        _repo.getSections(),
      ]);
      if (!mounted) return;
      _users = results[0] as List<Map<String, dynamic>>;
      _departments = results[1] as List<DepartmentModel>;
      _sections = results[2] as List<SectionModel>;
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Add User Dialog
  // ──────────────────────────────────────────────────────────────
  Future<void> _showAddUserDialog() async {
    final formKey = GlobalKey<FormState>();
    String name = '', email = '', password = '';
    String? departmentId, sectionId, yearStr;
    final selectedRole = ValueNotifier<String>('student');

    await showDialog(
      context: context,
      builder: (ctx) => ValueListenableBuilder<String>(
        valueListenable: selectedRole,
        builder: (_, roleVal, __) => AlertDialog(
          title: const Text('Create User'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      onSaved: (v) => name = v!.trim(),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email', hintText: 'first.last@astu.edu.et'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (!RegExp(r'^[a-zA-Z]+\.[a-zA-Z]+@astu\.edu\.et$').hasMatch(v)) {
                          return 'Must be first.last@astu.edu.et';
                        }
                        return null;
                      },
                      onSaved: (v) => email = v!.trim(),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                      onSaved: (v) => password = v!,
                    ),
                    DropdownButtonFormField<String>(
                      value: roleVal,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: const [
                        DropdownMenuItem(value: 'student', child: Text('Student')),
                        DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (v) => selectedRole.value = v ?? 'student',
                    ),
                    if (roleVal == 'student' || roleVal == 'teacher') ...[
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Department'),
                        items: _departments.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                        onChanged: (v) => departmentId = v,
                      ),
                      if (roleVal == 'student') ...[
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Year', hintText: 'e.g. 3'),
                          keyboardType: TextInputType.number,
                          onSaved: (v) => yearStr = v,
                        ),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Section'),
                          items: _sections
                              .where((s) => departmentId == null || s.departmentId == departmentId)
                              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.label)))
                              .toList(),
                          onChanged: (v) => sectionId = v,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                formKey.currentState!.save();
                try {
                  final created = await _repo.createUser({
                    'name': name,
                    'email': email,
                    'password': password,
                    'role': selectedRole.value,
                    'departmentId': departmentId,
                    'year': yearStr,
                    'semester': yearStr ?? '',
                    if (sectionId != null) 'sectionId': sectionId,
                  });
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  setState(() => _users.insert(0, created));
                  _showSuccess('User created successfully');
                } catch (e) {
                  _showError(e.toString().replaceAll('Exception: ', ''));
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Edit User Dialog
  // ──────────────────────────────────────────────────────────────
  Future<void> _showEditUserDialog(Map<String, dynamic> user) async {
    final formKey = GlobalKey<FormState>();
    String name = user['name'] ?? '';
    String email = user['email'] ?? '';
    String role = user['role'] ?? 'student';
    String? departmentId = user['departmentId']?.toString();
    String? sectionId = user['sectionId']?.toString();
    String? password;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit User'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    onSaved: (v) => name = v!.trim(),
                  ),
                  TextFormField(
                    initialValue: email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (!RegExp(r'^[a-zA-Z]+\.[a-zA-Z]+@astu\.edu\.et$').hasMatch(v)) {
                        return 'Must be first.last@astu.edu.et';
                      }
                      return null;
                    },
                    onSaved: (v) => email = v!.trim(),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'New Password (leave blank to keep)'),
                    obscureText: true,
                    validator: (v) => (v != null && v.isNotEmpty && v.length < 6) ? 'Min 6 characters' : null,
                    onSaved: (v) => password = (v != null && v.isNotEmpty) ? v : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(value: 'student', child: Text('Student')),
                      DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (v) => role = v ?? 'student',
                  ),
                  DropdownButtonFormField<String?>(
                    value: departmentId,
                    decoration: const InputDecoration(labelText: 'Department'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      ..._departments
                          .map((d) => DropdownMenuItem<String?>(value: d.id, child: Text(d.name))),
                    ],
                    onChanged: (v) => departmentId = v,
                  ),
                  if (role == 'student')
                    DropdownButtonFormField<String?>(
                      value: sectionId,
                      decoration: const InputDecoration(labelText: 'Section'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None')),
                        ..._sections
                            .where((s) => departmentId == null || s.departmentId == departmentId)
                            .map((s) => DropdownMenuItem<String?>(value: s.id, child: Text(s.label))),
                      ],
                      onChanged: (v) => sectionId = v,
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              formKey.currentState!.save();
              try {
                final updated = await _repo.updateUser(user['id'].toString(), {
                  'name': name,
                  'email': email,
                  if (password != null) 'password': password,
                  'role': role,
                  'departmentId': departmentId,
                  'sectionId': sectionId,
                });
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                setState(() {
                  final idx = _users.indexWhere((u) => u['id'].toString() == updated['id'].toString());
                  if (idx >= 0) _users[idx] = updated;
                });
                _showSuccess('User updated');
              } catch (e) {
                _showError(e.toString().replaceAll('Exception: ', ''));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Tabs
  // ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAll,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppColors.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadAll, child: const Text('Retry')),
                    ],
                  ),
                )
              : IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildDashboardTab(),
                    _buildUsersTab(),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: _showAddUserDialog,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildDashboardTab() {
    final teacherCount = _users.where((u) => u['role'] == 'teacher').length;
    final studentCount = _users.where((u) => u['role'] == 'student').length;
    final adminCount = _users.where((u) => u['role'] == 'admin').length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatCard('Teachers', teacherCount.toString(), Icons.school, AppColors.primary),
              const SizedBox(width: 12),
              _StatCard('Students', studentCount.toString(), Icons.people, AppColors.success),
              const SizedBox(width: 12),
              _StatCard('Admins', adminCount.toString(), Icons.admin_panel_settings, AppColors.warning),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Departments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _departments.length,
              itemBuilder: (_, i) {
                final dept = _departments[i];
                final count = _users.where((u) => u['departmentId']?.toString() == dept.id).length;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(title: Text(dept.name), trailing: Text('$count users')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    final filtered = _users.where((u) {
      final q = _userSearch.toLowerCase();
      return q.isEmpty ||
          (u['name']?.toString().toLowerCase().contains(q) ?? false) ||
          (u['email']?.toString().toLowerCase().contains(q) ?? false);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search users...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _userSearch = v),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final u = filtered[i];
              final roleColors = <String, Color>{
                'admin': AppColors.warning,
                'teacher': AppColors.primary,
                'student': AppColors.success,
              };
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (roleColors[u['role']] ?? AppColors.textGrey).withOpacity(0.2),
                    child: Text(
                      ((u['name'] ?? '') as String).substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: roleColors[u['role']] ?? AppColors.textGrey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(u['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${u['email']}  •  ${u['role']}'),
                  trailing: const Icon(Icons.edit, color: AppColors.textGrey),
                  onTap: () => _showEditUserDialog(u),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color)),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
            ],
          ),
        ),
      ),
    );
  }
}
