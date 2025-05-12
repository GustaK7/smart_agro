import 'package:flutter/material.dart';
import 'pages/dashboard.dart'; // Corrigido o caminho do import

void main() {
  runApp(const SmartEstufaApp());
}

class SmartEstufaApp extends StatelessWidget {
  const SmartEstufaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Estufa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Dashboard(), // Atualizado para usar o widget Dashboard
      debugShowCheckedModeBanner: false,
    );
  }
}