import 'package:flutter/material.dart';

class ShoppingScreen extends StatelessWidget {
  ShoppingScreen({super.key});

  final List<String> productImages = [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Galatasaray_Sports_Club_Logo.png/721px-Galatasaray_Sports_Club_Logo.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Be%C5%9Fikta%C5%9F_Logo_Be%C5%9Fikta%C5%9F_Amblem_Be%C5%9Fikta%C5%9F_Arma.png/600px-Be%C5%9Fikta%C5%9F_Logo_Be%C5%9Fikta%C5%9F_Amblem_Be%C5%9Fikta%C5%9F_Arma.png',
    'https://upload.wikimedia.org/wikipedia/tr/a/ab/TrabzonsporAmblemi.png?20221207195303',
    'https://upload.wikimedia.org/wikipedia/tr/c/cb/Osmanl%C4%B1spor_FK_logo.png?20161218205237',
    'https://upload.wikimedia.org/wikipedia/tr/b/bd/68AksarayBelediyespor.png?20190505203419',
    'https://upload.wikimedia.org/wikipedia/tr/f/f8/Yeni_Malatyaspor.png?20120222001258',
    'https://upload.wikimedia.org/wikipedia/tr/6/6a/BB_Erzurumspor.png?20160426151851',
    'https://upload.wikimedia.org/wikipedia/tr/4/41/Konyaspor_1922.png?20220809170233',
  ];

  final List<String> productPrices = [
    '\$1.00',
    '\$2.00',
    '\$0.50',
    '\$20.00',
    '\$10,000.00',
    '\$12,000.00',
    '\$15,000.00',
    '\$18,000.00',
  ];

  final List<String> explanation = [
    'Galatasaray',
    'Beşiktaş',
    'Trabzonspor',
    'Osmanlıspor',
    '68 Aksaray Belediyespor',
    'Yeni Malatyaspor',
    'Erzurum BelediyeSpor',
    'Konyaspor'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.9,
          ),
          itemCount: productImages.length,
          itemBuilder: (context, index) {
            return ProductCard(
              imageUrl: productImages[index],
              price: productPrices[index],
              explanation: explanation[index],
            );
          },
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final String imageUrl;
  final String price;
  final String explanation;

  const ProductCard({
    required this.imageUrl,
    required this.price,
    required this.explanation,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isLiked = false;
  bool isInCart = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                widget.imageUrl,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  widget.price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.explanation,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isLiked = !isLiked;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    isInCart
                        ? Icons.shopping_cart
                        : Icons.shopping_cart_outlined,
                    color: isInCart ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isInCart = !isInCart;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
