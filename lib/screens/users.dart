import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Users> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final snapshot = await _firestore.collection('users').get();
    setState(() {
      _users = snapshot.docs
          .map((doc) => Users.fromFirestore(doc.data(), doc.id))
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _editUserModal(BuildContext context, Users user) async {
    final walletController =
    TextEditingController(text: user.walletBalance.toString());
    final rewardController =
    TextEditingController(text: user.rewardPoints.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: Wrap(
            children: [
              Text(
                'Edit ${user.name}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: walletController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Wallet Balance'),
              ),
              TextField(
                controller: rewardController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Reward Points'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await _firestore.collection('users').doc(user.uid).update({
                    'walletBalance': double.tryParse(walletController.text) ?? 0.0,
                    'rewardPoints': int.tryParse(rewardController.text) ?? 0,
                  });
                  Navigator.pop(context);
                  await _fetchUsers();
                },
                icon: Icon(Icons.save),
                label: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48)),
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _toggleBanStatus(Users user) async {
    final newStatus = !(user.isBanned ?? false);
    await _firestore.collection('users').doc(user.uid).update({'isBanned': newStatus});
    await _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? Center(child: Text('No users found.'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(
                backgroundColor: user.isBanned ? Colors.red : Colors.deepPurple,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                user.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: user.isBanned ? Colors.red : Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email),
                  Text('Wallet: PKR: ${user.walletBalance.toStringAsFixed(2)}'),
                  Text('Points: ${user.rewardPoints}'),
                  if (user.isBanned)
                    Text('Status: BANNED',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
          if (value == 'edit') {
          _editUserModal(context, user);
          } else if (value == 'toggleBan') {
          _toggleBanStatus(user);
          }
          },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                value: 'toggleBan',
                child: Text(user.isBanned ? 'Unban User' : 'Ban User'),
              ),
            ],
          ),

          ),
          );
        },
      ),
    );
  }
}
