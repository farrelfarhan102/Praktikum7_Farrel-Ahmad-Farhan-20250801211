import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme.dart';
import '../../models/user_model.dart';
import '../widgets/common_widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccState();
}

class _AccState extends State<AccountPage> {
  late final usn = TextEditingController(text: Auth.name);
  final old = TextEditingController(),
      nw = TextEditingController(),
      nw2 = TextEditingController();
  bool hide = true;

  @override
  void dispose() {
    for (final t in [usn, old, nw, nw2]) {
      t.dispose();
    }
    super.dispose();
  }

  Future<bool> run(Future<void> Function() f, String okMsg) async {
    try {
      await f();
    } on AuthException catch (e) {
      if (mounted) toast(context, e.message, secs: 4);
      return false;
    } catch (e) {
      if (mounted) toast(context, 'Terjadi kesalahan: $e', secs: 4);
      return false;
    }
    if (mounted) {
      setState(() {});
      toast(context, okMsg, secs: 3);
    }
    return true;
  }

  Future<bool> savePass() {
    if (nw.text != nw2.text) {
      toast(context, 'Konfirmasi kata sandi baru tidak sama.', secs: 3);
      return Future.value(false);
    }
    return run(
      () => Auth.changePassword(old.text, nw.text),
      'Kata sandi berhasil diubah',
    ).then((ok) {
      if (ok) {
        old.clear();
        nw.clear();
        nw2.clear();
      }
      return ok;
    });
  }

  @override
  Widget build(BuildContext c) {
    final google = Auth.user.value?.google ?? false;
    return Scaffold(
      appBar: subBar('Pengaturan Akun'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        Auth.email,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Email tidak dapat diubah.',
                  style: TextStyle(fontSize: 11, color: Colors.black45),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Username',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                field(usn, hint: 'Username'),
                const SizedBox(height: 12),
                PButton(
                  'Simpan Username',
                  () => run(
                    () => Auth.updateName(usn.text),
                    'Username diperbarui',
                  ),
                  icon: Icons.save,
                ),
              ],
            ),
          ),
          if (google)
            box(
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: pink),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Kamu masuk dengan Google. Kata sandi dikelola di akun Google-mu.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else
            box(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ganti Kata Sandi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  authField(
                    old,
                    'Kata sandi lama',
                    Icons.lock_outline,
                    pw: true,
                    hide: hide,
                    toggle: () => setState(() => hide = !hide),
                  ),
                  authField(
                    nw,
                    'Kata sandi baru (min. 6 karakter)',
                    Icons.lock_reset,
                    pw: true,
                    hide: hide,
                    toggle: () => setState(() => hide = !hide),
                  ),
                  authField(
                    nw2,
                    'Ulangi kata sandi baru',
                    Icons.lock_reset,
                    pw: true,
                    hide: hide,
                    toggle: () => setState(() => hide = !hide),
                  ),
                  PButton('Ubah Kata Sandi', savePass, icon: Icons.key),
                  const SizedBox(height: 10),
                  Center(
                    child: Bouncy(
                      onTap: () => run(
                        () => Auth.resetPassword(Auth.email),
                        'Tautan reset dikirim ke ${Auth.email}',
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Lupa sandi lama? Kirim email reset',
                          style: TextStyle(
                            color: pink,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
}
