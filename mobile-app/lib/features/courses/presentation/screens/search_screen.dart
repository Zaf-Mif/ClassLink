import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SearchResultItem {
  final String id;
  final String type; // 'announcement', 'file', 'qna'
  final String title;
  final String courseName;
  final String previewText;
  final DateTime dateTime;
  final String? subtitle; // e.g. file size, teacher name

  const SearchResultItem({
    required this.id,
    required this.type,
    required this.title,
    required this.courseName,
    required this.previewText,
    required this.dateTime,
    this.subtitle,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Announcements', 'Files', 'Q&A'

  // Sample data simulating course elements
  final List<SearchResultItem> _sampleData = [
    // Database Systems
    SearchResultItem(
      id: 'db-a1',
      type: 'announcement',
      title: 'Exam Schedule Changed',
      courseName: 'Database Systems',
      previewText: 'Dear students, please note that the midterm exam has been moved to next Monday at 9:00 AM in Room 204. Please make sure to bring your student ID. The exam will cover chapters 1 through 5.',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      subtitle: 'Dr. Ahmed',
    ),
    SearchResultItem(
      id: 'db-a2',
      type: 'announcement',
      title: 'Assignment 2 Deadline Extended',
      courseName: 'Database Systems',
      previewText: 'The deadline for Assignment 2 has been extended to Friday at 11:59 PM. Please submit through the app. Late submissions will not be accepted after this date.',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      subtitle: 'Dr. Ahmed',
    ),
    SearchResultItem(
      id: 'db-a3',
      type: 'announcement',
      title: 'New Study Materials Uploaded',
      courseName: 'Database Systems',
      previewText: 'I have uploaded the lecture notes for chapters 4 and 5 in the Files section. Please review them before our next class on Thursday.',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      subtitle: 'Dr. Ahmed',
    ),
    SearchResultItem(
      id: 'db-f1',
      type: 'file',
      title: 'Chapter 1 - Introduction.pdf',
      courseName: 'Database Systems',
      previewText: 'Introductory slides covering the basics of Database Management Systems, relational databases, SQL queries, and architecture.',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      subtitle: 'PDF • 2.3 MB',
    ),
    SearchResultItem(
      id: 'db-f2',
      type: 'file',
      title: 'Assignment 2.docx',
      courseName: 'Database Systems',
      previewText: 'Detailed guidelines and relational schema problems to test database normalization concepts (1NF, 2NF, 3NF, BCNF).',
      dateTime: DateTime.now().subtract(const Duration(days: 5)),
      subtitle: 'DOCX • 1.1 MB',
    ),
    SearchResultItem(
      id: 'db-f3',
      type: 'file',
      title: 'Lecture Slides Week 3.pptx',
      courseName: 'Database Systems',
      previewText: 'Slides detailing Entity-Relationship (ER) model design, mapping to physical tables, and schema constraints.',
      dateTime: DateTime.now().subtract(const Duration(days: 7)),
      subtitle: 'PPTX • 5.4 MB',
    ),
    SearchResultItem(
      id: 'db-q1',
      type: 'qna',
      title: 'Will the exam cover the lab exercises?',
      courseName: 'Database Systems',
      previewText: 'Question: Will the exam cover the lab exercises?\nAnswer: Yes, lab exercises from weeks 1 to 4 will be included in the practical portion of the midterm exam.',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      subtitle: 'Answered by Dr. Ahmed',
    ),
    SearchResultItem(
      id: 'db-q2',
      type: 'qna',
      title: 'Where do we submit Assignment 2?',
      courseName: 'Database Systems',
      previewText: 'Question: Where do we submit Assignment 2?\nAnswer: Please submit through the ClassLink app under the Assignments tab in PDF or DOCX format.',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      subtitle: 'Answered by Dr. Ahmed',
    ),
    SearchResultItem(
      id: 'db-q3',
      type: 'qna',
      title: 'Can we work in groups for the final project?',
      courseName: 'Database Systems',
      previewText: 'Question: Can we work in groups for the final project?\nAnswer: Yes, groups of up to 3 students are allowed. More project specifications will follow next week.',
      dateTime: DateTime.now().subtract(const Duration(hours: 3)),
      subtitle: 'Answered by Dr. Ahmed',
    ),

    // Mobile Application Development
    SearchResultItem(
      id: 'mad-a1',
      type: 'announcement',
      title: 'Project Proposal Guidelines',
      courseName: 'Mobile Application Development',
      previewText: 'Please submit a 2-page project proposal by next Monday. Group size is restricted to 2-3 students. Focus on solving ASTU campus challenges.',
      dateTime: DateTime.now().subtract(const Duration(hours: 5)),
      subtitle: 'Abebe Kebede',
    ),
    SearchResultItem(
      id: 'mad-f1',
      type: 'file',
      title: 'Flutter Cheat Sheet.pdf',
      courseName: 'Mobile Application Development',
      previewText: 'A handy quick-reference PDF summarizing core Flutter widgets, Dart syntax, stateful lifecycle, and package configurations.',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      subtitle: 'PDF • 850 KB',
    ),
    SearchResultItem(
      id: 'mad-f2',
      type: 'file',
      title: 'Lab 1 - UI Layouts.pdf',
      courseName: 'Mobile Application Development',
      previewText: 'Lab instructions on building complex layouts with columns, rows, stacks, grids, list views, and custom cards.',
      dateTime: DateTime.now().subtract(const Duration(days: 4)),
      subtitle: 'PDF • 1.4 MB',
    ),
    SearchResultItem(
      id: 'mad-q1',
      type: 'qna',
      title: 'Can we use Firebase for our project?',
      courseName: 'Mobile Application Development',
      previewText: 'Question: Can we use Firebase for our project?\nAnswer: Yes, Firebase is allowed and encouraged for state persistence, user authentication, and notifications.',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      subtitle: 'Answered by Abebe Kebede',
    ),

    // Software Architecture and Design
    SearchResultItem(
      id: 'sad-a1',
      type: 'announcement',
      title: 'Guest Lecture on Microservices',
      courseName: 'Software Architecture and Design',
      previewText: 'Don\'t miss the guest lecture by an industry expert this Wednesday at 2 PM on Teams. Attendance is mandatory as we\'ll cover production scenarios.',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      subtitle: 'Wzo. Tigist',
    ),
    SearchResultItem(
      id: 'sad-f1',
      type: 'file',
      title: 'Design Patterns Summary.pdf',
      courseName: 'Software Architecture and Design',
      previewText: 'A detailed cheatsheet covering Creational, Structural, and Behavioral patterns with descriptions and basic Dart examples.',
      dateTime: DateTime.now().subtract(const Duration(days: 6)),
      subtitle: 'PDF • 3.2 MB',
    ),
    SearchResultItem(
      id: 'sad-q1',
      type: 'qna',
      title: 'Will there be coding questions in the midterm?',
      courseName: 'Software Architecture and Design',
      previewText: 'Question: Will there be coding questions in the midterm?\nAnswer: Yes, you will be asked to write code applying specific design patterns (e.g. Singleton, Factory, Observer).',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      subtitle: 'Answered by Wzo. Tigist',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<SearchResultItem> get _filteredResults {
    return _sampleData.where((item) {
      // 1. Category Filter
      if (_selectedFilter != 'All') {
        final type = item.type.toLowerCase();
        if (_selectedFilter == 'Announcements' && type != 'announcement') return false;
        if (_selectedFilter == 'Files' && type != 'file') return false;
        if (_selectedFilter == 'Q&A' && type != 'qna') return false;
      }

      // 2. Query Search
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = item.title.toLowerCase().contains(query);
        final matchesCourse = item.courseName.toLowerCase().contains(query);
        final matchesPreview = item.previewText.toLowerCase().contains(query);
        return matchesTitle || matchesCourse || matchesPreview;
      }

      return true;
    }).toList();
  }

  String _formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _getFormattedType(String type) {
    if (type == 'qna') return '• Q&A';
    return '• ${type[0].toUpperCase()}${type.substring(1)}';
  }

  void _showResultDetails(SearchResultItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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
            const SizedBox(height: 24),
            // Badges & Course Name
            Row(
              children: [
                _buildTypeBadge(item.type),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.courseName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                fontFamily: 'Poppins',
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            // Metadata
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(
                  _formatTime(item.dateTime),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    fontFamily: 'Poppins',
                  ),
                ),
                if (item.subtitle != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),
            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  item.previewText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    fontFamily: 'Poppins',
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bottom Simulated Action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening ${item.type == 'qna' ? 'discussion' : item.type}...'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: Icon(_getActionIcon(item.type), size: 20),
                label: Text(_getActionLabel(item.type)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    IconData icon;
    String label;

    switch (type) {
      case 'announcement':
        color = AppColors.accent;
        icon = Icons.campaign_rounded;
        label = 'Announcement';
        break;
      case 'file':
        color = AppColors.success;
        icon = Icons.insert_drive_file_rounded;
        label = 'File';
        break;
      case 'qna':
        color = AppColors.primary;
        icon = Icons.question_answer_rounded;
        label = 'Q&A';
        break;
      default:
        color = AppColors.textGrey;
        icon = Icons.info_outline;
        label = 'Info';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(String type) {
    if (type == 'file') return Icons.download_rounded;
    if (type == 'qna') return Icons.reply_rounded;
    return Icons.visibility_rounded;
  }

  String _getActionLabel(String type) {
    if (type == 'file') return 'Download File';
    if (type == 'qna') return 'View Discussion';
    return 'View Announcement';
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredResults;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search header
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Resources',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search text field
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search announcements, files, Q&A...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textGrey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: AppColors.textGrey),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Filter chips
            _buildFilterChips(),
            const SizedBox(height: 8),
            // Results list
            Expanded(
              child: results.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        return _buildResultCard(results[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Announcements', 'Files', 'Q&A'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: AppColors.shadow.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ],
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.divider,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textGrey,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultCard(SearchResultItem item) {
    Color iconColor;
    Color iconBgColor;
    IconData iconData;

    switch (item.type) {
      case 'announcement':
        iconColor = AppColors.accent;
        iconBgColor = AppColors.accent.withOpacity(0.1);
        iconData = Icons.campaign_rounded;
        break;
      case 'file':
        iconColor = AppColors.success;
        iconBgColor = AppColors.success.withOpacity(0.1);
        iconData = Icons.insert_drive_file_rounded;
        break;
      case 'qna':
        iconColor = AppColors.primary;
        iconBgColor = AppColors.primary.withOpacity(0.1);
        iconData = Icons.question_answer_rounded;
        break;
      default:
        iconColor = AppColors.textGrey;
        iconBgColor = AppColors.divider;
        iconData = Icons.search_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.divider),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showResultDetails(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          fontFamily: 'Poppins',
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Badges
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.courseName,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getFormattedType(item.type),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGrey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Preview Text
                      Text(
                        item.previewText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                          fontFamily: 'Poppins',
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Subtitle / Date metadata
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (item.subtitle != null)
                            Text(
                              item.subtitle!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          Text(
                            _formatTime(item.dateTime),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textLight,
                              fontFamily: 'Poppins',
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
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.divider.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 52,
                color: AppColors.textLight.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'There are no items matching this category yet.'
                  : 'We couldn\'t find any matches for "$_searchQuery".\nTry checking the spelling or search for something else.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
