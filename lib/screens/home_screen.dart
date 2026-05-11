import 'package:flutter/material.dart';
import '../widgets/course_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edumaster IA'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          CourseCard(
            title: "Intelligence Artificielle",
            description: "Cours complet sur les bases de l’IA.",
          ),
          CourseCard(
            title: "Développement Mobile",
            description: "Apprends Flutter de A à Z.",
          ),
        ],
      ),
    );
  }
}
