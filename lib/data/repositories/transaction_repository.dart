import 'dart:ffi';

import '../datasources/local/database_helper.dart';
import '../datasources/remote/api_service.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final DatabaseHelper database;
  final ApiService apiService;

  TransactionRepository({
    required this.database,
    required this.apiService,
  });

  Future<List<TransactionModel>> getTransactions(int userId) async {
    return await database.getTransactions(userId);
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end, int userId) async {
    return await database.getTransactionsByDateRange(start, end, userId);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final TransactionModel apiTransaction = await apiService.createTransaction(transaction);
    await database.insertTransaction(apiTransaction);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await database.updateTransaction(transaction);
    await apiService.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(int id, int userId) async {
    await database.deleteTransaction(id);
    await apiService.deleteTransaction(id, userId);
  }

  Future<double> getTotalBalance(int userId) async {
    final transactions = await database.getTransactions(userId);
    double income = 0;
    double expense = 0;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return income - expense;
  }

  Future<Map<String, double>> getMonthlyStatistics(int userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final transactions = await database.getTransactionsByDateRange(startOfMonth, endOfMonth, userId);

    double income = 0;
    double expense = 0;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }
}
