import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/visual_search_controller.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/product_model.dart';
import '../widgets/common_widgets.dart';
import 'chat_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const _fallbackProduct =
      Product('1', 'Cloud Marshmallow Slide', '🩴', 350000, 4.9);

  String g = 'Wanita';
  Set<String> get fav => app.wishlist;

  Future<void> scan() async {
    final f = await ImagePicker().pickImage(source: ImageSource.camera);
    if (f == null || !mounted) return;
    toast(context, 'Menganalisis foto...', secs: 2);
    final m = await visualMatch(f.path); // ML Kit Image Labeling (di perangkat)
    if (!mounted) return;
    final r = m.products;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (b) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(f.path),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Produk mirip yang ditemukan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (m.labels.isNotEmpty)
              Text(
                'Terdeteksi: ${m.labels.take(4).join(', ')}',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            for (final p in r.take(3))
              ListTile(
                leading: ph(p, h: 44, w: 44),
                title: Text(p.name),
                subtitle: Text(rp(p.price)),
                trailing: Bouncy(
                  onTap: () {
                    app.add(p);
                    Navigator.pop(b);
                  },
                  child: const Icon(Icons.add_shopping_cart, color: pink),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void previewProduct(Product p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (b) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ph(p, h: 260, w: double.infinity, r: 20),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                ),
                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${p.rating} (${reviews[p.id] ?? 0} ulasan)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              rp(p.price),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: pink,
              ),
            ),
            const SizedBox(height: 6),
            if (opt[p.id] != null)
              Text(
                opt[p.id]!,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            const SizedBox(height: 4),
            Text(
              desc[p.id] ?? 'Sandal nyaman berkualitas premium',
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            PButton(
              'Tambah ke Keranjang',
              () {
                app.add(p);
                Navigator.pop(b);
                toast(context, '${p.name} masuk keranjang');
              },
              icon: Icons.add_shopping_cart,
            ),
            const SizedBox(height: 10),
            PButton(
              'Chat Penjual',
              () {
                Navigator.pop(b);
                openSellerChat(context, product: p);
              },
              icon: Icons.chat_bubble_outline,
              outline: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget item(Product p, int i) => pop(
        i,
        Container(
          decoration: card(),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Bouncy(
                    onTap: () => previewProduct(p),
                    child: ph(p, h: 112, w: double.infinity, r: 14),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Bouncy(
                      onTap: () {
                        app.update(
                          () => fav.contains(p.id)
                              ? fav.remove(p.id)
                              : fav.add(p.id),
                        );
                        setState(() {});
                      },
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white.withValues(alpha: .92),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (w, a) =>
                              ScaleTransition(scale: a, child: w),
                          child: Icon(
                            fav.contains(p.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            key: ValueKey(fav.contains(p.id)),
                            color: pink,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${p.rating}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' (${reviews[p.id] ?? 0})',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                desc[p.id] ?? 'Sandal nyaman',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const Spacer(),
              Text(
                rp(p.price),
                style: const TextStyle(color: pink, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: miniBtn('+ Tambah', () {
                      app.add(p);
                      toast(context, '${p.name} masuk keranjang');
                    }),
                  ),
                  const SizedBox(width: 8),
                  Bouncy(
                    onTap: () => openSellerChat(context, product: p),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: pink,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext c) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: soft,
                    child: Icon(Icons.storefront, color: pink),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${Auth.name}!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: pink,
                          ),
                        ),
                        const Text(
                          'Cari sandal & aksesoris favoritmu',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Bouncy(
                    onTap: () => tab.value = 2,
                    child: ListenableBuilder(
                      listenable: app,
                      builder: (_, _) => Badge.count(
                        count: app.cart.length,
                        isLabelVisible: app.cart.isNotEmpty,
                        backgroundColor: pink,
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: pink,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: lav,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.black45),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Cari sandal & aksesoris...',
                              style: TextStyle(color: Colors.black45),
                            ),
                          ),
                          Bouncy(
                            onTap: scan,
                            child: const Icon(Icons.camera_alt, color: pink),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: lav,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.tune, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    pill(
                      'Wanita',
                      sel: g == 'Wanita',
                      ic: g == 'Wanita' ? Icons.check : null,
                      onTap: () => setState(() => g = 'Wanita'),
                    ),
                    const SizedBox(width: 8),
                    pill(
                      'Pria',
                      sel: g == 'Pria',
                      ic: g == 'Pria' ? Icons.check : null,
                      onTap: () => setState(() => g = 'Pria'),
                    ),
                    const SizedBox(width: 8),
                    pill('Koleksi Baru', ic: Icons.auto_awesome, bgc: yel),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFCE7F3), Color(0xFFFEF08A)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gold),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: pink,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Spesial Minggu Ini',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Promo Bundle:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'Beli 2 Diskon 20%',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: pink,
                            ),
                          ),
                          const Text(
                            'Kombinasi sandal chic & charms...',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 150,
                            child: PButton(
                              'Klaim Promo',
                              () => toast(c, 'Promo berhasil diklaim'),
                              icon: Icons.arrow_forward,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.rotate(
                      angle: .06,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ph(
                          products.isNotEmpty
                              ? products.first
                              : _fallbackProduct,
                          h: 110,
                          w: 100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              head('Kategori Populer', 'Lihat Semua'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final e in {
                    'Platform Slides': '1',
                    'Clogs': '2',
                    'Chunky Mules': '3',
                    'Gladiators': '5',
                  }.entries)
                    Column(
                      children: [
                        Bouncy(
                          onTap: () => toast(c, e.key),
                          child: Container(
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: pink.withValues(alpha: .25),
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: ph(
                                  products.firstWhere(
                                    (p) => p.id == e.value,
                                    orElse: () => products.isNotEmpty
                                        ? products.first
                                        : _fallbackProduct,
                                  ),
                                  h: 64,
                                  w: 64,
                                  r: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          e.key,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 14),
              box(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: yel,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.extension, color: Colors.brown),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Koleksi Aksesoris & Pins',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Kustom sandalmu mulai Rp 15.000',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    sbtn('Lihat', () => toast(c, 'Koleksi aksesoris')),
                  ],
                ),
              ),
              ListenableBuilder(
                listenable: app,
                builder: (_, _) {
                  final list = List<Product>.from(products);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pilihan Terlaris',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Menampilkan ${list.length} produk',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: .62,
                        ),
                        itemCount: list.length,
                        itemBuilder: (_, i) => item(list[i], i),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
}
