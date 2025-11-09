import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_d/presentation/screens/home/bloc/home_bloc.dart';
import 'package:mobile_d/presentation/screens/home/bloc/home_event.dart';
import 'package:mobile_d/presentation/screens/transactions/bloc/transactions_bloc.dart';
import 'package:mobile_d/presentation/screens/transactions/bloc/transactions_event.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import '../auth/login_screen.dart';
import '../main_screen.dart';
import '../statistics/bloc/statistics_bloc.dart';
import '../statistics/bloc/statistics_event.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.read<HomeBloc>().add(LoadHomeData());
          context.read<TransactionsBloc>().add(LoadTransactions());
          context.read<StatisticsBloc>().add(
            UpdateStatisticsPeriod(
              startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
              endDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else if (state is AuthUnauthenticated || state is AuthError) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Budget Planner',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
