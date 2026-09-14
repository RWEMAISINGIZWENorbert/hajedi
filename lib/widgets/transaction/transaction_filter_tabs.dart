import 'package:flutter/material.dart';
import 'package:hajedi/bloc/transaction/transaction_event.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:iconly/iconly.dart';

class TransactionFilterTabs extends StatelessWidget {
  final TransactionFilter currentFilter;
  final Function(TransactionFilter) onFilterChanged;

  const TransactionFilterTabs({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            TransactionFilter.all,
            IconlyLight.category,
            loc.all_transactions,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            TransactionFilter.sales,
            IconlyLight.buy,
            loc.sales,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            TransactionFilter.purchases,
            Icons.shopping_cart,
            loc.purchases,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            TransactionFilter.expenses,
            IconlyLight.wallet,
            loc.expenses,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    TransactionFilter filter,
    IconData icon,
    String label,
  ) {
    final isSelected = currentFilter == filter;
    
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        if (selected) {
          onFilterChanged(filter);
        }
      },
      selectedColor: _getFilterColor(filter).withOpacity(0.2),
      checkmarkColor: _getFilterColor(filter),
      labelStyle: TextStyle(
        color: isSelected ? _getFilterColor(filter) : Colors.grey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? _getFilterColor(filter) : Colors.grey,
      ),
    );
  }

  Color _getFilterColor(TransactionFilter filter) {
    switch (filter) {
      case TransactionFilter.all:
        return Colors.blue;
      case TransactionFilter.sales:
        return Colors.green;
      case TransactionFilter.purchases:
        return Colors.blue;
      case TransactionFilter.expenses:
        return Colors.orange;
    }
  }
}