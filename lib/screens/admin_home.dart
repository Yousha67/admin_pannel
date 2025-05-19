import 'package:admin_pannel/screens/dashboard.dart';
import 'package:admin_pannel/screens/orders_screen.dart';
import 'package:admin_pannel/screens/product_screen.dart';
import 'package:admin_pannel/screens/users.dart';
import 'package:admin_pannel/screens/wallet_reward.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'add_product.dart';


class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;
  String _subSection = '';

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const AdminDashboardScreen();
      case 1:
        if (_subSection == 'All Dresses') return const ProductsScreen();
        if (_subSection == 'Add') return const AddProductScreen();
        return const Center(child: Text('Select a product action.'));
      case 2:
        return  OrderManagementScreen();
      case 3:
        return  UserManagementScreen();
      case 4:
        return  WalletRewardSummaryScreen();
      default:
        return const Center(child: Text('Unknown screen'));
    }
  }

  void _onMenuSelect(int index, [String sub = '']) {
    setState(() {
      _selectedIndex = index;
      _subSection = sub;
    });
  }

  Widget _buildSidebar() {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text("Admin Panel")),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () => _onMenuSelect(0),
          ),
          ExpansionTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text("Products"),
            children: [
              ListTile(
                title: const Text("All Dresses"),
                onTap: () => _onMenuSelect(1, 'All Dresses'),
              ),
              ListTile(
                title: const Text("Add Dress"),
                onTap: () => _onMenuSelect(1, 'Add'),
              ),

            ],
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text("Orders"),
            onTap: () => _onMenuSelect(2),
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text("Users"),
            onTap: () => _onMenuSelect(3),
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: const Text("Wallet/Rewards"),
            onTap: () => _onMenuSelect(4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 800 || kIsWeb;

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      drawer: isWideScreen ? null : _buildSidebar(),
      body: Row(
        children: [
          if (isWideScreen)
            SizedBox(
              width: 250,
              child: _buildSidebar(),
            ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _getSelectedScreen(),
          ),
        ],
      ),
    );
  }
}
