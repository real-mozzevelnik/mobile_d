import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_d/data/repositories/user_repository.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../home/bloc/home_bloc.dart';
import '../../home/bloc/home_event.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;
  final UserRepository userRepository;

  TransactionsBloc({
    required this.transactionRepository,
    required this.categoryRepository,
    required this.userRepository,
  }) : super(TransactionsInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<FilterTransactions>(_onFilterTransactions);
  }

  Future<void> _onLoadTransactions(
      LoadTransactions event,
      Emitter<TransactionsState> emit,
      ) async {
    emit(TransactionsLoading());

    try {
      final uid = await userRepository.getUserId();
      final transactions = await transactionRepository.getTransactions(uid);
      final categories = await categoryRepository.getCategories();

      emit(TransactionsLoaded(
        transactions: transactions,
        categories: categories,
      ));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(
      AddTransaction event,
      Emitter<TransactionsState> emit,
      ) async {
    try {
      await transactionRepository.addTransaction(event.transaction);
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(
      UpdateTransaction event,
      Emitter<TransactionsState> emit,
      ) async {
    try {
      await transactionRepository.updateTransaction(event.transaction);
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
      DeleteTransaction event,
      Emitter<TransactionsState> emit,
      ) async {
    try {
      final uid = userRepository.getUserProfile().userId;
      await transactionRepository.deleteTransaction(event.id, uid);
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onFilterTransactions(
      FilterTransactions event,
      Emitter<TransactionsState> emit,
      ) async {
    emit(TransactionsLoading());

    try {
      List<TransactionModel> transactions;

      final uid = await userRepository.getUserId();
      if (event.startDate != null && event.endDate != null) {
        transactions = await transactionRepository.getTransactionsByDateRange(
          event.startDate!,
          event.endDate!,
          uid,
        );
      } else {
        transactions = await transactionRepository.getTransactions(uid);
      }

      if (event.type != null && event.type != TransactionType.all) {
        transactions = transactions
            .where((t) => t.type == event.type)
            .toList();
      }

      final categories = await categoryRepository.getCategories();

      emit(TransactionsLoaded(
        transactions: transactions,
        categories: categories,
      ));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }
}
