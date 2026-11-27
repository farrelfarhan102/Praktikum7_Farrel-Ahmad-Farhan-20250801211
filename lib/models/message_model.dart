import 'product_model.dart';

class Msg {
  final String text;
  final bool me;

  /// Bila diisi, pesan ini tampil sebagai kartu "tag produk" di percakapan.
  final Product? product;

  Msg(this.text, this.me, {this.product});
}
