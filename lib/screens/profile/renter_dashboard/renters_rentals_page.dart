import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/providers/class_store.dart';

class RentersRentalsPage extends StatelessWidget {
  const RentersRentalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
    final String userId = itemStore.renter.id;
    final rentals = itemStore.itemRenters
        .where((r) => r.ownerId == userId && r.transactionType == "rental")
        .toList();
    final purchases = itemStore.itemRenters
        .where((r) => r.ownerId == userId && r.transactionType == "purchase")
        .toList();
    final items = itemStore.items; // items should be a list or map of all items

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: width * 0.08),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          title: const Text(
            "RENTALS/PURCHASES",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: "Rentalss"),
              Tab(text: "Purchases"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Rentalss Tab
            rentals.isEmpty
                ? const Center(child: Text('No rentals found.'))
                : ListView.separated(
                    itemCount: rentals.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final rental = rentals[index];
                      // Find the item by ID
                      final item = items.firstWhere(
                        (it) => it.id == rental.itemId,
                        orElse: () => Item(id: '', name: 'Unknown Item', owner: '', type: '', bookingType: '', dateAdded: '', brand: '', colour: [], size: '', rentPriceDaily: 0, rentPriceWeekly: 0, rentPriceMonthly: 0, buyPrice: 0, rrp: 0, description: '', longDescription: '', imageId: [], status: '', minDays: 1, hashtags: []), // Provide a default Item
                      );
                      final itemName = item != null ? item.name : 'Unknown Item';

                      // Format endDate using intl package for better readability
                      final DateTime endDate = DateTime.parse(rental.endDate);
                      final formattedEndDate = DateFormat('d MMM yyyy').format(endDate);

                      return ListTile(
                        title: Text(itemName),
                        subtitle: Text('End Date: $formattedEndDate'),
                      );
                    },
                  ),
            // Purchases Tab
            purchases.isEmpty
                ? const Center(child: Text('No purchases found.'))
                : ListView.separated(
                    itemCount: purchases.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final purchase = purchases[index];
                      return ListTile(
                        title: Text(purchase.itemId),
                        subtitle: Text(
                          'Date: ${purchase.endDate}/${purchase.endDate}/${purchase.endDate}',
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}