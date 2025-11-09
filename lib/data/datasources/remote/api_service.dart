import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mobile_d/core/constants/app_constants.dart';

import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import '../../models/auth_model.dart';
import 'package:flutter/material.dart';

class ApiService {
  final dio = Dio();

  Future<Response> requestPost(String path, Map data) async {
    Response? res;
    try {
       res = await dio.post(AppConstants.baseUrl + path, data: data,
          options: Options(validateStatus: (int? status) {
            return true;
          }));
    } catch (e) {
      throw Exception('Internet problems');
    }
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(res.data['error']);
    }
    return res;
  }

  Future<AuthModel> login(LoginRequest request) async {
    final res = await requestPost('/auth/login', {'email': request.email, 'password': request.password});
    return AuthModel.fromJson(res.data);
  }

  Future<AuthModel> register(RegisterRequest request) async {
    final res = await requestPost('/auth/register', {'email': request.email, 'password': request.password, 'username': request.username});
    return AuthModel.fromJson(res.data);
  }

  Future<List<TransactionModel>> fetchTransactions(int userId) async {
    final res = await requestPost('/data/get_transactions', {'userId': userId});
    List<TransactionModel> transactions = [];
    for (final t in res.data) {
      transactions.add(TransactionModel.fromMap(t));
    }
    return transactions;
  }

  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    Map<String, dynamic> transactionMap = transaction.toMap();
    transactionMap.remove('id');
    final res = await requestPost('/data/create_transaction', transactionMap);
    transactionMap['id'] = res.data['id'];
    return TransactionModel.fromMap(transactionMap);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final res = await requestPost('/data/update_transaction', transaction.toMap());
  }

  Future<void> deleteTransaction(int id, int userId) async {
    final res = await requestPost('/data/delete_transaction', {'transactionId': id, 'userId': userId});
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final res = await requestPost('/data/get_categories', {});
    List<CategoryModel> categories = [];
    for (Map<String, dynamic> c in res.data) {
      c['isIncome'] = c['is_income'];
      categories.add(CategoryModel.fromMap(c));
    }
    return categories;
  }

  Future<void> updateBudgetLimit(int userId, double budgetLimit) async {
    final res = await requestPost('/user/update_budget', {'userId': userId, 'budgetLimit': budgetLimit});
  }

}
