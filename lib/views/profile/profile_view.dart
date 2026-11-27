import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../customer/orders_view.dart';
import '../customer/voucher_view.dart';
import '../widgets/common_widgets.dart';
import 'account_view.dart';
import 'address_view.dart';
import 'help_view.dart';
import 'payment_methods_view.dart';
import 'settings_view.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfState();
}

class _ProfState extends State<ProfilePage> {
  String? av;
  Future<void> pick() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => av = f.path);
  }

  void go(Widget w) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => w)).then((_) {
        if (mounted) setState(() {});
      });

  Widget menu(
    IconData i,
    String t,
    String s,
    VoidCallback f, {
    String? badge,
  }) =>
      Bouncy(
        onTap: f,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(i, color: pink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          t,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      s,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: pink2),
            ],
          ),
        ),
      );

  Widget stat(IconData i, String n, String l, Color bg, [VoidCallback? f]) =>
      Expanded(
        child: Bouncy(
          onTap: f ?? () {},
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: card(),
            child: Column(
              children: [
                CircleAvatar(backgroundColor: bg, child: Icon(i, color: pink)),
                const SizedBox(height: 6),
                Text(
                  n,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  l,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            'Profil Saya',
            style: TextStyle(fontWeight: FontWeight.w800, color: pink),
          ),
          actions: [
            Bouncy(
              onTap: () =>
                  toast(c, 'Profil: ${Auth.name} • $storeName', secs: 2),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.share_outlined),
              ),
            ),
            Bouncy(
              onTap: () => go(const SettingsPage()),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.settings_outlined),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [soft, Color(0xFFFEF9C3)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 38,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                av != null ? FileImage(File(av!)) : null,
                            child: av == null
                                ? const Icon(Icons.person, size: 40, color: pink)
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Bouncy(
                              onTap: pick,
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: pink,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    Auth.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  color: pink,
                                  size: 18,
                                ),
                              ],
                            ),
                            Text(
                              Auth.email.isNotEmpty ? Auth.email : Auth.phone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: gold,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListenableBuilder(
                                listenable: app,
                                builder: (_, _) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.workspace_premium,
                                      size: 14,
                                      color: Colors.brown,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${app.tier} • ${app.points} Poin',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Bouncy(
                    onTap: () => go(const VoucherPage()),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: pink),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tukar poinmu dengan voucher diskon!',
                            style: TextStyle(
                              color: pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward, color: pink, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ListenableBuilder(
              listenable: app,
              builder: (_, _) => Row(
                children: [
                  stat(
                    Icons.local_shipping,
                    '${app.orders.length}',
                    'Pesanan',
                    soft,
                    () => go(const OrdersPage()),
                  ),
                  stat(
                    Icons.favorite,
                    '${app.wishlist.length}',
                    'Wishlist',
                    soft,
                  ),
                  stat(
                    Icons.confirmation_number,
                    '${app.activeVouchers.length}',
                    'Voucher Saya',
                    yel,
                    () => go(const VoucherPage()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ListenableBuilder(
              listenable: app,
              builder: (_, _) => Container(
                decoration: card(),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'MENU PENGGUNA',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ringkasan Aktivitas',
                            style: TextStyle(
                              fontSize: 11,
                              color: pink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    menu(
                      Icons.receipt_long,
                      'Riwayat Pesanan',
                      'Lacak status, terima pesanan, rating & komplen',
                      () => go(const OrdersPage()),
                    ),
                    const Divider(height: 1),
                    menu(
                      Icons.location_on_outlined,
                      'Alamat Saya',
                      app.mainAddress?.text ?? 'Belum ada alamat tersimpan',
                      () => go(const AddressPage()),
                      badge: '${app.addresses.length} Tersimpan',
                    ),
                    const Divider(height: 1),
                    menu(
                      Icons.account_balance_wallet_outlined,
                      'Metode Pembayaran',
                      'Metode utama: ${app.payPref}',
                      () => go(const PaymentMethodsPage()),
                    ),
                    const Divider(height: 1),
                    menu(
                      Icons.manage_accounts_outlined,
                      'Pengaturan Akun',
                      'Username & kata sandi',
                      () => go(const AccountPage()),
                    ),
                    const Divider(height: 1),
                    menu(
                      Icons.headset_mic_outlined,
                      'Pusat Bantuan',
                      'Pertanyaan umum & Live Chat 24 Jam',
                      () => go(const HelpPage()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: yel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: gold),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_fix_high, color: Colors.brown),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buat Sandal Custom Kamu',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Pilih strap & pin favorit sekarang',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  sbtn('Coba', () => toast(c, 'Fitur custom segera hadir')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PButton(
              'Keluar Akun',
              () => doLogout(c),
              icon: Icons.logout,
              outline: true,
            ),
          ],
        ),
      );
}
