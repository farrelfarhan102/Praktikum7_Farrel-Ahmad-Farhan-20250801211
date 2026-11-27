import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/app_controller.dart';
import '../../core/theme.dart';
import '../../models/product_model.dart';
import '../widgets/common_widgets.dart';

class AdminProducts extends StatelessWidget {
  const AdminProducts({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin • Produk',
            style: TextStyle(fontWeight: FontWeight.w800, color: pink),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => open(c, const AddProduct()),
          backgroundColor: pink,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Tambah Produk'),
        ),
        body: ListenableBuilder(
          listenable: app,
          builder: (_, _) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              for (final p in List.of(products))
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: card(),
                  child: Row(
                    children: [
                      ph(p, h: 56, w: 56),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              rp(p.price),
                              style: const TextStyle(
                                color: pink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: c,
                            builder: (d) => AlertDialog(
                              title: const Text('Hapus produk?'),
                              content: Text(p.name),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(d, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(d, true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) {
                            app.update(() {
                              products.remove(p);
                              app.cart.removeWhere((x) => x.id == p.id);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              if (products.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Belum ada produk.'),
                  ),
                ),
            ],
          ),
        ),
      );
}

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});
  @override
  State<AddProduct> createState() => _AddState();
}

class _AddState extends State<AddProduct> {
  final pics = <String>[];
  final nm = TextEditingController(text: 'Cloud Marshmallow Platform Slide');
  final ds = TextEditingController(
    text:
        'Sandal platform empuk berbahan EVA foam premium ultra-ringan, anti-slip dan tahan air dengan slot charm kustom...',
  );
  final pr = TextEditingController(text: '350000');
  final st = TextEditingController(text: '50');
  String cat = 'Wanita';
  int draf = 2;
  final sz = <String>{'EU 38', 'EU 39'},
      cl = <String>{'Pastel Pink', 'Pastel Yellow'};
  static const colors = {
    'Pastel Pink': Color(0xFFF9A8D4),
    'Pastel Yellow': Color(0xFFFDE047),
    'Off-White': Color(0xFFF5F5F4),
    'Black': Colors.black,
  };

  @override
  void dispose() {
    for (final t in [nm, ds, pr, st]) {
      t.dispose();
    }
    super.dispose();
  }

  Future<void> pickPics() async {
    final room = 6 - pics.length;
    if (room <= 0) return;
    final l = await ImagePicker().pickMultiImage();
    if (l.isNotEmpty) {
      setState(() => pics.addAll(l.map((x) => x.path).take(room)));
    }
  }

  Future<bool> save() async {
    final n = nm.text.trim();
    if (n.isEmpty) {
      toast(context, 'Nama produk wajib diisi');
      return false;
    }
    await Future.delayed(const Duration(milliseconds: 600));
    var nextId = products.fold<int>(
          5,
          (m, p) => (int.tryParse(p.id) ?? 0) > m ? int.parse(p.id) : m,
        ) +
        1;
    while (products.any((p) => p.id == '$nextId') || nextId == 4) {
      nextId++;
    }
    final p = Product(
      '$nextId',
      n,
      '🩴',
      int.tryParse(pr.text.replaceAll(RegExp(r'\D'), '')) ?? 0,
      5.0,
    );
    if (pics.isNotEmpty) photos[p.id] = pics.first;
    app.update(() => products.add(p));
    if (mounted) toast(context, 'Produk "$n" tersimpan & tampil di Beranda');
    return true;
  }

  Widget lbl(String t, [String? r]) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            if (r != null)
              Text(
                r,
                style: const TextStyle(
                  fontSize: 11,
                  color: pink,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Produk Baru',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              Text(
                'KATALOG ADMIN',
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            Center(
              child: sbtn('Draf ($draf)', () => toast(c, 'Draf produk')),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Foto Produk',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                sbtn('${pics.length} dari 6 Terunggah', () {}),
              ],
            ),
            const SizedBox(height: 10),
            Bouncy(
              onTap: pickPics,
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: lav,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: pink2, width: 1.5),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: soft,
                      child: Icon(Icons.add_photo_alternate, color: pink),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Unggah Foto Sandal & Aksesoris',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Mendukung format JPG, PNG (Maks 10MB)',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    Text(
                      'Ketuk untuk memilih file',
                      style: TextStyle(
                        color: pink,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (pics.isNotEmpty)
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var i = 0; i < pics.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(top: 12, right: 10),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(pics[i]),
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                color: i == 0 ? pink : Colors.black54,
                                child: Text(
                                  i == 0 ? 'Foto Utama' : 'Foto ${i + 1}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Bouncy(
                                onTap: () => setState(() => pics.removeAt(i)),
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            box(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  lbl('Nama Produk *', '${nm.text.length}/80'),
                  field(nm, onChanged: (_) => setState(() {})),
                  lbl('Kategori Sandal'),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final k in ['Wanita', 'Pria', 'Unisex'])
                        pill(
                          k,
                          sel: cat == k,
                          ic: cat == k ? Icons.check : null,
                          onTap: () => setState(() => cat = k),
                        ),
                    ],
                  ),
                  lbl('Deskripsi Produk *', 'Template Deskripsi'),
                  field(ds, lines: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            lbl('HARGA (RP) *'),
                            field(pr, kb: TextInputType.number),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            lbl('JUMLAH STOK *'),
                            field(st, kb: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            box(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Varian & Opsi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const Text(
                    'Tentukan ukuran sandal dan pilihan warna dasar',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  lbl('Ukuran (EU Continental)', '${sz.length} dipilih'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var n = 35; n <= 41; n++)
                        pill(
                          'EU $n',
                          sel: sz.contains('EU $n'),
                          ic: sz.contains('EU $n') ? Icons.check : null,
                          onTap: () => setState(
                            () => sz.contains('EU $n')
                                ? sz.remove('EU $n')
                                : sz.add('EU $n'),
                          ),
                        ),
                    ],
                  ),
                  lbl('Warna Sandal', '${cl.length} dipilih'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final e in colors.entries)
                        Bouncy(
                          onTap: () => setState(
                            () => cl.contains(e.key)
                                ? cl.remove(e.key)
                                : cl.add(e.key),
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width:
                                (MediaQuery.of(c).size.width - 32 - 32 - 10) /
                                    2,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cl.contains(e.key) ? soft : Colors.white,
                              border: Border.all(
                                color: cl.contains(e.key)
                                    ? pink
                                    : Colors.black12,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: e.value,
                                  child: CircleAvatar(
                                    radius: 9,
                                    backgroundColor: e.value,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Icon(
                                  cl.contains(e.key)
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: cl.contains(e.key)
                                      ? pink
                                      : Colors.black26,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: soft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.star, color: pink),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Slot Charm Kustom Aktif',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Sandal ini kompatibel dengan pin & charm 12mm.',
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PButton('Simpan Produk', save, icon: Icons.upload),
            const SizedBox(height: 10),
            PButton(
              'Simpan sebagai Draf',
              () {
                setState(() => draf++);
                toast(c, 'Draf tersimpan');
              },
              icon: Icons.save,
              outline: true,
            ),
          ],
        ),
      );
}
