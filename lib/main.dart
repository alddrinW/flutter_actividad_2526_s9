import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/category.dart';
import 'models/product.dart';
import 'repositories/category_repository.dart';
import 'repositories/product_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      });
    }
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    if (mounted) {
      setState(() {
        _isDarkMode = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Inventario',
      theme: _isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: HomePage(isDarkMode: _isDarkMode, onThemeChanged: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final ProductRepository _productRepository = ProductRepository();

  List<Category> _categories = [];
  List<Product> _products = [];
  bool _isLoading = true;

  final TextEditingController _nameController =
      TextEditingController(); // Para nombre de categoría o producto
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _categories = await _categoryRepository.getAllCategories();
      _products = await _productRepository.getAllProducts();
    } catch (e) {
      print('Error cargando datos: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Diálogo para agregar categoría
  void _showAddCategoryDialog() {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Categoría'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la categoría',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isEmpty) return;
                final newCategory = Category(name: _nameController.text);
                await _categoryRepository.insertCategory(newCategory);
                Navigator.pop(context);
                _loadData();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // Diálogo para agregar producto
  void _showAddProductDialog() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    int? selectedCategoryId;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<int>(
                hint: const Text('Selecciona Categoría'),
                value: selectedCategoryId,
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => selectedCategoryId = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final price = double.tryParse(_priceController.text) ?? 0.0;
                final newProduct = Product(
                  name: _nameController.text,
                  description: _descriptionController.text.isEmpty
                      ? null
                      : _descriptionController.text,
                  price: price,
                  categoryId: selectedCategoryId, // Puede ser null
                );
                try {
                  await _productRepository.insertProduct(newProduct);
                  Navigator.pop(context);
                  _loadData();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                      ), // Muestra si falla foreign key
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          Row(
            children: [
              const Icon(Icons.wb_sunny, size: 16),
              Switch(
                value: widget.isDarkMode,
                onChanged: widget.onThemeChanged,
              ),
              const Icon(Icons.nightlight_round, size: 16),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Categorías',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _showAddCategoryDialog,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(cat.name),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Productos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _showAddProductDialog,
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final prod = _products[index];
                      final categoryName = _categories
                          .firstWhere(
                            (cat) => cat.id == prod.categoryId,
                            orElse: () => Category(name: 'Sin categoría'),
                          )
                          .name;
                      return ListTile(
                        title: Text(prod.name),
                        subtitle: Text(
                          '${prod.description ?? ''} - Precio: \$${prod.price} - Categoría: $categoryName - Destacado: ${prod.isFeatured ? 'Sí' : 'No'}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _productRepository.deleteProduct(prod.id!);
                            _loadData();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
