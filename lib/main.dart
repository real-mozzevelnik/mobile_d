import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_d/data/datasources/remote/updates_service.dart';
import 'package:mobile_d/presentation/screens/auth/bloc/auth_event.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local/database_helper.dart';
import 'data/datasources/local/preferences_helper.dart';
import 'data/datasources/remote/api_service.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/auth/bloc/auth_bloc.dart';
import 'presentation/screens/home/bloc/home_bloc.dart';
import 'presentation/screens/transactions/bloc/transactions_bloc.dart';
import 'presentation/screens/statistics/bloc/statistics_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final database = DatabaseHelper();
  await database.initDatabase();

  // Initialize preferences
  final preferences = PreferencesHelper();
  await preferences.init();

  // Initialize API service
  final apiService = ApiService();

  final updatesService = UpdatesService(apiService: apiService, databaseHelper: database, preferencesHelper: preferences);
  updatesService.getUpdates(null);

  // Initialize repositories
  final authRepository = AuthRepository(
    preferences: preferences,
    apiService: apiService,
  );

  final transactionRepository = TransactionRepository(
    database: database,
    apiService: apiService,
  );

  final categoryRepository = CategoryRepository(
    database: database,
    apiService: apiService,
  );

  final userRepository = UserRepository(
    preferences: preferences,
    apiService: apiService,
  );

  runApp(MyApp(
    authRepository: authRepository,
    transactionRepository: transactionRepository,
    categoryRepository: categoryRepository,
    userRepository: userRepository,
    updatesService: updatesService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;
  final UserRepository userRepository;
  final UpdatesService updatesService;

  const MyApp({
    Key? key,
    required this.authRepository,
    required this.transactionRepository,
    required this.categoryRepository,
    required this.userRepository,
    required this.updatesService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: transactionRepository),
        RepositoryProvider.value(value: categoryRepository),
        RepositoryProvider.value(value: userRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: authRepository,
              updatesService: updatesService,
            )..add(CheckAuthStatus()),
          ),
          BlocProvider(
            create: (context) => HomeBloc(
              transactionRepository: transactionRepository,
              userRepository: userRepository,
            ),
          ),
          BlocProvider(
            create: (context) => TransactionsBloc(
              transactionRepository: transactionRepository,
              categoryRepository: categoryRepository,
              userRepository: userRepository,
            ),
          ),
          BlocProvider(
            create: (context) => StatisticsBloc(
              transactionRepository: transactionRepository,
              userRepository: userRepository,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Budget Planner',
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
