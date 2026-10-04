import 'package:flutter/material.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/widgets/report/show_filter_bottom_sheet_modal.dart';
import 'package:iconly/iconly.dart';

class Reports extends StatelessWidget {
  const Reports({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBarComponent(
        title: loc.reports,
        actions: [
          InkWell(
            onTap: () {
               showFilterBottomSheetModal(context, loc);
            },
            child: Icon(IconlyLight.filter),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: Text(loc.reports),
      ),
    );
  }
}