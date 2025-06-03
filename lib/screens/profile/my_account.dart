import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/profile/edit/to_rent_edit.dart';
import 'package:revivals/screens/to_rent/to_rent.dart';
import 'package:revivals/shared/styled_text.dart';

import 'edit_profile_page.dart';

class MyAccount extends StatefulWidget {
  final String userN;
  const MyAccount({required this.userN, super.key});

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

  String? getFirstImageUrl(dynamic imageId) {
    log('getFirstImageUrl called with imageId: $imageId');
    if (imageId == null) return null;
    if (imageId is String && (imageId.startsWith('http://') || imageId.startsWith('https://'))) {
      return imageId;
    }
    if (imageId is Map && imageId['url'] != null && (imageId['url'] as String).startsWith('http')) {
      return imageId['url'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final itemStore = Provider.of<ItemStoreProvider>(context);
    final myRenters = itemStore.renters;
    final ownerList = myRenters.where((r) => r.name == widget.userN).toList();
    final renter = ownerList.isNotEmpty ? ownerList.first : null;
    final String currentUserId = itemStore.renter.id;


    if (renter == null) {
      return const Center(
        child: StyledBody(
          'User not found',
          color: Colors.red,
          weight: FontWeight.bold,
        ),
      );
    }

    final items = itemStore.items;
    final myItemsCount = items.where((item) => item.owner == renter.id && item.status != 'deleted').length;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: StyledTitle(renter.name),
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
      body: Column(
        children: [
          const SizedBox(height: 24),
          // Profile picture and stats
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: width * 0.06),
                CircleAvatar(
                  radius: width * 0.09,
                  backgroundColor: Colors.grey[300],
                  child: renter.profilePicUrl == null || renter.profilePicUrl.isEmpty
                      ? Icon(Icons.person, size: width * 0.09, color: Colors.white)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(width * 0.09),
                          child: Image.network(
                            renter.profilePicUrl,
                            fit: BoxFit.cover,
                            width: width * 0.18,
                            height: width * 0.18,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: SizedBox(
                                  width: width * 0.06,
                                  height: width * 0.06,
                                  child: const CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.person, size: width * 0.09, color: Colors.white),
                          ),
                        ),
                ),
                SizedBox(width: width * 0.04),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Items count
                      GestureDetector(
                        onTap: null,
                        child: Column(
                          children: [
                            StyledHeading(myItemsCount.toString(), weight: FontWeight.bold),
                            const SizedBox(height: 2),
                            const StyledBody("Items", color: Colors.black, weight: FontWeight.normal),
                          ],
                        ),
                      ),
                      // Following count
                      GestureDetector(
                        onTap: null,
                        child: Column(
                          children: [
                            StyledHeading(
                              (renter.following?.length ?? 0).toString(),
                              weight: FontWeight.bold,
                            ),
                            const SizedBox(height: 2),
                            const StyledBody("Following", color: Colors.black, weight: FontWeight.normal),
                          ],
                        ),
                      ),
                      // Followers count
                      GestureDetector(
                        onTap: null,
                        child: Column(
                          children: [
                            StyledHeading(
                              (renter.followers?.length ?? 0).toString(),
                              weight: FontWeight.bold,
                            ),
                            const SizedBox(height: 2),
                            const StyledBody("Followers", color: Colors.black, weight: FontWeight.normal),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Name, Location, and bio
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                if (renter.location.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[700] ?? Colors.grey, size: width * 0.05),
                      const SizedBox(width: 6),
                      Expanded(
                        child: StyledBody(
                          renter.location,
                          color: Colors.grey[700] ?? Colors.grey,
                          weight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                Center(
                  child: StyledBody(
                    renter.bio ?? '',
                    color: Colors.black,
                    weight: FontWeight.normal,
                  ),
                ),
                // Show EDIT button if viewing own profile, otherwise show FOLLOW/UNFOLLOW and MESSAGE
                if (Provider.of<ItemStoreProvider>(context, listen: false).renter.name == widget.userN)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
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
                        child: const StyledHeading('EDIT PROFILE', weight: FontWeight.bold),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: Implement message logic
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: const BorderSide(width: 1.0, color: Colors.black),
                            ),
                            child: const StyledHeading('MESSAGE', weight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              // Implement follow/unfollow logic
                              final isFollowing = renter.followers?.contains(currentUserId) ?? false;
                              final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);

                              if (isFollowing) {
                                // UNFOLLOW: Remove renter.id from current user's following
                                itemStore.renter.following?.remove(renter.id);
                                renter.followers?.remove(currentUserId);
                              } else {
                                // FOLLOW: Add renter.id to current user's following
                                itemStore.renter.following ??= [];
                                itemStore.renter.following!.add(renter.id);
                                renter.followers ??= [];
                                renter.followers!.add(currentUserId);
                              }

                              // Optionally, persist changes to backend here

                              setState(() {});
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: const BorderSide(width: 1.0, color: Colors.black),
                            ),
                            child: StyledHeading(
                              (renter.followers?.contains(currentUserId) ?? false) ? 'UNFOLLOW' : 'FOLLOW',
                              weight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ITEMS tab
                Builder(
                  builder: (context) {
                    final myItems = items.where((item) => item.owner == renter.id && item.status != 'deleted').toList();
                    if (myItems.isEmpty) {
                      return const Center(
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
                        final dynamic imageId = (item.imageId != null && item.imageId.isNotEmpty) ? item.imageId[0] : null;

                        bool isDirectUrl(dynamic id) =>
                            id is String && (id.startsWith('http://') || id.startsWith('https://'));
                        bool isMapWithUrl(dynamic id) =>
                            id is Map && id['url'] != null && (id['url'] as String).startsWith('http');

                        Widget imageWidget;

                        if (isDirectUrl(imageId)) {
                          imageWidget = ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageId,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                            ),
                          );
                        } else if (isMapWithUrl(imageId)) {
                          final url = imageId['url'];
                          imageWidget = ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              url,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                            ),
                          );
                        } else if (imageId is String && imageId.isNotEmpty) {
                          imageWidget = FutureBuilder<String?>(
                            future: getDownloadUrlFromPath(imageId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              }
                              final url = snapshot.data;
                              if (url != null) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    url,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, color: Colors.white),
                              );
                            },
                          );
                        } else {
                          imageWidget = Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.white),
                          );
                        }

                        return GestureDetector(
                          onTap: () async {
                            // Check if current profile is the owner of the item
                            if (item.owner == currentUserId) {
                              log("Item owner is the current profile, navigating to edit page");
                              log(item.owner.toString());
                              log(renter.id.toString());
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ToRentEdit(item),
                                ),
                              );
                              if (result == true) {
                                setState(() {});
                              }
                            } else {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ToRent(item), // Make sure ToRent accepts the item
                                ),
                              );
                            }
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: SizedBox(
                              width: 56,
                              height: 56,
                              child: imageWidget,
                            ),
                            title: StyledHeading(item.name, weight: FontWeight.bold),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StyledBody('฿${item.rentPriceDaily} per day', color: Colors.black, weight: FontWeight.normal),
                                StyledBody('Status: ${item.status}', color: Colors.grey[700] ?? Colors.grey, weight: FontWeight.normal),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                // SAVED tab
                const Center(
                  child: StyledBody(
                    'No saved items yet',
                    color: Colors.grey,
                    weight: FontWeight.normal,
                  ),
                ),
                // REVIEWS tab
                Builder(
                  builder: (context) {
                    final itemStore = Provider.of<ItemStoreProvider>(context);

                    final reviews = itemStore.reviews.where((review) {
                      ItemRenter? itemRenter;
                      try {
                        itemRenter = itemStore.itemRenters.firstWhere(
                          (ir) => ir.id == review.itemRenterId,
                        );
                      } catch (e) {
                        itemRenter = null;
                      }
                      return itemRenter != null && itemRenter.ownerId == renter.id;
                    }).toList();

                    if (reviews.isEmpty) {
                      return const Center(
                        child: StyledBody(
                          'No reviews yet',
                          color: Colors.grey,
                          weight: FontWeight.normal,
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: reviews.length,
                      separatorBuilder: (context, i) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final review = reviews[i];
                        return ListTile(
                          leading: const Icon(Icons.star, color: Colors.amber, size: 28),
                          title: StyledHeading(
                            '${review.title}  (${review.rating}/5)',
                            weight: FontWeight.bold,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (review.text.isNotEmpty)
                                StyledBody(review.text, color: Colors.black, weight: FontWeight.normal),
                              StyledBody(
                                review.date.toString().split(' ').first,
                                color: Colors.grey,
                                weight: FontWeight.normal,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> uploadAndGetDownloadUrl(File file, String storagePath) async {
    final ref = FirebaseStorage.instance.ref().child(storagePath);
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    return url;
  }

  Future<String?> getDownloadUrlFromPath(String storagePath) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}