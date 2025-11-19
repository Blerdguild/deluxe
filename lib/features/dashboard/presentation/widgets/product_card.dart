import 'package:deluxe/features/consumer/presentation/pages/consumer_order_form_screen.dart';
import 'package:deluxe/features/dashboard/presentation/pages/order_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:deluxe/shared/models/product_model.dart';

// Enum to define the card's purpose
enum ProductCardPurpose {
  forDispensary,
  forConsumer,
}

class ProductCard extends StatelessWidget {
  final Product product;
  final ProductCardPurpose purpose;

  const ProductCard({
    Key? key,
    required this.product,
    required this.purpose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonText =
        purpose == ProductCardPurpose.forConsumer ? 'Buy Now' : 'Order';

    return Card(
      clipBehavior: Clip.antiAlias,
      // Shape and elevation are handled by AppTheme
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                );
              },
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.type,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          product.rating.toString(),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ElevatedButton(
              onPressed: () {
                if (purpose == ProductCardPurpose.forConsumer) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ConsumerOrderFormScreen(product: product),
                    ),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => OrderFormScreen(product: product),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 36), // full width
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
