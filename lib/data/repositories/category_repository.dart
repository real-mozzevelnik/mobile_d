import '../datasources/local/database_helper.dart';
import '../datasources/remote/api_service.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final DatabaseHelper database;
  final ApiService apiService;

  CategoryRepository({
    required this.database,
    required this.apiService,
  });

  Future<List<CategoryModel>> getCategories() async {
    return await database.getCategories();
  }

  Future<List<CategoryModel>> getIncomeCategories() async {
    final allCategories = await database.getCategories();
    return allCategories.where((category) => category.isIncome).toList();
  }

  Future<List<CategoryModel>> getExpenseCategories() async {
    final allCategories = await database.getCategories();
    return allCategories.where((category) => !category.isIncome).toList();
  }
}
