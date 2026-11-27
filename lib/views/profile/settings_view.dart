import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants.dart';
import '../widgets/common_widgets.dart';
import 'account_view.dart';
import 'address_view.dart';
import 'help_view.dart';
import 'payment_methods_view.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: subBar('Pengaturan'),
        body: ListenableBuilder(
          listenable: app,
          builder: (_, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              secTitle('NOTIFIKASI'),
              box(
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Status pesanan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Pembayaran, pengiriman & penerimaan',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: app.notifOrder,
                      onChanged: (v) => app.update(() => app.notifOrder = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Promo & voucher',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Tampilkan notifikasi promo di tab Notifikasi',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: app.notifPromo,
                      onChanged: (v) => app.update(() => app.notifPromo = v),
                    ),
                  ],
                ),
              ),
              secTitle('AKUN'),
              box(
                child: Column(
                  children: [
                    navRow(
                      Icons.manage_accounts_outlined,
                      'Pengaturan Akun',
                      'Username & kata sandi',
                      () => open(c, const AccountPage()),
                    ),
                    const Divider(height: 1),
                    navRow(
                      Icons.location_on_outlined,
                      'Alamat Saya',
                      'Kelola alamat pengiriman',
                      () => open(c, const AddressPage()),
                    ),
                    const Divider(height: 1),
                    navRow(
                      Icons.account_balance_wallet_outlined,
                      'Metode Pembayaran',
                      'Metode utama: ${app.payPref}',
                      () => open(c, const PaymentMethodsPage()),
                    ),
                    const Divider(height: 1),
                    navRow(
                      Icons.headset_mic_outlined,
                      'Pusat Bantuan',
                      'Pertanyaan umum & chat',
                      () => open(c, const HelpPage()),
                    ),
                  ],
                ),
              ),
              secTitle('TENTANG'),
              box(
                child: Column(
                  children: [
                    srow('Aplikasi', storeName),
                    srow('Versi', '1.0.0'),
                    srow('Masuk sebagai', Auth.email),
                  ],
                ),
              ),
              PButton(
                'Keluar Akun',
                () => doLogout(c),
                icon: Icons.logout,
                outline: true,
              ),
            ],
          ),
        ),
      );
}
