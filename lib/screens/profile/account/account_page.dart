import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/shared/styled_text.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: width * 0.08),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          title: const StyledTitle(
            "ACCOUNT",
          ),
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Personal Information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Size Preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.beach_access),
            title: const Text('Vacation Mode'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.red),
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Are you sure?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "This will delete all your data and cancel any existing bookings.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Add your delete account logic here
              await Provider.of<ItemStoreProvider>(context, listen: false).deleteUser();
              // await reauthenticateAndDeleteUser(username, password)
              Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false); 
            },
            child: const Text(
              'CONFIRM',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> reauthenticateAndDeleteUser(String email, String password) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Re-authenticate
    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);

    // Now delete
    await user.delete();
  } catch (e) {
    print('Error deleting user: $e');
    rethrow;
  }
}