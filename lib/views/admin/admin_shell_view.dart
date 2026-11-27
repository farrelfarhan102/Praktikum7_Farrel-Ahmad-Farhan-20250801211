import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme.dart';
import '../widgets/common_widgets.dart';
import 'admin_account_view.dart';
import 'admin_payment_view.dart';
import 'admin_products_view.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int i = 0;
  @override
  Widget build(BuildContext c) {
    if (!Auth.isAdmin) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Akses ditolak: halaman ini khusus admin.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                PButton('Kembali ke Login', () => doLogout(c)),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: IndexedStack(
        index: i,
        children: const [AdminPage(), AdminProducts(), AdminAccount()],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: soft,
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments, color: pink),
            label: 'Pembayaran',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: pink),
            label: 'Produk',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings, color: pink),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}
