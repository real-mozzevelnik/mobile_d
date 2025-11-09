import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';
import 'bloc/transactions_bloc.dart';
import 'bloc/transactions_event.dart';
import 'bloc/transactions_state.dart';
import '../../../data/models/transaction_model.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionType? _filterType;
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          PopupMenuButton<TransactionType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (type) {
              setState(() {
                _filterType = type;
              });
              _applyFilter();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TransactionType.all,
                child: Text('All'),
              ),
              const PopupMenuItem(
                value: TransactionType.income,
                child: Text('Income'),
              ),
              const PopupMenuItem(
                value: TransactionType.expense,
                child: Text('Expense'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _dateRange,
              );

              if (range != null) {
                setState(() {
                  _dateRange = range;
                });
                _applyFilter();
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, state) {
          if (state is TransactionsLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          if (state is TransactionsError) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          }

          if (state is TransactionsLoaded) {
            if (state.transactions.isEmpty) {
              return const Center(
                child: Text('No transactions found'),
              );
            }

            final groupedTransactions = _groupTransactionsByDate(state.transactions);

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedTransactions.length,
              itemBuilder: (context, index) {
                final date = groupedTransactions.keys.elementAt(index);
                final transactions = groupedTransactions[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _formatDate(date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ...transactions.map((transaction) {
                      return Dismissible(
                        key: Key(transaction.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Transaction'),
                                content: const Text('Are you sure you want to delete this transaction?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          context.read<TransactionsBloc>().add(
                            DeleteTransaction(transaction.id!),
                          );
                        },
                        child: TransactionCard(
                          transaction: transaction,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddTransactionScreen(
                                  transaction: transaction,
                                ),
                              ),
                            ).then((value) {
                              if (value == true) {
                                context.read<TransactionsBloc>().add(LoadTransactions());
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          ).then((value) {
            if (value == true) {
              context.read<TransactionsBloc>().add(LoadTransactions());
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _applyFilter() {
    context.read<TransactionsBloc>().add(
      FilterTransactions(
        startDate: _dateRange?.start,
        endDate: _dateRange?.end,
        type: _filterType,
      ),
    );
  }

  Map<DateTime, List<TransactionModel>> _groupTransactionsByDate(
      List<TransactionModel> transactions,
      ) {
    final grouped = <DateTime, List<TransactionModel>>{};

    for (final transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }

      grouped[date]!.add(transaction);
    }

    return grouped;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}
