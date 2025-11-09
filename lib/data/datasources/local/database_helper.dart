import 'dart:ffi';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import '../../../core/constants/app_constants.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            icon INTEGER NOT NULL,
            color INTEGER NOT NULL,
            isIncome INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            type INTEGER NOT NULL,
            categoryId INTEGER NOT NULL,
            date TEXT NOT NULL,
            description TEXT,
            FOREIGN KEY (categoryId) REFERENCES categories (id)
          )
        ''');

        await _insertDefaultCategories(db);
      },
    );
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final categories = [
      CategoryModel(name: 'Salary', icon: Icons.work, color: Colors.green, isIncome: true),
      CategoryModel(name: 'Freelance', icon: Icons.computer, color: Colors.teal, isIncome: true),
      CategoryModel(name: 'Food', icon: Icons.restaurant, color: Colors.orange, isIncome: false),
      CategoryModel(name: 'Transport', icon: Icons.directions_car, color: Colors.blue, isIncome: false),
      CategoryModel(name: 'Shopping', icon: Icons.shopping_bag, color: Colors.purple, isIncome: false),
      CategoryModel(name: 'Entertainment', icon: Icons.movie, color: Colors.red, isIncome: false),
      CategoryModel(name: 'Bills', icon: Icons.receipt, color: Colors.grey, isIncome: false),
      CategoryModel(name: 'Healthcare', icon: Icons.medical_services, color: Colors.pink, isIncome: false),
    ];

    for (final category in categories) {
      await db.insert('categories', category.toMap());
    }
  }

  // Transaction methods
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    Map tm = transaction.toMap();
    tm['date'] = tm['date'].replaceAll('Z', '');
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, c.name as categoryName 
      FROM transactions t
      LEFT JOIN categories c ON t.categoryId = c.id
      WHERE t.userId = ?
      ORDER BY t.date DESC, t.id DESC
    ''', [userId]);

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end, int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, c.name as categoryName 
      FROM transactions t
      LEFT JOIN categories c ON t.categoryId = c.id
      WHERE userId = ? AND t.date >= ? AND t.date <= ?
      ORDER BY t.date DESC, t.id DESC
    ''', [userId, start.toIso8601String(), end.toIso8601String()]);

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> updateAllTransactions(List<TransactionModel> transactions) async {
    final db = await database;
    await db.execute('DELETE FROM transactions');
    for (final t in transactions) {
      insertTransaction(t);
    }
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CategoryModel>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');

    return List.generate(maps.length, (i) {
      return CategoryModel.fromMap(maps[i]);
    });
  }

  Future<void> updateAllCategories(List<CategoryModel> categories) async {
    final db = await database;
    await db.execute('DELETE FROM categories');
    for (final category in categories) {
      await db.insert('categories', category.toMap());
    }
  }
}
