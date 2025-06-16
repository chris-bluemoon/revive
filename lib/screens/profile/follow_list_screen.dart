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
                builder: (_) => Profile(userN: user.name),
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
          title: const Text('Followers & Following'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: buildUserList(followersIds),
            ),
            ListView(
              children: buildUserList(followingIds),
            ),
          ],
        ),
      ),
    );
  }
}