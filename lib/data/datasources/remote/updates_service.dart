import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_d/data/datasources/local/database_helper.dart';
import 'package:mobile_d/data/datasources/remote/api_service.dart';

import '../../../presentation/screens/home/bloc/home_bloc.dart';
import '../../../presentation/screens/home/bloc/home_event.dart';
import '../../../presentation/screens/statistics/bloc/statistics_bloc.dart';
import '../../../presentation/screens/statistics/bloc/statistics_event.dart';
import '../../../presentation/screens/transactions/bloc/transactions_bloc.dart';
import '../../../presentation/screens/transactions/bloc/transactions_event.dart';
import '../local/preferences_helper.dart';

class UpdatesService {
  final ApiService apiService;
  final DatabaseHelper databaseHelper;
  final PreferencesHelper preferencesHelper;

  UpdatesService({
    required this.apiService,
    required this.databaseHelper,
    required this.preferencesHelper,
  });

  Future<void> getUpdates(BuildContext? context) async {
    final authData = preferencesHelper.getAuthData();
    if (authData != null) {
      final uid = preferencesHelper.getAuthData()!.userId;
      final transactions = await apiService.fetchTransactions(uid);
      final categories = await apiService.fetchCategories();
      await databaseHelper.updateAllTransactions(transactions);
      await databaseHelper.updateAllCategories(categories);
    }
    if (context != null) {
      context.read<HomeBloc>().add(LoadHomeData());
      context.read<TransactionsBloc>().add(LoadTransactions());
      context.read<StatisticsBloc>().add(
        UpdateStatisticsPeriod(
          startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
          endDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
        ),
      );
    }
  }
}