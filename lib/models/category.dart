class Category {
  final int? id; // null cuando es una nueva categoría
  final String name;

  Category({this.id, required this.name});

  // Convierte el objeto Category a Map para insertar/actualizar en la DB
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  // Crea un Category a partir de un Map obtenido de la base de datos
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(id: map['id'] as int?, name: map['name'] as String);
  }

  // Útil para mostrar en dropdowns o listas
  @override
  String toString() => name;
}
