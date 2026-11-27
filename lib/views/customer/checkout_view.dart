import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/address_model.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../profile/address_view.dart';
import '../widgets/common_widgets.dart';
import 'payment_view.dart';
import 'voucher_view.dart';

class Checkout extends StatefulWidget {
  final List<Product> items;
  final int disc, ship;
  final String? voucher;
  const Checkout(this.items, this.disc, this.ship, {this.voucher, super.key});
  @override
  State<Checkout> createState() => _CoState();
}

class _CoState extends State<Checkout> {
  String m = app.payPref;
  late String addr = app.mainAddress?.text ?? '';
  late String who = app.mainAddress == null
      ? ''
      : '${app.mainAddress!.name}   |   ${app.mainAddress!.phone}';
  late String tag = app.mainAddress?.label ?? 'Rumah';
  late final sub = widget.items.fold<int>(0, (s, p) => s + p.price);
  late final total = sub - widget.disc + widget.ship;

  bool pay() {
    if (addr.isEmpty) {
      toast(context, 'Tambahkan alamat pengiriman dulu', secs: 2);
      return false;
    }
    final o = Order(
      'SL-${DateTime.now().millisecondsSinceEpoch % 100000}',
      widget.items,
      total,
      m,
    );
    app.update(() {
      app.orders.insert(0, o);
      if (widget.voucher != null) app.usedCodes.add(widget.voucher!);
      for (final p in widget.items) {
        app.cart.remove(p);
      }
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PaymentPage(o)),
    );
    return true;
  }

  Future<void> editAddr() async {
    final a = await Navigator.push<Address>(
      context,
      MaterialPageRoute(builder: (_) => const AddressPage(pick: true)),
    );
    if (!mounted) return;
    final target = a ?? (addr.isEmpty ? app.mainAddress : null);
    if (target == null) return;
    setState(() {
      addr = target.text;
      who = '${target.name}   |   ${target.phone}';
      tag = target.label;
    });
  }

  @override
  Widget build(BuildContext c) {
    final g = groupBy(widget.items);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Pembayaran / Checkout',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: pink,
            fontSize: 18,
          ),
        ),
        actions: [
          Center(
            child: Countdown(900, () {
              if (!mounted) return;
              toast(context, 'Waktu checkout telah habis');
              Navigator.pop(context);
            }),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: yel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: gold),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified, color: Colors.brown),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Garansi Produk 100% Original & Pengiriman Berasuransi',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Icon(Icons.lock, size: 16, color: pink),
                Text(
                  ' Aman',
                  style: TextStyle(
                    color: pink,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: pink),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Alamat Pengiriman (Utama)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    sbtn('Ubah Alamat', editAddr),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: lav,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (addr.isEmpty)
                        const Text(
                          'Belum ada alamat. Ketuk "Ubah Alamat" untuk menambah alamat pengiriman.',
                          style: TextStyle(color: Colors.red),
                        )
                      else ...[
                        Text(
                          who,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(addr, style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.home_outlined,
                              size: 14,
                              color: pink,
                            ),
                            Text(
                              ' $tag',
                              style: const TextStyle(
                                color: pink,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ringkasan Pesanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${widget.items.length} Barang',
                      style: const TextStyle(
                        color: pink,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final l in g.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        ph(l.first, h: 60, w: 60),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.first.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${(opt[l.first.id] ?? '').replaceAll('Ukuran: ', '').replaceAll('Warna: ', '')} • x${l.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                rp(l.first.price * l.length),
                                style: const TextStyle(
                                  color: pink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: lav,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: soft,
                        child: Icon(
                          Icons.local_shipping,
                          size: 16,
                          color: pink,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pengiriman Reguler (2–3 hari)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Estimasi tiba 14–15 Nov',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.ship == 0 ? 'Gratis' : rp(widget.ship),
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                const Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: pink),
                    SizedBox(width: 6),
                    Text(
                      'Pilih Metode Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final k in payIcons.keys)
                  Bouncy(
                    onTap: () => setState(() => m = k),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: m == k ? soft : Colors.white,
                        border: Border.all(
                          color: m == k ? pink : Colors.black12,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: payColors[k]!.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(payIcons[k], color: payColors[k]),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      k == 'Transfer ke Admin'
                                          ? 'Transfer Bank'
                                          : k,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (app.linked.contains(k)) ...[
                                      const SizedBox(width: 6),
                                      sbtn('Aktif', () {}),
                                    ],
                                  ],
                                ),
                                Text(
                                  wallets.containsKey(k)
                                      ? 'Bayar lewat aplikasi $k'
                                      : (k == 'QRIS'
                                          ? 'Pindai QR langsung'
                                          : 'Transfer ke rekening Admin'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: m == k
                                ? const Icon(
                                    Icons.check_circle,
                                    color: pink,
                                    key: ValueKey(1),
                                  )
                                : const Icon(
                                    Icons.chevron_right,
                                    key: ValueKey(0),
                                    color: Colors.black38,
                                  ),
                          ),
                        ],
                      ),
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
                  'Ringkasan Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const Divider(),
                srow('Subtotal Produk', rp(sub)),
                srow('Diskon Voucher', '-${rp(widget.disc)}', c: pink),
                srow(
                  'Ongkos Kirim',
                  widget.ship == 0 ? 'Gratis' : rp(widget.ship),
                ),
                const Divider(),
                srow('Total Pembayaran', rp(total), big: true),
                const Text(
                  'Termasuk PPN & Biaya Layanan',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, size: 15, color: pink),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Dana masuk ke rekening Admin (escrow) dan baru diteruskan ke seller setelah pesanan kamu terima.',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          box(
            c: soft,
            child: Row(
              children: [
                const Icon(Icons.confirmation_number, color: pink),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Punya kode promo sandal?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Gunakan voucher ekstra diskon',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                sbtn('Klaim', () => open(c, const VoucherPage())),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Tagihan',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    Text(
                      rp(total),
                      style: const TextStyle(
                        color: pink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Metode: $m',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            PButton('Bayar Sekarang – ${rp(total)}', pay, icon: Icons.lock),
          ],
        ),
      ),
    );
  }
}
