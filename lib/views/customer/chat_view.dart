import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/chat_reply_controller.dart';
import '../../core/theme.dart';
import '../../models/message_model.dart';
import '../../models/product_model.dart';
import '../widgets/common_widgets.dart';

/// Buka chat dengan Penjual. Bila [product] diberikan, produk tersebut
/// otomatis muncul sebagai tag/kartu di awal percakapan.
void openSellerChat(BuildContext c, {Product? product}) => Navigator.push(
      c,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text(
              'Chat Penjual',
              style: TextStyle(fontWeight: FontWeight.w800, color: pink),
            ),
          ),
          body: ChatRoom('Penjual', product: product),
        ),
      ),
    );

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String room = 'Penjual';
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chat',
            style: TextStyle(fontWeight: FontWeight.w800, color: pink),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Row(
              children: [
                const SizedBox(width: 12),
                for (final r in app.chats.keys)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(r),
                      selected: room == r,
                      onSelected: (_) => setState(() => room = r),
                    ),
                  ),
              ],
            ),
          ),
        ),
        body: ChatRoom(room, key: ValueKey(room)),
      );
}

class ChatRoom extends StatefulWidget {
  final String room;

  /// Produk yang otomatis di-tag ke percakapan saat ruang chat dibuka.
  final Product? product;
  const ChatRoom(this.room, {super.key, this.product});
  @override
  State<ChatRoom> createState() => _ChatState();
}

class _ChatState extends State<ChatRoom> {
  final t = TextEditingController();
  final sc = ScrollController();
  int _shown = -1;

  @override
  void initState() {
    super.initState();
    _tagProduct();
  }

  /// Tambahkan kartu produk ke percakapan (sekali saja bila tag yang sama
  /// masih menjadi pesan terakhir), lalu penjual menyapa soal produk itu.
  void _tagProduct() {
    final p = widget.product;
    if (p == null) return;
    final l = app.chats[widget.room]!;
    final last = l.isEmpty ? null : l.last;
    if (last != null && last.me && last.product?.id == p.id) return;
    l.add(Msg('Halo, saya mau tanya produk ini', true, product: p));
    Future.delayed(
      const Duration(seconds: 1),
      () => app.update(
        () => l.add(
          Msg(
            'Halo! Terima kasih sudah tertarik dengan ${p.name}. '
            'Ada yang ingin ditanyakan soal ukuran, warna, atau stok?',
            false,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    t.dispose();
    sc.dispose();
    super.dispose();
  }

  void send() {
    final s = t.text.trim();
    if (s.isEmpty) return;
    t.clear();
    final l = app.chats[widget.room]!;
    // produk yang sedang dibicarakan: tag terakhir di percakapan ini
    Product? ctx = widget.product;
    for (final m in l.reversed) {
      if (m.product != null) {
        ctx = m.product;
        break;
      }
    }
    final reply = widget.room == 'Admin'
        ? adminReply(s)
        : sellerReply(s, context: ctx);
    app.update(() => l.add(Msg(s, true)));
    Future.delayed(
      const Duration(seconds: 1),
      () => app.update(() => l.add(Msg(reply, false))),
    );
  }

  void _toEnd() {
    if (!sc.hasClients) return;
    sc.animateTo(
      sc.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Widget _productTag(Product p) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ph(p, h: 52, w: 52, r: 10),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rp(p.price),
                    style: const TextStyle(
                      color: pink,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _bubble(Msg m) => Align(
        alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
        child: pop(
          0,
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              color: m.me ? pink : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (m.product != null) _productTag(m.product!),
                Text(
                  m.text,
                  style: TextStyle(
                    color: m.me ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext c) => ListenableBuilder(
        listenable: app,
        builder: (_, _) {
          final msgs = app.chats[widget.room]!;
          if (msgs.length != _shown) {
            _shown = msgs.length;
            WidgetsBinding.instance.addPostFrameCallback((_) => _toEnd());
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  controller: sc,
                  padding: const EdgeInsets.all(16),
                  children: [for (final m in msgs) _bubble(m)],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: t,
                          onSubmitted: (_) => send(),
                          decoration: InputDecoration(
                            hintText: 'Tulis pesan...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Bouncy(
                        onTap: send,
                        child: const CircleAvatar(
                          backgroundColor: pink,
                          child: Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
}
