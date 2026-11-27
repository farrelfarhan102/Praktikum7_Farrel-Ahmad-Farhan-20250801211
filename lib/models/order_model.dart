import 'product_model.dart';

class Order {
  final String id, method;
  final List<Product> items;
  final int total;
  String status = 'Menunggu Pembayaran';
  int rating = 0;
  String? proof, complaint, payProof, resi, courier;
  Order(this.id, this.items, this.total, this.method);

  /// Tahapan yang ditampilkan pada pelacak status pengiriman.
  static const shipSteps = ['Dikemas', 'Dikirim', 'Diterima'];

  /// Posisi pesanan pada [shipSteps]; -1 bila belum masuk tahap pengiriman
  /// (belum dibayar, menunggu verifikasi, atau dibatalkan).
  int get shipStep {
    switch (status) {
      case 'Dikemas':
        return 0;
      case 'Dikirim':
        return 1;
      case 'Diterima':
      case 'Selesai':
      case 'Komplain':
      case 'Refund':
        return 2;
      default:
        return -1;
    }
  }
}
