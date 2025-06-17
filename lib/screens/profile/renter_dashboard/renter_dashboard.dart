import 'package:flutter/material.dart';
import 'package:revivals/screens/profile/lender_dashboard/balance_page.dart';
import 'package:revivals/screens/profile/lender_dashboard/earnings_page.dart';
import 'package:revivals/screens/profile/lender_dashboard/rentals_page.dart';
import 'package:revivals/screens/profile/renter_dashboard/renters_rentals_page.dart';

class RenterDashboard extends StatelessWidget {
  const RenterDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          "LENDER DASHBOARD",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.06),
        children: [
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Rentals/Purchases'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RentersRentalsPage(),
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}
