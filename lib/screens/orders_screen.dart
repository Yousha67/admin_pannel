import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderManagementScreen extends StatefulWidget {
  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<Map<String, dynamic>>> _ordersFuture;
  // Fetch orders from Firebase Firestore
  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    final snapshot = await _firestore.collection('orders').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['orderId'] = doc.id; // include doc ID for updating status
      return data;
    }).toList();
  }



  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = _fetchOrders();
    });
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({'status': status});
      _refreshOrders();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update status')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Orders')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order['orderId'];
              final userId = order['userId'];
              final orderDate = (order['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now();
              final rewardPoints = order['rewardPointsEarned'];
              final List items = order['items'] ?? [];
              final String status = order['status'] ?? 'Processing';
              final double totalAmount = (order['amount'] ?? 0).toDouble();

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID: $orderId', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('User ID: $userId'),
                      SizedBox(height: 4),
                      Text('Total Amount: PKR ${totalAmount.toStringAsFixed(2)}'),
                      SizedBox(height: 4),
                      Text('Reward Points Earned: $rewardPoints'),
                      SizedBox(height: 4),
                      Text('Order Date: ${orderDate.toLocal().toString()}'),
                      SizedBox(height: 8),
                      Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      ...items.map<Widget>((item) {
                        final String dressId = item['dressId'].toString();
                        final String imagePath = 'assets/images/${dressId}.jpg';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  imagePath,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey,
                                      child: Icon(Icons.image_not_supported),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${item['dressName']} (${item['size']}, ${item['color']})',
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('Original: PKR ${item['originalPrice']} | Sale: PKR ${item['salePrice']}'),
                                    Text('Reward Points: ${item['rewardPoints']}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      Divider(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  status,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              _buildStatusDropdown(orderId, status),
                            ],
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Dropdown for changing order status
  Widget _buildStatusDropdown(String orderId, String currentStatus) {
    return DropdownButton<String>(
      value: currentStatus,
      onChanged: (String? newStatus) {
        if (newStatus != null && newStatus != currentStatus) {
          _updateOrderStatus(orderId, newStatus);
          setState(() {}); // Refresh the UI
        }
      },
      items: ['Processing', 'Shipped', 'Delivered', 'Cancelled']
          .map((status) => DropdownMenuItem<String>(
        value: status,
        child: Text(status),
      ))
          .toList(),
    );
  }
}
