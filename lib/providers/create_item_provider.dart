import 'package:flutter/material.dart';

class CreateItemProvider with ChangeNotifier {
  bool isCompleteForm = false;
  final List<String> images = [];
  String productTypeValue = '';
  String colourValue = '';
  String brandValue = '';
  String retailPriceValue = '';
  String _sizeValue = '';
  String get sizeValue => _sizeValue;
  set sizeValue(String value) {
    _sizeValue = value;
    notifyListeners();
  }

  final titleController = TextEditingController();
  final retailPriceController = TextEditingController();
  final shortDescController = TextEditingController();
  final longDescController = TextEditingController();
  void checkFormComplete() {
    if (images.isNotEmpty &&
        productTypeValue.isNotEmpty &&
        colourValue.isNotEmpty &&
        brandValue.isNotEmpty &&
        // sizeValue.isNotEmpty && // <-- Add this line
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
