import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme.dart';
import '../../models/user_model.dart';
import '../widgets/common_widgets.dart';

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key});
  @override
  State<PhoneLogin> createState() => _PhoneState();
}

class _PhoneState extends State<PhoneLogin> {
  final phone = TextEditingController(), code = TextEditingController();
  bool sent = false;
  int left = 0;
  Timer? _t;

  @override
  void dispose() {
    _t?.cancel();
    phone.dispose();
    code.dispose();
    super.dispose();
  }

  void _countdown() {
    _t?.cancel();
    setState(() => left = 60);
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => left--);
      if (left <= 0) t.cancel();
    });
  }

  Future<bool> send({bool resend = false}) async {
    try {
      await Auth.sendOtp(phone.text, resend: resend);
    } on AuthException catch (e) {
      if (mounted) toast(context, e.message, secs: 4);
      return false;
    } catch (e) {
      if (mounted) toast(context, 'Gagal mengirim OTP: $e', secs: 4);
      return false;
    }
    if (!mounted) return true;
    setState(() => sent = true);
    _countdown();
    if (Auth.autoVerified) {
      authRun(context, () => Auth.verifyOtp('')); // SMS terbaca otomatis (Android)
    } else {
      toast(
        context,
        'Kode OTP dikirim ke ${Auth.normalizePhone(phone.text)}',
        secs: 3,
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: ink,
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            authHeader(
              'Masuk dengan nomor HP',
              'Kami kirim kode OTP 6 digit lewat SMS. Tanpa sandi.',
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nomor HP',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  authField(
                    phone,
                    '0812xxxxxxxx',
                    Icons.phone_android,
                    kb: TextInputType.phone,
                  ),
                  if (!sent)
                    PButton('Kirim Kode OTP', send, icon: Icons.sms_outlined),
                  if (sent) ...[
                    const Text(
                      'Kode OTP',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: code,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 26,
                        letterSpacing: 10,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '••••••',
                        filled: true,
                        fillColor: lav,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    PButton(
                      'Verifikasi & Masuk',
                      () => authRun(c, () => Auth.verifyOtp(code.text)),
                      icon: Icons.verified_user,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: left > 0
                          ? Text(
                              'Kirim ulang kode dalam ${left}s',
                              style: const TextStyle(color: Colors.black54),
                            )
                          : Bouncy(
                              onTap: () => send(resend: true),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Kirim ulang kode',
                                  style: TextStyle(
                                    color: pink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
}
