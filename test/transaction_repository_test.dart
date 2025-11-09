import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_d/data/models/transaction_model.dart';
import 'package:mobile_d/data/repositories/transaction_repository.dart';
import 'package:mobile_d/data/datasources/local/database_helper.dart';
import 'package:mobile_d/data/datasources/remote/api_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks using build_runner
@GenerateMocks([DatabaseHelper, ApiService])
import 'transaction_repository_test.mocks.dart';

void main() {
  late TransactionRepository repository;
  late MockDatabaseHelper mockDatabase;
  late MockApiService mockApiService;

  setUp(() {
    mockDatabase = MockDatabaseHelper();
    mockApiService = MockApiService();
    repository = TransactionRepository(
      database: mockDatabase,
      apiService: mockApiService,
    );
  });

  group('TransactionRepository', () {
    test('should return transactions from database when getTransactions is called', () async {
      // Arrange
      final testTransactions = [
        TransactionModel(
          id: 1,
          title: 'Test 1',
          amount: 100.0,
          type: TransactionType.income,
          categoryId: 1,
          date: DateTime.now(), userId: 1,
        ),
        TransactionModel(
          id: 2,
          title: 'Test 2',
          amount: 50.0,
          type: TransactionType.expense,
          categoryId: 2,
          date: DateTime.now(), userId: 1,
        ),
      ];

      when(mockApiService.fetchTransactions(1))
          .thenAnswer((_) async => testTransactions);
      when(mockDatabase.getTransactions(1))
          .thenAnswer((_) async => testTransactions);
      when(mockDatabase.insertTransaction(any))
          .thenAnswer((_) async => 1);

      // Act
      final result = await repository.getTransactions(1);

      // Assert
      expect(result.length, 2);
      expect(result[0].title, 'Test 1');
      expect(result[1].title, 'Test 2');
      verify(mockDatabase.getTransactions(1)).called(1);
    });

    test('should calculate correct total balance', () async {
      // Arrange
      final testTransactions = [
        TransactionModel(
          id: 1,
          title: 'Income',
          amount: 1000.0,
          type: TransactionType.income,
          categoryId: 1,
          date: DateTime.now(), userId: 1,
        ),
        TransactionModel(
          id: 2,
          title: 'Expense 1',
          amount: 300.0,
          type: TransactionType.expense,
          categoryId: 2,
          date: DateTime.now(), userId: 1,
        ),
        TransactionModel(
          id: 3,
          title: 'Expense 2',
          amount: 200.0,
          type: TransactionType.expense,
          categoryId: 3,
          date: DateTime.now(), userId: 1,
        ),
      ];

      when(mockDatabase.getTransactions(1))
          .thenAnswer((_) async => testTransactions);

      // Act
      final balance = await repository.getTotalBalance(1);

      // Assert
      expect(balance, 500.0); // 1000 - 300 - 200 = 500
      verify(mockDatabase.getTransactions(1)).called(1);
    });
  });
}
