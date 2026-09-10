import 'package:flutter/material.dart';

void main() => runApp(const CarApp());

class CarApp extends StatelessWidget {
  const CarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FPV RC Car',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Car App scaffold\nCamera and WebRTC begin in Phase 3.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
