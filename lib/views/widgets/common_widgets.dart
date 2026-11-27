import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../admin/admin_shell_view.dart';
import '../auth/login_view.dart';
import '../customer/shell_view.dart';

// ───────────── WIDGET ANIMASI & TOMBOL ─────────────
Widget pop(int i, Widget w) => TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + i * 80),
      curve: Curves.easeOutCubic,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: c),
      ),
      child: w,
    );

/// Tombol kecil/ikon dengan efek menciut saat ditekan
class Bouncy extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const Bouncy({super.key, required this.child, required this.onTap});
  @override
  State<Bouncy> createState() => _BouncyState();
}

class _BouncyState extends State<Bouncy> {
  bool down = false;
  @override
  Widget build(BuildContext c) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => down = true),
        onTapCancel: () => setState(() => down = false),
        onTapUp: (_) {
          setState(() => down = false);
          widget.onTap();
        },
        child: AnimatedScale(
          scale: down ? .85 : 1,
          duration: const Duration(milliseconds: 120),
          child: widget.child,
        ),
      );
}

Widget miniBtn(String t, VoidCallback f) => Bouncy(
      onTap: f,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: pink.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          t,
          style: const TextStyle(color: pink, fontWeight: FontWeight.bold),
        ),
      ),
    );

/// Tombol utama: menciut saat ditekan -> loading -> centang hijau
class PButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Function() onTap;
  final bool outline;
  const PButton(this.label, this.onTap, {super.key, this.icon, this.outline = false});
  @override
  State<PButton> createState() => _PState();
}

class _PState extends State<PButton> {
  bool down = false, busy = false, done = false;
  Future<void> _go() async {
    if (busy) return;
    setState(() => busy = true);
    final r = await widget.onTap();
    if (!mounted) return;
    if (r == false) {
      // aksi gagal (mis. login salah): hentikan loading tanpa centang hijau
      setState(() => busy = false);
      return;
    }
    setState(() {
      busy = false;
      done = true;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => done = false);
  }

  @override
  Widget build(BuildContext c) {
    final o = widget.outline, fg = o ? pink : Colors.white;
    return GestureDetector(
      onTapDown: (_) => setState(() => down = true),
      onTapCancel: () => setState(() => down = false),
      onTapUp: (_) {
        setState(() => down = false);
        _go();
      },
      child: AnimatedScale(
        scale: down ? .94 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 52,
          decoration: BoxDecoration(
            gradient: o
                ? null
                : LinearGradient(
                    colors: done ? [Colors.green, Colors.green.shade300] : [pink, pink2],
                  ),
            color: o ? Colors.white : null,
            border: o ? Border.all(color: done ? Colors.green : pink, width: 1.5) : null,
            borderRadius: BorderRadius.circular(done ? 26 : 16),
            boxShadow: down || o
                ? []
                : [
                    BoxShadow(
                      color: pink.withValues(alpha: .35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (w, a) => ScaleTransition(scale: a, child: w),
              child: busy
                  ? SizedBox(
                      key: const ValueKey('b'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
                    )
                  : done
                      ? Icon(
                          Icons.check_circle,
                          key: const ValueKey('d'),
                          color: o ? Colors.green : Colors.white,
                        )
                      : Row(
                          key: const ValueKey('n'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(widget.icon, color: fg, size: 20),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.label,
                              style: TextStyle(
                                color: fg,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Timer mundur (mm:ss), merah saat < 1 menit
class Countdown extends StatefulWidget {
  final int seconds;
  final VoidCallback onEnd;
  const Countdown(this.seconds, this.onEnd, {super.key});
  @override
  State<Countdown> createState() => _CdState();
}

class _CdState extends State<Countdown> {
  late int left = widget.seconds;
  Timer? t;
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (left <= 1) {
        t?.cancel();
        setState(() => left = 0);
        widget.onEnd();
      } else {
        setState(() => left--);
      }
    });
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final col = left < 60 ? Colors.red : pink;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: col.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, size: 18, color: col),
          const SizedBox(width: 6),
          Text(
            '${(left ~/ 60).toString().padLeft(2, '0')}:${(left % 60).toString().padLeft(2, '0')}',
            style: TextStyle(fontWeight: FontWeight.bold, color: col),
          ),
        ],
      ),
    );
  }
}

// ───────────── HELPER UI ─────────────
Widget ph(Product p, {double? h, double? w, double r = 12}) {
  final f = photos[p.id];
  final fb = Container(
    height: h,
    width: w,
    color: soft,
    alignment: Alignment.center,
    child: const Icon(Icons.shopping_bag_outlined, color: pink, size: 28),
  );
  return ClipRRect(
    borderRadius: BorderRadius.circular(r),
    child: f != null
        ? Image.file(
            File(f),
            height: h,
            width: w,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => fb,
          )
        : Image.asset(
            'assets/images/p${p.id}.png',
            height: h,
            width: w,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => fb,
          ),
  );
}

void toast(BuildContext c, String m, {int secs = 1}) =>
    ScaffoldMessenger.of(c).showSnackBar(
      SnackBar(content: Text(m), duration: Duration(seconds: secs)),
    );

Widget pill(
  String t, {
  bool sel = false,
  IconData? ic,
  Color? bgc,
  VoidCallback? onTap,
}) =>
    Bouncy(
      onTap: onTap ?? () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? soft : bgc ?? Colors.white,
          border: Border.all(
            color: sel ? pink : (bgc != null ? gold : Colors.black12),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ic != null) ...[
              Icon(ic, size: 14, color: pink),
              const SizedBox(width: 4),
            ],
            Text(
              t,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: sel ? pink : ink,
              ),
            ),
          ],
        ),
      ),
    );

Widget sbtn(String t, VoidCallback f, {bool dark = false}) => Bouncy(
      onTap: f,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: dark ? Colors.black87 : soft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          t,
          style: TextStyle(
            color: dark ? Colors.white : pink,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );

Widget head(String t, [String? a]) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            t,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          if (a != null)
            Text(
              a,
              style: const TextStyle(
                fontSize: 12,
                color: pink,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );

Widget box({required Widget child, Color? c}) => Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: card().copyWith(color: c),
      child: child,
    );

Widget srow(String a, String b, {bool big = false, Color? c}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            a,
            style: TextStyle(
              color: big ? ink : Colors.black54,
              fontWeight: big ? FontWeight.w800 : FontWeight.normal,
              fontSize: big ? 17 : 14,
            ),
          ),
          Text(
            b,
            style: TextStyle(
              color: c ?? (big ? pink : ink),
              fontWeight: big ? FontWeight.w800 : FontWeight.w600,
              fontSize: big ? 20 : 14,
            ),
          ),
        ],
      ),
    );

Widget field(
  TextEditingController t, {
  String? hint,
  int lines = 1,
  ValueChanged<String>? onChanged,
  TextInputType? kb,
}) =>
    TextField(
      controller: t,
      maxLines: lines,
      keyboardType: kb,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: lav,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );

PreferredSizeWidget subBar(String t) => AppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        t,
        style: const TextStyle(fontWeight: FontWeight.w800, color: pink),
      ),
    );

Widget secTitle(String t) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

Widget navRow(IconData i, String t, String s, VoidCallback f) => Bouncy(
      onTap: f,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: soft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(i, color: pink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    s,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: pink2),
          ],
        ),
      ),
    );

void open(BuildContext c, Widget w) =>
    Navigator.push(c, MaterialPageRoute(builder: (_) => w));

Future<void> doLogout(BuildContext c) async {
  await Auth.logout();
  app.resetPersonal();
  if (c.mounted) {
    Navigator.pushAndRemoveUntil(
      c,
      MaterialPageRoute(builder: (_) => const Login()),
      (r) => false,
    );
  }
}

Widget authField(
  TextEditingController t,
  String hint,
  IconData i, {
  bool pw = false,
  bool hide = true,
  VoidCallback? toggle,
  TextInputType? kb,
}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: t,
        obscureText: pw && hide,
        keyboardType: kb,
        autocorrect: !pw,
        enableSuggestions: !pw,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(i),
          suffixIcon: pw
              ? IconButton(
                  onPressed: toggle,
                  icon: Icon(hide ? Icons.visibility : Icons.visibility_off),
                )
              : null,
          filled: true,
          fillColor: lav,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );

/// Jalankan aksi auth; true bila sukses (lalu masuk ke beranda), false bila gagal (tampilkan pesan).
Future<bool> authRun(BuildContext c, Future<void> Function() f) async {
  try {
    await f();
  } on AuthException catch (e) {
    if (c.mounted) toast(c, e.message, secs: 4);
    return false;
  } catch (e) {
    if (c.mounted) toast(c, 'Terjadi kesalahan: $e', secs: 4);
    return false;
  }
  if (!c.mounted) return true;
  tab.value = 0;
  // admin & pelanggan dipisah: admin masuk ke area admin, pelanggan ke toko
  final Widget dest = Auth.isAdmin ? const AdminShell() : const Shell();
  Navigator.of(c).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => dest),
    (r) => false,
  );
  return true;
}

Widget authHeader(String title, String sub) => Container(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
      decoration: const BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.storefront, color: pink, size: 32),
              SizedBox(width: 10),
              Text(
                storeName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          pill('Voucher member baru', ic: Icons.confirmation_number),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: ink,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.elasticOut,
                builder: (_, v, ch) => Transform.scale(scale: v, child: ch),
                child: Container(
                  width: 80,
                  height: 80,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: pink.withValues(alpha: .18),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/images/p2.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.shopping_bag_outlined,
                        color: pink,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(sub, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
