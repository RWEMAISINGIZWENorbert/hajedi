import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/cart/cart_bloc.dart';
import 'package:hajedi/bloc/cart/cart_event.dart';
import 'package:hajedi/bloc/cart/cart_state.dart';
import 'package:hajedi/bloc/sale/sale_bloc.dart';
import 'package:hajedi/bloc/sale/sale_event.dart';
import 'package:hajedi/data/cart_item.dart';
import 'package:hajedi/widgets/primary_button.dart';
import 'package:iconly/iconly.dart';

Future<dynamic> showSellCartBottomSheet(
  BuildContext context,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Container(
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sell Cart',
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

              // Cart Items List
              BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  if (state is CartLoadedState) {
                    if (state.items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text('Cart is empty'),
                        ),
                      );
                    }

                    return Column(
                      children: state.items.map((item) {
                        return _CartItemRow(
                          item: item,
                          onRemove: () {
                            context.read<CartBloc>().add(
                              RemoveFromCart(item.productClientId),
                            );
                          },
                          onIncrease: () {
                            context.read<CartBloc>().add(
                              UpdateCartQuantity(
                                item.productClientId,
                                item.quantity + 1,
                              ),
                            );
                          },
                          onDecrease: () {
                            context.read<CartBloc>().add(
                              UpdateCartQuantity(
                                item.productClientId,
                                item.quantity - 1,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Save Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    if (state is CartLoadedState) {
                      return PrimaryButton(
                        label: 'Save',
                        // onPressed: (){}
                        onPressed:
                        //  state.items.isEmpty
                        //     ? null
                        //     :
                             () {
                              context.read<SaleBloc>().add(
                                CreateSaleLocal(
                                  cartItems: state.items,
                                  customerClientId: null, // Add customer ID if you have customer selection
                                  paymentMethod: 'cash', // or your preferred payment method
                               ),
                              );
                              context.read<CartBloc>().add(ClearCart());
                              Navigator.of(context).pop();
                           },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CartItemRow extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _CartItemRow({
    required this.item,
    required this.onRemove,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Product Name and Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.unitPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),

          // Quantity Controls
          Row(
            children: [
              IconButton(
                onPressed: onDecrease,
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Text(
                '${item.quantity}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onIncrease,
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Remove Button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
            iconSize: 20,
            color: Colors.red,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}