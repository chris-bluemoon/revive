import 'package:flutter/material.dart';

class CreateItemProvider with ChangeNotifier {
  bool isCompleteForm = false;
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
      isCompleteForm = true;
    } else {
      isCompleteForm = false;
    }
    notifyListeners();
  }
}
