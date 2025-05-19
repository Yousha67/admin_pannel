import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class WalletRewardSummaryScreen extends StatefulWidget {
  const WalletRewardSummaryScreen({super.key});

  @override
  State<WalletRewardSummaryScreen> createState() =>
      _WalletRewardSummaryScreenState();
}

class _WalletRewardSummaryScreenState
    extends State<WalletRewardSummaryScreen> {
  double totalRevenue = 0;
  int totalRewardPoints = 0;
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> transactionLogs = [];

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  Future<void> _calculateTotals() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('orders').get();

      double revenue = 0;
      int rewards = 0;
      List<Map<String, dynamic>> logs = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = data['amount'];
        final reward = data['rewardPointsEarned'];

        if (amount != null && amount is num) {
          revenue += amount.toDouble();
        }

        if (reward != null && reward is num) {
          rewards += reward.toInt();
        }

        logs.add({
          'id': doc.id,
          'amount': amount ?? 0,
          'reward': reward ?? 0,
          'date': data['orderDate'] != null
              ? (data['orderDate'] as Timestamp).toDate()
              : null,
        });
      }

      setState(() {
        totalRevenue = revenue;
        totalRewardPoints = rewards;
        transactionLogs = logs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data. Please try again later.';
        isLoading = false;
      });
    }
  }

  void _openAdjustmentDialog() {
    double rewardPoints = 0;
    double revenueAmount = 0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Manual Adjustment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Add Revenue (PKR)'),
              keyboardType: TextInputType.number,
              onChanged: (val) =>
              revenueAmount = double.tryParse(val) ?? 0,
            ),
            TextField(
              decoration:
              const InputDecoration(labelText: 'Add Reward Points'),
              keyboardType: TextInputType.number,
              onChanged: (val) => rewardPoints = double.tryParse(val) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance.collection('orders').add({
                'amount': revenueAmount,
                'rewardPointsEarned': rewardPoints.toInt(),
                'orderDate': Timestamp.now(),
                'manual': true,
              });

              _calculateTotals();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Adjustment added successfully!')));
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet & Reward Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _openAdjustmentDialog,
            tooltip: 'Manual Adjustment',
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              icon: Icons.account_balance_wallet,
              title: 'Total Revenue',
              value:
              'PKR: ${NumberFormat('#,##0.00').format(totalRevenue)}',
              color: Colors.green.shade600,
              chart: _buildPieChart(
                label1: 'Revenue',
                value1: totalRevenue,
                label2: 'Reward Points',
                value2: totalRewardPoints.toDouble(),
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              icon: Icons.card_giftcard,
              title: 'Total Reward Points Issued',
              value: totalRewardPoints.toString(),
              color: Colors.amber.shade800,
              chart: _buildPieChart(
                label1: 'Reward Points',
                value1: totalRewardPoints.toDouble(),
                label2: 'Revenue',
                value2: totalRevenue,
              ),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Recent Transactions',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...transactionLogs.map((log) {
              return ListTile(
                leading: const Icon(Icons.monetization_on),
                title: Text(
                    'PKR: ${log['amount']} | Rewards: ${log['reward']}'),
                subtitle: Text(
                  log['date'] != null
                      ? DateFormat.yMMMd().format(log['date'])
                      : 'No Date',
                ),
                trailing: log.containsKey('manual') && log['manual']
                    ? const Chip(
                  label: Text('Manual'),
                  backgroundColor: Colors.orange,
                )
                    : null,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    Widget? chart,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: color,
                radius: 25,
                child: Icon(icon, color: Colors.white),
              ),
              title: Text(
                title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            if (chart != null) ...[
              const SizedBox(height: 8),
              chart,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart({
    required String label1,
    required double value1,
    required String label2,
    required double value2,
  }) {
    if (value1.isNaN || value2.isNaN || (value1 == 0 && value2 == 0)) {
      return const SizedBox();
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: Colors.green.shade600,
                  value: value1,
                  title: '${value1.toStringAsFixed(2)}',
                  radius: 50,
                  titleStyle:
                  const TextStyle(color: Colors.white, fontSize: 14),
                ),
                PieChartSectionData(
                  color: Colors.amber.shade800,
                  value: value2,
                  title: '${value2.toStringAsFixed(2)}',
                  radius: 50,
                  titleStyle:
                  const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend(color: Colors.green.shade600, label: label1),
            const SizedBox(width: 20),
            _legend(color: Colors.amber.shade800, label: label2),
          ],
        )
      ],
    );
  }

  Widget _legend({required Color color, required String label}) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
