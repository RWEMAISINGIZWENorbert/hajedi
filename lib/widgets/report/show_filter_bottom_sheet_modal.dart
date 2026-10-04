import 'package:flutter/material.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/primary_button.dart';
import 'package:hajedi/widgets/report/date_range_picker.dart';
import 'package:hajedi/widgets/text.dart';
import 'package:hajedi/widgets/report/date_period_selector.dart';
import 'package:iconly/iconly.dart';

Future<dynamic> showFilterBottomSheetModal(
  BuildContext context,
  AppLocalizations loc,
  {String? selectedPeriod}
) {
  String? currentSelection = selectedPeriod;

  DateTime? startTime;
  DateTime? endTime;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          color: Theme.of(context).cardColor,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.filter,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(IconlyLight.close_square),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SimpleText(label: loc.date_range),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      DatePeriodSelector(
                        label: loc.today,
                        isSelected: currentSelection == 'today',
                        onTap: () {
                          setState(() {
                            currentSelection = 'today';
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      DatePeriodSelector(
                        label: loc.yesterday,
                        isSelected: currentSelection == 'yesterday',
                        onTap: () {
                          setState(() {
                            currentSelection = 'yesterday';
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      DatePeriodSelector(
                        label: loc.this_week,
                        isSelected: currentSelection == 'thisWeek',
                        onTap: () {
                          setState(() {
                            currentSelection = 'thisWeek';
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      DatePeriodSelector(
                        label: loc.this_month,
                        isSelected: currentSelection == 'thisMonth',
                        onTap: () {
                          setState(() {
                            currentSelection = 'thisMonth';
                          });
                         
                        },
                      ),
                      const SizedBox(height: 8),
                      DatePeriodSelector(
                        label: loc.this_year,
                        isSelected: currentSelection == 'thisYear',
                        onTap: () {
                          setState(() {
                            currentSelection = 'thisYear';
                          });                        
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SimpleText(label: "Custom Dates"),
                ),
                DateRangePicker(
                  startDate: startTime,
                  endDate: endTime,
                  onStartDateChanged: (val) => setState(() => startTime = val),
                  onEndDateChanged:(val) => setState(() => endTime = val),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: loc.apply,
                  onPressed: () {
                    // Navigator.pop(context, {
                    //   'period': currentSelection,
                    //   'startDate': startTime,
                    //   'endDate': endTime,
                    // });
                  },
                ),
                const SizedBox(height: 16),
               ],
            ),
          ),
        ),
      ),
    ),
  );
}