import 'package:lms_layered_architecture_example/service/lms_system.dart';
import 'package:test/test.dart';

void main() {
  late LmsSystem lms;

  setUp(() {
    lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'Ronan');
    lms.addStudent(studentId: 'S2', studentName: 'Alice');
  });

  group('Students', () {
    test('creates and removes a student', () {
      lms.removeStudent(studentId: 'S1');
      expect(lms.findStudent('S1'), isNull);
      expect(lms.students.length, 1);
    });

    test('rejects duplicate student', () {
      expect(
        () => lms.addStudent(studentId: 'S1', studentName: 'X'),
        throwsException,
      );
    });

    test('rejects removal of nonexistent student', () {
      expect(() => lms.removeStudent(studentId: 'S9'), throwsException);
    });
  });

  group('Task 1 - courses', () {
    test('adds and removes a course', () {
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      expect(lms.findCourse('C1')!.name, 'Mobile Development');

      lms.removeCourse(courseId: 'C1');
      expect(lms.findCourse('C1'), isNull);
    });

    test('rejects duplicate course ID', () {
      lms.addCourse(courseId: 'C1', courseName: 'A');
      expect(
        () => lms.addCourse(courseId: 'C1', courseName: 'B'),
        throwsException,
      );
    });

    test('rejects removal of nonexistent course', () {
      expect(() => lms.removeCourse(courseId: 'C9'), throwsException);
    });

    test('removing a course removes its results but keeps students', () {
      lms.addCourse(courseId: 'C1', courseName: 'A');
      lms.addCourse(courseId: 'C2', courseName: 'B');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.enrollStudent(studentId: 'S1', courseId: 'C2');
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 80);
      final other = lms.addResult(studentId: 'S1', courseId: 'C2', score: 70);

      lms.removeCourse(courseId: 'C1');

      expect(lms.resultsOfCourse('C1'), isEmpty);
      expect(lms.findResult(other.id), isNotNull);
      expect(lms.findStudent('S1'), isNotNull);
    });
  });

  group('Task 2 - enrollment', () {
    setUp(() => lms.addCourse(courseId: 'C1', courseName: 'A'));

    test('enrolls a student and records it', () {
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      expect(lms.isEnrolled(studentId: 'S1', courseId: 'C1'), isTrue);
      expect(lms.findCourse('C1')!.studentIds, ['S1']);
    });

    test('rejects unknown student', () {
      expect(
        () => lms.enrollStudent(studentId: 'S9', courseId: 'C1'),
        throwsException,
      );
    });

    test('rejects unknown course', () {
      expect(
        () => lms.enrollStudent(studentId: 'S1', courseId: 'C9'),
        throwsException,
      );
    });

    test('rejects duplicate enrollment', () {
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      expect(
        () => lms.enrollStudent(studentId: 'S1', courseId: 'C1'),
        throwsException,
      );
    });
  });

  group('Task 3 - discard student from course', () {
    setUp(() {
      lms.addCourse(courseId: 'C1', courseName: 'A');
      lms.addCourse(courseId: 'C2', courseName: 'B');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.enrollStudent(studentId: 'S1', courseId: 'C2');
    });

    test('removes an existing enrollment, student and course remain', () {
      lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1');
      expect(lms.isEnrolled(studentId: 'S1', courseId: 'C1'), isFalse);
      expect(lms.findStudent('S1'), isNotNull);
      expect(lms.findCourse('C1'), isNotNull);
    });

    test('rejects nonexistent enrollment', () {
      expect(
        () => lms.discardStudentFromCourse(studentId: 'S2', courseId: 'C1'),
        throwsException,
      );
    });

    test('rejects unknown student or course', () {
      expect(
        () => lms.discardStudentFromCourse(studentId: 'S9', courseId: 'C1'),
        throwsException,
      );
      expect(
        () => lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C9'),
        throwsException,
      );
    });

    test('removes only the results of that student in that course', () {
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 80);
      final kept = lms.addResult(studentId: 'S1', courseId: 'C2', score: 90);

      lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1');

      expect(lms.resultsOfCourse('C1'), isEmpty);
      expect(lms.findResult(kept.id), isNotNull);
    });

    test('removing a student with several enrollments cleans everything', () {
      lms.enrollStudent(studentId: 'S2', courseId: 'C1');
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 80);
      lms.addResult(studentId: 'S1', courseId: 'C2', score: 90);
      final s2Result = lms.addResult(studentId: 'S2', courseId: 'C1', score: 60);

      lms.removeStudent(studentId: 'S1');

      expect(lms.findStudent('S1'), isNull);
      expect(lms.findCourse('C1')!.studentIds, ['S2']);
      expect(lms.findCourse('C2')!.studentIds, isEmpty);
      expect(lms.resultsOfStudent('S1'), isEmpty);
      // The other student is unchanged
      expect(lms.findStudent('S2'), isNotNull);
      expect(lms.findResult(s2Result.id)!.score, 60);
    });
  });

  group('Task 4 - add result', () {
    setUp(() {
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    });

    test('adds a valid result', () {
      final r = lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);
      expect(lms.findResult(r.id)!.score, 85);
      expect(lms.resultsOfStudent('S1').length, 1);
    });

    test('accepts boundary scores 0 and 100', () {
      lms.addCourse(courseId: 'C2', courseName: 'B');
      lms.enrollStudent(studentId: 'S1', courseId: 'C2');
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 0);
      lms.addResult(studentId: 'S1', courseId: 'C2', score: 100);
      expect(lms.results.length, 2);
    });

    test('rejects nonexistent student or course', () {
      expect(
        () => lms.addResult(studentId: 'S9', courseId: 'C1', score: 50),
        throwsException,
      );
      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C9', score: 50),
        throwsException,
      );
    });

    test('rejects student not enrolled', () {
      expect(
        () => lms.addResult(studentId: 'S2', courseId: 'C1', score: 50),
        throwsException,
      );
    });

    test('rejects invalid score', () {
      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C1', score: -1),
        throwsException,
      );
      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C1', score: 101),
        throwsException,
      );
    });

    test('rejects a second result for the same student and course', () {
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);
      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C1', score: 90),
        throwsException,
      );
    });
  });

  group('Task 5 - remove result', () {
    late String resultId;
    late String otherId;

    setUp(() {
      lms.addCourse(courseId: 'C1', courseName: 'A');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.enrollStudent(studentId: 'S2', courseId: 'C1');
      resultId = lms.addResult(studentId: 'S1', courseId: 'C1', score: 85).id;
      otherId = lms.addResult(studentId: 'S2', courseId: 'C1', score: 70).id;
    });

    test('removes an existing result', () {
      lms.removeResult(resultId: resultId);
      expect(lms.findResult(resultId), isNull);
    });

    test('rejects nonexistent result', () {
      expect(() => lms.removeResult(resultId: 'R999'), throwsException);
    });

    test('student, course and unrelated results remain unchanged', () {
      lms.removeResult(resultId: resultId);
      expect(lms.findStudent('S1'), isNotNull);
      expect(lms.isEnrolled(studentId: 'S1', courseId: 'C1'), isTrue);
      expect(lms.findResult(otherId)!.score, 70);
    });
  });

  test('Scenario: remove one of two enrolled students with results', () {
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    lms.enrollStudent(studentId: 'S2', courseId: 'C1');
    lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);
    final s2Result = lms.addResult(studentId: 'S2', courseId: 'C1', score: 75);

    lms.removeStudent(studentId: 'S1');

    expect(lms.findStudent('S1'), isNull);
    expect(lms.isEnrolled(studentId: 'S1', courseId: 'C1'), isFalse);
    expect(lms.resultsOfStudent('S1'), isEmpty);
    expect(lms.isEnrolled(studentId: 'S2', courseId: 'C1'), isTrue);
    expect(lms.findResult(s2Result.id)!.score, 75);
  });
}
