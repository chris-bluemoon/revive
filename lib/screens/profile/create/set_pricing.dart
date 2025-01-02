import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/services/class_store.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class SetPricing extends StatefulWidget {
  const SetPricing(this.productType, this.brand, this.title, this.colour, this.retailPrice, this.shortDesc,
    this.longDesc, this.imagePath, this.imageFiles, {super.key});

final String productType;
final String brand;
final String title;
final String colour;
final String retailPrice; 
final String shortDesc;
final String longDesc;
final List<String> imagePath;
final List<XFile> imageFiles;


  @override
  State<SetPricing> createState() => _SetPricingState();
}

class _SetPricingState extends State<SetPricing> {
  @override
  void initState() {
    super.initState();
  }

List<String> imagePaths = [];

final dailyPriceController = TextEditingController();
final weeklyPriceController = TextEditingController();
final monthlyPriceController = TextEditingController();
final minimalRentalPeriodController = TextEditingController();

bool postageSwitch = false;

  bool formComplete = false;

  FirebaseStorage storage = FirebaseStorage.instance;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    checkFormComplete();
   
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        centerTitle: true,
        title: const StyledTitle('SET PRICING'),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: 
        Padding(
          padding: EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              SizedBox(height: width * 0.02),
              const StyledBody('Based on our price analytics we have provided you with optimal pricing to maximise rentals', weight: FontWeight.normal),
              SizedBox(height: width * 0.05),
              const StyledBody('Daily Price'),
              const StyledBody('Please provide a price per day for the item', weight: FontWeight.normal),
              SizedBox(height: width * 0.03),
              TextField(
                        keyboardType: TextInputType.number,
                        maxLines: null,
                        maxLength: 10,
                        controller: dailyPriceController,
                        onChanged: (text) {
                          monthlyPriceController.text = (int.parse(text) * 0.5).round().toString();
                          weeklyPriceController.text = (int.parse(text) * 0.8).round().toString();
                          // checkContents(text);
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.black)
                          ),
                          filled: true,
                          hintStyle: TextStyle(color: Colors.grey[800]),
                          hintText: "Daily Price",
                          fillColor: Colors.white70,
                        ),
                      ),
              const StyledBody('Weekly Price'),
              const StyledBody('In order to facilitate longer rentals such as holidays, we recommend offering weekly and/or monthly rental prices', weight: FontWeight.normal),
              SizedBox(height: width * 0.03),
              TextField(
                        keyboardType: TextInputType.number,
                        maxLines: null,
                        maxLength: 10,
                        controller: weeklyPriceController,
                        onChanged: (text) {
                          // checkContents(text);
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.black)
                          ),
                          filled: true,
                          hintStyle: TextStyle(color: Colors.grey[800]),
                          hintText: "Weekly Price",
                          fillColor: Colors.white70,
                        ),
                      ),
              const StyledBody('Monthly Price'),
              SizedBox(height: width * 0.03),
              TextField(
                        keyboardType: TextInputType.number,
                        maxLines: null,
                        maxLength: 10,
                        controller: monthlyPriceController,
                        onChanged: (text) {
                          // checkContents(text);
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.black)
                          ),
                          filled: true,
                          hintStyle: TextStyle(color: Colors.grey[800]),
                          hintText: "Monthly Price",
                          fillColor: Colors.white70,
                        ),
                      ),
              const StyledBody('Minimal Rental Period'),
              const StyledBody('Tip: The most common minimum rental period is 3 days', weight: FontWeight.normal),
              SizedBox(height: width * 0.03),
              TextField(
                        keyboardType: TextInputType.number,
                        maxLines: null,
                        maxLength: 10,
                        controller: minimalRentalPeriodController,
                        onChanged: (text) {
                          // checkContents(text);
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Colors.black)
                          ),
                          filled: true,
                          hintStyle: TextStyle(color: Colors.grey[800]),
                          hintText: 'Minimal Rental Period (days)',
                          fillColor: Colors.white70,
                        ),
                      ),
              const StyledBody('Postage Option'),
              const StyledBody('You can offer the option of local country tracked mail by charging a flat rate for this. The item should be received on the day the rental period begins at the very latest. The renter is in charge of sending back the item to you and icurring the fee', weight: FontWeight.normal),
              SizedBox(height: width * 0.03),
              Row(
                children: [
                  const StyledBody('Allow Postage Option'),
                  const Expanded(child: SizedBox()),
                  Switch(
                    value: postageSwitch, 
                    onChanged: (value) {
                      setState(() {
                        postageSwitch = value;
                      });
                    }),
                ],
              ),
              SizedBox(height: width * 0.03),
            ]
            ),
        )
        ),
      bottomNavigationBar: Container(
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
                if (!formComplete) Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                    },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                      side: const BorderSide(width: 1.0, color: Colors.black),
                      ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: StyledHeading('SUBMIT', weight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                if (formComplete) Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      handleSubmit();
                      Navigator.of(context).popUntil((route) => route.isFirst);

                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                      side: const BorderSide(width: 1.0, color: Colors.black),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: StyledHeading('SUBMIT', color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),   
      );
  }
    uploadFile(passedFile) {
    String id = Provider.of<ItemStore>(context, listen: false).renter.id;
    String rng = uuid.v4();
    Reference ref = storage.ref().child('items').child(id).child('$rng.png');
   
    File file = File(passedFile.path);
    UploadTask uploadTask = ref.putFile(file);
   
    uploadTask;
    //
    imagePaths.add(ref.fullPath.toString());
    log('uploadTask has completed');
   
    // setState(() {
      // readyToSubmit = true;
    // });
    // return await taskSnapshot.ref.getDownloadURL();
  }
  handleSubmit() {
    String ownerId = Provider.of<ItemStore>(context, listen: false).renter.id;
    
    for (XFile passedFile in widget.imageFiles) {
      log('Uploading passedFile: ${passedFile.path.toString()}');
      uploadFile(passedFile);
    }
    Provider.of<ItemStore>(context, listen: false).addItem(Item(
        id: uuid.v4(),
        owner: ownerId,
        type: widget.productType,
        bookingType: allItems[0].bookingType,
        occasion: allItems[0].occasion,
        dateAdded: allItems[0].dateAdded,
        style: allItems[0].style,
        name: widget.title,
        brand: widget.brand,
        colour: [widget.colour],
        size: ['6'],
        length: allItems[0].length,
        print: allItems[0].print,
        sleeve: allItems[0].sleeve,
        rentPrice: int.parse(dailyPriceController.text),
        buyPrice: allItems[0].buyPrice,
        rrp: int.parse(widget.retailPrice.substring(1)),
        description: widget.shortDesc,
        bust: allItems[0].bust,
        waist: allItems[0].waist,
        hips: allItems[0].hips,
        longDescription: widget.longDesc,
        imageId: imagePaths,
        status: 'submitted'
        ));
  }
  void checkFormComplete() {
    if (dailyPriceController.text != '' &&
      weeklyPriceController.text != '' &&
      monthlyPriceController.text != '' &&
      minimalRentalPeriodController.text != '') {
      formComplete = true;
    }
  }
  
}
