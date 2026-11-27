import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme.dart';
import '../widgets/common_widgets.dart';

class Register extends StatefulWidget {
  const Register({super.key});
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final usn = TextEditingController(),
      mail = TextEditingController(),
      pass = TextEditingController(),
      pass2 = TextEditingController();
  bool hide = true;

  @override
  void dispose() {
    for (final t in [usn, mail, pass, pass2]) {
      t.dispose();
    }
    super.dispose();
  }

  Future<bool> submit(BuildContext c) {
    if (pass.text != pass2.text) {
      toast(c, 'Konfirmasi kata sandi tidak sama.');
      return Future.value(false);
    }
    return authRun(c, () => Auth.register(usn.text, mail.text, pass.text));
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        body: ListView(
          children: [
            authHeader(
              'Buat akun baru, yuk!',
              'Daftar gratis & dapatkan voucher member baru.',
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Username',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  authField(usn, 'mis. hana', Icons.person_outline),
                  const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  authField(
                    mail,
                    'nama@email.com',
                    Icons.mail_outline,
                    kb: TextInputType.emailAddress,
                  ),
                  const Text(
                    'Kata Sandi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  authField(
                    pass,
                    'Minimal 6 karakter',
                    Icons.lock_outline,
                    pw: true,
                    hide: hide,
                    toggle: () => setState(() => hide = !hide),
                  ),
                  const Text(
                    'Ulangi Kata Sandi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  authField(
                    pass2,
                    'Ketik ulang kata sandi',
                    Icons.lock_outline,
                    pw: true,
                    hide: hide,
                    toggle: () => setState(() => hide = !hide),
                  ),
                  PButton('Daftar', () => submit(c), icon: Icons.person_add),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'atau daftar dengan',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PButton(
                    'Daftar dengan Google',
                    () => authRun(c, Auth.google),
                    icon: Icons.g_mobiledata,
                    outline: true,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Bouncy(
                      onTap: () => Navigator.pop(c),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text.rich(
                          TextSpan(
                            text: 'Sudah punya akun? ',
                            children: [
                              TextSpan(
                                text: 'Masuk',
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
