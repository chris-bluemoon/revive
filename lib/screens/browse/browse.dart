import 'package:flutter/material.dart';
import 'package:revivals/shared/item_results.dart';
import 'package:revivals/shared/styled_text.dart';

class Browse extends StatefulWidget {
  const Browse({super.key});

  @override
  State<Browse> createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  final List<Map<String, dynamic>> itemTypes = [
    {'label': 'Dress', 'icon': Icons.checkroom},
    {'label': 'Bag', 'icon': Icons.work_outline},
    {'label': 'Suit Pant', 'icon': Icons.shopping_bag_outlined},
    {'label': 'Jacket', 'icon': Icons.emoji_people_outlined},
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StyledTitle('BROWSE'),
          ],
        ),
        centerTitle: true,
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
                    prefixIcon: const Icon(Icons.search),
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
                      searchQuery = value;
                    });
                  },
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ItemResults(
                            'search',
                            '', // value is not used for search, only values is used
                            values: value
                                .split(RegExp(r'\s+|,'))
                                .where((s) => s.isNotEmpty)
                                .toList(),
                          ),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: width * 0.05),
                // Item type boxes
                Wrap(
                  spacing: width * 0.04,
                  runSpacing: width * 0.04,
                  children: itemTypes.map((type) {
                    return _buildTypeBox(context, width, type['label'], type['icon']);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBox(BuildContext context, double width, String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ItemResults(
              'type',
              label,
            ),
          ),
        );
      },
      child: Container(
        width: width * 0.4,
        height: width * 0.4,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12, width: 1.5),
          boxShadow: const [
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
