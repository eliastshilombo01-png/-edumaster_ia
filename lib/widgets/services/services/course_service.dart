import '../models/course.dart';

class CourseService {
  List<Course> getCourses() {
    return [
      Course(title: "IA", description: "Cours d’introduction à l’Intelligence Artificielle."),
      Course(title: "Flutter", description: "Développement mobile moderne."),
    ];
  }
}
