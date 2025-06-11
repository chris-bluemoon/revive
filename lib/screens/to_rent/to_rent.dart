import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import at the top
import 'package:provider/provider.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/models/item.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/profile/create/create_item.dart';
import 'package:revivals/screens/profile/my_account.dart';
import 'package:revivals/screens/sign_up/google_sign_in.dart';
import 'package:revivals/screens/summary/summary_purchase.dart';
import 'package:revivals/screens/to_rent/item_widget.dart';
import 'package:revivals/screens/to_rent/rent_this_with_date_selecter.dart';
import 'package:revivals/screens/to_rent/send_message_screen.dart';
import 'package:revivals/screens/to_rent/user_card.dart';
import 'package:revivals/shared/get_country_price.dart';
import 'package:revivals/shared/item_card.dart';
import 'package:revivals/shared/item_results.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

// ignore: must_be_immutable
class ToRent extends StatefulWidget {
  const ToRent(this.item, {super.key});

  @override
  State<ToRent> createState() => _ToRentState();

  final Item item;
  // late String itemName;
  // late String imageName;
  // late String itemType;

  // String setItemImage() {
  //   itemType = item.type.replaceAll(RegExp(' '), '_');
  //   itemName = item.name.replaceAll(RegExp(' '), '_');
  //   imageName = '${item.brand}_${itemName}_${itemType}.webp';
  //   return imageName;
  // }

  // final ValueNotifier<int> rentalDays = ValueNotifier<int>(0);
}

class _ToRentState extends State<ToRent> {
  List items = [];
  int currentIndex = 0;
  bool itemCheckComplete = false;
  List<Color> dotColours = [];
  // bool showMessageBox = false;

  CarouselSliderController buttonCarouselSliderController =
      CarouselSliderController();

  String convertedrentPriceDaily = '-1';
  String convertedBuyPrice = '-1';
  String convertedRRPPrice = '-1';
  String symbol = '?';

  String ownerName = 'Jane Doe';
  String location = 'UK';

  bool isOwner = false;

  int getPricePerDay(noOfDays) {
    // String country = Provider.of<ItemStoreProvider>(context, listen: false)
        // .renter
        // .settings[0];
    String country = 'BANGKOK'; // Default to Bangkok for now

    int oneDayPrice = widget.item.rentPriceDaily;

    if (country == 'BANGKOK') {
      oneDayPrice = widget.item.rentPriceDaily;
    } else {
      oneDayPrice = int.parse(convertFromTHB(widget.item.rentPriceDaily, country));
    }

    if (noOfDays == 3) {
      int threeDayPrice = (oneDayPrice * 0.8).toInt() - 1;
      if (country == 'BANGKOK') {
        return (threeDayPrice ~/ 100) * 100 + 100;
      } else {
        return (threeDayPrice ~/ 5) * 5 + 5;
      }
    }
    if (noOfDays == 5) {
      int fiveDayPrice = (oneDayPrice * 0.6).toInt() - 1;
      if (country == 'BANGKOK') {
        return (fiveDayPrice ~/ 100) * 100 + 100;
      } else {
        return (fiveDayPrice ~/ 5) * 5 + 5;
      }
    }
    return oneDayPrice;
  }

  @override
  void initState() {
    // setPrice();
    _initImages();
    for (Renter r
        in Provider.of<ItemStoreProvider>(context, listen: false).renters) {
      log('Renter: ${r.name}, Owner: ${widget.item.owner}');
      if (widget.item.owner == r.id) {
        log('Owner found: ${r.name}');
        ownerName = r.name;
        location = 'BANGKOK';
      }
      if (widget.item.owner ==
          Provider.of<ItemStoreProvider>(context, listen: false).renter.id) {
        isOwner = true;
      }
    }

    super.initState();
  }

  void setPrice() {
      String country = 'BANGKOK';
    if (country == 'BANGKOK') {
      // String country = Provider.of<ItemStoreProvider>(context, listen: false)
          // .renter
          // .settings[0];
      convertedrentPriceDaily = getPricePerDay(5).toString();
      // convertedrentPriceDaily = convertFromTHB(getPricePerDay(1), country);
      convertedBuyPrice = convertFromTHB(widget.item.buyPrice, country);
      convertedRRPPrice = convertFromTHB(widget.item.rrp, country);
      symbol = getCurrencySymbol(country);
    } else {
      convertedrentPriceDaily = getPricePerDay(5).toString();
      convertedBuyPrice = widget.item.buyPrice.toString();
      convertedRRPPrice = widget.item.rrp.toString();
      symbol = globals.thb;
    }
  }

  Future _initImages() async {
    int counter = 0;
    for (String i in widget.item.imageId) {
      counter++;
      items.add(counter);
      dotColours.add(Colors.grey);
    }
    setState(() {
      itemCheckComplete = true;
    });
  }

  // setSendMessagePressedToFalse() {
  //   setState(() {
  //     showMessageBox = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        title: SizedBox(
          width: width * 0.7, // Adjust as needed for your layout
          child: Text(
            widget.item.name,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
              onPressed: () =>
                  {Navigator.of(context).popUntil((route) => route.isFirst)},
              icon: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, width * 0.01, 0),
                child: Icon(Icons.close, size: width * 0.06),
              )),
        ],
      ),
      body: (!itemCheckComplete)
          ? const Text('Loading')
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: width * 0.01),
                  (items.length == 1)
                      ? SizedBox(
                          height: width,
                          child: Center(
                              child:
                                  ItemWidget(item: widget.item, itemNumber: 1)))
                      : Column(
                          children: [
                            CarouselSlider(
                              carouselController: buttonCarouselSliderController,
                              options: CarouselOptions(
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      currentIndex = index;
                                    });
                                  },
                                  height: width * 1,
                                  autoPlay: true,
                                  viewportFraction: 0.85,
                              ),
                              items: items.map((index) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: SizedBox(
                                        width: width * 0.85,
                                        height: width * 0.8,
                                        child: ItemWidget(item: widget.item, itemNumber: index),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                            SizedBox(height: width * 0.04),
                          ],
                        ),
                  SizedBox(height: width * 0.03),
                  if (items.length > 1)
                    Center(
                      child: DotsIndicator(
                        dotsCount: items.length,
                        position: currentIndex,
                        decorator: DotsDecorator(
                          colors: dotColours,
                          activeColor: Colors.black,
                        ),
                      ),
                    ),
                  SizedBox(height: width * 0.03),
                  Padding(
                    padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            final renters = Provider.of<ItemStoreProvider>(context, listen: false).renters;
                            final ownerList = renters.where((r) => r.name == ownerName).toList();
                            final owner = ownerList.isNotEmpty ? ownerList.first : null;
                            if (owner != null && owner.name.isNotEmpty) {
                              log('Owner name: ${owner.name}');
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MyAccount(userN: owner.name),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User not found')),
                              );
                            }
                          },
                          child: UserCard(ownerName, location),
                        ),
                        if (!isOwner)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => SendMessageScreen(to: ownerName, subject: widget.item.name)));
                              });
                            },
                            icon: Icon(Icons.email_outlined, size: width * 0.05),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Padding(
                    padding: EdgeInsets.all(width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StyledHeading(widget.item.description),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        Row(
                          children: [
                            // Item type to the left of the size, with a comma
                            StyledBody(
                              widget.item.type +
                                  (widget.item.type.toLowerCase() == 'dress' ? ',' : ''),
                              weight: FontWeight.normal,
                            ),
                            if (widget.item.type.toLowerCase() == 'dress') ...[
                              SizedBox(width: width * 0.01),
                              StyledBody(
                                widget.item.size.isNotEmpty ? "UK ${widget.item.size}" : '',
                                weight: FontWeight.normal,
                              ),
                            ],
                          ],
                        ),
                        // Move long description here, directly below type and size
                        if (widget.item.longDescription.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: width * 0.02),
                            child: StyledBody(
                              widget.item.longDescription,
                              weight: FontWeight.normal,
                            ),
                          ),
                        // --- Move hashtags block here ---
                        if (widget.item.hashtags.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Wrap(
                              spacing: 8,
                              children: widget.item.hashtags.map((tag) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ItemResults(
                                          'hashtag',
                                          tag,
                                        ),
                                      ),
                                    );
                                  },
                                  child: StyledBody(
                                    '#$tag',
                                    color: Colors.green,
                                    weight: FontWeight.bold,
                                    // decoration: TextDecoration.underline,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        // --- End hashtags block ---
                        Padding(
                          padding: EdgeInsets.only(top: width * 0.01),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const StyledBody("Product Type", weight: FontWeight.bold),
                                  StyledBody(widget.item.type, weight: FontWeight.normal),
                                ],
                              ),
                              const SizedBox(height: 12), // Slightly more spacing
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const StyledBody("Colour", weight: FontWeight.bold),
                                  StyledBody(widget.item.colour.isNotEmpty ? widget.item.colour[0] : '', weight: FontWeight.normal),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const StyledBody("Weekly Price", weight: FontWeight.bold),
                                  StyledBody(
                                    "${NumberFormat('#,###').format(widget.item.rentPriceWeekly)}$symbol",
                                    weight: FontWeight.normal,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const StyledBody("Retail Price", weight: FontWeight.bold),
                                  StyledBody(
                                    "${NumberFormat('#,###').format(widget.item.rrp)}$symbol",
                                    weight: FontWeight.normal,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const StyledBody("Minimal Rental Period", weight: FontWeight.bold),
                                  StyledBody(
                                    "${widget.item.minDays} days",
                                    weight: FontWeight.normal,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Divider(
                      color: Colors.grey[400],
                      thickness: 1,
                      height: 0, // Remove extra height from Divider itself
                    ),
                  ),
                  SizedBox(height: width * 0.04), // Make the gap above and below the divider the same
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.05, bottom: width * 0.05),
                    child: const StyledBody(
                        'Rent for longer to save on pricing.'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: width * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 1st card: minDays
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.black12),
                            ),
                            elevation: 2,
                            margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: width * 0.03, horizontal: width * 0.01),
                              child: Column(
                                children: [
                                  StyledBody(
                                    "${widget.item.minDays} days",
                                    weight: FontWeight.bold,
                                  ),
                                  const SizedBox(height: 6),
                                  // Per day price uses rentPriceDaily
                                  StyledBody(
                                    "${NumberFormat('#,###').format(widget.item.rentPriceDaily)}$symbol / day",
                                    weight: FontWeight.normal,
                                  ),
                                  const SizedBox(height: 6),
                                  StyledBody(
                                    "${NumberFormat('#,###').format(widget.item.rentPriceDaily * widget.item.minDays)}$symbol total",
                                    weight: FontWeight.normal,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 2nd card: Weekly (7 days)
                        Expanded(
                          child: Card(
                            color: Colors.green[50], // Light green background
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.black12),
                            ),
                            elevation: 2,
                            margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: width * 0.03, horizontal: width * 0.01),
                              child: Column(
                                children: [
                                  // "Recommended" label above "Weekly"
                                  const StyledBody(
                                    "Suggested", // Changed from "Recommended"
                                    weight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(height: 4),
                                  const StyledBody(
                                    "Weekly",
                                    weight: FontWeight.bold,
                                  ),
                                  const SizedBox(height: 6),
                                  // Per day price uses rentPriceWeekly / 7
                                  StyledBody(
                                    "${NumberFormat('#,###').format((widget.item.rentPriceWeekly / 7).floor())}$symbol / day",
                                    weight: FontWeight.normal,
                                  ),
                                  const SizedBox(height: 6),
                                  StyledBody(
                                    "${NumberFormat('#,###').format(widget.item.rentPriceWeekly)}$symbol total",
                                    weight: FontWeight.normal,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 3rd card: Monthly (30 days)
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.black12),
                            ),
                            elevation: 2,
                            margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: width * 0.03, horizontal: width * 0.01),
                              child: Column(
                                children: [
                                  const StyledBody(
                                    "Monthly",
                                    weight: FontWeight.bold,
                                  ),
                                  const SizedBox(height: 6),
                                  // Per day price uses rentPriceMonthly / 30
                                  StyledBody(
                                    "${NumberFormat('#,###').format((widget.item.rentPriceMonthly / 30).floor())}$symbol / day",
                                    weight: FontWeight.normal,
                                  ),
                                  const SizedBox(height: 6),
                                  StyledBody(
                                    "${NumberFormat('#,###').format(widget.item.rentPriceMonthly)}$symbol total",
                                    weight: FontWeight.normal,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.05,
                      right: width * 0.05,
                      top: width * 0.02,
                    ),
                    child: const Text(
                      "ALL PRICING IS FINAL, NEGOTIATION IS NOT ALLOWED.",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold, // <-- Make text bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.05,
                      right: width * 0.05,
                      top: width * 0.04,
                      bottom: width * 0.01,
                    ),
                    child: const Text(
                      "YOU MIGHT ALSO LIKE",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Larger font
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.05,
                      right: width * 0.05,
                      bottom: width * 0.03,
                    ),
                    child: SizedBox(
                      height: width * 1,
                      child: Consumer<ItemStoreProvider>(
                        builder: (context, store, _) {
                          final allItems = store.items ?? []; // <-- This ensures no null
                          if (allItems.isEmpty) {
                            return const Center(
                              child: StyledBody("No similar items found."),
                            );
                          }
                          final brandItems = allItems
                              .where((i) =>
                                  i.brand == widget.item.brand &&
                                  i.id != widget.item.id)
                              .toList();
                          log('Brand items: ${brandItems.length}');
                          if (brandItems.isEmpty) {
                            return const Center(
                              child: StyledBody("No similar items found."),
                            );
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: brandItems.length,
                            itemBuilder: (context, index) {
                              final item = brandItems[index];
                              return Padding(
                                padding: EdgeInsets.only(right: width * 0.03),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => ToRent(item),
                                      ),
                                    );
                                  },
                                  child: ItemCard(item, false, false),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: SizedBox(
        height: 90, // Increased height for the bottom bar
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 3,
              )
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Row(
                children: [
                  StyledHeading(
                    "${NumberFormat('#,###').format(widget.item.rentPriceDaily)}$symbol / day",
                    color: Colors.black,
                  ),
                  StyledBody(
                    "  (${widget.item.minDays} days)",
                    color: Colors.black,
                  ),
                ],
              ),
              const SizedBox(width: 10),
              (widget.item.bookingType == 'buy' ||
                      widget.item.bookingType == 'both')
                  ? Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => (SummaryPurchase(
                                  widget.item,
                                  DateTime.now(),
                                  DateTime.now(),
                                  0,
                                  widget.item.buyPrice,
                                  'booked',
                                  symbol))));
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1.0),
                          ),
                          side: const BorderSide(width: 1.0, color: Colors.black),
                        ),
                        child: const StyledHeading('BUY PRELOVED'),
                      ))
                  : const Expanded(child: SizedBox()),
              const SizedBox(width: 5),
              (widget.item.bookingType == 'rental' ||
                      widget.item.bookingType == 'both')
                  ? Expanded(
                      flex: 5,
                      child: isOwner
                          ? Row(
                              children: [
                                // DELETE button (logic from to_rent_edit)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      // Confirm before deleting
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Item'),
                                          content: const Text(
                                              'Are you sure you want to delete this item? This action cannot be undone.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        final store = Provider.of<ItemStoreProvider>(context, listen: false);

                                        // Check for future bookings
                                        final hasFutureBooking = store.ledgers.any((ledger) =>
                                            ledger.itemId == widget.item.id &&
                                            ledger.endDate.isAfter(DateTime.now()) &&
                                            ledger.status != 'cancelled');

                                        if (hasFutureBooking) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Cannot delete: This item has future bookings.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        // Update item status to 'deleted'
                                        widget.item.status = 'deleted';
                                        store.saveItem(widget.item);

                                        // Pop all screens until before ToRent
                                        int count = 0;
                                        Navigator.of(context).popUntil((route) {
                                          count++;
                                          // Pop until before this ToRent screen (which is the current one)
                                          return count >= 2;
                                        });
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(1.0),
                                      ),
                                      side: const BorderSide(width: 1.0, color: Colors.red),
                                      minimumSize: const Size(80, 44),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'DELETE',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // EDIT button
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => CreateItem(item: widget.item),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(1.0),
                                      ),
                                      side: const BorderSide(width: 1.0, color: Colors.black),
                                      minimumSize: const Size(100, 44),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'EDIT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        letterSpacing: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : OutlinedButton(
                              onPressed: () {
                                bool loggedIn = Provider.of<ItemStoreProvider>(context, listen: false).loggedIn;
                                if (loggedIn) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => (RentThisWithDateSelecter(widget.item))));
                                } else {
                                  showAlertDialog(context);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1.0),
                                ),
                                side: const BorderSide(width: 1.0, color: Colors.black),
                                minimumSize: const Size(100, 44),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'RENT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                    )
                  : const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}

showAlertDialog(BuildContext context) {
  // Create button
  double width = MediaQuery.of(context).size.width;

  Widget okButton = ElevatedButton(
    style: OutlinedButton.styleFrom(
      textStyle: const TextStyle(color: Colors.white),
      foregroundColor: Colors.white, //change background color of button
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      side: const BorderSide(width: 1.0, color: Colors.black),
    ),
    onPressed: () {
      // Navigator.of(context).pop();
      // Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => (const GoogleSignInScreen())));
    },
    child: const Center(child: StyledHeading("OK", color: Colors.white)),
  );
  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: const Center(child: StyledHeading("NOT LOGGED IN")),
    content: SizedBox(
      height: width * 0.2,
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StyledHeading("Please log in"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StyledHeading("or register to continue"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StyledHeading("to rent a dress"),
            ],
          ),
        ],
      ),
    ),
    actions: [
      okButton,
    ],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(0.0)),
    ),
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
