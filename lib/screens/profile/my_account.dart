import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/services/class_store.dart';
import 'package:revivals/shared/styled_text.dart';
import 'edit_profile_page.dart';

class MyAccount extends StatefulWidget {
  const MyAccount(this.userN, {super.key});
  final String userN;

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final renter = Provider.of<ItemStoreProvider>(context, listen: false).renter;
    final items = Provider.of<ItemStoreProvider>(context, listen: false).items;
    final myItemsCount = items.where((item) => item.owner == renter.id).length;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const StyledTitle('ACCOUNT'),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black, size: width * 0.07),
            onPressed: () {
              // Optionally navigate to settings
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile picture and stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile picture
                CircleAvatar(
                  radius: width * 0.14,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: renter.profilePicUrl != null && renter.profilePicUrl.isNotEmpty
                      ? NetworkImage(renter.profilePicUrl)
                      : null,
                  child: renter.profilePicUrl == null || renter.profilePicUrl.isEmpty
                      ? Icon(Icons.person, size: width * 0.14, color: Colors.white)
                      : null,
                ),
                SizedBox(width: width * 0.10),
                // Stats
                Row(
                  children: [
                    _ProfileStat(label: "Items", value: myItemsCount.toString()),
                    SizedBox(width: width * 0.06),
                    _ProfileStat(label: "Followers", value: "0"),
                    SizedBox(width: width * 0.06),
                    _ProfileStat(label: "Following", value: "0"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Name, Location, and bio
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StyledHeading(renter.name, weight: FontWeight.bold),
                  const SizedBox(height: 2),
                  if (renter.location.isNotEmpty)
                    StyledBody(
                      renter.location,
                      color: Colors.grey[700] ?? Colors.grey, // fallback to Colors.grey if null
                      weight: FontWeight.normal,
                    ),
                  const SizedBox(height: 4),
                  StyledBody(renter.bio ?? '', color: Colors.black, weight: FontWeight.normal),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Edit Profile Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    // Navigate to the EditProfilePage
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(renter: renter),
                      ),
                    );
                    setState(() {}); // Refresh after editing
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(width: 1.0, color: Colors.black),
                  ),
                  child: const StyledHeading('Edit Profile', weight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(thickness: 1, color: Colors.grey[300]),
            // --- Tabs Section ---
            SizedBox(
              height: 48,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                tabs: const [
                  Tab(text: 'ITEMS'),
                  Tab(text: 'SAVED'),
                  Tab(text: 'REVIEWS'),
                ],
              ),
            ),
            SizedBox(
              height: 300, // Adjust height as needed
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ITEMS tab
                  Builder(
                    builder: (context) {
                      final myItems = items.where((item) => item.owner == renter.id).toList();
                      if (myItems.isEmpty) {
                        return Center(
                          child: StyledBody(
                            'No items yet',
                            color: Colors.grey,
                            weight: FontWeight.normal,
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: myItems.length,
                        separatorBuilder: (context, i) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final item = myItems[i];
                          final imageUrl = (item.imageId != null && item.imageId.isNotEmpty)
                              ? item.imageId[0]
                              : null;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Add this line
                            leading: SizedBox(
                              width: 56,
                              height: 56,
                              child: imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image, color: Colors.white),
                                    ),
                            ),
                            title: StyledHeading(item.name, weight: FontWeight.bold),
                            subtitle: StyledBody('฿${item.rentPriceDaily} per day', color: Colors.black, weight: FontWeight.normal),
                            // Optionally add trailing or onTap
                          );
                        },
                      );
                    },
                  ),
                  // SAVED tab
                  Center(
                    child: StyledBody(
                      'No saved items yet',
                      color: Colors.grey,
                      weight: FontWeight.normal,
                    ),
                  ),
                  // REVIEWS tab
                  Center(
                    child: StyledBody(
                      'No reviews yet',
                      color: Colors.grey,
                      weight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StyledHeading(value, weight: FontWeight.bold),
        const SizedBox(height: 2),
        StyledBody(label, color: Colors.black, weight: FontWeight.normal),
      ],
    );
  }
}