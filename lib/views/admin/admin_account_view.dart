import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../profile/account_view.dart';
import '../widgets/common_widgets.dart';

class AdminAccount extends StatelessWidget {
  const AdminAccount({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin • Akun',
            style: TextStyle(fontWeight: FontWeight.w800, color: pink),
          ),
        ),
        body: ValueListenableBuilder(
          valueListenable: Auth.user,
          builder: (_, _, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [pink, pink2]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: pink,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Auth.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            Auth.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Administrator $storeName',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              box(
                child: Column(
                  children: [
                    navRow(
                      Icons.manage_accounts_outlined,
                      'Pengaturan Akun',
                      'Username & kata sandi admin',
                      () => open(c, const AccountPage()),
                    ),
                  ],
                ),
              ),
              box(
                c: yel,
                child: const Text(
                  'Akun admin terpisah dari akun pelanggan. Pelanggan tidak melihat dasbor ini.',
                  style: TextStyle(fontSize: 12),
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
