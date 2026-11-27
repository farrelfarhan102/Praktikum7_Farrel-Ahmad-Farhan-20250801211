class Product {
  final String id, name, emoji;
  final int price;
  final double rating;
  const Product(this.id, this.name, this.emoji, this.price, this.rating);
}

final products = <Product>[
  const Product('1', 'Cloud Marshmallow Slide', '🩴', 350000, 4.9),
  const Product('2', 'Pastel Blossom Clogs', '👡', 280000, 4.9),
  const Product('3', 'Sunshine Foam Slide', '🩴', 420000, 4.8),
  const Product('4', 'Daisy Jibbitz Charm Set', '🌼', 45000, 4.9),
  const Product('5', 'Marshmallow Strap Slide', '🩴', 195000, 4.9),
];

final photos = <String, String>{};
