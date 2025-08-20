import 'package:smartquitiot/features/products/data/product_repository.dart';
import 'package:smartquitiot/features/products/domain/models/product.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  const GetProductsUseCase(this.repository);

  Future<List<Product>> execute() {
    return repository.getProducts();
  }
}
