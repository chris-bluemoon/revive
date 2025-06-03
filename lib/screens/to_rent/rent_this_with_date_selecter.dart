// import 'dart:developer';

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/sign_up/google_sign_in.dart';
import 'package:revivals/screens/summary/summary_rental.dart';
import 'package:revivals/shared/get_country_price.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
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

    if (noOfDays < 7) {
        return widget.item.rentPriceDaily;
    }

    if (noOfDays < 30) {
      return widget.item.rentPriceWeekly ~/ 7;
    }

    if (noOfDays >= 30) {
      return widget.item.rentPriceMonthly ~/ 30;
    }

    return 0;

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
  final DateRangePickerController controller = DateRangePickerController();


  @override
  Widget build(BuildContext context) {
    // rebuildAllChildren(context);
    String country = 'BANGKOK';
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
            const StyledHeading('Select Rental Period', weight: FontWeight.normal),
            SizedBox(height: width * 0.03),

            // Add day options
            // if (startDate == null && endDate == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate a responsive width based on screen size, with a minimum
                        double chipWidth = (MediaQuery.of(context).size.width * 0.7).clamp(220, 400);
                        return Column(
                          children: [
                            SizedBox(
                              width: chipWidth,
                              child: ChoiceChip(
                                label: Text(
                                  '${widget.item.minDays}+ days @ ${getPricePerDay(3)} per day',
                                  overflow: TextOverflow.ellipsis,
                                ),
                                selected: selectedOption == 3,
                                selectedColor: Colors.grey[200],
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: selectedOption == 3 ? Colors.black : Colors.grey,
                                  width: 2,
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    selectedOption = 3;
                                    noOfDays = 3;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: chipWidth,
                              child: ChoiceChip(
                                label: Text(
                                  '7+ days @ ${getPricePerDay(7)} per day',
                                  overflow: TextOverflow.ellipsis,
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
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: chipWidth,
                              child: ChoiceChip(
                                label: Text(
                                  '30+ days @ ${getPricePerDay(30)} per day',
                                  overflow: TextOverflow.ellipsis,
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
                            ),
                          ],
                        );
                      },
                    ),
                  ],
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

                      // Use selectedOption for minimum days
                      // int minDays = selectedOption > 0 ? selectedOption : 3;

                      // Find the next selectable start date
                      DateTime nextSelectable = onlyDateTomorrow;
                      final blackoutDates = getBlackoutDates(widget.item.id, widget.item.minDays)
                          .map((d) => DateTime(d.year, d.month, d.day))
                          .toSet();
                      while (blackoutDates.contains(nextSelectable)) {
                        nextSelectable = nextSelectable.add(const Duration(days: 1));
                      }

                      // Find the next selectable end date after start
                      DateTime nextSelectableEnd = nextSelectable.add(Duration(days: widget.item.minDays - 1));
                      while (blackoutDates.contains(nextSelectableEnd)) {
                        nextSelectableEnd = nextSelectableEnd.add(const Duration(days: 1));
                      }

                      DateTimeRange initialRange = DateTimeRange(
                        start: nextSelectable,
                        end: nextSelectableEnd,
                      );

                      DateTimeRange? picked = await showSfDateRangePicker(
                        context,
                        firstDate,
                        lastDate,
                        blackoutDates,
                        initialRange,
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
                          setState(() {
                            dateRange = null;
                            startDate = null;
                            endDate = null;
                            showConfirm = false;
                          });
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
                        log('No of days: $noOfDays');
                        int totalPrice = getPricePerDay(noOfDays) * noOfDays;
                        int days = startDate!.difference(endDate!).inDays.abs() + 1;
                        if (loggedIn) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SummaryRental(
                              widget.item,
                              startDate!,
                              endDate!,
                              days,
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
  }

  Future<DateTimeRange?> showSfDateRangePicker(
  BuildContext context,
  DateTime firstDate,
  DateTime lastDate,
  Set<DateTime> blackoutDates,
  DateTimeRange initialRange,
) async {
  DateTimeRange? pickedRange;
  DateTime? start = initialRange.start;
  DateTime? end = initialRange.end;
  Set<DateTime> dynamicBlackoutDates = {...blackoutDates};
  // int minDays = selectedOption > 0 ? selectedOption : 3;

  await showDialog(
    context: context,
    builder: (context) {
      PickerDateRange selectedRange = PickerDateRange(start, end);
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white, // <-- Add this line
            title: const Text('Select Rental Dates'),
            content: SizedBox(
              width: 350,
              height: 400,
              child: SfDateRangePicker(
                controller: controller,
                initialSelectedRange: selectedRange,
                minDate: firstDate,
                maxDate: lastDate,
                selectionMode: DateRangePickerSelectionMode.range,
                enablePastDates: false,
                backgroundColor: Colors.white,
                viewSpacing: 0,
                headerStyle: const DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  backgroundColor: Colors.white,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                monthViewSettings: DateRangePickerMonthViewSettings(
                  blackoutDates: dynamicBlackoutDates.toList(),
                ),
                monthCellStyle: const DateRangePickerMonthCellStyle(
                  blackoutDateTextStyle: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                selectionShape: DateRangePickerSelectionShape.circle, // <-- Make selection circular
                startRangeSelectionColor: Colors.black,
                endRangeSelectionColor: Colors.black,
                rangeSelectionColor: Colors.black12,
                todayHighlightColor: Colors.black,
                selectionColor: Colors.black,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  if (args.value is PickerDateRange) {
                    final PickerDateRange range = args.value;
                    if (range.startDate != null) {
                      start = range.startDate;
                      setState(() {
                        dynamicBlackoutDates = {...blackoutDates};
                      });
                    }
                    if (range.endDate != null) {
                      end = range.endDate;
                      int selectedDays = end!.difference(start!).inDays + 1;

                      // Check if any blackout date is in the selected range
                      bool hasBlackout = false;
                      DateTime temp = start!;
                      while (!temp.isAfter(end!)) {
                        if (dynamicBlackoutDates.contains(DateTime(temp.year, temp.month, temp.day))) {
                          hasBlackout = true;
                          break;
                        }
                        temp = temp.add(const Duration(days: 1));
                      }

                      // Only enforce minimum days if there are NO blackout days in the range
                      if (!hasBlackout && selectedDays < widget.item.minDays) { // <-- use minDays here
                        end = start!.add(Duration(days: widget.item.minDays - 1)); // <-- use minDays here
                        controller.selectedRange = PickerDateRange(start, end);
                        setState(() {
                          selectedRange = PickerDateRange(start, end);
                        });
                        return;
                      }

                      if (hasBlackout) {
                        // Reset selection to single day (end date)
                        start = end;
                        controller.selectedRange = PickerDateRange(start, end);
                        setState(() {
                          selectedRange = PickerDateRange(start, end);
                        });
                      } else {
                        setState(() {
                          selectedRange = PickerDateRange(start, end);
                        });
                      }
                    } else {
                      setState(() {
                        selectedRange = PickerDateRange(start, start);
                      });
                    }
                  }
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.black), // <-- Black text
                ),
              ),
              TextButton(
                onPressed: () {
                  if (start != null && end != null) {
                    pickedRange = DateTimeRange(start: start!, end: end!);
                  }
                  Navigator.pop(context);
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.black), // <-- Black text
                ),
              ),
            ],
          );
        },
      );
    },
  );
  return pickedRange;
}}