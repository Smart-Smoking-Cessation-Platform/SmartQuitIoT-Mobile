import 'package:smartquitiot/features/products/domain/models/product.dart';

class ProductDto {
  final String id;
  final String name;
  final String? description;

  const ProductDto({required this.id, required this.name, this.description});

  Product toDomain() => Product(id: id, name: name, description: description);
}
