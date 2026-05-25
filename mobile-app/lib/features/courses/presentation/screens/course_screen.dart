// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/announcements/data/models/announcement_model.dart';
import '../../../../features/assignments/data/models/assignment_model.dart';
import '../../../../features/files/presentation/bloc/file_bloc.dart';
import '../../../../features/files/presentation/bloc/file_event.dart';
import '../../../../features/files/presentation/bloc/file_state.dart';
import '../../data/models/course_model.dart';
import '../../../announcements/presentation/bloc/announcement_bloc.dart';
import '../../../announcements/presentation/bloc/announcement_event.dart';
import '../../../announcements/presentation/bloc/announcement_state.dart';
import '../../../assignments/presentation/bloc/assignment_bloc.dart';
import '../../../assignments/presentation/bloc/assignment_event.dart';
import '../../../assignments/presentation/bloc/assignment_state.dart';
import '../../../forum/data/models/forum_question_model.dart';
import '../../../forum/presentation/bloc/forum_bloc.dart';
import '../../../forum/presentation/bloc/forum_event.dart';
import '../../../forum/presentation/bloc/forum_state.dart';
import '../../../../injection/injection_container.dart';

class CourseScreen extends StatefulWidget {
  final CourseModel course;
  const CourseScreen({super.key, required this.course});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatDeadline(DateTime deadline) {
    final diff = deadline.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h left';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m left';
    return '${diff.inMinutes}m left';
  }

  Color _getDeadlineColor(DateTime deadline) {
    final diff = deadline.difference(DateTime.now());
    if (diff.isNegative) return AppColors.error;
    if (diff.inDays < 1) return AppColors.accent;
    if (diff.inDays < 3) return AppColors.warning;
    return AppColors.success;
  }

  void _onRefresh() {
    context.read<AnnouncementBloc>().add(LoadAnnouncements(widget.course.id));
    context.read<AssignmentBloc>().add(RefreshAssignments(widget.course.id));
    context.read<FileBloc>().add(RefreshFiles(widget.course.id));
    context.read<ForumBloc>().add(LoadQuestions(widget.course.id));
  }

  String _getFileExtension(String title) {
    final ext = title.split('.').last.toLowerCase();
    return ext;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: MultiBlocProvider(
        providers: [
          BlocProvider<AnnouncementBloc>(
            create: (_) =>
                sl<AnnouncementBloc>()..add(LoadAnnouncements(widget.course.id)),
          ),
          BlocProvider<AssignmentBloc>(
            create: (_) =>
                sl<AssignmentBloc>()..add(LoadAssignments(widget.course.id)),
          ),
          BlocProvider<FileBloc>(
            create: (_) => sl<FileBloc>()..add(LoadFiles(widget.course.id)),
          ),
          BlocProvider<ForumBloc>(
            create: (_) =>
                sl<ForumBloc>()..add(LoadQuestions(widget.course.id)),
          ),
        ],
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAnnouncementsTab(),
            _buildAssignmentsTab(),
            _buildFilesTab(),
            _buildQATab(),
          ],
        ),
      ),
    );
  }

  // ── ANNOUNCEMENTS TAB ──
  Widget _buildAnnouncementsTab() {
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: BlocBuilder<AnnouncementBloc, AnnouncementState>(
        builder: (context, state) {
          if (state is AnnouncementLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AnnouncementError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message,
                      style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<AnnouncementBloc>()
                        .add(LoadAnnouncements(widget.course.id)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is AnnouncementLoaded) {
            final announcements = state.announcements;
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
                return GestureDetector(
                  onTap: () {
                    if (!a.isRead) {
                      context
                          .read<AnnouncementBloc>()
                          .add(MarkAnnouncementRead(a.id));
                    }
                    _showAnnouncementDetail(a);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: !a.isRead
                          ? Border.all(
                              color: AppColors.primary.withOpacity(0.4))
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: (!a.isRead
                                    ? AppColors.primary
                                    : AppColors.textGrey)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.campaign_rounded,
                            color: !a.isRead
                                ? AppColors.primary
                                : AppColors.textGrey,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      a.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: !a.isRead
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  if (!a.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                a.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textGrey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    a.teacherName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _formatTime(a.createdAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                ],
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
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showAnnouncementDetail(AnnouncementModel a) {
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
            const SizedBox(height: 20),
            Text(
              a.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  a.teacherName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.access_time,
                    size: 14, color: AppColors.textGrey),
                const SizedBox(width: 4),
                Text(
                  _formatTime(a.createdAt),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  a.content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textDark,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ASSIGNMENTS TAB ──
  Widget _buildAssignmentsTab() {
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: BlocBuilder<AssignmentBloc, AssignmentState>(
        builder: (context, state) {
          if (state is AssignmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AssignmentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message,
                      style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<AssignmentBloc>()
                        .add(LoadAssignments(widget.course.id)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is AssignmentLoaded) {
            final assignments = state.assignments;
            if (assignments.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(
                    child: Text(
                      'No assignments yet',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                final deadline = assignment.deadline;
                final isSubmitted = assignment.submitted ?? false;
                final isExpired =
                    deadline != null && deadline.isBefore(DateTime.now());
                final deadlineColor = deadline != null
                    ? _getDeadlineColor(deadline)
                    : AppColors.textGrey;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: isSubmitted
                        ? Border.all(
                            color: AppColors.success.withOpacity(0.4))
                        : isExpired
                            ? Border.all(
                                color: AppColors.error.withOpacity(0.4))
                            : Border.all(
                                color: AppColors.primary.withOpacity(0.2)),
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
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSubmitted
                              ? AppColors.success.withOpacity(0.05)
                              : isExpired
                                  ? AppColors.error.withOpacity(0.05)
                                  : AppColors.primary.withOpacity(0.05),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSubmitted
                                    ? AppColors.success.withOpacity(0.1)
                                    : isExpired
                                        ? AppColors.error.withOpacity(0.1)
                                        : AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isSubmitted
                                    ? Icons.check_circle_rounded
                                    : isExpired
                                        ? Icons.cancel_rounded
                                        : Icons.assignment_rounded,
                                color: isSubmitted
                                    ? AppColors.success
                                    : isExpired
                                        ? AppColors.error
                                        : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    assignment.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (deadline != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 12,
                                          color: deadlineColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isExpired && !isSubmitted
                                              ? 'Deadline passed'
                                              : _formatDeadline(deadline),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: deadlineColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSubmitted
                                    ? AppColors.success
                                    : isExpired
                                        ? AppColors.error
                                        : AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isSubmitted
                                    ? 'Submitted'
                                    : isExpired
                                        ? 'Missed'
                                        : 'Pending',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Body
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (assignment.description != null)
                              Text(
                                assignment.description!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textGrey,
                                  height: 1.5,
                                ),
                              ),
                            if (assignment.description != null)
                              const SizedBox(height: 12),

                            // Deadline info
                            if (deadline != null)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: deadlineColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 14,
                                      color: deadlineColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Deadline: ${deadline.day}/${deadline.month}/${deadline.year} at ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: deadlineColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Submitted file info
                            if (isSubmitted &&
                                assignment.submittedFile != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.success.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.attach_file_rounded,
                                      size: 14,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        assignment.submittedFile!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 16,
                                      color: AppColors.success,
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 14),

                            // Submit / Resubmit button
                            if ((deadline != null && !isExpired) ||
                                isSubmitted)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showSubmitDialog(
                                      context, assignment),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSubmitted
                                        ? AppColors.success
                                        : AppColors.primary,
                                    minimumSize: const Size(0, 44),
                                  ),
                                  icon: Icon(
                                    isSubmitted
                                        ? Icons.refresh_rounded
                                        : Icons.upload_file_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    isSubmitted
                                        ? 'Resubmit'
                                        : 'Submit Assignment',
                                  ),
                                ),
                              ),

                            if (deadline != null &&
                                isExpired &&
                                !isSubmitted)
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock_rounded,
                                      size: 16,
                                      color: AppColors.error,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Submission closed',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showSubmitDialog(BuildContext context, AssignmentModel assignment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Text(
              assignment.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            if (assignment.deadline != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.textGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDeadline(assignment.deadline!),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Upload your submission file',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Accepted formats: PDF, DOCX, ZIP, PNG, JPG',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final result = await FilePicker.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'docx', 'zip', 'png', 'jpg'],
                );
                if (result != null) {
                  final fileName = result.files.single.name;
                  Navigator.pop(context);
                  context.read<AssignmentBloc>().add(
                        SubmitAssignment(
                          assignmentId: assignment.id,
                          fileUrl: fileName,
                        ),
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$fileName submitted successfully!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_rounded,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Tap to select file',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'PDF, DOCX, ZIP, PNG, JPG',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── FILES TAB ──
  Widget _buildFilesTab() {
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: BlocBuilder<FileBloc, FileState>(
        builder: (context, state) {
          if (state is FileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message,
                      style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<FileBloc>()
                        .add(LoadFiles(widget.course.id)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is FileLoaded) {
            final files = state.files;
            if (files.isEmpty) {
              return Column(
                children: [
                  const SizedBox(height: 80),
                  const Center(
                    child: Text(
                      'No files yet',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search files...',
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.divider),
                      ),
                      filled: true,
                      fillColor: AppColors.card,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      final ext = _getFileExtension(file.title);
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
                                size: 22,
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
                                  const SizedBox(height: 2),
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
                                Icons.download_rounded,
                                color: AppColors.primary,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Downloading ${file.title}...'),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  // ── Q&A TAB ──
  Widget _buildQATab() {
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: BlocBuilder<ForumBloc, ForumState>(
        builder: (context, state) {
          if (state is ForumLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ForumError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message,
                      style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ForumBloc>()
                        .add(LoadQuestions(widget.course.id)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is ForumLoaded) {
            final questions = state.questions;
            if (questions.isEmpty) {
              return Stack(
                children: [
                  ListView(
                    children: const [
                      SizedBox(height: 80),
                      Center(
                        child: Text(
                          'No questions yet',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton.extended(
                      onPressed: () => _showAskQuestionDialog(context),
                      backgroundColor: AppColors.primary,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Ask Question',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    final firstAnswer = q.answers.isNotEmpty
                        ? q.answers.first
                        : null;
                    return GestureDetector(
                      onTap: () => _showQuestionDetail(context, q),
                      child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            q.studentName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: (q.isAnswered
                                                          ? AppColors.success
                                                          : AppColors.accent)
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                ),
                                                child: Text(
                                                  q.isAnswered
                                                      ? 'Answered'
                                                      : 'Pending',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: q.isAnswered
                                                        ? AppColors.success
                                                        : AppColors.accent,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                _formatTime(q.createdAt),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.textGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        q.content,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (firstAnswer != null)
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 14, right: 14, bottom: 14),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: firstAnswer.isPinned
                                    ? AppColors.accent.withOpacity(0.08)
                                    : AppColors.primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: firstAnswer.isPinned
                                      ? AppColors.accent.withOpacity(0.4)
                                      : AppColors.primary.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: firstAnswer.isPinned
                                          ? AppColors.accent
                                          : AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      firstAnswer.isPinned
                                          ? Icons.push_pin_rounded
                                          : Icons.school_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          firstAnswer.teacherName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          firstAnswer.content,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                      ],
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
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.extended(
                    onPressed: () => _showAskQuestionDialog(context),
                    backgroundColor: AppColors.primary,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Ask Question',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showQuestionDetail(BuildContext context, ForumQuestionModel q) {
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
                Container(
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
                  child: Text(
                    q.isAnswered ? 'Answered' : 'Pending',
                    style: TextStyle(
                      fontSize: 12,
                      color: q.isAnswered
                          ? AppColors.success
                          : AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                            'No answers yet. Check back later.',
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

  void _showAskQuestionDialog(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
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
                'Ask a Question',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your question here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      Navigator.pop(context);
                      context.read<ForumBloc>().add(
                            AskQuestion(
                              courseId: widget.course.id,
                              content: controller.text,
                            ),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Question submitted successfully!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('Submit Question'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
