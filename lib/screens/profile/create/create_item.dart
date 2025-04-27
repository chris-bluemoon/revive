import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_image.dart';
import 'package:revivals/screens/profile/create/set_pricing.dart';
import 'package:revivals/screens/profile/create/view_image.dart';
import 'package:revivals/services/class_store.dart';
import 'package:revivals/providers/create_item_provider.dart';
import 'package:revivals/shared/black_button.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class CreateItem extends StatefulWidget {
  const CreateItem({required this.item, super.key});

  final Item? item;

  // final item;

  @override
  State<CreateItem> createState() => _CreateItemState();
}

class _CreateItemState extends State<CreateItem> {
  @override
  void initState() {
    brands.sort((a, b) => a.compareTo(b));
    colours.sort((a, b) => a.compareTo(b));
    super.initState();
  }

  late Image thisImage;

  List<String> productTypes = ['Dress', 'Bag', 'Jacket', 'Suit Pant'];
  List<String> colours = [
    'Black',
    'White',
    'Blue',
    'Red',
    'Green',
    'Grey',
    'Brown',
    'Yellow',
    'Purple',
    'Pink',
    'Lime',
    'Cyan',
    'Teal'
  ];

  // String productTypeValue = '';
  // String colourValue = '';
  // String brandValue = '';
  // String retailPriceValue = '';

  List<String> brands = [
    'BARDOT',
    'HOUSE OF CB',
    'LEXI',
    'AJE',
    'ALC',
    'BRONX AND BANCO',
    'ELIYA',
    'NADINE MERABI',
    'REFORMATION',
    'SELKIE',
    'ZIMMERMANN',
    'ROCOCO SAND',
    'BAOBAB'
  ];

  List<String> imagePath = [];

  bool readyToSubmit = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final List<XFile> _imageFiles = [];
  // final List<XFile> _images = [];
  // final List<Image> _images = [];

  FirebaseStorage storage = FirebaseStorage.instance;

  String number = '';

  // final titleController = TextEditingController();
  // final retailPriceController = TextEditingController();
  // final shortDescController = TextEditingController();
  // final longDescController = TextEditingController();

  // bool formComplete = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // checkFormComplete();
    return Consumer<CreateItemProvider>(
        builder: (context, CreateItemProvider cip, child) {
      if (widget.item != null) {
        cip.productTypeValue = widget.item!.type;
        cip.colourValue = widget.item!.colour[0];
        cip.brandValue = widget.item!.brand;
        cip.retailPriceValue = widget.item!.rrp.toString();
        cip.shortDescController.text = widget.item!.description.toString();
        cip.longDescController.text = widget.item!.longDescription.toString();
        cip.titleController.text = widget.item!.name.toString();
        for (ItemImage i
            in Provider.of<ItemStore>(context, listen: false).images) {
          for (String itemImageString in widget.item!.imageId) {
            if (i.id == itemImageString) {
              cip.images.add(i.imageId);
            }
          }
        }
      }

      return Scaffold(
          appBar: AppBar(
            toolbarHeight: width * 0.2,
            centerTitle: true,
            title: const StyledTitle('LIST ITEM'),
            leading: IconButton(
              icon: Icon(Icons.chevron_left, size: width * 0.08),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: (cip.images.isNotEmpty)
                            ? SizedBox(width: 80, child: cip.images[0])
                            : Icon(Icons.image_outlined, size: width * 0.2),
                        onTap: () {
                          if (cip.images.isNotEmpty) {
                            showModal('edit', 1, width);
                          } else {
                            showModal('create', 1, width);
                          }
                          cip.checkFormComplete();
                        },
                      ),
                      SizedBox(width: width * 0.02),
                      GestureDetector(
                        child: (cip.images.length > 1)
                            ? SizedBox(width: 80, child: cip.images[1])
                            : Icon(Icons.image_outlined, size: width * 0.2),
                        onTap: () {
                          if (cip.images.length > 1) {
                            showModal('edit', 2, width);
                          } else {
                            showModal('create', 2, width);
                          }
                          cip.checkFormComplete();
                        },
                      ),
                      SizedBox(width: width * 0.02),
                      GestureDetector(
                        child: (cip.images.length > 2)
                            ? SizedBox(width: 80, child: cip.images[2])
                            : Icon(Icons.image_outlined, size: width * 0.2),
                        onTap: () {
                          if (cip.images.length > 2) {
                            showModal('edit', 3, width);
                          } else {
                            showModal('create', 3, width);
                          }
                          cip.checkFormComplete();
                        },
                      ),
                      SizedBox(width: width * 0.02),
                      GestureDetector(
                        child: (cip.images.length > 3)
                            ? SizedBox(width: 80, child: cip.images[3])
                            : Icon(Icons.image_outlined, size: width * 0.2),
                        onTap: () {
                          if (cip.images.length > 3) {
                            showModal('edit', 4, width);
                          } else {
                            showModal('create', 4, width);
                          }
                          cip.checkFormComplete();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: width * 0.02),
                  const Divider(),
                  InkWell(
                    onTap: () => showModalBottomSheet(
                        backgroundColor: Colors.white,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return FractionallySizedBox(
                            heightFactor: 0.9,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(width * 0.03),
                                  child: ListTile(
                                    trailing: Icon(Icons.close,
                                        color: Colors.white,
                                        size: width * 0.04),
                                    leading: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Icon(Icons.close,
                                            color: Colors.black,
                                            size: width * 0.04)),
                                    title: const Center(
                                        child: StyledBody('PRODUCT TYPE')),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          width * 0.05,
                                          width * 0.05,
                                          width * 0.05,
                                          width * 0.05),
                                      child: ListView.separated(
                                          itemCount: productTypes.length,
                                          separatorBuilder: (BuildContext
                                                      context,
                                                  int index) =>
                                              Divider(height: height * 0.05),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  // formComplete = true;
                                                  cip.productTypeValue =
                                                      productTypes[index];
                                                });
                                                Navigator.pop(context);
                                                cip.checkFormComplete();
                                              },
                                              child: SizedBox(
                                                  // height: 50,
                                                  child: StyledBody(
                                                      productTypes[index])),
                                            );
                                          }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    child: SizedBox(
                      height: width * 0.1,
                      child: Row(
                        children: [
                          const StyledBody('Product Type'),
                          const Expanded(child: SizedBox()),
                          StyledBody(cip.productTypeValue),
                          Icon(Icons.chevron_right_outlined, size: width * 0.05)
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  InkWell(
                    onTap: () => showModalBottomSheet(
                        backgroundColor: Colors.white,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return FractionallySizedBox(
                            heightFactor: 0.9,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(width * 0.03),
                                  child: ListTile(
                                    trailing: Icon(Icons.close,
                                        color: Colors.white,
                                        size: width * 0.04),
                                    leading: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Icon(Icons.close,
                                            color: Colors.black,
                                            size: width * 0.04)),
                                    title: const Center(
                                        child: StyledBody('COLOURS')),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          width * 0.05,
                                          width * 0.05,
                                          width * 0.05,
                                          width * 0.05),
                                      child: ListView.separated(
                                          itemCount: colours.length,
                                          separatorBuilder: (BuildContext
                                                      context,
                                                  int index) =>
                                              Divider(height: height * 0.05),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  cip.colourValue =
                                                      colours[index];
                                                });
                                                Navigator.pop(context);
                                                cip.checkFormComplete();
                                              },
                                              child: SizedBox(
                                                  // height: 50,
                                                  child: StyledBody(
                                                      colours[index])),
                                            );
                                          }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    child: SizedBox(
                      height: width * 0.1,
                      child: Row(
                        children: [
                          const StyledBody('Colours'),
                          const Expanded(child: SizedBox()),
                          StyledBody(cip.colourValue),
                          Icon(Icons.chevron_right_outlined, size: width * 0.05)
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  InkWell(
                    onTap: () => showModalBottomSheet(
                        backgroundColor: Colors.white,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return FractionallySizedBox(
                            heightFactor: 0.9,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(width * 0.03),
                                  child: ListTile(
                                    trailing: Icon(Icons.close,
                                        color: Colors.white,
                                        size: width * 0.04),
                                    leading: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Icon(Icons.close,
                                            color: Colors.black,
                                            size: width * 0.04)),
                                    title: const Center(
                                        child: StyledBody('BRAND')),
                                    // leading: IconButton(
                                    //   onPressed: () {
                                    //     Navigator.pop(context);
                                    //   },
                                    //   icon: Icon(Icons.close, size: width * 0.04))
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          width * 0.05,
                                          width * 0.05,
                                          width * 0.05,
                                          width * 0.05),
                                      child: ListView.separated(
                                          itemCount: brands.length,
                                          separatorBuilder: (BuildContext
                                                      context,
                                                  int index) =>
                                              Divider(height: height * 0.05),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  cip.brandValue =
                                                      brands[index];
                                                });
                                                Navigator.pop(context);
                                                cip.checkFormComplete();
                                              },
                                              child: SizedBox(
                                                  // height: 50,
                                                  child: StyledBody(
                                                      brands[index])),
                                            );
                                          }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    child: SizedBox(
                      height: width * 0.1,
                      child: Row(
                        children: [
                          const StyledBody('Brand'),
                          const Expanded(child: SizedBox()),
                          StyledBody(cip.brandValue),
                          Icon(Icons.chevron_right_outlined, size: width * 0.05)
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  InkWell(
                    onTap: () => showModalBottomSheet(
                        backgroundColor: Colors.white,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return FractionallySizedBox(
                            heightFactor: 0.9,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(width * 0.03),
                                  child: ListTile(
                                    trailing: Icon(Icons.close,
                                        color: Colors.white,
                                        size: width * 0.04),
                                    leading: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Icon(Icons.close,
                                            color: Colors.black,
                                            size: width * 0.04)),
                                    title: const Center(
                                        child: StyledBody('RETAIL PRICE')),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(width * 0.03),
                                  child: const StyledBody(
                                      'The retail price of market value (if no longer in production) of the item',
                                      weight: FontWeight.normal),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(width * 0.03),
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    maxLines: null,
                                    maxLength: 10,
                                    controller: cip.retailPriceController,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                              color: Colors.black)),
                                      filled: true,
                                      hintStyle:
                                          TextStyle(color: Colors.grey[800]),
                                      hintText: "Daily Price",
                                      fillColor: Colors.white70,
                                    ),
                                  ),
                                ),
                                BlackButton('SAVE', width * 0.1, () {
                                  Navigator.pop(context);
                                  setState(() {
                                    cip.retailPriceValue =
                                        cip.retailPriceController.text;
                                  });
                                  cip.checkFormComplete();
                                }),
                              ],
                            ),
                          );
                        }),
                    child: SizedBox(
                      height: width * 0.1,
                      child: Row(
                        children: [
                          const StyledBody('Retail Price'),
                          const Expanded(child: SizedBox()),
                          StyledBody(cip.retailPriceValue),
                          Icon(Icons.chevron_right_outlined, size: width * 0.05)
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  SizedBox(height: width * 0.04),
                  const Row(
                    children: [
                      StyledBody('Describe your item'),
                    ],
                  ),
                  SizedBox(height: width * 0.01),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    maxLength: 60,
                    controller: cip.titleController,
                    onChanged: (text) {
                      cip.checkFormComplete();
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
                          borderSide: const BorderSide(color: Colors.black)),
                      filled: true,
                      hintStyle: TextStyle(color: Colors.grey[800]),
                      hintText: "Title",
                      fillColor: Colors.white70,
                    ),
                  ),
                  // SizedBox(height: width * 0.01),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    minLines: 2,
                    maxLines: null,
                    maxLength: 200,
                    controller: cip.shortDescController,
                    onChanged: (text) {
                      // checkContents(text);
                      cip.checkFormComplete();
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
                          borderSide: const BorderSide(color: Colors.black)),
                      filled: true,
                      hintStyle: TextStyle(color: Colors.grey[800]),
                      hintText: "Short Description",
                      fillColor: Colors.white70,
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    maxLines: null,
                    maxLength: 1000,
                    controller: cip.longDescController,
                    onChanged: (text) {
                      // checkContents(text);
                      cip.checkFormComplete();
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
                          borderSide: const BorderSide(color: Colors.black)),
                      filled: true,
                      hintStyle: TextStyle(color: Colors.grey[800]),
                      hintText: "Long Description",
                      fillColor: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border.all(color: Colors.black.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 3,
                )
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Expanded(
              child: OutlinedButton(
                onPressed: cip.isCompleteForm
                    ? () async {
                        // handleSubmit();
                        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => (SetPricing(productTypeValue, brandValue, titleController.text, colourValue, retailPriceValue, shortDescController.text, longDescController.text, imagePath, _imageFiles))));
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => (SetPricing(
                                cip.productTypeValue,
                                cip.brandValue,
                                cip.titleController.text,
                                cip.colourValue,
                                cip.retailPriceValue,
                                cip.shortDescController.text,
                                cip.longDescController.text,
                                const [],
                                _imageFiles))));
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      cip.isCompleteForm ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                  side: const BorderSide(width: 1.0, color: Colors.black),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StyledHeading('CONTINUE',
                      color: cip.isCompleteForm ? Colors.white : Colors.grey),
                ),
              ),
            ),
          ));
    });
  }

  uploadFile() async {
    String id = Provider.of<ItemStore>(context, listen: false).renter.id;
    String rng = uuid.v4();
    Reference ref = storage.ref().child('items').child(id).child('$rng.png');

    File file = File(_image!.path);
    UploadTask uploadTask = ref.putFile(file);

    await uploadTask;
    //
    imagePath.add(ref.fullPath.toString());
    log('Added imagePath of: ${ref.fullPath.toString()}');

    setState(() {
      readyToSubmit = true;
    });
    // return await taskSnapshot.ref.getDownloadURL();
  }

  // listFiles() async {
  //   final storageRef = FirebaseStorage.instance.ref();
  //   final listResult = await storageRef.listAll();
  //   // for (var prefix in listResult.prefixes) {
  //   // The prefixes under storageRef.
  //   // You can call listAll() recursively on them.
  //   // // }
  //   // for (var ref in listResult.items) {
  //   //   print('Found file: $ref');
  //   // }
  //   // for (var item in listResult.items) {}
  // }

  void showModal(type, n, width) {
    CreateItemProvider cip =
        Provider.of<CreateItemProvider>(context, listen: false);
    if (type == 'create') {
      showModalBottomSheet(
          backgroundColor: Colors.white,
          context: context,
          isScrollControlled: false,
          constraints:
              BoxConstraints(maxHeight: width * 0.4, minWidth: width * 0.8),
          builder: (context) {
            return Column(
              children: [
                SizedBox(height: width * 0.04),
                GestureDetector(
                  onTap: () async {
                    final XFile? image = await _picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1000,
                        maxHeight: 1500,
                        imageQuality: 100);
                    if (image != null) {
                      cip.images.add(Image.file(File(image.path)));
                      _imageFiles.add(image);
                      log('Added imageFile: ${image.path.toString()}');
                    }

                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Center(child: StyledBody('ADD FROM GALLERY')),
                ),
                Divider(height: width * 0.04),
                GestureDetector(
                  onTap: () async {
                    final XFile? image = await _picker.pickImage(
                        source: ImageSource.camera,
                        maxWidth: 1000,
                        maxHeight: 1500,
                        imageQuality: 100);
                    if (image != null) {
                      cip.images.add(Image.file(File(image.path)));
                      _imageFiles.add(image);
                      log('Added imageFile: ${image.path.toString()}');
                    }

                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Center(child: StyledBody('ADD FROM CAMERA')),
                ),
                // SizedBox(height: 400)
              ],
            );
          });
    } else if (type == 'edit') {
      showModalBottomSheet(
          backgroundColor: Colors.white,
          context: context,
          isScrollControlled: false,
          constraints:
              BoxConstraints(maxHeight: width * 0.4, minWidth: width * 0.8),
          builder: (context) {
            return Column(children: [
              SizedBox(height: width * 0.04),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => (ViewImage(cip.images, n))));
                },
                child: const Center(child: StyledBody('VIEW IMAGE')),
              ),
              Divider(height: width * 0.04),
              GestureDetector(
                onTap: () {
                  setState(() {
                    cip.images.removeAt(n - 1);
                    _imageFiles.removeAt(n - 1);
                  });
                  Navigator.pop(context);
                  cip.checkFormComplete();
                },
                child: const Center(child: StyledBody('DELETE')),
              ),
            ]);
          });
    }
  }

  // void checkFormComplete() {
  //   formComplete = true;
  //   if (_images.isNotEmpty &&
  //       productTypeValue != '' &&
  //       colourValue != '' &&
  //       brandValue != '' &&
  //       titleController.text != '' &&
  //       shortDescController.text != '' &&
  //       longDescController.text != '') {
  //     formComplete = true;
  //   }
  // }
}
