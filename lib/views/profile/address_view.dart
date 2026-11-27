import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme.dart';
import '../../models/address_model.dart';
import '../widgets/common_widgets.dart';

class AddressPage extends StatelessWidget {
  final bool pick; // true = dipakai untuk memilih alamat saat checkout
  const AddressPage({super.key, this.pick = false});

  Future<void> form(BuildContext c, [Address? a]) async {
    final nm = TextEditingController(text: a?.name ?? Auth.name);
    final ph = TextEditingController(text: a?.phone ?? '');
    final tx = TextEditingController(text: a?.text ?? '');
    var label = a?.label ?? 'Rumah';
    String? err;
    final ok = await showModalBottomSheet<bool>(
      context: c,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (b) => StatefulBuilder(
        builder: (b, set) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(b).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a == null ? 'Tambah Alamat' : 'Ubah Alamat',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final l in ['Rumah', 'Kantor', 'Lainnya'])
                      pill(
                        l,
                        sel: label == l,
                        onTap: () => set(() => label = l),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                field(nm, hint: 'Nama penerima'),
                const SizedBox(height: 10),
                field(
                  ph,
                  hint: 'No. HP (08xxxxxxxxxx)',
                  kb: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                field(
                  tx,
                  hint: 'Alamat lengkap (jalan, kecamatan, kota, kode pos)',
                  lines: 3,
                ),
                if (err != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      err!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 16),
                PButton('Simpan', () {
                  if (nm.text.trim().isEmpty) {
                    set(() => err = 'Nama penerima wajib diisi');
                    return false;
                  }
                  if (ph.text.replaceAll(RegExp(r'\D'), '').length < 9) {
                    set(() => err = 'No. HP tidak valid');
                    return false;
                  }
                  if (tx.text.trim().length < 10) {
                    set(() => err = 'Alamat terlalu pendek, tulis lengkap');
                    return false;
                  }
                  Navigator.pop(b, true);
                  return true;
                }, icon: Icons.save),
              ],
            ),
          ),
        ),
      ),
    );
    final nameVal = nm.text.trim();
    final phoneVal = ph.text.trim();
    final textVal = tx.text.trim();
    nm.dispose();
    ph.dispose();
    tx.dispose();
    if (ok != true) return;
    app.update(() {
      if (a == null) {
        app.addresses.add(Address(label, nameVal, phoneVal, textVal));
      } else {
        a.label = label;
        a.name = nameVal;
        a.phone = phoneVal;
        a.text = textVal;
      }
    });
  }

  Future<void> remove(BuildContext c, int i) async {
    final ok = await showDialog<bool>(
      context: c,
      builder: (d) => AlertDialog(
        title: const Text('Hapus alamat?'),
        content: Text(app.addresses[i].text),
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
    if (ok != true) return;
    app.update(() {
      app.addresses.removeAt(i);
      if (i < app.mainAddr) {
        app.mainAddr--;
      } else if (i == app.mainAddr) {
        app.mainAddr = 0;
      }
    });
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: subBar(pick ? 'Pilih Alamat' : 'Alamat Saya'),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => form(c),
          backgroundColor: pink,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Tambah Alamat'),
        ),
        body: ListenableBuilder(
          listenable: app,
          builder: (_, _) => app.addresses.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Belum ada alamat.\nKetuk "Tambah Alamat" untuk menambah alamat pengiriman.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    for (var i = 0; i < app.addresses.length; i++)
                      Builder(
                        builder: (_) {
                          final a = app.addresses[i];
                          final main = i == app.mainAddr;
                          return Bouncy(
                            onTap: pick ? () => Navigator.pop(c, a) : () {},
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: card().copyWith(
                                border: Border.all(
                                  color: main ? pink : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        a.label == 'Kantor'
                                            ? Icons.business
                                            : (a.label == 'Rumah'
                                                ? Icons.home_outlined
                                                : Icons.place_outlined),
                                        size: 18,
                                        color: pink,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        a.label,
                                        style: const TextStyle(
                                          color: pink,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (main) sbtn('Utama', () {}),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${a.name}   |   ${a.phone}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    a.text,
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      sbtn('Ubah', () => form(c, a)),
                                      sbtn('Hapus', () => remove(c, i)),
                                      if (!main)
                                        sbtn(
                                          'Jadikan Utama',
                                          () => app.update(
                                            () => app.mainAddr = i,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
        ),
      );
}
