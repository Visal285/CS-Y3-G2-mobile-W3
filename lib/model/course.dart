/// A course and the IDs of the students enrolled in it.
/// Pure data: business rules live in LmsSystem.
class Course {
  final String id;
  final String name;
  final List<String> studentIds = [];

  Course({required this.id, required this.name});

  @override
  String toString() => 'Course($id, $name)';
}
