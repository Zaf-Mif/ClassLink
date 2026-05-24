// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/announcements/data/models/announcement_model.dart';
import '../../data/models/course_model.dart';

class CourseScreen extends StatefulWidget {
  final CourseModel course;
  const CourseScreen({super.key, required this.course});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<AnnouncementModel> _announcements = [
    AnnouncementModel(
      id: '1',
      title: 'Exam Schedule Changed',
      content:
          'Dear students, please note that the midterm exam has been moved to next Monday at 9:00 AM in Room 204. Please make sure to bring your student ID. The exam will cover chapters 1 through 5.',
      teacherName: 'Dr. Ahmed',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    AnnouncementModel(
      id: '2',
      title: 'Assignment 2 Deadline Extended',
      content:
          'The deadline for Assignment 2 has been extended to Friday at 11:59 PM. Please submit through the app. Late submissions will not be accepted after this date.',
      teacherName: 'Dr. Ahmed',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    AnnouncementModel(
      id: '3',
      title: 'New Study Materials Uploaded',
      content:
          'I have uploaded the lecture notes for chapters 4 and 5 in the Files section. Please review them before our next class on Thursday.',
      teacherName: 'Dr. Ahmed',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];

  final List<Map<String, dynamic>> _assignments = [
    {
      'id': '1',
      'title': 'Assignment 1 — ER Diagram',
      'description':
          'Design an ER diagram for a hospital management system. Include all entities, relationships, and attributes. Submit as PDF.',
      'deadline': DateTime.now().add(const Duration(days: 2, hours: 5)),
      'submitted': false,
      'submittedFile': null,
    },
    {
      'id': '2',
      'title': 'Assignment 2 — Normalization',
      'description':
          'Normalize the given schema to 3NF. Show all steps clearly. Submit as PDF or DOCX.',
      'deadline': DateTime.now().add(const Duration(days: 5)),
      'submitted': true,
      'submittedFile': 'normalization_zaferan.pdf',
    },
    {
      'id': '3',
      'title': 'Assignment 3 — SQL Queries',
      'description':
          'Write SQL queries for the given 10 problems. Test your queries and include screenshots.',
      'deadline': DateTime.now().subtract(const Duration(days: 1)),
      'submitted': false,
      'submittedFile': null,
    },
  ];

  final List<Map<String, String>> _files = [
    {
      'name': 'Chapter 1 - Introduction.pdf',
      'size': '2.3 MB',
      'date': '3 days ago',
      'type': 'pdf',
    },
    {
      'name': 'Assignment 2.docx',
      'size': '1.1 MB',
      'date': '5 days ago',
      'type': 'doc',
    },
    {
      'name': 'Lecture Slides Week 3.pptx',
      'size': '5.4 MB',
      'date': '1 week ago',
      'type': 'ppt',
    },
    {
      'name': 'Reference Material.pdf',
      'size': '3.2 MB',
      'date': '2 weeks ago',
      'type': 'pdf',
    },
  ];

  final List<Map<String, dynamic>> _questions = [
    {
      'id': '1',
      'question': 'Will the exam cover the lab exercises?',
      'askedBy': 'Student',
      'answer': 'Yes, lab exercises from weeks 1 to 4 will be included.',
      'answeredBy': 'Dr. Ahmed',
      'isAnswered': true,
      'time': '1 day ago',
    },
    {
      'id': '2',
      'question': 'Where do we submit Assignment 2?',
      'askedBy': 'Student',
      'answer': 'Please submit through the app under the Assignments tab.',
      'answeredBy': 'Dr. Ahmed',
      'isAnswered': true,
      'time': '2 days ago',
    },
    {
      'id': '3',
      'question': 'Can we work in groups for the final project?',
      'askedBy': 'Student',
      'answer': null,
      'answeredBy': null,
      'isAnswered': false,
      'time': '3 hours ago',
    },
  ];

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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnnouncementsTab(),
          _buildAssignmentsTab(),
          _buildFilesTab(),
          _buildQATab(),
        ],
      ),
    );
  }

  // ── ANNOUNCEMENTS TAB ──
  Widget _buildAnnouncementsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _announcements.length,
      itemBuilder: (context, index) {
        final a = _announcements[index];
        return GestureDetector(
          onTap: () => _showAnnouncementDetail(a),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: !a.isRead
                  ? Border.all(color: AppColors.primary.withOpacity(0.4))
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
                    color: (!a.isRead ? AppColors.primary : AppColors.textGrey)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.campaign_rounded,
                    color: !a.isRead ? AppColors.primary : AppColors.textGrey,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assignments.length,
      itemBuilder: (context, index) {
        final assignment = _assignments[index];
        final deadline = assignment['deadline'] as DateTime;
        final isSubmitted = assignment['submitted'] as bool;
        final isExpired = deadline.isBefore(DateTime.now());
        final deadlineColor = _getDeadlineColor(deadline);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: isSubmitted
                ? Border.all(color: AppColors.success.withOpacity(0.4))
                : isExpired
                    ? Border.all(color: AppColors.error.withOpacity(0.4))
                    : Border.all(color: AppColors.primary.withOpacity(0.2)),
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
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
                            assignment['title'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
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
                    Text(
                      assignment['description'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Deadline info
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
                    if (isSubmitted && assignment['submittedFile'] != null) ...[
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
                                assignment['submittedFile'] as String,
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
                    if (!isExpired || isSubmitted)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showSubmitDialog(index, assignment),
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

                    if (isExpired && !isSubmitted)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  void _showSubmitDialog(int index, Map<String, dynamic> assignment) {
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
              assignment['title'] as String,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
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
                  _formatDeadline(assignment['deadline'] as DateTime),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
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
                  setState(() {
                    _assignments[index]['submitted'] = true;
                    _assignments[index]['submittedFile'] = fileName;
                  });
                  if (mounted) {
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search files...',
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textGrey),
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
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _files.length,
            itemBuilder: (context, index) {
              final file = _files[index];
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
                        color:
                            _getFileColor(file['type']!).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getFileIcon(file['type']!),
                        color: _getFileColor(file['type']!),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file['name']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${file['size']} • ${file['date']}',
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
                                Text('Downloading ${file['name']}...'),
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

  Color _getFileColor(String type) {
    switch (type) {
      case 'pdf':
        return AppColors.error;
      case 'doc':
        return AppColors.primary;
      case 'ppt':
        return AppColors.accent;
      default:
        return AppColors.textGrey;
    }
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
        return Icons.description_rounded;
      case 'ppt':
        return Icons.slideshow_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  // ── Q&A TAB ──
  Widget _buildQATab() {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final q = _questions[index];
            return Container(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Student',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (q['isAnswered']
                                                  ? AppColors.success
                                                  : AppColors.accent)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          q['isAnswered']
                                              ? 'Answered'
                                              : 'Pending',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: q['isAnswered']
                                                ? AppColors.success
                                                : AppColors.accent,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        q['time'],
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
                                q['question'],
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
                  if (q['isAnswered'])
                    Container(
                      margin: const EdgeInsets.only(
                          left: 14, right: 14, bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  q['answeredBy'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  q['answer'],
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
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showAskQuestionDialog(),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Ask Question',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _showAskQuestionDialog() {
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
                    borderSide:
                        const BorderSide(color: AppColors.divider),
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