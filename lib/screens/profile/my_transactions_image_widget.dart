// import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_image.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/models/review.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/shared/loading.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class MyTransactionsImageWidget extends StatefulWidget {
  const MyTransactionsImageWidget(this.itemRenter, this.itemId, this.startDate,
      this.endDate, this.price, this.status,
      {super.key});

  final ItemRenter itemRenter;
  final String itemId;
  final String startDate;
  final String endDate;
  final int price;
  final String status;

  @override
  State<MyTransactionsImageWidget> createState() =>
      _MyTransactionsImageWidgetState();
}

class _MyTransactionsImageWidgetState extends State<MyTransactionsImageWidget> {
  late String itemType;

  late String itemName;

  late String brandName;

  late String imageName;

  // Item item = Item(id: '-', owner: 'owner', type: 'dress', bookingType: 'rental', dateAdded: '01-01-2023', occasion: ['party'], style: 'classic', name: 'MISSING', brand: 'MISSING', colour: ['Black'], size: ['8'], length: 'midi', print: 'none', sleeve: 'short sleeve', rentPriceDaily: 1200, buyPrice: 0, rrp: 16000, description: 'Short Description', bust: '', waist: '', hips: '', longDescription: '', imageId: [] );
  late Item item;
  String thisImage = "";
  // Image thisImage = Image.asset('assets/img/items2/No_Image_Available.jpg');
  late Item thisItem;

  @override
  void initState() {
    super.initState();
    for (Item it
        in Provider.of<ItemStoreProvider>(context, listen: false).items) {
      if (it.id == widget.itemId) {
        thisItem = it;
      }
    }
    for (ItemImage i
        in Provider.of<ItemStoreProvider>(context, listen: false).images) {
      if (i.id == thisItem.imageId[0]) {
        setState(() {
          thisImage = i.imageId;
        });
      }
    }
  }

  String setItemImage() {
    itemType =
        toBeginningOfSentenceCase(item.type.replaceAll(RegExp(' +'), '_'));
    itemName = item.name.replaceAll(RegExp(' +'), '_');
    brandName = item.brand.replaceAll(RegExp(' +'), '_');
    imageName = '${brandName}_${itemName}_${itemType}_1.jpg';
    return imageName;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    List<Item> allItems =
        Provider.of<ItemStoreProvider>(context, listen: false).items;
    DateTime fromDate = DateTime.parse(widget.startDate);
    DateTime toDate = DateTime.parse(widget.endDate);
    String fromDateString = DateFormat('d MMMM, y').format(fromDate);
    String toDateString = DateFormat('d MMMM, y').format(toDate);
    // yMMMMd('en_US')
    for (Item d in allItems) {
      if (d.id == widget.itemId) {
        item = d;
      }
    }

    return Card(
        margin: EdgeInsets.only(bottom: width * 0.04),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        color: Colors.white,
        child: Row(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: width * 0.25,
                  width: width * 0.2,
                  child: CachedNetworkImage(
                    imageUrl: thisImage,
                    placeholder: (context, url) => const Loading(),
                    errorWidget: (context, url, error) => Image.asset(
                        'assets/img/items2/No_Image_Available.jpg'),
                  ),
                )),
            const SizedBox(width: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledBody(
                  '${item.name} from ${item.brand}',
                  weight: FontWeight.normal,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(
                        width: width * 0.2,
                        child: const StyledBody('From',
                            color: Colors.grey, weight: FontWeight.normal)),
                    SizedBox(width: width * 0.01),
                    StyledBody(fromDateString,
                        color: Colors.grey, weight: FontWeight.normal),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                        width: width * 0.2,
                        child: const StyledBody('To',
                            color: Colors.grey, weight: FontWeight.normal)),
                    SizedBox(width: width * 0.01),
                    StyledBody(toDateString,
                        color: Colors.grey, weight: FontWeight.normal),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                        width: width * 0.2,
                        child: const StyledBody('Price',
                            color: Colors.grey, weight: FontWeight.normal)),
                    SizedBox(width: width * 0.01),
                    StyledBody('${widget.price.toString()}${globals.thb}',
                        color: Colors.grey, weight: FontWeight.normal),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                        width: width * 0.2,
                        child: const StyledBody('Status',
                            color: Colors.grey, weight: FontWeight.normal)),
                    SizedBox(width: width * 0.01),
                    StyledBody(widget.status,
                        color: Colors.grey, weight: FontWeight.normal),
                  ],
                ),
                // Add this after the Status row
                if (widget.status.toLowerCase() == 'booked' &&
                    !_hasReviewForThisTransaction())
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            int rating = 0;
                            final titleController = TextEditingController();
                            final descController = TextEditingController();
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: const Text('Leave a Review',
                                      textAlign: TextAlign.center),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(5, (index) {
                                            return IconButton(
                                              icon: Icon(
                                                Icons.star,
                                                color: index < rating
                                                    ? Colors.amber
                                                    : Colors.grey,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  rating = index + 1;
                                                });
                                              },
                                            );
                                          }),
                                        ),
                                        TextField(
                                          controller: titleController,
                                          decoration: const InputDecoration(
                                            labelText: 'Title',
                                          ),
                                        ),
                                        TextField(
                                          controller: descController,
                                          decoration: const InputDecoration(
                                            labelText: 'Description (optional)',
                                          ),
                                          maxLines: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        // Save review logic here
                                        final itemStoreProvider = Provider.of<ItemStoreProvider>(context, listen: false);

                                        // Example review object, adjust fields as needed
                                        final review = Review(
                                          id: uuid.v4(),
                                          reviewerId: itemStoreProvider.renter.id, // Replace with your actual user id getter
                                          itemRenterId: widget.itemRenter.id,
                                          itemId: widget.itemId,
                                          rating: rating,
                                          title: titleController.text,
                                          text: descController.text,
                                          date: DateTime.now(),
                                        );

                                        // Add the review to the provider (implement addReview in your provider)
                                        itemStoreProvider.addReview(review);

                                        Navigator.of(context).pop();
                                        setState(() {}); // Optionally refresh the widget to hide the Review button
                                      },
                                      child: const Text('Submit'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      child: const Text('Review'),
                    ),
                  ),
              ],
            )
          ],
        ));
  }

  bool _hasReviewForThisTransaction() {
    // Replace this with your actual logic to check if a review exists for this ItemRenter
    // For example, if you have a list of reviews in Provider or elsewhere:
    // return Provider.of<ReviewsProvider>(context, listen: false)
    //   .hasReview(widget.itemRenter.id);
    return false; // Default: no review exists
  }
}
