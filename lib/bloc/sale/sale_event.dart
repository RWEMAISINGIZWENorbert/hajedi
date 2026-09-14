
import 'package:hajedi/data/cart_item.dart';

abstract class SaleEvent {}

class LoadLocalSales extends SaleEvent {}

class CreateSaleLocal extends SaleEvent {
  final List<CartItem> cartItems;
  final String? customerClientId;
  final String paymentMethod;

  CreateSaleLocal({
    required this.cartItems,
    this.customerClientId,
    required this.paymentMethod,
  });
}

class RetrySaleSync extends SaleEvent {
  final String clientId;

  RetrySaleSync(this.clientId);
}