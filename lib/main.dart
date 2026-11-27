import 'package:flutter/material.dart';
import 'controllers/auth_controller.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'views/admin/admin_shell_view.dart';
import 'views/auth/login_view.dart';
import 'views/customer/shell_view.dart';

export 'controllers/app_controller.dart';
export 'controllers/auth_controller.dart';
export 'controllers/visual_search_controller.dart';
export 'core/constants.dart';
export 'core/theme.dart';
export 'models/address_model.dart';
export 'models/message_model.dart';
export 'models/notification_model.dart';
export 'models/order_model.dart';
export 'models/product_model.dart';
export 'models/user_model.dart';
export 'views/admin/admin_account_view.dart';
export 'views/admin/admin_payment_view.dart';
export 'views/admin/admin_products_view.dart';
export 'views/admin/admin_shell_view.dart';
export 'views/auth/login_view.dart';
export 'views/auth/phone_login_view.dart';
export 'views/auth/register_view.dart';
export 'views/customer/cart_view.dart';
export 'views/customer/chat_view.dart';
export 'views/customer/checkout_view.dart';
export 'views/customer/home_view.dart';
export 'views/customer/notif_view.dart';
export 'views/customer/orders_view.dart';
export 'views/customer/payment_view.dart';
export 'views/customer/shell_view.dart';
export 'views/customer/voucher_view.dart';
export 'views/profile/account_view.dart';
export 'views/profile/address_view.dart';
export 'views/profile/help_view.dart';
export 'views/profile/payment_methods_view.dart';
export 'views/profile/profile_view.dart';
export 'views/profile/settings_view.dart';
export 'views/widgets/common_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Auth.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: storeName,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: pink,
        scaffoldBackgroundColor: bg,
      ),
      // sesi Firebase yang tersimpan -> langsung masuk tanpa login ulang
      home: Auth.user.value == null
          ? const Login()
          : (Auth.isAdmin ? const AdminShell() : const Shell()),
    );
  }
}
