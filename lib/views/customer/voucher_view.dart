import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/app_controller.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../widgets/common_widgets.dart';

class VoucherPage extends StatelessWidget {
  const VoucherPage({super.key});
  static const rewards = [(100, 10000), (200, 25000), (400, 60000)];

  Widget _code(BuildContext c, String k, int v) {
    final used = app.usedCodes.contains(k);
    return box(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: used ? Colors.black12 : soft,
            child: Icon(
              Icons.confirmation_number,
              color: used ? Colors.black38 : pink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  used
                      ? 'Sudah dipakai'
                      : 'Diskon ${rp(v)} • sekali pakai',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          if (!used)
            sbtn('Salin', () {
              Clipboard.setData(ClipboardData(text: k));
              toast(c, 'Kode $k disalin. Tempel di keranjang.');
            }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: subBar('Voucher & Poin'),
        body: ListenableBuilder(
          listenable: app,
          builder: (_, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [pink, pink2]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          app.tier,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${app.points} Poin',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Dapat 1 poin setiap belanja Rp10.000, masuk setelah kamu menerima pesanan.',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              head('Tukar Poin'),
              for (final (cost, val) in rewards)
                box(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: soft,
                        child: Icon(Icons.card_giftcard, color: pink),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Voucher ${rp(val)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$cost poin',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      sbtn(app.points >= cost ? 'Tukar' : 'Poin kurang', () {
                        final k = app.redeem(cost, val);
                        toast(
                          c,
                          k == null
                              ? 'Poin belum cukup'
                              : 'Voucher $k berhasil ditukarkan',
                          secs: 3,
                        );
                      }),
                    ],
                  ),
                ),
              head('Voucher Saya'),
              if (app.myVouchers.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: Text(
                    'Belum ada voucher. Tukar poinmu di atas.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              for (final e in app.myVouchers.entries)
                _code(c, e.key, e.value),
              head('Kode Promo Umum'),
              for (final e in promoCodes.entries) _code(c, e.key, e.value),
            ],
          ),
        ),
      );
}
