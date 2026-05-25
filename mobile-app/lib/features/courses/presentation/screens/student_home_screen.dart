import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/data/models/user_model.dart';
import '../../data/models/course_model.dart';
import '../../../messaging/presentation/screens/conversations_screen.dart';
import '../../presentation/bloc/course_bloc.dart';
import '../../presentation/bloc/course_event.dart';
import '../../presentation/bloc/course_state.dart';
import 'course_screen.dart';

final sl = GetIt.instance;

class StudentHomeScreen extends StatefulWidget {
  final UserModel user;
  const StudentHomeScreen({super.key, required this.user});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
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
    if (name.isEmpty) return 'Student';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocProvider<CourseBloc>(
        create: (_) => sl<CourseBloc>(),
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            _buildCoursesTab(),
            _buildMessagesTab(),
            _buildSearchTab(),
            _buildProfileTab(),
          ],
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
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
        ),
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
            icon: Icon(Icons.search_rounded),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Search',
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

  Widget _buildHomeTab() {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        if (state is CourseLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CourseError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => sl<CourseBloc>().add(LoadCourses()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is CourseLoaded) {
          final courses = state.courses;
          final totalNew = courses.fold<int>(
            0,
            (sum, c) => sum + (c.newAnnouncements ?? 0) + (c.newFiles ?? 0),
          );

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                sl<CourseBloc>().add(RefreshCourses());
              },
              child: CustomScrollView(
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
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Text(
                                    _getFirstName(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                      fontFamily: 'Poppins',
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
                                  if (totalNew > 0)
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
                                  '${courses.fold<int>(0, (s, c) => s + (c.newAnnouncements ?? 0))}',
                                  'New Updates',
                                  Icons.campaign_rounded,
                                ),
                                _buildSummaryItem(
                                  '${courses.fold<int>(0, (s, c) => s + (c.newFiles ?? 0))}',
                                  'New Files',
                                  Icons.folder_rounded,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Courses Header
                          const Text(
                            'Your Courses',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                              fontFamily: 'Poppins',
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
                        (context, index) => _buildCourseCard(courses[index]),
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
        return const SizedBox();
      },
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
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    final hasUpdates =
        (course.newAnnouncements ?? 0) > 0 || (course.newFiles ?? 0) > 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseScreen(course: course),
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
          border: hasUpdates
              ? Border.all(color: AppColors.primary.withOpacity(0.3))
              : null,
        ),
        child: Row(
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
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if ((course.newAnnouncements ?? 0) > 0)
                        _buildBadge(
                          '${course.newAnnouncements} announcement',
                          AppColors.accent,
                        ),
                      if ((course.newAnnouncements ?? 0) > 0 &&
                          (course.newFiles ?? 0) > 0)
                        const SizedBox(width: 6),
                      if ((course.newFiles ?? 0) > 0)
                        _buildBadge(
                          '${course.newFiles} new file',
                          AppColors.success,
                        ),
                      if (!hasUpdates)
                        const Text(
                          'No new updates',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                            fontFamily: 'Poppins',
                          ),
                        ),
                    ],
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
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildCoursesTab() {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        if (state is CourseLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CourseError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => sl<CourseBloc>().add(LoadCourses()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is CourseLoaded) {
          final courses = state.courses;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'All Courses',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (_, i) => _buildCourseCard(courses[i]),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildMessagesTab() {
    return ConversationsScreen(currentUser: widget.user);
  }

  Widget _buildSearchTab() {
    return const SafeArea(
      child: Center(
        child: Text(
          'Search\nComing Soon',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textGrey,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
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
              widget.user.name.isEmpty ? 'Student' : widget.user.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              widget.user.email,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.error,
                  fontFamily: 'Poppins',
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
}
