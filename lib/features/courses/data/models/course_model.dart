class CourseModel {
  final String id;
  final String name;
  final String departmentId;
  final String year;
  final String semester;
  final int? newAnnouncements;
  final int? newFiles;

  const CourseModel({
    required this.id,
    required this.name,
    required this.departmentId,
    required this.year,
    required this.semester,
    this.newAnnouncements,
    this.newFiles,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      departmentId: json['departmentId']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      semester: json['semester']?.toString() ?? '',
      newAnnouncements: json['newAnnouncements'],
      newFiles: json['newFiles'],
    );
  }
}