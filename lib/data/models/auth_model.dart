import 'package:equatable/equatable.dart';

class AuthModel extends Equatable {
  final int userId;
  final String email;
  final String username;
  final double budgetLimit;

  const AuthModel({
    required this.userId,
    required this.email,
    required this.username,
    required this.budgetLimit,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      userId: json['userId'],
      email: json['email'],
      username: json['username'],
      budgetLimit: json['budgetLimit'] is int ? json['budgetLimit'].toDouble() : json['budgetLimit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'username': username,
      'budgetLimit': budgetLimit,
    };
  }

  @override
  List<Object?> get props => [userId, email, username, budgetLimit];
}

class LoginRequest extends Equatable {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  @override
  List<Object> get props => [email, password];
}

class RegisterRequest extends Equatable {
  final String username;
  final String email;
  final String password;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }

  @override
  List<Object> get props => [username, email, password];
}
