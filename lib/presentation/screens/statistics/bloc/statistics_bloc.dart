import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_d/data/repositories/user_repository.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/models/transaction_model.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final TransactionRepository transactionRepository;
  final UserRepository userRepository;

  StatisticsBloc({
    required this.transactionRepository,
    required this.userRepository,
  }) : super(StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
    on<UpdateStatisticsPeriod>(_onUpdateStatisticsPeriod);
  }

  Future<void> _onLoadStatistics(
      LoadStatistics event,
      Emitter<StatisticsState> emit,
      ) async {
    emit(StatisticsLoading());

    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      await _loadStatisticsForPeriod(startOfMonth, endOfMonth, emit);
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }

  Future<void> _onUpdateStatisticsPeriod(
      UpdateStatisticsPeriod event,
      Emitter<StatisticsState> emit,
      ) async {
    emit(StatisticsLoading());

    try {
      await _loadStatisticsForPeriod(event.startDate, event.endDate, emit);
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }

  Future<void> _loadStatisticsForPeriod(
      DateTime startDate,
      DateTime endDate,
      Emitter<StatisticsState> emit,
      ) async {
    final uid = await userRepository.getUserId();
    final transactions = await transactionRepository.getTransactionsByDateRange(
      startDate,
      endDate,
      uid,
    );

    double totalIncome = 0;
    double totalExpense = 0;
    Map<String, double> categoryExpenses = {};
    Map<String, double> monthlyData = {};

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;

        final categoryName = transaction.categoryName ?? 'Other';
        categoryExpenses[categoryName] =
            (categoryExpenses[categoryName] ?? 0) + transaction.amount;
      }

      final monthKey = '${transaction.date.year}-${transaction.date.month}';
      monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) +
          (transaction.type == TransactionType.income
              ? transaction.amount
              : -transaction.amount);
    }

    emit(StatisticsLoaded(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      categoryExpenses: categoryExpenses,
      monthlyData: monthlyData,
    ));
  }
}
