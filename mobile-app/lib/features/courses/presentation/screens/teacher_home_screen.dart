import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/data/models/user_model.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../data/models/course_model.dart';
import '../../data/repositories/course_repository.dart';
import '../../../announcements/presentation/bloc/announcement_bloc.dart';
import '../../../announcements/presentation/bloc/announcement_event.dart';
import '../../../announcements/presentation/bloc/announcement_state.dart';
import '../../../messaging/presentation/screens/conversations_screen.dart';
import '../../presentation/bloc/course_bloc.dart';
import '../../presentation/bloc/course_event.dart';
import '../../presentation/bloc/course_state.dart';
import 'teacher_course_screen.dart';

final sl = GetIt.instance;

class TeacherHomeScreen extends StatefulWidget {
  final UserModel user;
  const TeacherHomeScreen({super.key, required this.user});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    sl<CourseBloc>().add(LoadCourses());
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getFirstName() {
    final name = widget.user.name;
    if (name.isEmpty) return 'Teacher';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocProvider<CourseBloc>(
        create: (_) => sl<CourseBloc>(),
        child: BlocBuilder<CourseBloc, CourseState>(
          builder: (context, state) {
            if (state is CourseLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CourseError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<CourseBloc>().add(LoadCourses()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final courses = state is CourseLoaded ? state.courses : <CourseModel>[];
            return IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeTab(courses),
                _buildCoursesTab(courses),
                _buildMessagesTab(),
                _buildProfileTab(),
              ],
            );
          },
        ),
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
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book_rounded),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(List<CourseModel> courses) {
    final totalStudents = 0;
    final totalPending = 0;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<CourseBloc>().add(RefreshCourses());
          await context.read<CourseBloc>().stream.firstWhere(
            (state) => state is CourseLoaded || state is CourseError,
          );
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()},',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textGrey,
                              ),
                            ),
                            Text(
                              'Dr. ${_getFirstName()}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: AppColors.textDark,
                              ),
                            ),
                            if (totalPending > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                            '${courses.length}',
                            'Courses',
                            Icons.book_rounded,
                          ),
                          _buildSummaryItem(
                            '$totalStudents',
                            'Students',
                            Icons.people_rounded,
                          ),
                          _buildSummaryItem(
                            '$totalPending',
                            'Pending Q&A',
                            Icons.question_answer_rounded,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            Icons.campaign_rounded,
                            'New\nAnnouncement',
                            AppColors.primary,
                            () => _showCreateAnnouncementSheet(courses),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAction(
                            Icons.upload_file_rounded,
                            'Upload\nFile',
                            AppColors.success,
                            () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAction(
                            Icons.question_answer_rounded,
                            'View\nQ&A',
                            AppColors.accent,
                            () => setState(() => _currentIndex = 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // My Courses
                    const Text(
                      'My Courses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Course Cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildTeacherCourseCard(courses[index]),
                  childCount: courses.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherCourseCard(CourseModel course) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherCourseScreen(
              course: course,
              sections: const [],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.book_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Course',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textGrey,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCourseStats('0', 'Students', Icons.people_outline),
                _buildCourseStats(
                  '0',
                  'Pending Q&A',
                  Icons.question_answer_outlined,
                ),
                _buildCourseStats('0', 'Sections', Icons.group_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseStats(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.textGrey),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesTab(List<CourseModel> courses) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Courses',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: courses.length,
                itemBuilder: (_, i) => _buildTeacherCourseCard(courses[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    return ConversationsScreen(currentUser: widget.user);
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dr. ${widget.user.name}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            Text(
              widget.user.email,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Teacher',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAnnouncementSheet(List<CourseModel> courses) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedTarget = 'All Sections';
    final targets = ['All Sections', 'Section A', 'Section B'];
    final courseId = courses.isNotEmpty ? courses.first.id : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<AnnouncementBloc>.value(
        value: sl<AnnouncementBloc>(),
        child: BlocConsumer<AnnouncementBloc, AnnouncementState>(
          listener: (context, state) {
            if (state is AnnouncementCreated) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Announcement posted successfully!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            if (state is AnnouncementError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AnnouncementLoading;
            return StatefulBuilder(
              builder: (context, setModalState) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  decoration: const BoxDecoration(
                    color: AppColors.card,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'New Announcement',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        'Title',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'Announcement title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.divider),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Content
                      const Text(
                        'Message',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: contentController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Write your announcement here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.divider),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Target
                      const Text(
                        'Send To',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: targets.map((target) {
                          final isSelected = selectedTarget == target;
                          return GestureDetector(
                            onTap: () =>
                                setModalState(() => selectedTarget = target),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.divider,
                                ),
                              ),
                              child: Text(
                                target,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textGrey,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const Spacer(),

                      // Post Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ||
                                  titleController.text.isEmpty ||
                                  contentController.text.isEmpty
                              ? null
                              : () {
                                  context.read<AnnouncementBloc>().add(
                                    CreateAnnouncement(
                                      title: titleController.text,
                                      content: contentController.text,
                                      courseId: courseId,
                                      sectionIds: selectedTarget ==
                                              'All Sections'
                                          ? null
                                          : [selectedTarget],
                                    ),
                                  );
                                },
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Post Announcement'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
