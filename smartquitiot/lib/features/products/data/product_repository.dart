import 'models/product_dto.dart';
import 'package:smartquitiot/features/products/domain/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
}

class InMemoryProductRepository implements ProductRepository {
  @override
  Future<List<Product>> getProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    const dtos = <ProductDto>[
      ProductDto(id: '1', name: 'Starter Kit', description: 'IoT starter kit'),
      ProductDto(
        id: '2',
        name: 'Sensor Module',
        description: 'Environmental sensor',
      ),
      ProductDto(id: '3', name: 'Controller', description: 'Device controller'),
    ];
    return dtos.map((e) => e.toDomain()).toList(growable: false);
  }
}
