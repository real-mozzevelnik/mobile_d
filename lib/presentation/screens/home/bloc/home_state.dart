import 'package:equatable/equatable.dart';
import '../../../../data/models/transaction_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final List<TransactionModel> recentTransactions;
  final double budgetLimit;
  final double budgetUsed;

  const HomeLoaded({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.recentTransactions,
    required this.budgetLimit,
    required this.budgetUsed,
  });

  @override
  List<Object> get props => [
    totalBalance,
    monthlyIncome,
    monthlyExpense,
    recentTransactions,
    budgetLimit,
    budgetUsed,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
