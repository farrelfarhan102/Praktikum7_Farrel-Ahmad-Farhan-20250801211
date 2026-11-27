import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/order_model.dart';

/// Pelacak status pengiriman sederhana: Dikemas -> Dikirim -> Diterima.
/// Hanya menampilkan status (tanpa riwayat perjalanan paket).
class ShippingStatus extends StatelessWidget {
  final Order o;
  const ShippingStatus(this.o, {super.key});

  static const _icons = [
    Icons.inventory_2_outlined,
    Icons.local_shipping_outlined,
    Icons.check_circle_outline,
  ];

  static const _caption = [
    'Pesanan sedang dikemas, menunggu diserahkan ke kurir',
    'Pesanan sedang dalam pengiriman',
    'Pesanan sudah diterima',
  ];

  @override
  Widget build(BuildContext context) {
    final cur = o.shipStep;
    if (cur < 0) return const SizedBox.shrink();
    final n = Order.shipSteps.length;
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < n; i++) ...[
                _dot(i, cur),
                if (i < n - 1)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i < cur ? pink : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < n; i++)
                Expanded(
                  child: Text(
                    Order.shipSteps[i],
                    textAlign: i == 0
                        ? TextAlign.left
                        : i == n - 1
                            ? TextAlign.right
                            : TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: i == cur ? FontWeight.w800 : FontWeight.w500,
                      color: i <= cur ? pink : Colors.black45,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _caption[cur],
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _dot(int i, int cur) {
    final done = i <= cur;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? pink : Colors.white,
        border: Border.all(color: done ? pink : Colors.black12, width: 1.5),
      ),
      child: Icon(
        _icons[i],
        size: 16,
        color: done ? Colors.white : Colors.black38,
      ),
    );
  }
}
