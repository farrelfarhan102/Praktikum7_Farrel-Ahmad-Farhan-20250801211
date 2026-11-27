import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/app_controller.dart';
import '../../core/theme.dart';
import '../../models/order_model.dart';
import '../widgets/common_widgets.dart';
import '../widgets/shipping_status.dart';
import 'chat_view.dart';
import 'payment_view.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Pesanan Saya',
            style: TextStyle(fontWeight: FontWeight.w800, color: pink),
          ),
        ),
        body: ListenableBuilder(
          listenable: app,
          builder: (_, _) => app.orders.isEmpty
              ? const Center(child: Text('Belum ada pesanan'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: app.orders.length,
                  itemBuilder: (_, i) => pop(i, OrderCard(app.orders[i])),
                ),
        ),
      );
}

class OrderCard extends StatelessWidget {
  final Order o;
  const OrderCard(this.o, {super.key});

  Future<void> receive() async {
    final f = await ImagePicker()
        .pickImage(source: ImageSource.camera); // foto penerimaan
    if (f == null) return;
    app.update(() {
      o.proof = f.path;
      o.status = 'Diterima';
      final pts = o.total ~/ 10000; // 1 poin / Rp10.000
      app.points += pts;
      app.earned += pts;
    });
  }

  Future<void> complain(BuildContext c) async {
    final t = TextEditingController();
    final ok = await showDialog<bool>(
      context: c,
      builder: (d) => AlertDialog(
        title: const Text('Komplen pesanan'),
        content: TextField(
          controller: t,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Jelaskan masalahnya...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
    final msg = t.text.trim();
    t.dispose();
    if (ok == true && msg.isNotEmpty) {
      app.update(() {
        o.complaint = msg;
        o.status = 'Komplain';
      });
    }
  }

  @override
  Widget build(BuildContext c) {
    final rated = o.status == 'Diterima' || o.status == 'Selesai';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${o.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(o.status),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: sc(o.status).withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    o.status,
                    style: TextStyle(
                      color: sc(o.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            o.items.map((p) => p.name).join(', '),
            style: const TextStyle(color: Colors.black54),
          ),
          Text(
            '${o.method} • ${rp(o.total)}',
            style: const TextStyle(color: pink, fontWeight: FontWeight.bold),
          ),
          if (o.proof != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(o.proof!),
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (o.complaint != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Komplen: ${o.complaint}'),
            ),
          const SizedBox(height: 10),
          if (o.status == 'Menunggu Pembayaran')
            PButton(
              'Lanjut Bayar',
              () => Navigator.push(
                c,
                MaterialPageRoute(builder: (_) => PaymentPage(o)),
              ),
              icon: Icons.payments_outlined,
            ),
          if (o.status == 'Menunggu Verifikasi')
            const Row(
              children: [
                Icon(Icons.schedule, size: 15, color: Colors.black54),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Menunggu verifikasi pembayaran oleh Admin',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ShippingStatus(o),
          if (o.resi != null &&
              (o.status == 'Dikirim' ||
                  o.status == 'Diterima' ||
                  o.status == 'Selesai'))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 16,
                    color: pink,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${o.courier} • Resi ${o.resi}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  sbtn('Salin', () {
                    Clipboard.setData(ClipboardData(text: o.resi!));
                    toast(c, 'Nomor resi disalin');
                  }),
                ],
              ),
            ),
          if (o.status == 'Dikirim')
            PButton('Terima Pesanan + Foto', receive, icon: Icons.camera_alt),
          if (rated) ...[
            Row(
              children: [
                const Text('Rating: '),
                for (var s = 1; s <= 5; s++)
                  Bouncy(
                    onTap: () => app.update(() => o.rating = s),
                    child: AnimatedScale(
                      scale: o.rating >= s ? 1.2 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        o.rating >= s ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                  ),
              ],
            ),
            if (o.status == 'Diterima') ...[
              const SizedBox(height: 8),
              PButton(
                'Ajukan Komplen',
                () => complain(c),
                icon: Icons.report_problem,
                outline: true,
              ),
            ],
          ],
          if (o.items.isNotEmpty && o.status != 'Dibatalkan')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: PButton(
                'Chat Penjual',
                () => openSellerChat(c, product: o.items.first),
                icon: Icons.chat_bubble_outline,
                outline: true,
              ),
            ),
        ],
      ),
    );
  }
}
