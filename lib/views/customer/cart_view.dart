import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/product_model.dart';
import '../widgets/common_widgets.dart';
import 'checkout_view.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartState();
}

class _CartState extends State<CartPage> {
  final off = <String>{};
  final code = TextEditingController();
  String? v;
  static const free = 900000;

  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  Widget stepper(Product p, int n) => Container(
        decoration: BoxDecoration(
          color: lav,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Bouncy(
              onTap: () => app.update(() => app.cart.remove(p)),
              child: const Icon(Icons.remove, size: 18, color: pink),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '$n',
                  key: ValueKey(n),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Bouncy(
              onTap: () => app.add(p),
              child: const Icon(Icons.add, size: 18, color: pink),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext c) => ListenableBuilder(
        listenable: app,
        builder: (_, _) {
          final g = groupBy(app.cart);
          // Bersihkan ID item yang sudah tidak ada di keranjang agar status Pilih Semua tetap akurat
          off.removeWhere((id) => !g.containsKey(id));
          final on = g.values.where((l) => !off.contains(l.first.id)).toList();
          final sub = on.fold<int>(0, (s, l) => s + l.first.price * l.length);
          final disc = v != null && sub > 0
              ? (app.voucherValue(v!) ?? 0).clamp(0, sub).toInt()
              : 0;
          final ship = sub == 0 || sub >= free ? 0 : 10000;
          final total = sub - disc + ship;
          final prog = (sub / free).clamp(0.0, 1.0).toDouble();
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              toolbarHeight: 64,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keranjang Belanja (${app.cart.length} Item)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const Text(
                    'Pilih item untuk checkout sekarang',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              actions: [
                Bouncy(
                  onTap: () => app.update(() {
                    app.cart.clear();
                    off.clear();
                  }),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.delete_outline),
                  ),
                ),
              ],
            ),
            body: g.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 48,
                          color: Colors.black26,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Keranjang belanja masih kosong',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: lav,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: off.isEmpty,
                              activeColor: pink,
                              onChanged: (x) => setState(() {
                                off.clear();
                                if (x == false) off.addAll(g.keys);
                              }),
                            ),
                            Text('Pilih Semua (${g.length})'),
                            const Spacer(),
                            Bouncy(
                              onTap: () => app.update(
                                () => app.cart
                                    .removeWhere((p) => !off.contains(p.id)),
                              ),
                              child: const Text(
                                'Hapus yang Selesai',
                                style: TextStyle(
                                  color: pink,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      box(
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: soft,
                              child: Icon(Icons.local_shipping, color: pink),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'PROMO ONGKIR',
                                        style: TextStyle(
                                          color: pink,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${(prog * 100).round()}%',
                                        style: const TextStyle(
                                          color: pink,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    sub >= free
                                        ? 'Selamat! Kamu mendapat Bebas Ongkir'
                                        : 'Tambah ${rp(free - sub)} lagi untuk Bebas Ongkir Se-Indonesia!',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 6),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(end: prog),
                                    duration: const Duration(milliseconds: 600),
                                    builder: (_, x, _) => ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: x,
                                        minHeight: 8,
                                        color: pink,
                                        backgroundColor: lav,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (var i = 0; i < g.length; i++)
                        pop(i, () {
                          final l = g.values.elementAt(i), p = l.first;
                          return box(
                            child: Row(
                              children: [
                                Checkbox(
                                  value: !off.contains(p.id),
                                  activeColor: pink,
                                  onChanged: (x) => setState(
                                    () => x == true
                                        ? off.remove(p.id)
                                        : off.add(p.id),
                                  ),
                                ),
                                ph(p, h: 80, w: 80),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              p.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Bouncy(
                                            onTap: () => app.update(() {
                                              app.cart.removeWhere(
                                                (q) => q.id == p.id,
                                              );
                                              off.remove(p.id);
                                            }),
                                            child: const Icon(
                                              Icons.close,
                                              size: 18,
                                              color: Colors.black38,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: lav,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          opt[p.id] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            rp(p.price),
                                            style: const TextStyle(
                                              color: pink,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const Spacer(),
                                          stepper(p, l.length),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }()),
                      box(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.confirmation_number,
                                  color: pink,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Voucher & Kupon Diskon',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Spacer(),
                                Text(
                                  'Lihat Semua',
                                  style: TextStyle(
                                    color: pink,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: field(
                                    code,
                                    hint: 'Masukkan kode promo...',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                sbtn('Gunakan', () {
                                  final k = code.text.trim().toUpperCase();
                                  if (app.voucherValue(k) != null) {
                                    setState(() => v = k);
                                  } else {
                                    toast(
                                      c,
                                      app.usedCodes.contains(k)
                                          ? 'Kode promo sudah pernah dipakai'
                                          : 'Kode promo tidak valid',
                                    );
                                  }
                                }),
                              ],
                            ),
                            if (app.activeVouchers.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final k in app.activeVouchers)
                                      sbtn(
                                        '$k • -${rp(app.myVouchers[k]!)}',
                                        () => setState(() => v = k),
                                      ),
                                  ],
                                ),
                              ),
                            if (v != null)
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: soft,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: pink,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$v (-${rp(disc)})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    Bouncy(
                                      onTap: () => setState(() => v = null),
                                      child: const Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      box(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ringkasan Pesanan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            srow('Subtotal Produk', rp(sub)),
                            srow('Diskon Voucher', '-${rp(disc)}', c: pink),
                            srow(
                              'Estimasi Ongkir',
                              ship == 0 ? 'Gratis' : rp(ship),
                            ),
                            const Divider(),
                            srow('Total Pembayaran', rp(total), big: true),
                          ],
                        ),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user,
                            size: 14,
                            color: Colors.black45,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Garansi 100% Produk Asli & Pembayaran Aman',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
            bottomNavigationBar: g.isEmpty
                ? null
                : Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 12),
                      ],
                    ),
                    child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Harga:',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              rp(total),
                              style: const TextStyle(
                                color: pink,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (disc > 0)
                              Text(
                                'Hemat ${rp(disc)}',
                                style: const TextStyle(
                                  color: pink,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: PButton(
                            'Lanjut ke Pembayaran',
                            () {
                              if (on.isEmpty) {
                                toast(c, 'Pilih minimal 1 item');
                                return false;
                              }
                              Navigator.push(
                                c,
                                MaterialPageRoute(
                                  builder: (_) => Checkout(
                                    [for (final l in on) ...l],
                                    disc,
                                    ship,
                                    voucher: v,
                                  ),
                                ),
                              );
                            },
                            icon: Icons.arrow_forward,
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      );
}
