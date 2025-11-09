import 'package:equatable/equatable.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final Map<String, double> categoryExpenses;
  final Map<String, double> monthlyData;

  const StatisticsLoaded({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.categoryExpenses,
    required this.monthlyData,
  });

  @override
  List<Object> get props => [
    totalIncome,
    totalExpense,
    balance,
    categoryExpenses,
    monthlyData,
  ];
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object> get props => [message];
}
