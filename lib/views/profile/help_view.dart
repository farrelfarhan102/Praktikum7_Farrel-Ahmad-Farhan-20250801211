import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../customer/chat_view.dart';
import '../widgets/common_widgets.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});
  @override
  State<HelpPage> createState() => _HelpState();
}

class _HelpState extends State<HelpPage> {
  String q = '';
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final l = faqs
        .where(
          (f) =>
              q.isEmpty ||
              f.$1.toLowerCase().contains(q) ||
              f.$2.toLowerCase().contains(q),
        )
        .toList();
    return Scaffold(
      appBar: subBar('Pusat Bantuan'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          field(
            search,
            hint: 'Cari pertanyaan...',
            onChanged: (v) => setState(() => q = v.trim().toLowerCase()),
          ),
          const SizedBox(height: 14),
          if (l.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Tidak ada hasil. Coba kata lain atau hubungi kami lewat chat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          for (final f in l)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: card(),
              child: Theme(
                data: Theme.of(c).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  expandedAlignment: Alignment.centerLeft,
                  title: Text(
                    f.$1,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  children: [
                    Text(f.$2, style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          box(
            c: yel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Masih butuh bantuan?',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Chat langsung dengan Penjual atau Admin.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                PButton(
                  'Chat Sekarang',
                  () => open(c, const ChatPage()),
                  icon: Icons.chat_bubble_outline,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
