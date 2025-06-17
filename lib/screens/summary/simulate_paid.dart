import 'package:flutter/material.dart';

class SimulatePaidPage extends StatelessWidget {
  const SimulatePaidPage({super.key});

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
        title: const Text(
          "SIMULATE PAID",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Simulate Stripe payment logic here
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text(
            "STRIPE PAY",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }}