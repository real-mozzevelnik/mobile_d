import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_d/presentation/screens/statistics/bloc/statistics_bloc.dart';
import 'package:mobile_d/presentation/screens/statistics/bloc/statistics_event.dart';
import 'package:mobile_d/presentation/screens/transactions/bloc/transactions_bloc.dart';
import 'package:mobile_d/presentation/screens/transactions/bloc/transactions_event.dart';
import 'home/bloc/home_bloc.dart';
import 'home/bloc/home_event.dart';
import 'home/home_screen.dart';
import 'transactions/transactions_screen.dart';
import 'statistics/statistics_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionsScreen(),
    const StatisticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          context.read<HomeBloc>().add(LoadHomeData());
          context.read<TransactionsBloc>().add(LoadTransactions());
          context.read<StatisticsBloc>().add(
            UpdateStatisticsPeriod(
              startDate: DateTime(DateTime.now().year, DateTime.now().month, 0),
              endDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
            ),
          );
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
