import 'package:equatable/equatable.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/category_model.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object> get props => [];
}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<TransactionModel> transactions;
  final List<CategoryModel> categories;

  const TransactionsLoaded({
    required this.transactions,
    required this.categories,
  });

  @override
  List<Object> get props => [transactions, categories];
}

class TransactionsError extends TransactionsState {
  final String message;

  const TransactionsError(this.message);

  @override
  List<Object> get props => [message];
}
