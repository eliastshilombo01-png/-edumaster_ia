import 'package:flutter/material.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tous les cours")),
      body: const Center(child: Text("Liste de tous les cours bientôt...")),
    );
  }
}
