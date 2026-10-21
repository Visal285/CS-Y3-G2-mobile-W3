/// A student of the LMS. Pure data.
class Student {
  final String id;
  final String name;

  Student({required this.id, required this.name});

  @override
  String toString() => 'Student($id, $name)';
}
