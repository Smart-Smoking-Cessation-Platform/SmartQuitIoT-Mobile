import 'package:flutter/material.dart';
import 'package:smartquitiot/features/products/domain/models/product.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Product product =
        ModalRoute.of(context)!.settings.arguments as Product;
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product ID: ${product.id}'),
            const SizedBox(height: 8),
            if (product.description != null) Text(product.description!),
          ],
        ),
      ),
    );
  }
}
