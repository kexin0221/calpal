import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const CalPal());
}

class CalPal extends StatelessWidget {
  const CalPal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CalPal',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xffF5F5F7),
        fontFamily: 'SF Pro Display',
      ),
      home: const HomePage(),
    );
  }
}