class Product {
  final int? id; // null cuando es un nuevo producto
  final String name;
  final String? description;
  final double price;
  final int? categoryId; // puede ser null si no tiene categoría
  final bool isFeatured; // nuevo campo requerido en la Fase 4

  Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.categoryId,
    this.isFeatured = false, // por defecto no destacado
  });

  // Convierte el objeto Product a Map para operaciones en DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'is_featured': isFeatured ? 1 : 0, // SQLite guarda bool como 0/1
    };
  }

  // Crea un Product a partir de un Map de la base de datos
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num).toDouble(),
      categoryId: map['categoryId'] as int?,
      isFeatured: (map['is_featured'] as int? ?? 0) == 1,
    );
  }

  // Copia el producto con posibles cambios (útil en formularios de edición)
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? categoryId,
    bool? isFeatured,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  @override
  String toString() => name;
}
