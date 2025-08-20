import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartquitiot/features/products/data/product_repository.dart';
import 'package:smartquitiot/features/products/domain/models/product.dart';
import 'package:smartquitiot/features/products/use_cases/get_products_use_case.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return InMemoryProductRepository();
});

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductsUseCase(repository);
});

final productListProvider = FutureProvider<List<Product>>((ref) async {
  final useCase = ref.watch(getProductsUseCaseProvider);
  return useCase.execute();
});
