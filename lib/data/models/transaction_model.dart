import 'package:equatable/equatable.dart';

enum TransactionType { income, expense, all }

class TransactionModel extends Equatable {
  final int? id;
  final int userId;
  final String title;
  final double amount;
  final TransactionType type;
  final int categoryId;
  final String? categoryName;
  final DateTime date;
  final String? description;

  const TransactionModel({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.categoryName,
    required this.date,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'type': type.index,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      amount: map['amount'].toDouble(),
      type: TransactionType.values[map['type']],
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
      date: DateTime.parse(map['date']),
      description: map['description'],
    );
  }

  TransactionModel copyWith({
    int? id,
    int? userId,
    String? title,
    double? amount,
    TransactionType? type,
    int? categoryId,
    String? categoryName,
    DateTime? date,
    String? description,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, amount, type, categoryId, date, description];
}
