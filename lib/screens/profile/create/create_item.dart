import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_image.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/providers/create_item_provider.dart';
import 'package:revivals/screens/profile/create/set_pricing.dart';
import 'package:revivals/screens/to_rent/view_image.dart';
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
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && widget.item != null) {
      final cip = Provider.of<CreateItemProvider>(context, listen: false);
      cip.sizeValue = (widget.item!.size.isNotEmpty) ? widget.item!.size[0].toString() : '';
      cip.productTypeValue = widget.item!.type;
      cip.colourValue = widget.item!.colour[0];
      cip.brandValue = widget.item!.brand;
      cip.retailPriceValue = widget.item!.rrp.toString();
      cip.retailPriceController.text = widget.item!.rrp.toString();
      cip.shortDescController.text = widget.item!.description.toString();
      cip.longDescController.text = widget.item!.longDescription.toString();
      cip.titleController.text = widget.item!.name.toString();
      cip.images.clear();
      for (ItemImage i in Provider.of<ItemStoreProvider>(context, listen: false).images) {
        for (String itemImageString in widget.item!.imageId) {
          if (i.id == itemImageString) {
            cip.images.add(i.imageId);
          }
        }
      }
      _initialized = true;
      // Schedule checkFormComplete after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        cip.checkFormComplete();
      });
    }
  }

  late Image thisImage;

  List<String> productTypes = ['Dress', 'Bag', 'Jacket', 'Suit Pant'];
  List<String> colours = [
    'Black',
    'White',
    'Blue',
    'Red',
    'Green',
    'Yellow',
    'Grey',
    'Brown',
    'Purple',
    'Pink',
    'Cyan',
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

  List<String> sizes = [
    '4',
    '6',
    '8',
    '10',
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

  final TextEditingController _hashtagsController = TextEditingController();
  List<String> hashtags = [];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // checkFormComplete();
    return Consumer<CreateItemProvider>(
        builder: (context, CreateItemProvider cip, child) {
              log('Images size: ${cip.images.length}');
      // if (widget.item != null) {
      //   cip.productTypeValue = widget.item!.type;
      //   cip.colourValue = widget.item!.colour[0];
      //   cip.brandValue = widget.item!.brand;
      //   cip.retailPriceValue = widget.item!.rrp.toString();
      //   cip.shortDescController.text = widget.item!.description.toString();
      //   cip.longDescController.text = widget.item!.longDescription.toString();
      //   cip.titleController.text = widget.item!.name.toString();
      //   // for (ItemImage i
      //   //     in Provider.of<ItemStoreProvider>(context, listen: false).images) {
      //   //   for (String itemImageString in widget.item!.imageId) {
      //   //     if (i.id == itemImageString) {
      //   //       cip.images.add(i.imageId);
      //   //       log('Added image: ${i.imageId}');
      //   //     }
      //   //   }
      //   // }
      //         log('Images size: ${cip.images.length}');
      // }

      return Scaffold(
          appBar: AppBar(
            toolbarHeight: width * 0.2,
            centerTitle: true,
            title: StyledTitle(widget.item != null ? 'EDIT ITEM' : 'LIST ITEM'),
            leading: IconButton(
              icon: Icon(Icons.chevron_left, size: width * 0.08),
              onPressed: () {
                // Clear all fields before navigating back
                cip.productTypeValue = '';
                cip.colourValue = '';
                cip.brandValue = '';
                cip.retailPriceValue = '';
                cip.titleController.clear();
                cip.shortDescController.clear();
                cip.longDescController.clear();
                cip.retailPriceController.clear();
                cip.images.clear();
                _imageFiles.clear();
                cip.checkFormComplete();
                Navigator.pop(context);
              },
            ),
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(width * 0.05, width * 0.05, width * 0.05, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search item types...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        setState(() {
                          // Optionally filter the boxes based on search
                        });
                      },
                    ),
                    SizedBox(height: width * 0.05),
                    // Item type boxes
                    Wrap(
                      spacing: width * 0.04,
                      runSpacing: width * 0.04,
                      children: [
                        _buildTypeBox(context, width, 'Dress', Icons.checkroom),
                        _buildTypeBox(context, width, 'Bag', Icons.work_outline),
                        _buildTypeBox(context, width, 'Suit Pant', Icons.shopping_bag_outlined),
                        _buildTypeBox(context, width, 'Jacket', Icons.emoji_people_outlined),
                      ],
                    ),
                  ],
                ),
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
            child: OutlinedButton(
              onPressed: cip.isCompleteForm
                  ? () async {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SetPricing(
                          cip.productTypeValue,
                          cip.brandValue,
                          cip.titleController.text,
                          cip.colourValue,
                          cip.retailPriceValue,
                          cip.shortDescController.text,
                          cip.longDescController.text,
                          cip.sizeValue,
                          const [],
                          _imageFiles,
                          dailyPrice: widget.item?.rentPriceDaily.toString(),
                          weeklyPrice: widget.item?.rentPriceWeekly.toString(),
                          monthlyPrice: widget.item?.rentPriceMonthly.toString(),
                          minRentalPeriod: widget.item?.minDays.toString(),
                          hashtags: hashtags,
                          id: widget.item?.id, // <-- Pass the id here
                        ),
                      ));
                    }
                  : null,
              style: OutlinedButton.styleFrom(
                backgroundColor: cip.isCompleteForm ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(1.0),
                ),
                side: const BorderSide(width: 1.0, color: Colors.black),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StyledHeading(
                  'CONTINUE',
                  color: cip.isCompleteForm ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ));
    });
  }

  uploadFile() async {
    String id =
        Provider.of<ItemStoreProvider>(context, listen: false).renter.id;
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
                      cip.images.add(image.path);
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
                      cip.images.add(image.path);
                      _imageFiles.add(image);
                      log('Added imageFile: ${image.path.toString()}');
                    }

                    setState(() {});
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
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
                      builder: (context) => (ViewImage(
                            cip.images,
                            n,
                            isNetworkImage: false,
                          ))));
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

  void showHashtagModal(double width, double height) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        String newHashtag = '';
        List<String> allHashtags = [
          // Example: populate with your app's global hashtags or fetch from backend
          'summer', 'wedding', 'party', 'vintage', 'designer', 'classic', 'new', 'sale'
        ];
        // Remove already selected hashtags from the list
        final availableHashtags = allHashtags.where((tag) => !hashtags.contains(tag)).toList();

        return FractionallySizedBox(
          heightFactor: 0.7,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.all(width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Free text entry at the top
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Enter a hashtag (no # needed)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final text = newHashtag.trim();
                            if (text.isNotEmpty && !hashtags.contains(text)) {
                              setState(() {
                                hashtags.add(text);
                              });
                              setModalState(() {
                                newHashtag = '';
                              });
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          newHashtag = val;
                        });
                      },
                      onSubmitted: (val) {
                        final text = val.trim();
                        if (text.isNotEmpty && !hashtags.contains(text)) {
                          setState(() {
                            hashtags.add(text);
                          });
                          setModalState(() {
                            newHashtag = '';
                          });
                          Navigator.pop(context);
                        }
                      },
                    ),
                    SizedBox(height: width * 0.04),
                    const StyledBody('Choose from existing hashtags:'),
                    SizedBox(height: width * 0.02),
                    Expanded(
                      child: availableHashtags.isEmpty
                          ? const Center(child: StyledBody('No more hashtags'))
                          : ListView.separated(
                              itemCount: availableHashtags.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final tag = availableHashtags[index];
                                return ListTile(
                                  title: Text('#$tag'),
                                  trailing: const Icon(Icons.add, color: Colors.black),
                                  onTap: () {
                                    setState(() {
                                      hashtags.add(tag);
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTypeBox(BuildContext context, double width, String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Set the selected type and continue to the next step
        final cip = Provider.of<CreateItemProvider>(context, listen: false);
        cip.productTypeValue = label;
        cip.checkFormComplete();
        // You can navigate to the next screen or show the rest of the form here
      },
      child: Container(
        width: width * 0.4,
        height: width * 0.4,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: width * 0.15, color: Colors.black87),
            SizedBox(height: width * 0.03),
            StyledHeading(label),
          ],
        ),
      ),
    );
  }
}
