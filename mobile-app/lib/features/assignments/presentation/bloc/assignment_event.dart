abstract class AssignmentEvent {}

class LoadAssignments extends AssignmentEvent {
  final String courseId;
  LoadAssignments(this.courseId);
}

class SubmitAssignment extends AssignmentEvent {
  final String assignmentId;
  final String fileUrl;
  SubmitAssignment({required this.assignmentId, required this.fileUrl});
}

class CreateAssignment extends AssignmentEvent {
  final String title;
  final String? description;
  final DateTime? deadline;
  final String courseId;
  final List<String>? sectionIds;
  CreateAssignment({
    required this.title,
    this.description,
    this.deadline,
    required this.courseId,
    this.sectionIds,
  });
}

class RefreshAssignments extends AssignmentEvent {
  final String courseId;
  RefreshAssignments(this.courseId);
}
