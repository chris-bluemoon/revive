import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/screens/profile/edit/to_rent_edit.dart';
import 'package:revivals/screens/profile/follow_list_screen.dart';
import 'package:revivals/services/class_store.dart';
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
  late int followingCount;
  late int followersCount;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Initialize followersCount in build or here after getting renter
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
    final renters = Provider.of<ItemStoreProvider>(context, listen: false).renters;
    final ownerList = renters.where((r) => r.name == widget.userN).toList();
    final renter = ownerList.isNotEmpty ? ownerList.first : null;
    final currentRenter = Provider.of<ItemStoreProvider>(context, listen: false).renter;

    // Initialize followingCount if not already set
    followingCount = currentRenter.following.length;
    followersCount = renter?.followers.length ?? 0; // Initialize here

    if (renter == null) {
      return const Center(
        child: StyledBody(
          'User not found',
          color: Colors.red,
          weight: FontWeight.bold,
        ),
      );
    }

    final items = Provider.of<ItemStoreProvider>(context, listen: false).items;
    final myItemsCount = items.where((item) => item.owner == renter.id).length;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: StyledTitle(renter.name), // <-- Change from 'ACCOUNT' to username
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
            padding: EdgeInsets.symmetric(horizontal: width * 0.04), // Reduce padding for more space
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: width * 0.06), // Add this line to move avatar right
                // Smaller profile picture
                CircleAvatar(
                  radius: width * 0.09, // Reduced size
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
                SizedBox(width: width * 0.04), // Slightly reduced spacing
                // Use Expanded and a Row with MainAxisAlignment.spaceEvenly for equal spacing
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ProfileStat(label: "Items", value: myItemsCount.toString()),
                      _ProfileStat(
                        label: "Followers",
                        value: followersCount.toString(),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => FollowListScreen(
                              followersIds: renter.followers,
                              followingIds: renter.following,
                            ),
                          ));
                        },
                      ),
                      _ProfileStat(
                        label: "Following",
                        value: followingCount.toString(),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => FollowListScreen(
                              followersIds: renter.followers,
                              followingIds: renter.following,
                            ),
                          ));
                        },
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
                // Show EDIT button if viewing own profile
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
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Edit Profile Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: SizedBox(
              width: double.infinity,
              child: Provider.of<ItemStoreProvider>(context, listen: false).renter.name == widget.userN
                  ? const SizedBox.shrink() // Do not show any button if viewing own profile
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final currentRenter = Provider.of<ItemStoreProvider>(context, listen: false).renter;

                              // Use local renters list to get the targetRenter by name
                              final rentersList = Provider.of<ItemStoreProvider>(context, listen: false).renters;
                              final targetList = rentersList.where((r) => r.name == widget.userN).toList();
                              final targetRenter = targetList.isNotEmpty ? targetList.first : null;

                              if (targetRenter == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('NULL User not found in local renters list.')),
                                );
                                return;
                              }

                              log('Target Renter ID: ${targetRenter.id}');

                              if (targetRenter.id != currentRenter.id) {
                                // Proceed with update
                                await FirebaseFirestore.instance
                                    .collection('renter')
                                    .doc(targetRenter.id)
                                    .update({
                                  'followers': FieldValue.arrayUnion([currentRenter.id])
                                });

                                await FirebaseFirestore.instance
                                    .collection('renter')
                                    .doc(currentRenter.id)
                                    .update({
                                  'following': FieldValue.arrayUnion([targetRenter.id])
                                });

                                // Update the local followers count by calling setState
                                setState(() {
                                  // Increment followersCount, not followingCount
                                  // Make sure you have a local variable for followersCount, initialized as:
                                  // followersCount = renter.followers.length;
                                  followersCount += 1;
                                });

                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: Text('You are now following ${targetRenter.name}'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User not found in database.')),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: const BorderSide(width: 1.0, color: Colors.black),
                            ),
                            child: const StyledHeading('FOLLOW', weight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                      ],
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

                        // Helper to check if this is a direct URL
                        bool isDirectUrl(dynamic id) =>
                            id is String && (id.startsWith('http://') || id.startsWith('https://'));
                        bool isMapWithUrl(dynamic id) =>
                            id is Map && id['url'] != null && (id['url'] as String).startsWith('http');

                        Widget imageWidget;

                        if (isDirectUrl(imageId)) {
                          print('Direct URL: $imageId');
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
                          print('Map URL: $url');
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
                          print('Storage path: $imageId');
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
                              print('FutureBuilder resolved URL: $url');
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ToRentEdit(item), // Pass the item to the edit page
                              ),
                            );
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
                const Center(
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
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _ProfileStat({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          StyledHeading(value, weight: FontWeight.bold),
          const SizedBox(height: 2),
          StyledBody(label, color: Colors.black, weight: FontWeight.normal),
        ],
      ),
    );
  }
}

Future<String> uploadAndGetDownloadUrl(File file, String storagePath) async {
  final ref = FirebaseStorage.instance.ref().child(storagePath);
  await ref.putFile(file);
  final url = await ref.getDownloadURL();
  return url; // Save this URL to Firestore, not the storage path!
}

Future<String?> getDownloadUrlFromPath(String storagePath) async {
  try {
    final ref = FirebaseStorage.instance.ref().child(storagePath);
    return await ref.getDownloadURL();
  } catch (e) {
    return null;
  }
}