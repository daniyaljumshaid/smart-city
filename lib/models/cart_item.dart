import 'package:classicon_vs_code/models/product.dart';

class CardItem {
  final Product product;
  int quantity;
  CardItem({required this.product, this.quantity=1});
  double get subtotal => product.price * quantity;
}
