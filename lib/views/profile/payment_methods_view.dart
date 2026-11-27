import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../widgets/common_widgets.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: subBar('Metode Pembayaran'),
        body: ListenableBuilder(
          listenable: app,
          builder: (_, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Ketuk metode untuk menjadikannya utama. Metode utama otomatis terpilih saat checkout.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
              for (final k in payIcons.keys)
                Builder(
                  builder: (_) {
                    final wallet = wallets.containsKey(k),
                        on = app.linked.contains(k),
                        main = app.payPref == k;
                    return Bouncy(
                      onTap: () {
                        if (wallet && !on) {
                          toast(c, 'Aktifkan $k dulu');
                        } else {
                          app.update(() => app.payPref = k);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: main ? soft : Colors.white,
                          border: Border.all(
                            color: main ? pink : Colors.black12,
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
                                  Text(
                                    k == 'Transfer ke Admin'
                                        ? 'Transfer Bank'
                                        : k,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    wallet
                                        ? (on
                                            ? 'Aktif • Bayar lewat aplikasi $k'
                                            : 'Tidak aktif')
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
                            if (wallet)
                              sbtn(on ? 'Nonaktifkan' : 'Aktifkan', () {
                                app.update(() {
                                  if (on) {
                                    app.linked.remove(k);
                                    if (app.payPref == k) app.payPref = 'QRIS';
                                  } else {
                                    app.linked.add(k);
                                  }
                                });
                              }),
                            const SizedBox(width: 6),
                            Icon(
                              main
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: main ? pink : Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const Text(
                'Pembayaran dilakukan lewat aplikasi e-wallet / transfer, lalu unggah bukti bayar untuk diverifikasi Admin.',
                style: TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
        ),
      );
}
