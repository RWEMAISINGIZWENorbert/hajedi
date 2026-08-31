import 'package:flutter/material.dart';
import 'package:hajedi/core/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      // themeMode: themeState.themeMode,
      themeMode: ThemeMode.dark,
      home: Scaffold(
        body: const Center(
          child: Text('HAJEDI CENTER'),
        ),
      ),
    );
  }
}