import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme.dart';
import '../../models/user_model.dart';
import '../widgets/common_widgets.dart';
import 'phone_login_view.dart';
import 'register_view.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final mail = TextEditingController(), pass = TextEditingController();
  bool hide = true;

  @override
  void dispose() {
    mail.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> forgot() async {
    final t = TextEditingController(text: mail.text.trim());
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Reset kata sandi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kami kirim tautan reset ke emailmu.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            field(t, hint: 'nama@email.com', kb: TextInputType.emailAddress),
          ],
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
    final emailText = t.text;
    t.dispose();
    if (ok != true || !mounted) return;
    try {
      await Auth.resetPassword(emailText);
      if (mounted) {
        toast(
          context,
          'Tautan reset dikirim. Cek emailmu (termasuk folder spam).',
          secs: 4,
        );
      }
    } on AuthException catch (e) {
      if (mounted) toast(context, e.message, secs: 4);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        body: ListView(
          children: [
            authHeader(
              'Halo! Yuk masuk & lanjut belanja',
              'Sandal Crocs favoritmu menunggu: Clog, Slide, Jibbitz & lainnya.',
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  authField(
                    mail,
                    'nama@email.com',
                    Icons.mail_outline,
                    kb: TextInputType.emailAddress,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kata Sandi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Bouncy(
                        onTap: forgot,
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Text(
                            'Lupa sandi?',
                            style: TextStyle(
                              color: pink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  authField(
                    pass,
                    'Masukkan kata sandi',
                    Icons.lock_outline,
                    pw: true,
                    hide: hide,
                    toggle: () => setState(() => hide = !hide),
                  ),
                  PButton(
                    'Masuk',
                    () => authRun(c, () => Auth.login(mail.text, pass.text)),
                    icon: Icons.login,
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'atau masuk dengan',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PButton(
                          'Google',
                          () => authRun(c, Auth.google),
                          icon: Icons.g_mobiledata,
                          outline: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PButton(
                          'Nomor HP (OTP)',
                          () => Navigator.push(
                            c,
                            MaterialPageRoute(builder: (_) => const PhoneLogin()),
                          ),
                          icon: Icons.sms_outlined,
                          outline: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Member Swanvacation dapat poin belanja, voucher diskon, wishlist, dan pelacakan pesanan.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Bouncy(
                      onTap: () => Navigator.push(
                        c,
                        MaterialPageRoute(builder: (_) => const Register()),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text.rich(
                          TextSpan(
                            text: 'Belum punya akun? ',
                            children: [
                              TextSpan(
                                text: 'Daftar sekarang',
                                style: TextStyle(
                                  color: pink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
