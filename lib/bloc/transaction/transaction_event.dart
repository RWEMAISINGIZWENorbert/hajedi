enum TransactionFilter { all, sales, purchases, expenses }

enum ReportPeriod {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  thisYear,
}

abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {}

class FilterTransactions extends TransactionEvent {
  final TransactionFilter filter;

  FilterTransactions(this.filter);
}

class RefreshTransactions extends TransactionEvent {}

class LoadReports extends TransactionEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final ReportPeriod? period;
 
  LoadReports({
    this.startDate,
    this.endDate,
    this.period,
  });
}
