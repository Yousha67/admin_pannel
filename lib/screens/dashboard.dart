import 'package:admin_pannel/screens/add_product.dart';
import 'package:admin_pannel/screens/orders_screen.dart';
import 'package:admin_pannel/screens/users.dart';
import 'package:admin_pannel/screens/wallet_reward.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int totalOrders = 0;
  int totalUsers = 0;
  int totalProducts = 0;
  double totalSales = 0.0;
  int totalRewards = 0;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final ordersSnapshot = await FirebaseFirestore.instance.collection('orders').get();
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

      int orders = ordersSnapshot.docs.length;
      int users = usersSnapshot.docs.length;
      int products = 40;
      double sales = 0;
      int rewards = 0;

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        final amount = data['amount'];
        final reward = data['rewardPointsEarned'];

        if (amount != null && amount is num) {
          sales += amount.toDouble();
        }
        if (reward != null && reward is num) {
          rewards += reward.toInt();
        }
      }

      setState(() {
        totalOrders = orders;
        totalUsers = users;
        totalProducts = products;
        totalSales = sales;
        totalRewards = rewards;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = '⚠️ Failed to load dashboard data';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth >= 1000
        ? 4
        : screenWidth >= 700
        ? 3
        : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        elevation: 4,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildDashboardCard("Total Orders", "$totalOrders", Icons.shopping_cart, Colors.blue),
                _buildDashboardCard("Total Users", "$totalUsers", Icons.person, Colors.green),
                _buildDashboardCard("Total Products", "$totalProducts", Icons.list_alt, Colors.orange),
                _buildDashboardCard(
                  "Total Sales",
                  "PKR: ${NumberFormat('#,##0.00').format(totalSales)}",
                  Icons.attach_money,
                  Colors.purple,
                ),
                _buildDashboardCard("Rewards Given", "$totalRewards pts", Icons.card_giftcard, Colors.teal),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("📦 Recent Orders"),
            const SizedBox(height: 8),
            _buildRecentOrders(),
            const SizedBox(height: 32),
            _buildSectionTitle("⚡ Quick Actions"),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickAction(context, Icons.add_box, "Add Product", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductScreen()));
                }),
                _buildQuickAction(context, Icons.receipt_long, "View Orders", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OrderManagementScreen()));
                }),
                _buildQuickAction(context, Icons.people, "Manage Users", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserManagementScreen()));
                }),
                _buildQuickAction(context, Icons.wallet, "Wallet Adjust", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => WalletRewardSummaryScreen()));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, String value, IconData icon, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.03)]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 6, offset: const Offset(2, 4)),
        ],
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Dynamically adjust the icon and text size based on the container's width
          double containerWidth = constraints.maxWidth;
          double iconSize = containerWidth * 0.28; // Icon size based on width
          double textSize = containerWidth * 0.07; // Text size based on width

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: color),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(fontSize: textSize * 1.2, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: textSize, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600));
  }

  Widget _buildRecentOrders() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .limit(5)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text("❌ Error loading orders");
        }

        final orders = snapshot.data?.docs ?? [];
        if (orders.isEmpty) {
          return const Text("No recent orders found.");
        }

        return Column(
          children: orders.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.receipt, color: Colors.deepPurple),
                title: Text("Order #${doc.id}"),
                subtitle: Text("User: ${data['userId'] ?? 'N/A'}\nStatus: ${data['status'] ?? 'Pending'}"),
                trailing: Text("PKR: ${data['amount']?.toStringAsFixed(2) ?? '0.00'}"),
                isThreeLine: true,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepPurple.shade100),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double containerWidth = 150;
            double iconSize = containerWidth * 0.18; // Icon size based on container width
            double textSize = containerWidth * 0.05; // Text size based on container width

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: iconSize, color: Colors.deepPurple),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: textSize, fontWeight: FontWeight.w500),
                ),
              ],
            );
          },
        ),
      ),
    );
  }


}
