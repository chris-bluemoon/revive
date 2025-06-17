import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/models/ledger.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';

class RentersRentalsPage extends StatelessWidget {
  const RentersRentalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
    final String userId = itemStore.renter.id;
    final rentals = itemStore.itemRenters
        .where((r) => r.renterId == userId && r.transactionType == "rental")
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
              Tab(text: "Rentals"),
              Tab(text: "Purchases"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Rentals Tab
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

                      // Format endDate using intl package for better readability
                      final DateTime startDate = DateTime.parse(rental.startDate);
                      final DateTime endDate = DateTime.parse(rental.endDate);
                      final formattedStartDate = DateFormat('d MMM yyyy').format(startDate);
                      final formattedEndDate = DateFormat('d MMM yyyy').format(endDate);
                      final status = rental.status;
                      final itemType = item.type;
                      final itemName = item != null ? item.name : 'Unknown Item';

                      // Assuming you have a renters table/list in itemStore and itemRenter.owner is the renter's id
                      final Renter owner = itemStore.renters.firstWhere(
                        (r) => r.id == rental.ownerId,
                        orElse: () => Renter(id: '', name: 'Unknown Renter', email: '', type: '', size: 0, address: '', countryCode: '', phoneNum: '', favourites: [], verified: '', imagePath: '', creationDate: '', location: '', bio: '', followers: [], following: []), // Provide a default Renter
                      );

                      final String ownerName = owner.name;



                      return ItemRenterCard(
                        itemRenter: rental,
                        itemName: itemName,
                        itemType: itemType,
                        startDate: formattedStartDate,
                        endDate: formattedEndDate,
                        status: status,
                        ownerName: ownerName,
                        price: rental.price,
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

// Create a custom widget to display more details from ItemRenter

class ItemRenterCard extends StatefulWidget {
  final ItemRenter itemRenter;
  final String itemName;
  final String itemType;
  String status;
  final String startDate;
  final String endDate;
  final String ownerName;
  final int price;
  // Add more fields as needed

  ItemRenterCard({
    super.key,
    required this.itemRenter,
    required this.itemName,
    required this.itemType,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.ownerName,
    required this.price,
    // Add more required parameters as needed
  });

  @override
  State<ItemRenterCard> createState() => _ItemRenterCardState();
}

class _ItemRenterCardState extends State<ItemRenterCard> {
  @override
  Widget build(BuildContext context) {
    final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
    final isOwner = widget.itemRenter.ownerId == itemStore.renter.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.itemName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${widget.status}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Owner: ${widget.ownerName}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Start: ${widget.startDate}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'End: ${widget.endDate}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: \$${widget.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (widget.itemRenter.status == "accepted")
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.itemRenter.status = "paid";
                      });
                      widget.status = "paid";
                      ItemStoreProvider itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
                      itemStore.saveItemRenter(widget.itemRenter);
                      Ledger newLedgerEntry = Ledger(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        itemRenterId: widget.itemRenter.id,
                        owner: widget.itemRenter.ownerId,
                        date: DateTime.now().toIso8601String(),
                        type: "rental",
                        desc: "Payment for rental of ${widget.itemName}",
                        amount: widget.price,
                      );
                      itemStore.addLedger(newLedgerEntry);
                      // Make payment logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('MAKE PAYMENT'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.itemRenter.status = "cancelled";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('CANCEL'),
                  ),
                ],
              ),
            // Add more fields here as needed
          ],
        ),
      ),
    );
  }
}