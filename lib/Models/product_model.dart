class Product {
  final String id;
  final String imageUrl;
  final String price;
  final String name;
  final bool isLiked;
  final bool isInCart;

  Product({
    required this.id,
    required this.imageUrl,
    required this.price,
    required this.name,
    this.isLiked = false,
    this.isInCart = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'price': price,
      'name': name,
      'isLiked': isLiked,
      'isInCart': isInCart,
    };
  }
}
