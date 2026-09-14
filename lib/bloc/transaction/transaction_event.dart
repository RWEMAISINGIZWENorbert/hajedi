enum TransactionFilter { all, sales, purchases, expenses }

abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {}

class FilterTransactions extends TransactionEvent {
  final TransactionFilter filter;

  FilterTransactions(this.filter);
}

class RefreshTransactions extends TransactionEvent {}