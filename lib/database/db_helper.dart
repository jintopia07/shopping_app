// ignore_for_file: prefer_conditional_assignment

import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:shopping_cart/model/cart_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db!;
    }
    // ปรับการใช้งาน db ให้ดีกว่า
    _db = await initDatabase();
    return _db;
  }

  Future<Database?> initDatabase() async {
    try {
      io.Directory documentDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentDirectory.path, 'cart_db');
      var db = await openDatabase(
        path,
        version: 2, // Updated to version 2
        onCreate: _onCreate,
        onUpgrade: _onUpgrade, // Set onUpgrade callback
      );
      return db;
    } catch (e) {
      print('Error initializing the database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE cart (productId TEXT PRIMARY KEY, productName TEXT, productPrice REAL, productImage TEXT, productTag TEXT)', // ใช้ REAL แทน TEXT สำหรับราคาสินค้า
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      try {
        // Step 1: Create a new table with the correct schema
        await db.execute('''
        CREATE TABLE IF NOT EXISTS new_cart (
          productId TEXT PRIMARY KEY,
          productName TEXT,
          productPrice TEXT,
          productImage TEXT,
          productTag TEXT
        );
      ''');

        // Step 2: Copy data from the old table to the new table
        await db.execute('''
        INSERT INTO new_cart (productId, productName, productPrice, productImage, productTag)
        SELECT productId, productName, productPrice, productImage, productTag
        FROM cart;
      ''');

        // Step 3: Drop the old table
        await db.execute('DROP TABLE cart');

        // Step 4: Rename the new table to the original table name
        await db.execute('ALTER TABLE new_cart RENAME TO cart');
      } catch (e) {
        print('Error during schema upgrade: $e');
      }
    }
  }

  Future<Cart> insert(Cart cart) async {
    var dbClient = await db;

    if (dbClient == null) {
      dbClient = await db;
    }

    // ตรวจสอบก่อนว่าสินค้ามีอยู่แล้วหรือไม่
    var existingCart = await dbClient!.query(
      'cart',
      where: 'productId = ?',
      whereArgs: [cart.productId],
    );

    if (existingCart.isNotEmpty) {
      // ถ้าสินค้าซ้ำ ให้คืนค่าผลลัพธ์ว่าเป็นสินค้าที่มีอยู่แล้ว
      return Future.error("Product already added");
    } else {
      // ถ้าไม่มี ให้ INSERT ปกติ
      await dbClient.insert('cart', cart.toMap());
      return cart;
    }
  }

  Future<List<Cart>> getCartList() async {
    var dbClient = await db;
    if (dbClient == null) {
      throw Exception("Database is not initialized");
    }
    final List<Map<String, Object?>> queryResult = await dbClient.query('cart');
    return queryResult.map((e) => Cart.fromMap(e)).toList();
  }

  Future<int> delete(String productId) async {
    var dbClient = await db;
    if (dbClient == null) {
      throw Exception("Database is not initialized");
    }
    return await dbClient
        .delete('cart', where: 'productId = ?', whereArgs: [productId]);
  }
}
