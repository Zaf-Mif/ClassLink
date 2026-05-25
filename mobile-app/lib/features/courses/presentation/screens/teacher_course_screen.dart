import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/course_model.dart';
import '../../../assignments/data/models/assignment_model.dart';
import '../../../announcements/data/models/announcement_model.dart';
import '../../../announcements/data/repositories/announcement_repository.dart';
import '../../../announcements/presentation/bloc/announcement_bloc.dart';
import '../../../announcements/presentation/bloc/announcement_event.dart';
import '../../../announcements/presentation/bloc/announcement_state.dart';
import '../../../assignments/presentation/bloc/assignment_bloc.dart';
import '../../../assignments/presentation/bloc/assignment_event.dart';
import '../../../assignments/presentation/bloc/assignment_state.dart';
import '../../../files/presentation/bloc/file_bloc.dart';
import '../../../files/presentation/bloc/file_event.dart';
import '../../../files/presentation/bloc/file_state.dart';
import '../../../forum/presentation/bloc/forum_bloc.dart';
import '../../../forum/presentation/bloc/forum_event.dart';
import '../../../forum/presentation/bloc/forum_state.dart';
import '../../../forum/data/models/forum_question_model.dart';
import '../../../files/data/models/file_item_model.dart';
import '../../../../injection/injection_container.dart';

class TeacherCourseScreen extends StatefulWidget {
  final CourseModel course;
  final List<String> sections;
  const TeacherCourseScreen({
    super.key,
    required this.course,
    required this.sections,
  });

  @override
  State<TeacherCourseScreen> createState() => _TeacherCourseScreenState();
}

class _ReadStats {
  final int readCount;
  final int totalCount;
  _ReadStats(this.readCount, this.totalCount);
}

class _TeacherCourseScreenState extends State<TeacherCourseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final AnnouncementBloc _announcementBloc;
  late final AssignmentBloc _assignmentBloc;
  late final FileBloc _fileBloc;
  late final ForumBloc _forumBloc;
  final AnnouncementRepository _announcementRepo = sl<AnnouncementRepository>();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, _ReadStats> _readStats = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _announcementBloc = sl<AnnouncementBloc>();
    _assignmentBloc = sl<AssignmentBloc>();
    _fileBloc = sl<FileBloc>();
    _forumBloc = sl<ForumBloc>();
    _announcementBloc.add(LoadAnnouncements(widget.course.id));
    _assignmentBloc.add(LoadAssignments(widget.course.id));
    _fileBloc.add(LoadFiles(widget.course.id));
    _forumBloc.add(LoadQuestions(widget.course.id));
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<void> _onRefresh() async {
    _announcementBloc.add(LoadAnnouncements(widget.course.id, query: _searchQuery));
    _assignmentBloc.add(RefreshAssignments(widget.course.id));
    _fileBloc.add(RefreshFiles(widget.course.id));
    _forumBloc.add(LoadQuestions(widget.course.id));
  }

  Future<void> _loadReadStats(String announcementId) async {
    try {
      final data = await _announcementRepo.getReadReceipts(announcementId);
      final reads = (data['reads'] as List).length;
      final total = data['total'] as int;
      if (mounted) {
        setState(() {
          _readStats[announcementId] = _ReadStats(reads, total);
        });
      }
    } catch (_) {}
  }

  Future<void> _loadAllReadStats(List<AnnouncementModel> announcements) async {
    for (final a in announcements) {
      if (!_readStats.containsKey(a.id)) {
        _loadReadStats(a.id);
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _announcementBloc.add(LoadAnnouncements(widget.course.id, query: value));
  }

  String _formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AnnouncementBloc>.value(value: _announcementBloc),
        BlocProvider<AssignmentBloc>.value(value: _assignmentBloc),
        BlocProvider<FileBloc>.value(value: _fileBloc),
        BlocProvider<ForumBloc>.value(value: _forumBloc),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.course.name,
            style: const TextStyle(fontSize: 16),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textGrey,
            indicatorColor: AppColors.primary,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Announcements'),
              Tab(text: 'Assignments'),
              Tab(text: 'Files'),
              Tab(text: 'Q&A'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAnnouncementsTab(),
            _buildAssignmentsTab(),
            _buildFilesTab(),
            _buildQATab(),
          ],
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        if (_tabController.index == 0) {
          _showCreateAnnouncementSheet();
        }
      },
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        _tabController.index == 0
            ? 'New Announcement'
            : _tabController.index == 1
                ? 'Upload File'
                : 'Answer Q&A',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildAnnouncementsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search announcements...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              filled: true,
              fillColor: AppColors.card,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        Expanded(
          child: BlocListener<AnnouncementBloc, AnnouncementState>(
            listener: (context, state) {
              if (state is AnnouncementLoaded) {
                _loadAllReadStats(state.announcements);
              }
            },
            child: BlocBuilder<AnnouncementBloc, AnnouncementState>(
              builder: (context, state) {
                if (state is AnnouncementLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AnnouncementError) {
                  return Center(child: Text(state.message));
                }
                final announcements = state is AnnouncementLoaded
                    ? state.announcements
                    : <AnnouncementModel>[];
                if (announcements.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 80),
                      Center(
                        child: Text(
                          'No announcements yet',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ),
                    ],
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    final a = announcements[index];
                    final stats = _readStats[a.id];
                    final readCount = stats?.readCount ?? 0;
                    final totalCount = stats?.totalCount ?? 1;
                    final percent = totalCount > 0 ? readCount / totalCount : 0.0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  a.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'All Sections',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            a.content,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.remove_red_eye_outlined,
                                size: 14,
                                color: AppColors.textGrey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$readCount read',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textGrey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percent,
                                    backgroundColor: AppColors.divider,
                                    color: AppColors.success,
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(percent * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatTime(a.createdAt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentsTab() {
    return BlocBuilder<AssignmentBloc, AssignmentState>(
      builder: (context, state) {
        if (state is AssignmentLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AssignmentError) {
          return Center(child: Text(state.message));
        }
        final assignments = state is AssignmentLoaded
            ? state.assignments
            : <AssignmentModel>[];
        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final a = assignments[index];
                final deadline = a.deadline ?? DateTime.now();
                final submitted = a.submissionCount ?? 0;
                final total = a.totalStudents ?? 0;
                final isExpired = deadline.isBefore(DateTime.now());
                final submitPercent = total > 0 ? submitted / total : 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
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
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.assignment_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'All Sections',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isExpired
                                  ? AppColors.error.withOpacity(0.1)
                                  : AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isExpired ? 'Closed' : 'Open',
                              style: TextStyle(
                                fontSize: 11,
                                color: isExpired
                                    ? AppColors.error
                                    : AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Deadline
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: AppColors.textGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Deadline: ${deadline.day}/${deadline.month}/${deadline.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Submission progress
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline_rounded,
                            size: 13,
                            color: AppColors.textGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$submitted/$total submitted',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: submitPercent,
                                backgroundColor: AppColors.divider,
                                color: submitPercent == 1.0
                                    ? AppColors.success
                                    : AppColors.primary,
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(submitPercent * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // Create Assignment FAB
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () => _showCreateAssignmentSheet(),
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'New Assignment',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateAnnouncementSheet() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final List<String> allSections = [...widget.sections];
    final List<String> selectedSections = [];
    bool selectAll = false;
    bool isScheduled = false;
    DateTime scheduledDate = DateTime.now().add(const Duration(hours: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          'Content',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: contentController,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: 'Write your announcement...',
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

                        // Schedule toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Schedule for later',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            Switch(
                              value: isScheduled,
                              onChanged: (v) {
                                setModalState(() {
                                  isScheduled = v;
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                        if (isScheduled) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: scheduledDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(scheduledDate),
                                );
                                if (time != null) {
                                  setModalState(() {
                                    scheduledDate = DateTime(
                                      picked.year,
                                      picked.month,
                                      picked.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  });
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year} at ${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.edit_rounded,
                                    color: AppColors.textGrey,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Section selector
                        const Text(
                          'Send To',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Select All toggle
                        GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectAll = !selectAll;
                              if (selectAll) {
                                selectedSections.clear();
                                selectedSections.addAll(allSections);
                              } else {
                                selectedSections.clear();
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: selectAll
                                  ? AppColors.primary
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectAll
                                    ? AppColors.primary
                                    : AppColors.divider,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  selectAll
                                      ? Icons.check_box_rounded
                                      : Icons.check_box_outline_blank_rounded,
                                  color: selectAll
                                      ? Colors.white
                                      : AppColors.textGrey,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'All Sections',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: selectAll
                                        ? Colors.white
                                        : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Individual sections
                        ...allSections.map((section) {
                          final isSelected =
                              selectedSections.contains(section);
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  selectedSections.remove(section);
                                } else {
                                  selectedSections.add(section);
                                }
                                selectAll =
                                    selectedSections.length ==
                                        allSections.length;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.08)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.divider,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_box_rounded
                                        : Icons.check_box_outline_blank_rounded,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textGrey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    section,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Post Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty &&
                          contentController.text.isNotEmpty &&
                          (selectAll || selectedSections.isNotEmpty)) {
                        _announcementBloc.add(CreateAnnouncement(
                          title: titleController.text,
                          content: contentController.text,
                          courseId: widget.course.id,
                          sectionIds: selectedSections,
                          scheduledAt: isScheduled ? scheduledDate : null,
                        ));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Announcement posted successfully!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please fill all fields and select at least one section'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const Text('Post Announcement'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateAssignmentSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDeadline = DateTime.now().add(const Duration(days: 7));
    final List<String> allSections = [...widget.sections];
    final List<String> selectedSections = [];
    bool selectAll = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  'New Assignment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            hintText: 'Assignment title',
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

                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                'Describe the assignment requirements...',
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

                        // Deadline
                        const Text(
                          'Deadline',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDeadline,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setModalState(() {
                                  selectedDeadline = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${selectedDeadline.day}/${selectedDeadline.month}/${selectedDeadline.year} at ${selectedDeadline.hour.toString().padLeft(2, '0')}:${selectedDeadline.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.edit_rounded,
                                  color: AppColors.textGrey,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Section selector
                        const Text(
                          'Send To',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Select All toggle
                        GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectAll = !selectAll;
                              if (selectAll) {
                                selectedSections.clear();
                                selectedSections.addAll(allSections);
                              } else {
                                selectedSections.clear();
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: selectAll
                                  ? AppColors.primary
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectAll
                                    ? AppColors.primary
                                    : AppColors.divider,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  selectAll
                                      ? Icons.check_box_rounded
                                      : Icons.check_box_outline_blank_rounded,
                                  color: selectAll
                                      ? Colors.white
                                      : AppColors.textGrey,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'All Sections',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: selectAll
                                        ? Colors.white
                                        : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Individual sections
                        ...allSections.map((section) {
                          final isSelected =
                              selectedSections.contains(section);
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  selectedSections.remove(section);
                                } else {
                                  selectedSections.add(section);
                                }
                                selectAll =
                                    selectedSections.length ==
                                        allSections.length;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.08)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.divider,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_box_rounded
                                        : Icons.check_box_outline_blank_rounded,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textGrey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    section,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Post Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty &&
                          descController.text.isNotEmpty &&
                          (selectAll || selectedSections.isNotEmpty)) {
                        _assignmentBloc.add(CreateAssignment(
                          title: titleController.text,
                          description: descController.text,
                          deadline: selectedDeadline,
                          courseId: widget.course.id,
                          sectionIds: selectedSections,
                        ));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Assignment posted successfully!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please fill all fields and select at least one section'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const Text('Post Assignment'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilesTab() {
    return BlocBuilder<FileBloc, FileState>(
      builder: (context, state) {
        if (state is FileLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FileError) {
          return Center(child: Text(state.message));
        }
        final files = state is FileLoaded ? state.files : <FileItemModel>[];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            final ext = file.title.contains('.')
                ? file.title.split('.').last.toLowerCase()
                : '';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getFileColor(ext).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getFileIcon(ext),
                      color: _getFileColor(ext),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'v${file.versionNumber} • ${_formatTime(file.uploadedAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getFileColor(String ext) {
    switch (ext) {
      case 'pdf':
        return AppColors.error;
      case 'doc':
      case 'docx':
        return AppColors.primary;
      case 'ppt':
      case 'pptx':
        return AppColors.accent;
      default:
        return AppColors.textGrey;
    }
  }

  IconData _getFileIcon(String ext) {
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Widget _buildQATab() {
    return BlocBuilder<ForumBloc, ForumState>(
      builder: (context, state) {
        if (state is ForumLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ForumError) {
          return Center(child: Text(state.message));
        }
        final questions =
            state is ForumLoaded ? state.questions : <ForumQuestionModel>[];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final q = questions[index];
            final firstAnswer = q.answers.isNotEmpty ? q.answers.first : null;
            return GestureDetector(
              onTap: () => _showQuestionDetail(q),
              child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: !q.isAnswered
                    ? Border.all(color: AppColors.accent.withOpacity(0.4))
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          q.content,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (q.isAnswered
                                  ? AppColors.success
                                  : AppColors.accent)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          q.isAnswered ? 'Answered' : 'Pending',
                          style: TextStyle(
                            fontSize: 11,
                            color: q.isAnswered
                                ? AppColors.success
                                : AppColors.accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!q.isAnswered)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            _showAnswerDialog(q.id, q.content),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text('Answer'),
                      ),
                    ),
                  if (firstAnswer != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: firstAnswer.isPinned
                            ? AppColors.accent.withOpacity(0.08)
                            : AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: firstAnswer.isPinned
                              ? AppColors.accent.withOpacity(0.4)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (firstAnswer.isPinned) ...[
                            Icon(
                              Icons.push_pin_rounded,
                              size: 14,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              firstAnswer.content,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            );
          },
        );
      },
    );
  }

  void _showQuestionDetail(ForumQuestionModel q) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.studentName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(q.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _forumBloc.add(ToggleAnswered(q.id));
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (q.isAnswered
                                  ? AppColors.success
                                  : AppColors.accent)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              q.isAnswered
                                  ? Icons.check_circle_rounded
                                  : Icons.help_outline_rounded,
                              size: 14,
                              color: q.isAnswered
                                  ? AppColors.success
                                  : AppColors.accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              q.isAnswered ? 'Answered' : 'Pending',
                              style: TextStyle(
                                fontSize: 12,
                                color: q.isAnswered
                                    ? AppColors.success
                                    : AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.content,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textDark,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (q.answers.isNotEmpty) ...[
                      const Text(
                        'Answers',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...q.answers.map((a) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: a.isPinned
                              ? AppColors.accent.withOpacity(0.08)
                              : AppColors.primary.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: a.isPinned
                                ? AppColors.accent.withOpacity(0.4)
                                : AppColors.primary.withOpacity(0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  a.isPinned
                                      ? Icons.push_pin_rounded
                                      : Icons.school_rounded,
                                  size: 16,
                                  color: a.isPinned
                                      ? AppColors.accent
                                      : AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  a.teacherName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: a.isPinned
                                        ? AppColors.accent
                                        : AppColors.primary,
                                  ),
                                ),
                                if (a.isPinned) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Pinned',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    _forumBloc.add(TogglePin(questionId: q.id, answerId: a.id));
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    a.isPinned
                                        ? Icons.push_pin
                                        : Icons.push_pin_outlined,
                                    size: 18,
                                    color: a.isPinned
                                        ? AppColors.accent
                                        : AppColors.textGrey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatTime(a.createdAt),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              a.content,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textDark,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                    if (q.answers.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: const Center(
                          child: Text(
                            'No answers yet.',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnswerDialog(String questionId, String question) {
    final controller = TextEditingController();
    bool isPinned = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Answer Question',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                question,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your answer...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    size: 18,
                    color: isPinned ? AppColors.accent : AppColors.textGrey,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pin this answer',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: isPinned,
                    onChanged: (v) {
                      setModalState(() {
                        isPinned = v;
                      });
                    },
                    activeColor: AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      _forumBloc.add(AnswerQuestion(
                        questionId: questionId,
                        content: controller.text,
                        isPinned: isPinned,
                      ));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Answer posted successfully!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('Post Answer'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
