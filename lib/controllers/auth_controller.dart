import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../firebase_options.dart';
import '../models/user_model.dart';

/// Autentikasi: Firebase (email + Google) bila sudah dikonfigurasi,
/// otherwise mode lokal (akun disimpan di memori, tanpa Google).
class Auth {
  static bool firebaseOn = false;
  static final user = ValueNotifier<AppUser?>(null);
  static final _local = <String, ({String name, String pass})>{};

  /// Nama untuk sapaan "Halo, ...!"
  static String get name => user.value?.name ?? 'Tamu';
  static String get email => user.value?.email ?? '';
  static String get phone =>
      firebaseOn ? (FirebaseAuth.instance.currentUser?.phoneNumber ?? '') : '';
  static bool get isAdmin => adminEmails.contains(email.toLowerCase());

  static AppUser _from(User u) {
    final mail = u.email ?? '';
    final n = (u.displayName?.trim().isNotEmpty ?? false)
        ? u.displayName!.trim()
        : (mail.contains('@')
            ? mail.split('@').first
            : (u.phoneNumber ?? 'Pengguna'));
    final g = !u.providerData
        .any((p) => p.providerId == 'password'); // true = tidak punya sandi (Google / nomor HP)
    return AppUser(n, mail, google: g);
  }

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      firebaseOn = true;
      final u = FirebaseAuth.instance.currentUser; // sesi tersimpan -> masuk otomatis
      if (u != null) user.value = _from(u);
    } catch (_) {
      firebaseOn = false;
    }
  }

  static String _msg(FirebaseAuthException e) => switch (e.code) {
        'email-already-in-use' => 'Email sudah terdaftar, silakan masuk.',
        'invalid-email' => 'Format email tidak valid.',
        'weak-password' => 'Kata sandi terlalu lemah (min. 6 karakter).',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'Email atau kata sandi salah.',
        'too-many-requests' => 'Terlalu banyak percobaan, coba lagi nanti.',
        'network-request-failed' => 'Tidak ada koneksi internet.',
        'account-exists-with-different-credential' =>
          'Email ini terdaftar dengan metode masuk lain.',
        'invalid-verification-code' => 'Kode OTP salah.',
        'session-expired' => 'Kode OTP kedaluwarsa, kirim ulang kode.',
        'invalid-phone-number' => 'Nomor HP tidak valid.',
        'quota-exceeded' => 'Kuota SMS hari ini habis, coba lagi nanti.',
        _ => 'Gagal: ${e.message ?? e.code}',
      };

  static Future<void> register(String username, String mail, String pass) async {
    username = username.trim();
    mail = mail.trim().toLowerCase();
    if (username.length < 3) throw AuthException('Username minimal 3 karakter.');
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(mail)) {
      throw AuthException('Format email tidak valid.');
    }
    if (pass.length < 6) throw AuthException('Kata sandi minimal 6 karakter.');
    if (firebaseOn) {
      try {
        final c = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: mail, password: pass);
        await c.user!.updateDisplayName(username);
        await c.user!.reload();
        user.value = AppUser(username, mail);
      } on FirebaseAuthException catch (e) {
        throw AuthException(_msg(e));
      }
    } else {
      if (_local.containsKey(mail)) {
        throw AuthException('Email sudah terdaftar, silakan masuk.');
      }
      _local[mail] = (name: username, pass: pass);
      user.value = AppUser(username, mail);
    }
  }

  static Future<void> login(String mail, String pass) async {
    mail = mail.trim().toLowerCase();
    if (mail.isEmpty || pass.isEmpty) {
      throw AuthException('Isi email dan kata sandi.');
    }
    if (firebaseOn) {
      try {
        final c = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: mail, password: pass);
        user.value = _from(c.user!);
      } on FirebaseAuthException catch (e) {
        throw AuthException(_msg(e));
      }
    } else {
      final a = _local[mail];
      if (a == null || a.pass != pass) {
        throw AuthException(
            'Email atau kata sandi salah. Belum punya akun? Daftar dulu.');
      }
      user.value = AppUser(a.name, mail);
    }
  }

  static Future<void> google() async {
    if (!firebaseOn) {
      throw AuthException(
          'Login Google butuh Firebase. Jalankan "flutterfire configure" (lihat README).');
    }
    try {
      final p = GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'});
      final c = await FirebaseAuth.instance.signInWithProvider(p);
      user.value = _from(c.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled' || e.code == 'web-context-canceled') {
        throw AuthException('Login Google dibatalkan.');
      }
      throw AuthException(_msg(e));
    }
  }

  static Future<void> updateName(String n) async {
    n = n.trim();
    if (n.length < 3) throw AuthException('Username minimal 3 karakter.');
    final u = user.value;
    if (u == null) throw AuthException('Sesi pengguna tidak ditemukan.');
    if (firebaseOn) {
      try {
        final cu = FirebaseAuth.instance.currentUser!;
        await cu.updateDisplayName(n);
        await cu.reload();
      } on FirebaseAuthException catch (e) {
        throw AuthException(_msg(e));
      }
    } else {
      final a = _local[u.email];
      if (a != null) _local[u.email] = (name: n, pass: a.pass);
    }
    user.value = AppUser(n, u.email, google: u.google);
  }

  static Future<void> changePassword(String oldPass, String newPass) async {
    if (oldPass.isEmpty) throw AuthException('Isi kata sandi lama.');
    if (newPass.length < 6) {
      throw AuthException('Kata sandi baru minimal 6 karakter.');
    }
    final u = user.value;
    if (u == null) throw AuthException('Sesi pengguna tidak ditemukan.');
    if (firebaseOn) {
      try {
        final cu = FirebaseAuth.instance.currentUser!;
        await cu.reauthenticateWithCredential(
            EmailAuthProvider.credential(email: u.email, password: oldPass));
        await cu.updatePassword(newPass);
      } on FirebaseAuthException catch (e) {
        throw AuthException(e.code == 'wrong-password' ||
                e.code == 'invalid-credential'
            ? 'Kata sandi lama salah.'
            : _msg(e));
      }
    } else {
      final a = _local[u.email];
      if (a == null || a.pass != oldPass) {
        throw AuthException('Kata sandi lama salah.');
      }
      _local[u.email] = (name: a.name, pass: newPass);
    }
  }

  static Future<void> resetPassword(String mail) async {
    mail = mail.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(mail)) {
      throw AuthException('Format email tidak valid.');
    }
    if (!firebaseOn) {
      throw AuthException('Reset sandi lewat email butuh Firebase (lihat README).');
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: mail);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
          e.code == 'user-not-found' ? 'Email belum terdaftar.' : _msg(e));
    }
  }

  // ───────── Login nomor HP (OTP SMS lewat Firebase Phone Auth) ─────────
  static String? _verId;
  static int? _resendToken;
  static PhoneAuthCredential? _autoCred;
  static bool get autoVerified => _autoCred != null;

  /// 08123456789 / 8123456789 / 628123456789 -> +628123456789
  static String normalizePhone(String raw) {
    final p = raw.replaceAll(RegExp(r'[\s\-().]'), '');
    if (p.startsWith('+')) return p;
    if (p.startsWith('0')) return '+62${p.substring(1)}';
    if (p.startsWith('62')) return '+$p';
    return '+62$p';
  }

  static Future<void> sendOtp(String phone, {bool resend = false}) async {
    if (!firebaseOn) {
      throw AuthException(
          'Login OTP butuh Firebase. Jalankan "flutterfire configure" (lihat README).');
    }
    final p = normalizePhone(phone);
    if (!RegExp(r'^\+62\d{8,13}$').hasMatch(p)) {
      throw AuthException('Nomor HP tidak valid. Contoh: 081234567890');
    }
    _autoCred = null;
    final done = Completer<void>();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: p,
      timeout: const Duration(seconds: 60),
      forceResendingToken: resend ? _resendToken : null,
      verificationCompleted: (cred) {
        _autoCred = cred; // Android bisa membaca SMS otomatis
        if (!done.isCompleted) done.complete();
      },
      verificationFailed: (e) {
        if (!done.isCompleted) done.completeError(AuthException(_msg(e)));
      },
      codeSent: (id, token) {
        _verId = id;
        _resendToken = token;
        if (!done.isCompleted) done.complete();
      },
      codeAutoRetrievalTimeout: (id) => _verId = id,
    );
    return done.future;
  }

  static Future<void> verifyOtp(String code) async {
    final c = code.trim();
    PhoneAuthCredential? cred = _autoCred;
    if (cred == null) {
      if (_verId == null) throw AuthException('Minta kode OTP dulu.');
      if (c.length != 6) throw AuthException('Masukkan 6 digit kode OTP.');
      cred = PhoneAuthProvider.credential(verificationId: _verId!, smsCode: c);
    }
    try {
      final r = await FirebaseAuth.instance.signInWithCredential(cred);
      user.value = _from(r.user!);
      _autoCred = null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_msg(e));
    }
  }

  static Future<void> logout() async {
    _autoCred = null;
    _verId = null;
    if (firebaseOn) await FirebaseAuth.instance.signOut();
    user.value = null;
  }
}
