import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(IconlyLight.setting),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/settings',
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Dashboard'),
      ),
    );
  }
}