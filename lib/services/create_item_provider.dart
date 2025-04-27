import 'package:flutter/material.dart';

class CreateItemProvider with ChangeNotifier {
  bool isComplete_listItem = false;
  final List<Image> images = [];
  String productTypeValue = '';
  String colourValue = '';
  String brandValue = '';
  String retailPriceValue = '';
  final titleController = TextEditingController();
  final retailPriceController = TextEditingController();
  final shortDescController = TextEditingController();
  final longDescController = TextEditingController();
  void checkFormComplete() {
    if (images.isNotEmpty &&
        productTypeValue.isNotEmpty &&
        colourValue.isNotEmpty &&
        brandValue.isNotEmpty &&
        titleController.text.isNotEmpty &&
        shortDescController.text.isNotEmpty &&
        longDescController.text.isNotEmpty) {
      isComplete_listItem = true;
    } else {
      isComplete_listItem = false;
    }
    notifyListeners();
  }
}
