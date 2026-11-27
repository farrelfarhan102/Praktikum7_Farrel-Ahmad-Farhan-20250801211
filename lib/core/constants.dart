import 'package:flutter/material.dart';

const storeName = 'Swanvacation';

/// Email yang otomatis menjadi ADMIN (masuk ke dasbor admin, bukan tampilan pelanggan).
/// Ganti/tambah email di sini. Akun ini harus didaftarkan dulu lewat "Daftar" atau Google.
const adminEmails = {'farrelfarhan102@gmail.com'};

/// Rekening tujuan transfer pelanggan. WAJIB diganti dengan rekening asli toko.
const adminBank = 'BCA 1234567890 a.n. Admin Swanvacation';

/// Kode promo umum (sekali pakai per akun). Tambah/ubah sesuai kebutuhan.
const promoCodes = {'DISKONSUMMER': 15000};

const opt = {
  '1': 'Ukuran: EU 38 • Warna: Pastel Yellow',
  '2': 'Ukuran: EU 37 • Warna: Soft Pink',
  '3': 'Ukuran: EU 39 • Warna: Sunshine',
  '4': 'Ukuran: All Size • Warna: Sunshine Yellow',
  '5': 'Ukuran: EU 38 • Warna: Nude',
};

const desc = {
  '1': 'Bantalan ekstra empuk',
  '2': 'Termasuk 3 free charms',
  '3': 'Desain ergonomis stylish',
  '4': 'Pin & charm 12mm',
  '5': 'Tali lembut anti lecet',
};

const reviews = {'1': 128, '2': 94, '3': 76, '4': 52, '5': 210};

const wallets = {'GoPay': 520000, 'OVO': 140000, 'DANA': 300000};

const payIcons = {
  'GoPay': Icons.account_balance_wallet,
  'OVO': Icons.account_balance_wallet_outlined,
  'DANA': Icons.payments,
  'QRIS': Icons.qr_code_2,
  'Transfer ke Admin': Icons.account_balance,
};

const payColors = {
  'GoPay': Color(0xFF00AA13),
  'OVO': Color(0xFF4C2A86),
  'DANA': Color(0xFF118EEA),
  'QRIS': Color(0xFFEE4D2D),
  'Transfer ke Admin': Color(0xFF6366F1),
};

const visualKeywords = {
  '1': ['slide', 'slipper', 'sandal', 'flip', 'foam', 'footwear', 'white'],
  '2': ['clog', 'shoe', 'footwear', 'flower', 'pink', 'sandal'],
  '3': ['slide', 'sandal', 'flip', 'foam', 'yellow', 'footwear'],
  '4': ['flower', 'daisy', 'charm', 'jewelry', 'accessory', 'badge', 'petal', 'yellow'],
  '5': ['strap', 'sandal', 'slide', 'footwear', 'slipper', 'beige'],
};

const faqs = [
  (
    'Bagaimana cara memesan?',
    'Pilih sandal di Beranda lalu tambahkan ke keranjang. Buka tab Keranjang, pilih barang, tekan Checkout, pilih alamat dan metode pembayaran, lalu tekan Bayar Sekarang.',
  ),
  (
    'Metode pembayaran apa saja yang tersedia?',
    'GoPay, OVO, DANA, QRIS, dan Transfer Virtual Account ke rekening Admin. Kamu bisa mengatur metode utama di Profil > Metode Pembayaran.',
  ),
  (
    'Berapa lama batas waktu pembayaran?',
    'Setelah pesanan dibuat, kamu punya waktu 30 menit untuk membayar. Jika lewat, pesanan otomatis dibatalkan. Di halaman Checkout juga ada batas waktu 15 menit.',
  ),
  (
    'Apakah uang saya aman?',
    'Ya. Pembayaranmu ditahan dulu oleh Admin (escrow) dan baru diteruskan ke penjual setelah kamu menerima pesanan.',
  ),
  (
    'Bagaimana cara menerima pesanan?',
    'Saat paket sampai, buka Pesanan Saya lalu tekan Terima Pesanan + Foto dan foto paketnya. Setelah itu kamu bisa memberi rating.',
  ),
  (
    'Barang bermasalah, bagaimana komplen atau refund?',
    'Di Pesanan Saya, tekan Ajukan Komplen dan jelaskan masalahnya. Admin akan memeriksa; jika disetujui, uangmu dikembalikan (refund).',
  ),
  (
    'Di mana memasukkan kode voucher?',
    'Di halaman Checkout, pada kolom kode promo. Contoh kode: DISKONSUMMER (sekali pakai per akun).',
  ),
  (
    'Bagaimana mengubah alamat pengiriman?',
    'Buka Profil > Alamat Saya untuk menambah, mengubah, menghapus, atau menjadikan alamat sebagai utama. Saat checkout kamu juga bisa memilih alamat lain.',
  ),
  (
    'Saya lupa kata sandi.',
    'Di halaman masuk, tekan "Lupa sandi?" lalu masukkan emailmu. Tautan reset akan dikirim ke email tersebut. Akun Google tidak memakai sandi aplikasi.',
  ),
  (
    'Bagaimana menghubungi penjual atau Admin?',
    'Tekan tombol Chat di bawah, lalu pilih ruang Penjual atau Admin. Kami siap membantu 24 jam.',
  ),
];

/// Stok tiap produk (id produk -> jumlah). UBAH sesuai stok asli tokomu;
/// dipakai chat penjual untuk menjawab "apakah masih ada stok?".
const productStock = {'1': 24, '2': 12, '3': 8, '4': 40, '5': 3};

/// Ukuran yang tersedia per produk. UBAH sesuai kenyataan.
const productSizes = {
  '1': 'EU 36 - EU 41',
  '2': 'EU 36 - EU 40',
  '3': 'EU 37 - EU 41',
  '4': 'All Size',
  '5': 'EU 36 - EU 40',
};
