import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/summary/rental_price_summary.dart';
import 'package:revivals/screens/summary/summary_image_widget.dart';
import 'package:revivals/shared/send_email2.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class SummaryRental extends StatefulWidget {
  const SummaryRental(this.item, this.startDate, this.endDate, this.noOfDays,
      this.price, this.status, this.symbol,
      {super.key});

  final Item item;
  final DateTime startDate;
  final DateTime endDate;
  final int noOfDays;
  final int price;
  final String status;
  final String symbol;

  @override
  State<SummaryRental> createState() => _SummaryRentalState();
}

class _SummaryRentalState extends State<SummaryRental> {
  // final int i;

  @override
  Widget build(BuildContext context) {
    int pricePerDay = widget.price ~/ widget.noOfDays;

    void handleSubmit(String renterId, String ownerId, String itemId,
        String startDate, String endDate, int price, String status) {
      Provider.of<ItemStoreProvider>(context, listen: false)
          .addItemRenter(ItemRenter(
        id: uuid.v4(),
        renterId: renterId,
        ownerId: ownerId,
        itemId: itemId,
        transactionType: 'rental',
        startDate: startDate,
        endDate: endDate,
        price: price,
        status: status,
      ));
    }

    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        title: const StyledTitle('REVIEW AND PAY'),
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
        //     preferredSize: const Size.fromHeight(4.0),
        //     child: Container(
        //       color: Colors.grey[300],
        //       height: 1.0,
        //     )),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            SummaryImageWidget(widget.item),
            const SizedBox(height: 20),

            // --- Date Row ---
            Row(children: [
              const SizedBox(width: 20),
              Icon(Icons.calendar_month_outlined, size: width * 0.06),
              const SizedBox(width: 20),
              StyledBody(
                DateFormat.yMMMd().format(widget.startDate),
                fontSize: width * 0.045, // Larger font
              ),
              const StyledBody('   -   ', fontSize: 20), // Slightly larger separator
              StyledBody(
                DateFormat.yMMMd().format(widget.endDate),
                fontSize: width * 0.045, // Larger font
              ),
            ]),
            const SizedBox(height: 20),
            // --- Location Row ---
            Row(children: [
              const SizedBox(width: 20),
              Icon(Icons.location_pin, size: width * 0.06),
              const SizedBox(width: 20),
              // Show location only if it's set and not empty
              (Provider.of<ItemStoreProvider>(context, listen: false)
                              .renter
                              .location !=
                          null &&
                      Provider.of<ItemStoreProvider>(context, listen: false)
                              .renter
                              .location
                              .toString()
                              .trim()
                              .isNotEmpty)
                  ? StyledBody(
                      Provider.of<ItemStoreProvider>(context, listen: false)
                          .renter
                          .location
                          .toString(),
                      fontSize: width * 0.045, // Larger font
                    )
                  : const SizedBox.shrink(),
            ]),
            const SizedBox(height: 20),
            // --- Price Details ---
            Center(
              child: Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (widget.noOfDays > 1)
                        ? Text(
                            'Renting for ${widget.noOfDays} days (at $pricePerDay${widget.symbol} per day)',
                            maxLines: 3, // <-- Add this line
                            overflow: TextOverflow.visible, // <-- Add this line
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: width * 0.045, // Larger font
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            'Renting for ${widget.price}${widget.symbol}',
                            maxLines: 2, // <-- Add this line
                            overflow: TextOverflow.visible, // <-- Add this line
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: width * 0.045, // Larger font
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(
              height: 1,
              indent: 50,
              endIndent: 50,
              color: Colors.grey[200],
            ),
            // --- REMOVE DeliveryRadioWidget and deliveryPrice ValueListenableBuilder ---
            // DeliveryRadioWidget(updateDeliveryPrice, widget.symbol),
            // Divider(
            //   height: 1,
            //   indent: 50,
            //   endIndent: 50,
            //   color: Colors.grey[300],
            // ),
            // ValueListenableBuilder(
            //     valueListenable: widget.deliveryPrice,
            //     builder: (BuildContext context, int val, Widget? child) {
            //       return RentalPriceSummary(
            //           widget.price, widget.noOfDays, val, widget.symbol);
            //     }),
            // --- Instead, just show the rental price summary without delivery ---
            RentalPriceSummary(
              widget.price,
              widget.noOfDays,
              0, // delivery fee is now always 0
              widget.symbol,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8), // Reduced horizontal padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 48,
                // Remove width constraint to avoid overflow
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                    side: const BorderSide(width: 1.0, color: Colors.black),
                  ),
                  onPressed: () {
                    String renterId =
                        Provider.of<ItemStoreProvider>(context, listen: false)
                            .renter
                            .id;
                    String email =
                        Provider.of<ItemStoreProvider>(context, listen: false)
                            .renter
                            .email;
                    String name =
                        Provider.of<ItemStoreProvider>(context, listen: false)
                            .renter
                            .name;
                    String startDateText = widget.startDate.toString();
                    String endDateText = widget.endDate.toString();
                    String ownerId = '';
                    for (Renter r in Provider.of<ItemStoreProvider>(context,
                            listen: false)
                        .renters) {
                      if (r.id == widget.item.owner) {
                        ownerId = r.id;
                      }
                    }

                    handleSubmit(
                        renterId,
                        ownerId,
                        widget.item.id,
                        startDateText,
                        endDateText,
                        widget.item.rentPriceDaily,
                        widget.status);
                    String startDateTextForEmail =
                        DateFormat('yMMMd').format(widget.startDate);
                    String endDateTextForEmail =
                        DateFormat('yMMMd').format(widget.endDate);
                    EmailComposer2(
                            emailAddress: email,
                            itemType: widget.item.type,
                            userName: name,
                            itemName: widget.item.name,
                            itemBrand: widget.item.brand,
                            startDate: startDateTextForEmail,
                            endDate: endDateTextForEmail,
                            deliveryPrice: 0, // <-- always 0
                            price: widget.price.toString(),
                            deposit: widget.item.rentPriceDaily.toString(),
                            gd_image_id: widget.item.imageId[0])
                        .sendEmailWithFirebase();
                    showAlertDialog(context, widget.item.type, MediaQuery.of(context).size.width);
                  },
                  child: const StyledHeading('CONFIRM', color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, String itemType, double width) {
    // Create button
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
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: const Center(child: StyledBody("OK", color: Colors.white)),
    );
    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white, // <-- Set background to white
      title: const Center(child: StyledHeading("Thank You!")),
      content: SizedBox(
        height: width * 0.15,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledBody("Your $itemType is being prepared,",
                    weight: FontWeight.normal),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledBody("Please check your", weight: FontWeight.normal),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledBody("email for details.", weight: FontWeight.normal),
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
}
