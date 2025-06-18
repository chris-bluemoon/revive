import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/models/review.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class LendersRentalsPage extends StatefulWidget {
  const LendersRentalsPage({super.key});

  @override
  State<LendersRentalsPage> createState() => _LendersRentalsPageState();
}

class _LendersRentalsPageState extends State<LendersRentalsPage> {
    bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refreshItemRenters();
  }

  void _refreshItemRenters() async {
    await Provider.of<ItemStoreProvider>(context, listen: false)
        .fetchItemRentersAgain();
    log('Loaded item renters');
    setState(() {
      _loading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
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
                      final renter = itemStore.renters.firstWhere(
                        (r) => r.id == rental.renterId,
                        orElse: () => Renter(id: '', name: 'Unknown Renter', email: '', type: '', size: 0, address: '', countryCode: '', phoneNum: '', favourites: [], verified: '', imagePath: '', creationDate: '', location: '', bio: '', followers: [], following: []), // Provide a default Renter
                      );
                      final renterName = renter.name;

                      return ItemRenterCard(
                        itemRenter: rental,
                        itemName: itemName,
                        itemType: itemType,
                        startDate: formattedStartDate,
                        endDate: formattedEndDate,
                        status: status,
                        renterName: renterName,
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
  final String renterName;
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
    required this.renterName,
    required this.price,
    // Add more required parameters as needed
  });

  @override
  State<ItemRenterCard> createState() => _ItemRenterCardState();
}

class _ItemRenterCardState extends State<ItemRenterCard> {
  @override
  Widget build(BuildContext context) {
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
              'Renter: ${widget.renterName}',
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
            if (widget.itemRenter.status == "requested")
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.itemRenter.status = "accepted";
                        widget.status = "accepted";
                      });
                      ItemStoreProvider itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
                      itemStore.saveItemRenter(widget.itemRenter);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('ACCEPT'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.itemRenter.status = "rejected";
                        widget.status = "rejected";
                      });
                      ItemStoreProvider itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
                      itemStore.saveItemRenter(widget.itemRenter);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('REJECT'),
                  ),
                ],
              ),
            if (DateTime.parse(widget.itemRenter.endDate).isBefore(DateTime.now()))
              ElevatedButton(
      onPressed: () async {
        setState(() {
          widget.itemRenter.status = "completed";
          widget.status = "completed";
        });
        // Update in itemStore (if using Provider or similar)
        Provider.of<ItemStoreProvider>(context, listen: false)
            .saveItemRenter(widget.itemRenter);

        int selectedStars = 0;
        TextEditingController reviewController = TextEditingController();

        await showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text('Leave a Review'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < selectedStars ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedStars = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reviewController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Write your review here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // You can use selectedStars and reviewController.text here
                      ItemStoreProvider itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
                      Review review = Review(
                        id: uuid.v4(),
                        date: DateTime.now(),
                        itemId: widget.itemRenter.itemId,
                        itemRenterId: widget.itemRenter.id,
                        rating: selectedStars,
                        reviewedUserId: widget.itemRenter.renterId,
                        reviewerId: itemStore.renter.id,
                        text: reviewController.text,
                        title: widget.itemName
                      );
                      itemStore.addReview(review);
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            );
          },
        );
      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('COMPLETE BOOKING'),
              ),
            // Add more fields here as needed
          ],
        ),
      ),
    );
  }
}

// Usage in your list:
// ListView.builder(
//   itemCount: itemStore.itemRenters.length,
//   itemBuilder: (context, index) {
//     final itemRenter = itemStore.itemRenters[index];
//     return ItemRenterCard(itemRenter: itemRenter);
//   },
// )