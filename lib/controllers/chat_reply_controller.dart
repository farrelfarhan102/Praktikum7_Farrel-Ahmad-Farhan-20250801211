import '../core/constants.dart';
import '../core/theme.dart';
import '../models/product_model.dart';
import 'app_controller.dart';

// Balasan otomatis (simulasi) untuk chat Penjual & Admin.
// Jawaban dipilih dari kata kunci pertanyaan + produk yang sedang di-tag.

int _turn = 0;
String _pick(List<String> l) => l[_turn++ % l.length];

String _norm(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// Kata pendek (<=3 huruf) dicocokkan sebagai kata utuh agar tidak salah kena.
bool _has(String t, List<String> keys) {
  final p = ' $t ';
  return keys.any((k) => k.length <= 3 ? p.contains(' $k ') : p.contains(k));
}

String _stem(String w) => w.endsWith('s') ? w.substring(0, w.length - 1) : w;

/// Produk yang disebut langsung di pesan (pakai kata unik pada nama produk).
Product? _mentioned(String t) {
  final count = <String, int>{};
  for (final p in products) {
    for (final w in p.name.toLowerCase().split(' ').map(_stem).toSet()) {
      count[w] = (count[w] ?? 0) + 1;
    }
  }
  for (final p in products) {
    for (final w in p.name.toLowerCase().split(' ').map(_stem)) {
      if (w.length >= 4 && count[w] == 1 && t.contains(w)) return p;
    }
  }
  return null;
}

String _stockLine(Product p) {
  final n = productStock[p.id] ?? 0;
  if (n <= 0) {
    return _pick([
      'Mohon maaf, ${p.name} sedang habis. Boleh kami kabari kalau sudah restock?',
      'Untuk saat ini ${p.name} kosong, kak. Kamu bisa lihat produk lain di Beranda ya.',
    ]);
  }
  if (n <= 5) {
    return _pick([
      'Stok ${p.name} tinggal $n lagi, kak. Kalau berminat sebaiknya segera dimasukkan ke keranjang ya.',
      'Masih ada, tapi tinggal $n saja untuk ${p.name}. Yuk checkout sebelum kehabisan.',
    ]);
  }
  return _pick([
    'Stok ${p.name} masih tersedia, kak (sekitar $n). Silakan langsung diorder ya.',
    'Ready ya! ${p.name} masih ada $n. Mau ukuran dan warna yang mana?',
    'Masih ada kak, stok ${p.name} aman ($n tersedia).',
  ]);
}

String _allStock() {
  final b = StringBuffer(
      'Berikut stok produk kami saat ini:');
  for (final p in products) {
    final n = productStock[p.id] ?? 0;
    b.write('\n• ${p.name}: ${n > 0 ? '$n tersedia' : 'habis'}');
  }
  return b.toString();
}

String _askProduct() =>
    'Untuk produk yang mana ya, kak? Tekan ikon chat di produk yang dimaksud, '
    'atau sebutkan namanya: ${products.map((p) => p.name).join(', ')}.';

String _color(Product p) {
  final o = opt[p.id] ?? '';
  final i = o.indexOf('Warna:');
  return i < 0 ? '' : o.substring(i + 6).trim();
}

String _orderStatus() {
  if (app.orders.isEmpty) {
    return 'Kamu belum punya pesanan. Pilih produk di Beranda lalu checkout ya, kak.';
  }
  final o = app.orders.last;
  final base = 'Pesanan terakhirmu #${o.id} berstatus ${o.status}.';
  switch (o.status) {
    case 'Menunggu Pembayaran':
      return '$base Silakan selesaikan pembayaran lewat Pesanan Saya > Lanjut Bayar (batas 30 menit).';
    case 'Menunggu Verifikasi':
      return '$base Admin sedang memeriksa bukti pembayaranmu.';
    case 'Dikemas':
      return '$base Pesanan sedang dikemas dan segera diserahkan ke kurir.';
    case 'Dikirim':
      return '$base Dikirim lewat ${o.courier ?? 'kurir'}'
          '${o.resi != null ? ' dengan resi ${o.resi}' : ''}. '
          'Setelah paket sampai, tekan Terima Pesanan + Foto.';
    case 'Diterima':
    case 'Selesai':
      return '$base Terima kasih sudah belanja! Jangan lupa beri rating ya.';
    case 'Dibatalkan':
      return '$base Kamu bisa memesan ulang kapan saja.';
    default:
      return base;
  }
}

String sellerReply(String raw, {Product? context}) {
  final t = _norm(raw);
  final p = _mentioned(t) ?? context;
  final out = <String>[];

  if (_has(t, ['stok', 'stock', 'ready', 'tersedia', 'masih ada', 'kosong', 'habis'])) {
    out.add(p != null ? _stockLine(p) : _allStock());
  }
  if (_has(t, ['ukuran', 'size', 'muat', 'kebesaran', 'kekecilan', 'eu'])) {
    out.add(p == null
        ? _askProduct()
        : '${p.name} tersedia ukuran ${productSizes[p.id] ?? '-'}. '
            'Contoh yang ada: ${opt[p.id] ?? '-'}. Mau ukuran berapa, kak? Nanti kami cek.');
  }
  if (_has(t, ['warna', 'color', 'colour'])) {
    out.add(p == null
        ? _askProduct()
        : 'Warna ${p.name} yang tersedia: ${_color(p).isEmpty ? '-' : _color(p)}. '
            'Kalau mau warna lain, tulis saja ya.');
  }
  if (_has(t, ['harga', 'murah', 'nego', 'tawar'])) {
    if (_has(t, ['nego', 'tawar'])) {
      out.add('Mohon maaf kak, harga sudah harga terbaik dan belum bisa nego. '
          'Tapi kamu bisa pakai kode promo DISKONSUMMER di checkout, atau tukar poin jadi voucher.');
    } else if (p != null) {
      out.add('${p.name} harganya ${rp(p.price)}, rating ${p.rating} dari ${reviews[p.id] ?? 0} ulasan.');
    } else {
      out.add('Daftar harga kami:\n${products.map((e) => '• ${e.name}: ${rp(e.price)}').join('\n')}');
    }
  }
  if (_has(t, ['diskon', 'promo', 'voucher', 'kode', 'potongan', 'poin'])) {
    out.add('Ada kode promo DISKONSUMMER (potongan ${rp(promoCodes['DISKONSUMMER'] ?? 0)}, '
        'sekali pakai per akun). Isi di kolom kode promo saat Checkout. '
        'Selain itu, tiap belanja Rp10.000 kamu dapat 1 poin yang bisa ditukar voucher.');
  }
  if (_has(t, ['bahan', 'material', 'nyaman', 'empuk', 'kualitas', 'spesifikasi', 'detail', 'deskripsi'])) {
    out.add(p == null
        ? _askProduct()
        : '${p.name}: ${desc[p.id] ?? 'sandal nyaman berkualitas'}. ${opt[p.id] ?? ''}'.trim());
  }
  if (_has(t, ['rekomendasi', 'terlaris', 'bagus', 'saran', 'bestseller'])) {
    final top = [...products]..sort((a, b) => b.rating.compareTo(a.rating));
    out.add('Yang paling banyak diminati: ${top.take(3).map((e) => e.name).join(', ')}. '
        'Mau kami jelaskan salah satunya?');
  }
  if (_has(t, ['ongkir', 'kurir', 'ekspedisi', 'jne', 'j t', 'sicepat', 'anteraja', 'pos', 'estimasi', 'lama kirim', 'kapan sampai', 'pengiriman'])) {
    out.add('Pesanan dikirim setelah pembayaran diverifikasi Admin, lewat JNE, J&T, SiCepat, '
        'AnterAja, atau Pos Indonesia. Nomor resi muncul di Pesanan Saya, dan lama sampainya '
        'tergantung alamat tujuan.');
  }
  if (_has(t, ['resi', 'lacak', 'tracking', 'status', 'pesanan saya', 'order', 'paket', 'sampai'])
      && !_has(t, ['kapan sampai', 'estimasi'])) {
    out.add(_orderStatus());
  }
  if (_has(t, ['bayar', 'pembayaran', 'gopay', 'ovo', 'dana', 'qris', 'transfer', 'cod', 'cicil'])) {
    out.add(_has(t, ['cod'])
        ? 'Mohon maaf, saat ini belum melayani COD. Pembayaran lewat GoPay, OVO, DANA, QRIS, atau transfer ke Admin.'
        : 'Pembayaran bisa lewat GoPay, OVO, DANA, QRIS, atau transfer ke rekening Admin. '
            'Batas bayarnya 30 menit setelah pesanan dibuat, dan uangmu ditahan aman oleh Admin '
            'sampai pesanan kamu terima.');
  }
  if (_has(t, ['retur', 'refund', 'tukar', 'komplen', 'komplain', 'rusak', 'cacat', 'salah kirim', 'garansi', 'kembalikan'])) {
    out.add('Kalau barang bermasalah, buka Pesanan Saya lalu tekan Ajukan Komplen dan jelaskan '
        'masalahnya (setelah pesanan kamu terima). Admin akan memeriksa, dan bila disetujui '
        'uangmu dikembalikan.');
  }
  if (_has(t, ['lokasi', 'jam buka', 'alamat toko', 'dimana toko'])) {
    out.add('Kami toko online, jadi order kapan saja lewat aplikasi ya, kak. Alamat pengiriman bisa '
        'diatur di Profil > Alamat Saya.');
  }
  if (_has(t, ['grosir', 'reseller', 'dropship', 'partai'])) {
    out.add('Untuk pembelian grosir atau reseller, silakan sebutkan produk dan jumlahnya, '
        'nanti kami bantu cek ketersediaannya.');
  }

  if (out.isNotEmpty) return out.join('\n\n');

  if (_has(t, ['terima kasih', 'makasih', 'thanks', 'thank', 'mantap', 'oke', 'ok', 'siap'])) {
    return _pick([
      'Sama-sama, kak! Kalau ada yang mau ditanyakan lagi, kabari kami ya.',
      'Siap, terima kasih sudah berbelanja di $storeName!',
    ]);
  }
  if (_has(t, ['halo', 'hai', 'hallo', 'hi', 'pagi', 'siang', 'sore', 'malam', 'assalamualaikum', 'permisi'])) {
    return _pick([
      'Halo kak! Ada yang bisa kami bantu soal produk atau pesananmu?',
      'Hai, selamat datang di $storeName! Mau tanya stok, ukuran, atau pengiriman?',
    ]);
  }
  return _pick([
    'Maaf, kami belum menangkap maksud pertanyaannya. Kamu bisa tanya soal stok, ukuran, '
        'warna, harga, promo, pengiriman, pembayaran, atau retur.',
    'Boleh dijelaskan lebih detail, kak? Misalnya "stok ready?", "ada ukuran 38?", atau "bagaimana cara retur?".',
    'Pesanmu sudah kami terima. Untuk jawaban paling cepat, coba tanyakan seputar stok, ukuran, harga, atau pengiriman ya.',
  ]);
}

String adminReply(String raw) {
  final t = _norm(raw);
  if (_has(t, ['verifikasi', 'bukti', 'konfirmasi', 'bayar', 'pembayaran', 'transfer'])) {
    return 'Admin memeriksa bukti pembayaran yang kamu unggah. Setelah terverifikasi, status pesanan '
        'berubah menjadi Dikemas. Pastikan nominal dan bukti transfernya jelas ya.';
  }
  if (_has(t, ['refund', 'uang kembali', 'komplen', 'komplain', 'batal'])) {
    return 'Untuk komplen atau refund, ajukan lewat Pesanan Saya > Ajukan Komplen. Bila disetujui, '
        'uangmu dikembalikan oleh Admin. Pesanan yang belum dibayar akan batal otomatis setelah 30 menit.';
  }
  if (_has(t, ['aman', 'escrow', 'ditahan', 'penipuan'])) {
    return 'Pembayaranmu ditahan dulu oleh Admin (escrow) dan baru diteruskan ke penjual setelah '
        'kamu menerima pesanan.';
  }
  if (_has(t, ['resi', 'kirim', 'status', 'paket', 'pesanan'])) {
    return _orderStatus();
  }
  if (_has(t, ['halo', 'hai', 'hallo', 'hi', 'pagi', 'siang', 'sore', 'malam'])) {
    return 'Halo, ini Admin $storeName. Ada kendala pembayaran atau pesanan?';
  }
  return _pick([
    'Terima kasih, Admin sudah menerima pesanmu. Boleh sebutkan nomor pesanan agar kami cek?',
    'Kami bantu cek ya. Kendalanya di pembayaran, pengiriman, atau komplen?',
  ]);
}
