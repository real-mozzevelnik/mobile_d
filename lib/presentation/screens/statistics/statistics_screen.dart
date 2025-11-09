import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../widgets/expense_chart.dart';
import 'bloc/statistics_bloc.dart';
import 'bloc/statistics_event.dart';
import 'bloc/statistics_state.dart';
import '../../../core/constants/app_constants.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: DateTimeRange(
                  start: _startDate,
                  end: _endDate,
                ),
              );

              if (range != null) {
                setState(() {
                  _startDate = range.start;
                  _endDate = range.end;
                });

                context.read<StatisticsBloc>().add(
                  UpdateStatisticsPeriod(
                    startDate: _startDate,
                    endDate: _endDate,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<StatisticsBloc, StatisticsState>(
        builder: (context, state) {
          if (state is StatisticsLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          if (state is StatisticsError) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          }

          if (state is StatisticsLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRangeCard(),
                  const SizedBox(height: 16),
                  _buildSummaryCards(state),
                  const SizedBox(height: 20),
                  const Text(
                    'Expenses by Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: ExpenseChart(
                      categoryExpenses: state.categoryExpenses,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Category Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildCategoryList(state),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${DateFormat('MMM dd').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(StatisticsLoaded state) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Income',
            state.totalIncome,
            Colors.green,
            Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            'Expense',
            state.totalExpense,
            Colors.red,
            Icons.arrow_downward,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, double amount, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${AppConstants.currency}${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(StatisticsLoaded state) {
    final sortedCategories = state.categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedCategories.length,
        itemBuilder: (context, index) {
          final entry = sortedCategories[index];
          final percentage = state.totalExpense > 0
              ? (entry.value / state.totalExpense * 100)
              : 0.0;

          return ListTile(
            title: Text(entry.key),
            subtitle: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              color: Color(0xFF2196F3),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${AppConstants.currency}${entry.value.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
