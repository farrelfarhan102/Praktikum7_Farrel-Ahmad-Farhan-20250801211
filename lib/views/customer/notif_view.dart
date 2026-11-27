import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme.dart';
import '../../models/notification_model.dart';
import '../widgets/common_widgets.dart';
import 'chat_view.dart';
import 'orders_view.dart';

class NotifPage extends StatefulWidget {
  const NotifPage({super.key});
  @override
  State<NotifPage> createState() => _NotifState();
}

class _NotifState extends State<NotifPage> {
  String f = 'Semua';
  final ns = [
    Nt(
      'Pembayaran Berhasil',
      'Sandal pilihanmu sedang disiapkan oleh toko! No. Pesanan #SL-88921. Cek detail pesanan kamu sekarang.',
      '5 menit lalu',
      'Transaksi',
      Icons.check_circle,
      tag: 'Baru',
      act: 'Detail Pesanan',
      unread: true,
    ),
    Nt(
      'Pesanan Sedang Dikirim',
      'Paket berisi Cloud Marshmallow Slide sudah diserahkan ke kurir J&T Express. Lacak pengiriman di sini.',
      '2 jam lalu',
      'Transaksi',
      Icons.local_shipping,
      act: 'Lacak Resi',
      unread: true,
    ),
    Nt(
      'Promo Spesial Gajian',
      'Dapatkan diskon hingga 30% untuk koleksi Clogs & Jibbitz accessories weekend ini.',
      '1 hari lalu',
      'Promo',
      Icons.card_giftcard,
      tag: 'Diskon 30%',
      act: 'Klaim Voucher',
    ),
    Nt(
      'Ulasan Produk',
      'Bagikan ulasanmu untuk Strappy Sunset Flat dan dapatkan 50 poin loyalty!',
      '3 hari lalu',
      'Promo',
      Icons.rate_review,
      tag: '+50 Poin',
      act: 'Tulis Ulasan',
    ),
  ];

  void run(Nt n) {
    setState(() => n.unread = false);
    if (n.act == 'Klaim Voucher') {
      toast(context, 'Voucher berhasil diklaim');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OrdersPage()),
      );
    }
  }

  Widget tile(Nt n) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.all(14),
          decoration: card().copyWith(
            color: n.unread ? yel : Colors.white,
            border: Border.all(color: n.unread ? gold : Colors.transparent),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: n.unread ? Colors.white : lav,
                child: Icon(n.ic, color: n.unread ? Colors.brown : pink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.t,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (n.tag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: n.tag == 'Baru' ? pink : gold,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              n.tag!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: n.tag == 'Baru'
                                    ? Colors.white
                                    : Colors.brown,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.b,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 13,
                          color: Colors.black45,
                        ),
                        Text(
                          ' ${n.time}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                        const Spacer(),
                        if (n.act != null)
                          sbtn(
                            n.act!,
                            () => run(n),
                            dark: n.unread && n.tag == 'Baru',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext c) => ListenableBuilder(
        listenable: app,
        builder: (_, _) {
          final l = ns
              .where(
                (n) =>
                    (f == 'Semua' || n.cat == f) &&
                    (app.notifPromo || n.cat != 'Promo') &&
                    (app.notifOrder || n.cat != 'Transaksi'),
              )
              .toList();
          final nu = l.where((n) => n.unread).toList(),
              old = l.where((n) => !n.unread).toList();
          final cnt = ns.where((n) => n.unread).length;
          return Scaffold(
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: soft,
                        child: Icon(Icons.storefront, color: pink),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, ${Auth.name}!',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: pink,
                              ),
                            ),
                            Text(
                              '$cnt pesan baru menunggumu',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Bouncy(
                        onTap: () => tab.value = 2,
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: pink,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifikasi',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Bouncy(
                        onTap: () => setState(() {
                          for (final n in ns) {
                            n.unread = false;
                          }
                        }),
                        child: const Row(
                          children: [
                            Icon(Icons.done_all, color: pink, size: 16),
                            Text(
                              ' Tandai Semua Dibaca',
                              style: TextStyle(
                                color: pink,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final k in ['Semua', 'Transaksi', 'Promo'])
                        pill(
                          k == 'Semua' ? 'Semua ($cnt)' : k,
                          sel: f == k,
                          onTap: () => setState(() => f = k),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  for (final n in nu) tile(n),
                  if (old.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Terdahulu',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  for (final n in old) tile(n),
                  Bouncy(
                    onTap: () => Navigator.push(
                      c,
                      MaterialPageRoute(builder: (_) => const ChatPage()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [soft, lav]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: pink,
                            child: Icon(Icons.auto_awesome, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pusat Bantuan & Pesanan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Kendala pengiriman sandal Anda? Kami siap bantu 24/7',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.headset_mic, color: pink),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
