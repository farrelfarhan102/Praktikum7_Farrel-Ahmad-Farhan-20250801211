import 'dart:io';
import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../core/theme.dart';
import '../../models/order_model.dart';
import '../widgets/common_widgets.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin • Pembayaran',
            style: TextStyle(fontWeight: FontWeight.w800, color: pink),
          ),
        ),
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
                    const Text(
                      'Saldo Escrow Admin',
                      style: TextStyle(color: Colors.white70),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: app.escrow.toDouble()),
                      duration: const Duration(milliseconds: 700),
                      builder: (_, v, _) => Text(
                        rp(v.round()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cair ke seller: ${rp(app.paidSeller)}  •  Refund ke customer: ${rp(app.refunded)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              for (final o in app.orders
                  .where((o) => o.status == 'Menunggu Verifikasi'))
                VerifyTile(o),
              for (final o in app.orders.where((o) => o.status == 'Dikemas'))
                ShipTile(o),
              for (final o in app.orders.where(
                (o) => o.status == 'Diterima' || o.status == 'Komplain',
              ))
                Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: card(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${o.id} • ${rp(o.total)} • ${o.status}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (o.complaint != null) Text('Komplen: ${o.complaint}'),
                      const SizedBox(height: 10),
                      if (o.status == 'Diterima')
                        PButton(
                          'Cairkan ke Seller',
                          () => app.update(() {
                            app.escrow -= o.total;
                            app.paidSeller += o.total;
                            o.status = 'Selesai';
                          }),
                          icon: Icons.storefront,
                        ),
                      if (o.status == 'Komplain')
                        PButton(
                          'Refund ke Customer',
                          () => app.update(() {
                            app.escrow -= o.total;
                            app.refunded += o.total;
                            o.status = 'Refund';
                          }),
                          icon: Icons.undo,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
}

class VerifyTile extends StatelessWidget {
  final Order o;
  const VerifyTile(this.o, {super.key});
  @override
  Widget build(BuildContext c) => Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(16),
        decoration: card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verifikasi bayar #${o.id} • ${rp(o.total)} • ${o.method}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              o.items.map((p) => p.name).join(', '),
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
            if (o.payProof != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(o.payProof!),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: PButton(
                    'Verifikasi',
                    () => app.update(() {
                      app.escrow += o.total;
                      o.status = 'Dikemas';
                    }),
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PButton(
                    'Tolak',
                    () => app.update(() {
                      o.payProof = null;
                      o.status = 'Menunggu Pembayaran';
                    }),
                    icon: Icons.close,
                    outline: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class ShipTile extends StatefulWidget {
  final Order o;
  const ShipTile(this.o, {super.key});
  @override
  State<ShipTile> createState() => _ShipState();
}

class _ShipState extends State<ShipTile> {
  static const couriers = [
    'JNE',
    'J&T',
    'SiCepat',
    'AnterAja',
    'Pos Indonesia',
  ];
  String courier = couriers.first;
  final resi = TextEditingController();

  @override
  void dispose() {
    resi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final o = widget.o;
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kirim pesanan #${o.id} • ${rp(o.total)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            o.items.map((p) => p.name).join(', '),
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in couriers)
                pill(
                  k,
                  sel: courier == k,
                  onTap: () => setState(() => courier = k),
                ),
            ],
          ),
          const SizedBox(height: 10),
          field(resi, hint: 'Nomor resi'),
          const SizedBox(height: 10),
          PButton('Tandai Dikirim', () {
            final r = resi.text.trim();
            if (r.length < 6) {
              toast(c, 'Isi nomor resi yang valid');
              return false;
            }
            app.update(() {
              o.courier = courier;
              o.resi = r;
              o.status = 'Dikirim';
            });
          }, icon: Icons.local_shipping),
        ],
      ),
    );
  }
}
