import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/address_model.dart';
import '../models/message_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class AppState extends ChangeNotifier {
  final cart = <Product>[], orders = <Order>[];
  // data pribadi pengguna (dihapus saat keluar akun)
  final addresses = <Address>[];
  int mainAddr = 0;
  String payPref = 'GoPay';
  final linked = <String>{'GoPay', 'OVO', 'DANA'};
  bool notifOrder = true, notifPromo = true;
  // poin, voucher & wishlist
  int points = 0, earned = 0;
  final wishlist = <String>{}, myVouchers = <String, int>{}, usedCodes = <String>{};

  String get tier => earned >= 500
      ? 'VIP Member'
      : earned >= 200
          ? 'Gold Member'
          : 'Regular Member';

  List<String> get activeVouchers =>
      myVouchers.keys.where((k) => !usedCodes.contains(k)).toList();

  int? voucherValue(String k) =>
      usedCodes.contains(k) ? null : (myVouchers[k] ?? promoCodes[k]);

  String? redeem(int cost, int value) {
    if (points < cost) return null;
    final code = 'POIN${DateTime.now().microsecondsSinceEpoch % 900000 + 100000}';
    update(() {
      points -= cost;
      myVouchers[code] = value;
    });
    return code;
  }

  Address? get mainAddress => addresses.isEmpty
      ? null
      : addresses[mainAddr.clamp(0, addresses.length - 1)];

  void resetPersonal() => update(() {
        addresses.clear();
        mainAddr = 0;
        payPref = 'GoPay';
        linked
          ..clear()
          ..addAll({'GoPay', 'OVO', 'DANA'});
        notifOrder = notifPromo = true;
        points = earned = 0;
        wishlist.clear();
        myVouchers.clear();
        usedCodes.clear();
      });

  final chats = <String, List<Msg>>{
    'Penjual': [
      Msg('Halo! Selamat datang di Swanvacation. Ada yang bisa kami bantu?', false),
    ],
    'Admin': [Msg('Halo, ini Admin. Ada kendala pembayaran?', false)],
  };

  int escrow = 0, refunded = 0, paidSeller = 0;

  int get cartTotal => cart.fold(0, (s, p) => s + p.price);

  void add(Product p) => update(() => cart.add(p));

  void update(VoidCallback f) {
    f();
    notifyListeners();
  }
}

final app = AppState();
final tab = ValueNotifier<int>(0);

Map<String, List<Product>> groupBy(Iterable<Product> l) {
  final g = <String, List<Product>>{};
  for (final p in l) {
    (g[p.id] ??= []).add(p);
  }
  return g;
}
