# LMS – Layered Architecture

Three layers: `lib/model` (data), `lib/service` (state + business rules), `test` (service API tests).
No repository layer, no database.

## UML

```mermaid
classDiagram
    class LmsSystem {
        +List~Student~ students
        +List~Course~ courses
        +List~CourseResult~ results
        +addStudent(studentId, studentName)
        +removeStudent(studentId)
        +addCourse(courseId, courseName)
        +removeCourse(courseId)
        +enrollStudent(studentId, courseId)
        +discardStudentFromCourse(studentId, courseId)
        +addResult(studentId, courseId, score) CourseResult
        +removeResult(resultId)
    }
    class Student { +String id +String name }
    class Course { +String id +String name +List~String~ studentIds }
    class CourseResult { +String id +String studentId +String courseId +double score }
    LmsSystem "1" o-- "*" Student
    LmsSystem "1" o-- "*" Course
    LmsSystem "1" o-- "*" CourseResult
    Course "*" ..> "*" Student : enrolls (by studentId)
    CourseResult "*" ..> "1" Student : studentId
    CourseResult "*" ..> "1" Course : courseId
```

## Business rules (chosen policies)

| Operation | Rules |
|---|---|
| `addCourse` | Course ID must be unique. |
| `removeCourse` | Course must exist. Its enrollments and all its results are removed; students are kept. |
| `enrollStudent` | Student and course must exist; not already enrolled. |
| `discardStudentFromCourse` | Student and course must exist; student must be enrolled. The student's results in that course are removed. |
| `removeStudent` | Student must exist. Removed from the student list, every course, and all results. |
| `addResult` | Student and course must exist; student must be enrolled; score in 0–100; only one result per student per course. ID auto-generated (`R1`, `R2`, ...). |
| `removeResult` | Result must exist. Student and course are untouched; no enrollment required. |

## Run

```
dart pub get
dart test
```
