import 'package:flutter/material.dart';

const pink = Color(0xFFDB2777),
    pink2 = Color(0xFFF472B6),
    bg = Color(0xFFFDF4FF),
    lav = Color(0xFFF1EEFB),
    soft = Color(0xFFFCE7F3),
    yel = Color(0xFFFEF3C7),
    gold = Color(0xFFFDE68A),
    ink = Color(0xFF1F1B2E);

String rp(int v) =>
    'Rp ${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

BoxDecoration card() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: pink.withValues(alpha: .08),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );

Color sc(String s) =>
    {
      'Menunggu Verifikasi': Colors.indigo,
      'Dibatalkan': Colors.red,
      'Komplain': Colors.orange,
      'Refund': Colors.blueGrey,
      'Selesai': Colors.green,
      'Diterima': Colors.green,
    }[s] ??
    pink;
