import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CategoryModel extends Equatable {
  final int? id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isIncome;

  const CategoryModel({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color.value,
      'isIncome': isIncome ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      icon: IconData(map['icon'] is String ? int.parse(map['icon']) : map['icon'] , fontFamily: 'MaterialIcons'),
      color: Color(map['color'] is String ? int.parse(map['color']) : map['color']),
      isIncome: map['isIncome'] == 1,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, color, isIncome];
}
