import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/sale/sale_bloc.dart';
import 'package:hajedi/bloc/sale/sale_state.dart';
import 'package:hajedi/bloc/purchase/purchase_bloc.dart';
import 'package:hajedi/bloc/purchase/purchase_state.dart';
import 'package:hajedi/bloc/expense/expense_bloc.dart';
import 'package:hajedi/bloc/expense/expense_state.dart';
import 'package:hajedi/bloc/transaction/transaction_event.dart';
import 'package:hajedi/bloc/transaction/transaction_state.dart';
import 'package:hajedi/data/transaction.dart';
import 'package:hajedi/data/sale.dart';
import 'package:hajedi/data/purchase.dart';
import 'package:hajedi/data/expense.dart';
import 'package:hive/hive.dart';
import 'package:hajedi/data/customer.dart';
import 'package:hajedi/data/supplier.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final SaleBloc _saleBloc;
  final PurchaseBloc _purchaseBloc;
  final ExpenseBloc _expenseBloc;

  StreamSubscription? _saleSubscription;
  StreamSubscription? _purchaseSubscription;
  StreamSubscription? _expenseSubscription;

  TransactionBloc({
    required SaleBloc saleBloc,
    required PurchaseBloc purchaseBloc,
    required ExpenseBloc expenseBloc,
  })  : _saleBloc = saleBloc,
        _purchaseBloc = purchaseBloc,
        _expenseBloc = expenseBloc,
        super(TransactionsLoading()) {
    
    // Subscribe to existing bloc state changes
    _saleSubscription = _saleBloc.stream.listen((_) => add(LoadTransactions()));
    _purchaseSubscription = _purchaseBloc.stream.listen((_) => add(LoadTransactions()));
    _expenseSubscription = _expenseBloc.stream.listen((_) => add(LoadTransactions()));
    
    on<LoadTransactions>(_onLoadTransactions);
    on<FilterTransactions>(_onFilterTransactions);
    on<RefreshTransactions>(_onRefreshTransactions);
    
    add(LoadTransactions());
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      // Get current states from existing blocs
      final saleState = _saleBloc.state;
      final purchaseState = _purchaseBloc.state;
      final expenseState = _expenseBloc.state;

      List<Sale> sales = [];
      List<Purchase> purchases = [];
      List<Expense> expenses = [];

      if (saleState is SalesLoadedState) {
        sales = saleState.sales;
      }
      if (purchaseState is PurchasesLoadedState) {
        purchases = purchaseState.purchases;
      }
      if (expenseState is ExpensesLoadedState) {
        expenses = expenseState.expenses;
      }

      final allTransactions = _combineAndSortTransactions(
        sales,
        purchases,
        expenses,
      );

      // Get current filter if we have one
      TransactionFilter currentFilter = TransactionFilter.all;
      if (state is TransactionsLoaded) {
        currentFilter = (state as TransactionsLoaded).currentFilter;
      }

      final filteredTransactions = _filterTransactions(
        allTransactions,
        currentFilter,
      );

      emit(TransactionsLoaded(
        allTransactions: allTransactions,
        filteredTransactions: filteredTransactions,
        currentFilter: currentFilter,
      ));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onFilterTransactions(
    FilterTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      final filteredTransactions = _filterTransactions(
        currentState.allTransactions,
        event.filter,
      );

      emit(TransactionsLoaded(
        allTransactions: currentState.allTransactions,
        filteredTransactions: filteredTransactions,
        currentFilter: event.filter,
      ));
    }
  }

  Future<void> _onRefreshTransactions(
    RefreshTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    add(LoadTransactions());
  }

  List<Transaction> _combineAndSortTransactions(
    List<Sale> sales,
    List<Purchase> purchases,
    List<Expense> expenses,
  ) {
    final allTransactions = [
      ...sales.map(_saleToTransaction),
      ...purchases.map(_purchaseToTransaction),
      ...expenses.map(_expenseToTransaction),
    ];

    // Sort by createdAt descending (newest first)
    allTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return allTransactions;
  }

  List<Transaction> _filterTransactions(
    List<Transaction> transactions,
    TransactionFilter filter,
  ) {
    switch (filter) {
      case TransactionFilter.all:
        return transactions;
      case TransactionFilter.sales:
        return transactions.where((t) => t.type == TransactionType.sale).toList();
      case TransactionFilter.purchases:
        return transactions.where((t) => t.type == TransactionType.purchase).toList();
      case TransactionFilter.expenses:
        return transactions.where((t) => t.type == TransactionType.expense).toList();
    }
  }

  Transaction _saleToTransaction(Sale sale) {
   // Retrieve customer name from local Hive
   final customerBox = Hive.box<Customer>('customers');
   final customer = customerBox.get(sale.customerClientId);
   final customerName = customer?.name ?? "";
    

    return Transaction(
      clientId: sale.clientId,
      type: TransactionType.sale,
      createdAt: sale.createdAt,
      amount: sale.totalAmount,
      status: sale.syncStatus,
      rawData: sale.toJson(),
      userId: sale.userId,
      paymentMethod: sale.paymentMethod,
      customerName: customerName, // Would need to look up actual name
    );
  }

  Transaction _purchaseToTransaction(Purchase purchase) {
    
    final supplierBox = Hive.box<Supplier>('suppliers');
    final supplier = supplierBox.get(purchase.supplierClientId);
    final supplierName = supplier?.name ?? "";

    return Transaction(
      clientId: purchase.clientId,
      type: TransactionType.purchase,
      createdAt: purchase.createdAt,
      amount: purchase.totalCost,
      status: purchase.syncStatus,
      rawData: purchase.toJson(),
      userId: purchase.userId,
      paymentMethod: purchase.paymentMethod,
      supplierName: supplierName, // Would need to look up actual name
    );
  }

  Transaction _expenseToTransaction(Expense expense) {
    return Transaction(
      clientId: expense.clientId,
      type: TransactionType.expense,
      createdAt: expense.createdAt,
      amount: expense.amount,
      status: expense.syncStatus,
      rawData: expense.toJson(),
      userId: expense.userId,
      paymentMethod: expense.paymentMethod,
      description: expense.description,
      category: expense.category,
    );
  }

  @override
  Future<void> close() async {
    await _saleSubscription?.cancel();
    await _purchaseSubscription?.cancel();
    await _expenseSubscription?.cancel();
    return super.close();
  }
}