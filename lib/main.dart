import 'package:flutter/material.dart';

void main() {
  runApp(const EduMasterApp());
}

class EduMasterApp extends StatelessWidget {
  const EduMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduMaster IA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EduMaster IA"),
      ),
      body: const Center(
        child: Text(
          "Bienvenue dans EduMaster IA !",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
