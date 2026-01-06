import '../helpers/database_helper.dart';
import '../models/product.dart';
import 'package:sqflite/sqflite.dart';

class ProductRepository {
  // Obtiene todos los productos
  Future<List<Product>> getAllProducts() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('products');

    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  // Inserta un nuevo producto
  Future<int> insertProduct(Product product) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('products', product.toMap());
  }

  // Actualiza un producto existente
  Future<int> updateProduct(Product product) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Elimina un producto por id
  Future<int> deleteProduct(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
