import 'package:hajedi/bloc/transaction/transaction_event.dart';
import 'package:hajedi/data/transaction.dart';

abstract class TransactionState {}

class TransactionsLoading extends TransactionState {}

class TransactionsLoaded extends TransactionState {
  final List<Transaction> allTransactions;
  final List<Transaction> filteredTransactions;
  final TransactionFilter currentFilter;

  TransactionsLoaded({
    required this.allTransactions,
    required this.filteredTransactions,
    required this.currentFilter,
  });
}

class ReportsLoading extends TransactionState {}

class ReportsLoaded extends TransactionState {
  final double totalSales;
  final double totalPurchases;
  final double totalExpenses;
  final DateTime startDate;
  final DateTime endDate;

  ReportsLoaded({
    required this.totalSales,
    required this.totalPurchases,
    required this.totalExpenses,
    required this.startDate,
    required this.endDate,
  });
}

class TransactionsError extends TransactionState {
  final String message;

  TransactionsError(this.message);
}