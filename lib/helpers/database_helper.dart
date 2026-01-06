import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  // === PATRÓN SINGLETON ===
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Inicialización para pruebas en desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'inventory.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      onUpgrade: _onUpgrade,
    );
  }

  // === ACTIVAR FOREIGN KEYS ===
  Future<void> _onConfigure(Database db) async {
    // Esto habilita las restricciones de integridad referencial
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  // === CREACIÓN INICIAL DE TABLAS (versión 1) ===
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        categoryId INTEGER,
        is_featured INTEGER DEFAULT 0,  -- Nueva columna desde el inicio (para nuevas instalaciones)
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');
  }

  // === MIGRACIÓN DE VERSIÓN 1 A VERSIÓN 2 ===
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE products ADD COLUMN is_featured INTEGER DEFAULT 0;',
      );
    }
  }
}
