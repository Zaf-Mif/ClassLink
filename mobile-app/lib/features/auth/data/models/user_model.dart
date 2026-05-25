class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? departmentId;
  final String? year;
  final String? semester;
  final String? sectionId;
  final String? token;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.departmentId,
    this.year,
    this.semester,
    this.sectionId,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      departmentId: json['departmentId']?.toString(),
      year: json['year']?.toString(),
      semester: json['semester']?.toString(),
      sectionId: json['sectionId']?.toString(),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'departmentId': departmentId,
      'year': year,
      'semester': semester,
      'sectionId': sectionId,
      'token': token,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? departmentId,
    String? year,
    String? semester,
    String? sectionId,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      sectionId: sectionId ?? this.sectionId,
      token: token ?? this.token,
    );
  }
}