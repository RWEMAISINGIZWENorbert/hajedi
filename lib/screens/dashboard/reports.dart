import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/transaction/transaction_bloc.dart';
import 'package:hajedi/bloc/transaction/transaction_event.dart';
import 'package:hajedi/bloc/transaction/transaction_state.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/widgets/loading.dart';
import 'package:hajedi/widgets/report/report_card.dart';
import 'package:hajedi/widgets/report/show_filter_bottom_sheet_modal.dart';
import 'package:iconly/iconly.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  String? selectedPeriod;

  @override
  void initState() {
    super.initState();
    // Load reports for today on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionBloc>().add(LoadReports(period: ReportPeriod.today));
      setState(() {
        selectedPeriod = 'today';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBarComponent(
        title: loc.reports,
        actions: [
          InkWell(
            onTap: () {
              showFilterBottomSheetModal(
                context,
                loc,
                selectedPeriod: selectedPeriod,
              );
            },
            child: const Icon(IconlyLight.filter),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ReportsLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: [
                ReportCard(
                  name: loc.sales,
                  totalAmount: state.totalSales,
                ),
                const SizedBox(height: 16),
                ReportCard(
                  name: loc.purchases,
                  totalAmount: state.totalPurchases,
                ),
                const SizedBox(height: 16),
                ReportCard(
                  name: loc.expenses,
                  totalAmount: state.totalExpenses,
                ),
                const SizedBox(height: 16),
                ReportCard(
                  name: loc.credits,
                  totalAmount: state.totalCredits,
                ),
                const SizedBox(height: 16),
                ReportCard(
                  name: loc.payedCredits,
                  totalAmount: state.collectedCredits,
                ),
              ],
            );
          }

          if (state is TransactionsError) {
            return Center(
              child: Text(state.message),
            );
          }

          return const Center(
            child: Loading(),
          );
        },
      ),
    );
  }
}