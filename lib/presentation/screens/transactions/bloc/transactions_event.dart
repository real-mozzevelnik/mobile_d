import 'package:equatable/equatable.dart';
import '../../../../data/models/transaction_model.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object> get props => [];
}

class LoadTransactions extends TransactionsEvent {}

class AddTransaction extends TransactionsEvent {
  final TransactionModel transaction;

  const AddTransaction(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class UpdateTransaction extends TransactionsEvent {
  final TransactionModel transaction;

  const UpdateTransaction(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class DeleteTransaction extends TransactionsEvent {
  final int id;

  const DeleteTransaction(this.id);

  @override
  List<Object> get props => [id];
}

class FilterTransactions extends TransactionsEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionType? type;

  const FilterTransactions({
    this.startDate,
    this.endDate,
    this.type,
  });

  @override
  List<Object> get props => [];
}
