import 'package:flutter/material.dart';
// Import any other dependencies you use in MyTransactions
// import 'package:revive/models/transaction.dart'; // Example

class MySales extends StatelessWidget {
  const MySales({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace this with your actual sales data fetching logic
    final List sales = []; // Example placeholder

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.width * 0.2,
        title: const Text(
          'SALES',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: sales.isEmpty
          ? const Center(child: Text('No sales found.'))
          : ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                // Replace with your actual sale item widget
                return ListTile(
                  title: Text('Sale #${index + 1}'),
                  subtitle: const Text('Details for sale'),
                  // trailing: ...,
                );
              },
            ),
    );
  }
}