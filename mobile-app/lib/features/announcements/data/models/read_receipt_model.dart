class ReadReceiptModel {
  final String id;
  final String studentId;
  final String studentName;
  final DateTime readAt;

  const ReadReceiptModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.readAt,
  });

  factory ReadReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReadReceiptModel(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      studentName: json['studentName'] ?? '',
      readAt: DateTime.parse(json['readAt']),
    );
  }
}
