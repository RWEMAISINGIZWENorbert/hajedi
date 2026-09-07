import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/utils/auth_utils.dart';
import 'package:hajedi/widgets/dashboard/dashboard_card.dart';
import 'package:hajedi/widgets/dashboard/dashboard_header.dart';
import 'package:hajedi/widgets/dashboard/quick_actions_btn.dart';
import 'package:hajedi/widgets/text.dart';
import 'package:iconly/iconly.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;            
    return Builder(
      builder: (context) {
        return Scaffold(
          body: FutureBuilder(
            future: AuthUtils.readUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
        
              final userName = snapshot.data?.name ?? '';
        
              return SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 4,
                    left: 8,
                    right: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardHeader(
                        userName: userName,
                        isPopoverActive: false,
                        onAvatarTap: () {
                          Navigator.pushNamed(
                            context,
                            '/settings',
                          );
                        },
                      ),
                      const SizedBox(height: 12,),
                      SimpleText(label: loc.today),
                      DashboardCard(),
                      const SizedBox(height: 12),
                      SimpleText(label: "Actions"),
                      QuickActionsBtn()
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
    );
  }
}
