import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/models/item.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/profile/my_account.dart';
import 'package:revivals/screens/sign_up/google_sign_in.dart';
import 'package:revivals/screens/summary/summary_purchase.dart';
import 'package:revivals/screens/to_rent/item_widget.dart';
import 'package:revivals/screens/to_rent/rent_this_with_date_selecter.dart';
import 'package:revivals/screens/to_rent/send_message_screen.dart';
import 'package:revivals/screens/to_rent/user_card.dart';
import 'package:revivals/shared/get_country_price.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

// ignore: must_be_immutable
class ToRent extends StatefulWidget {
  ToRent(this.item, {super.key});

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
    setPrice();
    _initImages();
    for (Renter r
        in Provider.of<ItemStoreProvider>(context, listen: false).renters) {
      if (widget.item.owner == r.id) {
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
        title: StyledTitle(widget.item.name.toUpperCase()),
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
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(4.0),
        //   child: Container(
        //     color: Colors.grey[300],
        //     height: 1.0,
        //   )
        // ),
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
                                  viewportFraction: 0.85, // <--- Add this line for horizontal gap
                              ),
                              items: items.map((index) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8), // Adjust for desired gap
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
                            SizedBox(height: width * 0.04), // <-- Add vertical gap after carousel
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
                          // colors: [Colors.grey[300], Colors.grey[600], Colors.grey[900]], // Inactive dot colors
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
                  SizedBox(height: width * 0.03),
                  // if (showMessageBox)
                  //   SendMessage(setSendMessagePressedToFalse,
                  //       from: Provider.of<ItemStoreProvider>(context, listen: false)
                  //           .renter
                  //           .name,
                  //       to: ownerName,
                  //       subject: widget.item.name),
                  Padding(
                    padding: EdgeInsets.all(width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StyledHeading(widget.item.description),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01), // Add this line for spacing
                        StyledBody(
                          'Size UK ${widget.item.size.isNotEmpty ? widget.item.size[0] : widget.item.size}',
                          weight: FontWeight.normal,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.05, bottom: width * 0.05),
                    child: StyledBody(
                        'Rental price: From $convertedrentPriceDaily$symbol'),
                    // child: StyledBody('Rental price: ${widget.item.rentPriceDaily.toString()} ${getCurrency()}'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.05, bottom: width * 0.05),
                    child: StyledBody(widget.item.longDescription,
                        weight: FontWeight.normal),
                  ),
                  // if (widget.item.rentPriceDaily > 0) Padding(
                  // padding: const EdgeInsets.only(left: 20, bottom: 10),
                  // child: RentalDaysRadioWidget(updateRentalDays),
                  // ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        // height: 300,
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
                    child: OutlinedButton(
                      onPressed: () {
                        bool loggedIn = Provider.of<ItemStoreProvider>(context,
                                listen: false)
                            .loggedIn;
                        if (loggedIn) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  (RentThisWithDateSelecter(widget.item))
                              // )) : goToLogin();
                              ));
                        } else {
                          showAlertDialog(context);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(10),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1.0),
                        ),
                        side: const BorderSide(width: 1.0, color: Colors.black),
                      ),
                      child:
                          const StyledHeading('RENT THIS', color: Colors.white),
                    ),
                  )
                : const Expanded(child: SizedBox()),
          ],
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
