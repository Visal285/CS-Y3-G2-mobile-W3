import '../model/course.dart';
import '../model/course_result.dart';
import '../model/student.dart';

/// Holds the LMS state (students, courses, results) and enforces
/// every business rule. See README.md for the documented policies.
class LmsSystem {
  static const double minScore = 0;
  static const double maxScore = 100;

  final List<Student> students = [];
  final List<Course> courses = [];
  final List<CourseResult> results = [];

  int _nextResultNumber = 1;

  // Students

  void addStudent({required String studentId, required String studentName}) {
    if (_findStudentOrNull(studentId) != null) {
      throw Exception('Student $studentId already exists');
    }
    students.add(Student(id: studentId, name: studentName));
  }

  /// Business operation: removes the student everywhere in the LMS
  /// (student list, every course enrollment, every result).
  void removeStudent({required String studentId}) {
    _findStudent(studentId);

    students.removeWhere((s) => s.id == studentId);
    for (final course in courses) {
      course.studentIds.remove(studentId);
    }
    results.removeWhere((r) => r.studentId == studentId);
  }

  //  Courses

  void addCourse({required String courseId, required String courseName}) {
    if (_findCourseOrNull(courseId) != null) {
      throw Exception('Course $courseId already exists');
    }
    courses.add(Course(id: courseId, name: courseName));
  }

  /// Policy: removing a course also removes all results of that course.
  /// Enrollments disappear with the course (they are stored inside it).
  /// Students are never removed.
  void removeCourse({required String courseId}) {
    _findCourse(courseId);

    courses.removeWhere((c) => c.id == courseId);
    results.removeWhere((r) => r.courseId == courseId);
  }

  // Enrollment

  void enrollStudent({required String studentId, required String courseId}) {
    _findStudent(studentId);
    final course = _findCourse(courseId);

    if (course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is already enrolled in $courseId');
    }
    course.studentIds.add(studentId);
  }

  /// Policy: both student and course must exist and the student must be
  /// enrolled. Results of this student in this course are removed too.
  void discardStudentFromCourse({
    required String studentId,
    required String courseId,
  }) {
    _findStudent(studentId);
    final course = _findCourse(courseId);

    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled in $courseId');
    }
    course.studentIds.remove(studentId);
    results.removeWhere(
      (r) => r.studentId == studentId && r.courseId == courseId,
    );
  }

  bool isEnrolled({required String studentId, required String courseId}) {
    final course = _findCourseOrNull(courseId);
    return course != null && course.studentIds.contains(studentId);
  }

  // Results

  /// Policy: student and course must exist, the student must be enrolled,
  /// score must be within [minScore, maxScore], and a student can have only
  /// ONE result per course. Returns the created result (with generated ID).
  CourseResult addResult({
    required String studentId,
    required String courseId,
    required double score,
  }) {
    _findStudent(studentId);
    _findCourse(courseId);

    if (!isEnrolled(studentId: studentId, courseId: courseId)) {
      throw Exception('Student $studentId is not enrolled in $courseId');
    }
    if (score < minScore || score > maxScore) {
      throw Exception('Score $score must be between $minScore and $maxScore');
    }
    if (_findResultFor(studentId, courseId) != null) {
      throw Exception(
        'Student $studentId already has a result for course $courseId',
      );
    }

    final result = CourseResult(
      id: 'R${_nextResultNumber++}',
      studentId: studentId,
      courseId: courseId,
      score: score,
    );
    results.add(result);
    return result;
  }

  /// Policy: the result must exist. Student and course are untouched.
  void removeResult({required String resultId}) {
    if (_findResultOrNull(resultId) == null) {
      throw Exception('Result $resultId not found');
    }
    results.removeWhere((r) => r.id == resultId);
  }

  // Queries

  Student? findStudent(String studentId) => _findStudentOrNull(studentId);
  Course? findCourse(String courseId) => _findCourseOrNull(courseId);
  CourseResult? findResult(String resultId) => _findResultOrNull(resultId);

  List<CourseResult> resultsOfStudent(String studentId) =>
      results.where((r) => r.studentId == studentId).toList();

  List<CourseResult> resultsOfCourse(String courseId) =>
      results.where((r) => r.courseId == courseId).toList();

  // Helpers

  Student _findStudent(String studentId) {
    final s = _findStudentOrNull(studentId);
    if (s == null) throw Exception('Student $studentId not found');
    return s;
  }

  Course _findCourse(String courseId) {
    final c = _findCourseOrNull(courseId);
    if (c == null) throw Exception('Course $courseId not found');
    return c;
  }

  Student? _findStudentOrNull(String studentId) {
    for (final s in students) {
      if (s.id == studentId) return s;
    }
    return null;
  }

  Course? _findCourseOrNull(String courseId) {
    for (final c in courses) {
      if (c.id == courseId) return c;
    }
    return null;
  }

  CourseResult? _findResultOrNull(String resultId) {
    for (final r in results) {
      if (r.id == resultId) return r;
    }
    return null;
  }

  CourseResult? _findResultFor(String studentId, String courseId) {
    for (final r in results) {
      if (r.studentId == studentId && r.courseId == courseId) return r;
    }
    return null;
  }
}
