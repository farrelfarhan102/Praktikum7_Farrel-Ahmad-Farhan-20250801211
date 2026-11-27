import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../core/constants.dart';
import '../models/product_model.dart';

Future<({List<Product> products, List<String> labels})> visualMatch(
    String path) async {
  final labeler =
      ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.45));
  var found = <ImageLabel>[];
  try {
    found = await labeler.processImage(InputImage.fromFilePath(path));
  } catch (_) {
    // model gagal: tetap tampilkan produk terlaris di bawah
  } finally {
    await labeler.close();
  }
  final score = <String, double>{};
  for (final p in products) {
    final words = visualKeywords[p.id] ?? p.name.toLowerCase().split(' ');
    var s = 0.0;
    for (final l in found) {
      final t = l.label.toLowerCase();
      if (t.length < 3) continue;
      if (words.any((w) => w.length >= 3 && (t.contains(w) || w.contains(t)))) {
        s += l.confidence;
      }
    }
    score[p.id] = s;
  }
  final ranked = [...products]..sort((a, b) {
      final d = score[b.id]!.compareTo(score[a.id]!);
      return d != 0 ? d : b.rating.compareTo(a.rating);
    });
  return (products: ranked, labels: [for (final l in found) l.label]);
}
