/// A score obtained by a student in a course.
/// Links to Student and Course by ID (not by object reference).
class CourseResult {
  final String id;
  final String studentId;
  final String courseId;
  final double score;

  CourseResult({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.score,
  });

  @override
  String toString() => 'CourseResult($id, $studentId, $courseId, $score)';
}
