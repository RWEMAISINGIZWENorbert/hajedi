import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/product/product_bloc.dart';
import 'package:hajedi/data/product.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/screens/product/edit_product.dart';
import 'package:hajedi/widgets/animated_snackbar.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/widgets/confirmation_dialog.dart';
import 'package:iconly/iconly.dart';

class ProductDetails extends StatelessWidget {
  final Product product;

  const ProductDetails({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        Product currentProduct = product;

        if (state is ProductsLoadedSuccessfully) {
          for (final item in state.products) {
            if (item.clientId == product.clientId) {
              currentProduct = item;
              break;
            }
          }
        } else if (state is ProductsUpdatedSuccessfully &&
            state.product.clientId == product.clientId) {
          currentProduct = state.product;
        }

        return _buildDetailsScreen(
          context,
          currentProduct,
        );
      },
    );
  }

  Widget _buildDetailsScreen(
    BuildContext context,
    Product product,
  ) {
    final showPurchaseCost =
        product.purchaseMethod == 'packet' ||
        product.purchaseMethod == 'crate';

    return Scaffold(
      appBar: AppBarComponent(
        icon: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            IconlyLight.arrow_left_circle,
          ),
        ),
        title: product.name,
      ),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductsDeletedSuccessfully) {
            showAnimatedSnackBar(
              context,
              state.message,
            );

            Navigator.pop(context);
          }

          if (state is ProductDeleteFailure) {
            showAnimatedSnackBar(
              context,
              state.message,
              isSuccess: false,
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProductSummary(product: product),
                    const SizedBox(height: 28),
                    _ProductInformation(
                      product: product,
                      showPurchaseCost: showPurchaseCost,
                    ),
                    const SizedBox(height: 30),
                    const _TransactionsSection(),
                  ],
                ),
              ),
            ),
            _ProductActions(product: product),
          ],
        ),
      ),
    );
  }
}

class _ProductSummary extends StatelessWidget {
  final Product product;

  const _ProductSummary({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.quantityInStock <= 5;
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            product.name.isEmpty
                ? '?'
                : product.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          product.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          product.productType,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${product.quantityInStock} ${product.saleMethod} ${loc.in_stock}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (isLowStock)
              const Text(
                'Low stock',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ProductInformation extends StatelessWidget {
  final Product product;
  final bool showPurchaseCost;

  const _ProductInformation({
    required this.product,
    required this.showPurchaseCost,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoItem(
                label: 'Purchase method',
                value: product.purchaseMethod,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _InfoItem(
                label: 'Sale method',
                value: product.saleMethod,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            if (showPurchaseCost)
              Expanded(
                child: _InfoItem(
                  label:
                      'Purchase cost / 1 ${product.purchaseMethod}',
                  value: '${product.purchaseCost} RWF',
                ),
              ),

            if (showPurchaseCost) const SizedBox(width: 24),

            Expanded(
              child: _InfoItem(
                label:
                    'Selling price / 1 ${product.saleMethod}',
                value: '${product.sellingPrice} RWF',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _InfoItem(
          label: 'Units per package',
          value: product.unitsPerPackage.toString(),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ],
      ),
    );
  }
}

class _TransactionsSection extends StatelessWidget {
  const _TransactionsSection();

  @override
  Widget build(BuildContext context) {
    // Sales and purchases will share this single list.
    // Their icons will differentiate the transaction type.
    const transactions = <_TransactionPreview>[];
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.transactions,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: Text('No transactions yet'),
            ),
          )
        else
          ...transactions.map(
            (transaction) => ListTile(
              leading: Icon(
                transaction.type == TransactionType.sale
                    ? Icons.trending_down
                    : Icons.trending_up,
                color: transaction.type == TransactionType.sale
                    ? Colors.red
                    : Colors.green,
              ),
              title: Text(transaction.title),
              subtitle: Text(transaction.date),
              trailing: Text(transaction.amount),
            ),
          ),
      ],
    );
  }
}

enum TransactionType {
  sale,
  purchase,
}

class _TransactionPreview {
  final TransactionType type;
  final String title;
  final String date;
  final String amount;

  const _TransactionPreview({
    required this.type,
    required this.title,
    required this.date,
    required this.amount,
  });
}

class _ProductActions extends StatelessWidget {
  final Product product;

  const _ProductActions({
    required this.product,
  });

  Future<void> _confirmDelete(BuildContext context) async {
  await showConfirmationDialog(
    context,
    title: 'Remove product',
    content:
        'Are you sure you want to remove ${product.name}? Once removed, it cannot be easily recovered.',
    onConfirm: () {
      // Close the confirmation dialog first.
      Navigator.of(context).pop();

      context.read<ProductBloc>().add(
            DeleteLocalProduct(
              clientId: product.clientId,
            ),
          );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProduct(
                    product: product,
                    ),
                  ),
                );
              },
                icon: const Icon(Icons.edit_outlined),
                label: Text(loc.edit),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline),
                label: Text(loc.delete),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}