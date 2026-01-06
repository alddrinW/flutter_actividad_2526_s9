import '../helpers/database_helper.dart';
import '../models/category.dart';
import 'package:sqflite/sqflite.dart';

class CategoryRepository {
  // Obtiene todas las categorías
  Future<List<Category>> getAllCategories() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');

    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  // Inserta una nueva categoría
  Future<int> insertCategory(Category category) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('categories', category.toMap());
  }

  // Actualiza una categoría existente
  Future<int> updateCategory(Category category) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // Elimina una categoría por id
  Future<int> deleteCategory(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
