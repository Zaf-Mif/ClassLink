class SectionModel {
  final String id;
  final String name;
  final String year;
  final String semester;
  final String departmentId;

  const SectionModel({
    required this.id,
    required this.name,
    required this.year,
    required this.semester,
    required this.departmentId,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      year: json['year']?.toString() ?? '',
      semester: json['semester']?.toString() ?? '',
      departmentId: json['departmentId']?.toString() ?? '',
    );
  }

  String get label => '$name (Year $year, Sem $semester)';
}
