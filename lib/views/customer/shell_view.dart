import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../core/theme.dart';
import '../profile/profile_view.dart';
import 'cart_view.dart';
import 'home_view.dart';
import 'notif_view.dart';

class Shell extends StatelessWidget {
  const Shell({super.key});
  static const pages = [Home(), NotifPage(), CartPage(), ProfilePage()];
  @override
  Widget build(BuildContext c) => ListenableBuilder(
        listenable: Listenable.merge([tab, app]),
        builder: (_, _) => Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: KeyedSubtree(
              key: ValueKey(tab.value),
              child: pages[tab.value],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            backgroundColor: Colors.white,
            indicatorColor: soft,
            selectedIndex: tab.value,
            onDestinationSelected: (v) => tab.value = v,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: pink),
                label: 'Beranda',
              ),
              const NavigationDestination(
                icon: Icon(Icons.notifications_none),
                selectedIcon: Icon(Icons.notifications, color: pink),
                label: 'Notifikasi',
              ),
              NavigationDestination(
                icon: Badge.count(
                  count: app.cart.length,
                  isLabelVisible: app.cart.isNotEmpty,
                  backgroundColor: pink,
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                selectedIcon: const Icon(Icons.shopping_bag, color: pink),
                label: 'Keranjang',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: pink),
                label: 'Profil',
              ),
            ],
          ),
        ),
      );
}
