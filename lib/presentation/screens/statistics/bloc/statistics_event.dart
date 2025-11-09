import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object> get props => [];
}

class LoadStatistics extends StatisticsEvent {}

class UpdateStatisticsPeriod extends StatisticsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const UpdateStatisticsPeriod({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}
