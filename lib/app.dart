import 'package:flutter/material.dart';
import 'shared/widgets/app_shell.dart';

class BebiaApp extends StatelessWidget {
  const BebiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bebia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
      ),
      home: const AppShell(),
    );
  }
}