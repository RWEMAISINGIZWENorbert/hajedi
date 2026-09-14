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

class TransactionsError extends TransactionState {
  final String message;

  TransactionsError(this.message);
}