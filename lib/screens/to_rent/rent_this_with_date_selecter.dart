// import 'dart:developer';

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/screens/sign_up/google_sign_in.dart';
import 'package:revivals/screens/summary/summary_rental.dart';
import 'package:revivals/services/class_store.dart';
import 'package:revivals/shared/get_country_price.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class RentThisWithDateSelecter extends StatefulWidget {
  const RentThisWithDateSelecter(this.item, {super.key});

  final Item item;
  // final int rentalDays;

  @override
  State<RentThisWithDateSelecter> createState() =>
      _RentThisWithDateSelecterState();
}

class _RentThisWithDateSelecterState extends State<RentThisWithDateSelecter> {
  DateTimeRange? dateRange;
  DateTime? startDate;
  DateTime? endDate;

  late int noOfDays = 0;
  // late int totalPrice = 0;
  bool bothDatesSelected = false;
  bool showConfirm = false;

  int getPricePerDay(noOfDays) {
    String country = Provider.of<ItemStoreProvider>(context, listen: false)
        .renter
        .settings[0];

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

  List<DateTime> getBlackoutDates(String itemId, int daysToRent) {
    //
    List<ItemRenter> itemRenters =
        Provider.of<ItemStoreProvider>(context, listen: false).itemRenters;
    List<DateTime> tempList = [];

    for (int i = 0; i < itemRenters.length; i++) {
      DateTime startDate =
          DateFormat("yyyy-MM-dd").parse(itemRenters[i].startDate);
      DateTime endDate = DateFormat("yyyy-MM-dd").parse(itemRenters[i].endDate);
      String itemIdDB = itemRenters[i].itemId;
      if (itemIdDB == itemId) {
        for (int y = 0;
            y <=
                endDate
                    .difference(startDate.subtract(Duration(days: daysToRent)))
                    .inDays;
            y++) {
          tempList.add(startDate
              .subtract(Duration(days: daysToRent))
              .add(Duration(days: y)));
        }
      }
    }

    log(tempList.toString());
    return tempList;
  }

  // Future pickDateRange() async {
  //   DateTimeRange? newDateRange = await showDateRangePicker(
  //     context: context,
  //     initialDateRange: dateRange,
  //     firstDate: DateTime(1900),
  //     lastDate: DateTime(2100),
  //   );
  //   if (newDateRange == null) return;
  //   setState(() => dateRange = newDateRange);
  // }

  // DateRange selectedDateRange = DateRange(DateTime.now(), DateTime.now());

  int selectedOption = -1;
  String symbol = '?';


  @override
  Widget build(BuildContext context) {
    // rebuildAllChildren(context);
    String country = Provider.of<ItemStoreProvider>(context, listen: false)
        .renter
        .settings[0];
    symbol = getCurrencySymbol(country);

    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 32, // <-- Make header very small (fixed height, e.g. 32 pixels)
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StyledTitle('SELECT OPTION', weight: FontWeight.bold),
          ],
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // const Text('RENTAL TERM', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 30),
            StyledHeading('Select Rental Period', weight: FontWeight.normal),
            SizedBox(height: width * 0.03),

            // Add day options
            // if (startDate == null && endDate == null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChoiceChip(
                  label: Text(
                    '3+ days (${widget.item.rentPriceDaily}/day, ${getPricePerDay(3)} per day)',
                  ),
                  selected: selectedOption == 3,
                  selectedColor: Colors.grey[200], // Light grey highlight
                  backgroundColor: Colors.white,   // Unselected color is white
                  side: BorderSide(
                    color: selectedOption == 3 ? Colors.black : Colors.grey, // Black if selected, grey if not
                    width: 2,
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedOption = 3;
                      noOfDays = 3;
                    });
                  },
                ),
                const SizedBox(height: 10),
                ChoiceChip(
                  label: Text(
                    '7+ days (${widget.item.rentPriceWeekly}/week, ${getPricePerDay(7)} per day)',
                  ),
                  selected: selectedOption == 7,
                  selectedColor: Colors.grey[200],
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: selectedOption == 7 ? Colors.black : Colors.grey,
                    width: 2,
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedOption = 7;
                      noOfDays = 7;
                    });
                  },
                ),
                const SizedBox(height: 10),
                ChoiceChip(
                  label: Text(
                    '30+ days (${widget.item.rentPriceMonthly}/month, ${getPricePerDay(30)} per day)',
                  ),
                  selected: selectedOption == 30,
                  selectedColor: Colors.grey[200],
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: selectedOption == 30 ? Colors.black : Colors.grey,
                    width: 2,
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedOption = 30;
                      noOfDays = 30;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (selectedOption > 0)
              const SizedBox(height: 32), // <-- Add this line for more gap between chips and button
            if (selectedOption > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0), // <-- Square corners
                      ),
                      side: const BorderSide(
                        color: Colors.black, // or your preferred border color
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    onPressed: () async {
                      final now = DateTime.now();
                      final onlyDateToday = DateTime(now.year, now.month, now.day);
                      final onlyDateTomorrow = onlyDateToday.add(const Duration(days: 1));
                      final firstDate = onlyDateTomorrow;
                      final lastDate = onlyDateTomorrow.add(const Duration(days: 60));

                      // Find the next selectable start date
                      DateTime nextSelectable = onlyDateTomorrow;
                      final blackoutDates = getBlackoutDates(widget.item.id, noOfDays)
                          .map((d) => DateTime(d.year, d.month, d.day))
                          .toSet();
                      while (blackoutDates.contains(nextSelectable)) {
                        nextSelectable = nextSelectable.add(const Duration(days: 1));
                      }

                      // Find the next selectable end date after start
                      DateTime nextSelectableEnd = nextSelectable.add(const Duration(days: 1));
                      while (blackoutDates.contains(nextSelectableEnd)) {
                        nextSelectableEnd = nextSelectableEnd.add(const Duration(days: 1));
                      }

                      DateTimeRange initialRange = DateTimeRange(
                        start: nextSelectable,
                        end: nextSelectableEnd,
                      );

                      DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        initialDateRange: initialRange,
                        firstDate: firstDate,
                        lastDate: lastDate,
                        selectableDayPredicate: (date, _, __) {
                          final blackoutDates = getBlackoutDates(widget.item.id, noOfDays)
                              .map((d) => DateTime(d.year, d.month, d.day))
                              .toSet();
                          final d = DateTime(date.year, date.month, date.day);
                          return !blackoutDates.contains(d);
                        },
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Colors.black,         // Selected day circle
                                onPrimary: Colors.white,     // Selected day text
                                surface: Colors.white,
                                onSurface: Colors.black,     // Unselected day text
                                secondary: Colors.black,       // Range selection (Material 2)
                                // Optionally add tertiary: Colors.red, // For Material 3 range
                              ),
                              
                              useMaterial3: false, // <-- Force Material 2 for consistent coloring
                              textTheme: const TextTheme(
                                headlineMedium: TextStyle(fontSize: 12),
                                bodyMedium: TextStyle(color: Colors.black),
                                bodyLarge: TextStyle(color: Colors.black),
                              ),
                              dialogBackgroundColor: Colors.white,
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        int selectedDays = picked.end.difference(picked.start).inDays + 1;
                        // Check for blackout days in the selected range
                        bool hasBlackout = false;
                        for (int i = 0; i < selectedDays; i++) {
                          final d = picked.start.add(Duration(days: i));
                          if (blackoutDates.contains(DateTime(d.year, d.month, d.day))) {
                            hasBlackout = true;
                            break;
                          }
                        }
                        if (hasBlackout) {
                          // Reset both start and end date, and show a message
                          setState(() {
                            dateRange = null;
                            startDate = null;
                            endDate = null;
                            showConfirm = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Your selected range includes unavailable (blackout) days. Please choose a different range.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (selectedDays < noOfDays) {
                          // Show a warning dialog and do not accept the selection
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Minimum Rental Period'),
                              content: Text('Please select at least $noOfDays days.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                        setState(() {
                          dateRange = picked;
                          startDate = picked.start;
                          endDate = picked.end;
                          noOfDays = selectedDays;
                          showConfirm = true;
                        });
                      }
                    },
                    child: StyledBody(
                      (startDate != null && endDate != null)
                          ? 'Selected: ${DateFormat('dd MMM yyyy').format(startDate!)} - ${DateFormat('dd MMM yyyy').format(endDate!)}'
                          : 'SELECT START AND END DATE', // <-- Changed to all capitals
                      weight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
        ],
      ),
    ),
    bottomNavigationBar: (startDate != null && endDate != null)
        ? SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 48,
                    width: 120, // Shorter width for the button
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // Square corners
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                      child: const Text(
                        'NEXT',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                      onPressed: () {
                        bool loggedIn = Provider.of<ItemStoreProvider>(context, listen: false).loggedIn;
                        int totalPrice = getPricePerDay(noOfDays) * noOfDays;
                        if (loggedIn) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SummaryRental(
                              widget.item,
                              startDate!,
                              endDate!,
                              noOfDays,
                              totalPrice,
                              'booked',
                              symbol,
                            ),
                          ));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const GoogleSignInScreen(),
                          ));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        : null,
  );
  }}