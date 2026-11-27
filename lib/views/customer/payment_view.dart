import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/app_controller.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/order_model.dart';
import '../widgets/common_widgets.dart';

class PaymentPage extends StatefulWidget {
  final Order o;
  const PaymentPage(this.o, {super.key});
  @override
  State<PaymentPage> createState() => _PayState();
}

class _PayState extends State<PaymentPage> {
  Order get o => widget.o;

  void expire() {
    if (o.status != 'Menunggu Pembayaran') return;
    app.update(() => o.status = 'Dibatalkan');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Pembayaran Dibatalkan'),
        content: const Text(
          'Batas waktu 30 menit habis, pesanan otomatis dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> openWallet() async {
    const links = {'GoPay': 'gojek://', 'OVO': 'ovo://', 'DANA': 'dana://'};
    try {
      final ok = await launchUrl(
        Uri.parse(links[o.method]!),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) throw 'gagal';
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aplikasi ${o.method} belum terpasang')),
        );
      }
    }
  }

  /// Pelanggan mengunggah bukti bayar; Admin yang memverifikasi (bukan otomatis).
  Future<bool> confirm() async {
    if (o.status != 'Menunggu Pembayaran') return false;
    final f = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (f == null || !mounted || o.status != 'Menunggu Pembayaran') return false;
    app.update(() {
      o.payProof = f.path;
      o.status = 'Menunggu Verifikasi';
    });
    await showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Bukti Pembayaran Terkirim'),
        content: const Text(
          'Admin akan memeriksa pembayaranmu. Status pesanan otomatis berubah setelah terverifikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    return true;
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: Text('Bayar via ${o.method}')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(child: Countdown(1800, expire)),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Selesaikan pembayaran maks. 30 menit',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                rp(o.total),
                style: const TextStyle(
                  color: pink,
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (o.method == 'QRIS')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: card(),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/qris.png',
                      height: 300,
                      errorBuilder: (_, _, _) => Container(
                        height: 240,
                        width: 240,
                        decoration: BoxDecoration(
                          color: soft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_2, size: 150, color: pink),
                            SizedBox(height: 6),
                            Text(
                              'QRIS $storeName',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: pink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Scan dengan GoPay, OVO, DANA, atau m-banking',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else if (o.method == 'Transfer ke Admin')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: card(),
                child: const Text(
                  'Transfer ke rekening Admin\n$adminBank\nLalu unggah bukti transfer di bawah.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            else
              PButton(
                'Buka aplikasi ${o.method}',
                openWallet,
                icon: Icons.open_in_new,
              ),
            const SizedBox(height: 16),
            PButton(
              'Unggah Bukti Pembayaran',
              confirm,
              icon: Icons.upload_file,
            ),
          ],
        ),
      );
}
