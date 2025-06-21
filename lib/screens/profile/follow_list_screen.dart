import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/profile/profile.dart';
import 'package:revivals/shared/styled_text.dart';

class FollowListScreen extends StatelessWidget {
  final List<String> followersIds;
  final List<String> followingIds;

  const FollowListScreen({
    required this.followersIds,
    required this.followingIds,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final renters = Provider.of<ItemStoreProvider>(context, listen: false).renters;

    List<Widget> buildUserList(List<String> ids) {
      final users = renters.where((r) => ids.contains(r.id)).toList();
      if (users.isEmpty) {
        return <Widget>[
          const Center(
            child: StyledBody('No users found', color: Colors.grey, weight: FontWeight.normal),
          ),
        ];
      }
      return users.map<Widget>((user) {
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Increased padding
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage: (user.profilePicUrl.isNotEmpty)
                ? NetworkImage(user.profilePicUrl)
                : null,
            child: (user.profilePicUrl.isEmpty)
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: StyledHeading(user.name, weight: FontWeight.bold),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Profile(userN: user.name, canGoBack: true,),
              ),
            );
          },
        );
      }).toList();
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            labelColor: Colors.black, // Selected tab text color
            unselectedLabelColor: Colors.grey, // Unselected tab text color
            indicatorColor: Colors.black, // Highlight underscore bar color
            tabs: [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Builder(
              builder: (context) {
                final followingList = renters.where((r) => followingIds.contains(r.id)).toList();
                if (followingList.isEmpty) {
                  return Center(
                    child: Text(
                      'Not Following Anyone',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: followingList.length,
                  itemBuilder: (context, index) {
                    final user = followingList[index];
                    final isFollowing = Provider.of<ItemStoreProvider>(context, listen: false).renter.following.contains(user.id);
                    log('Following user: ${user.name}, isFollowing: $isFollowing');

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Increased padding
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        backgroundImage: (user.profilePicUrl.isNotEmpty)
                            ? NetworkImage(user.profilePicUrl)
                            : null,
                        child: (user.profilePicUrl.isEmpty)
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      title: StyledHeading(user.name, weight: FontWeight.bold),
                      trailing: !isFollowing
                          ? ElevatedButton(
                              onPressed: () {
                                // Add follow logic here
                              },
                              child: Text('FOLLOW'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                textStyle: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          : null,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Profile(userN: user.name, canGoBack: true,),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            Builder(
              builder: (context) {
                final followersList = renters.where((r) => followersIds.contains(r.id)).toList();
                if (followersList.isEmpty) {
                  return Center(
                    child: Text(
                      'No Current Followers',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: followersList.length,
                  itemBuilder: (context, index) {
                    final user = followersList[index];
                    final isFollowing = Provider.of<ItemStoreProvider>(context, listen: false).renter.following.contains(user.id);
                    log('Following user: ${user.name}, isFollowing: $isFollowing');
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Increased padding
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        backgroundImage: (user.profilePicUrl.isNotEmpty)
                            ? NetworkImage(user.profilePicUrl)
                            : null,
                        child: (user.profilePicUrl.isEmpty)
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      title: StyledHeading(user.name, weight: FontWeight.bold),
                      trailing: !isFollowing
                          ? ElevatedButton(
                              onPressed: () {
                                // Add follow logic here
                              },
                              child: Text('FOLLOW'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                textStyle: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          : null,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Profile(userN: user.name, canGoBack: true,),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}