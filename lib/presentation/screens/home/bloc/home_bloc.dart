import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final TransactionRepository transactionRepository;
  final UserRepository userRepository;

  HomeBloc({
    required this.transactionRepository,
    required this.userRepository,
  }) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    final uid = await userRepository.getUserId();
    try {
      final balance = await transactionRepository.getTotalBalance(uid);
      final monthlyStats = await transactionRepository.getMonthlyStatistics(uid);
      final transactions = await transactionRepository.getTransactions(uid);
      final budgetLimit = userRepository.getBudgetLimit();

      final recentTransactions = transactions.take(5).toList();

      emit(HomeLoaded(
        totalBalance: balance,
        monthlyIncome: monthlyStats['income'] ?? 0,
        monthlyExpense: monthlyStats['expense'] ?? 0,
        recentTransactions: recentTransactions,
        budgetLimit: budgetLimit,
        budgetUsed: monthlyStats['expense'] ?? 0,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onRefreshHomeData(RefreshHomeData event, Emitter<HomeState> emit) async {
    await _onLoadHomeData(LoadHomeData(), emit);
  }
}
