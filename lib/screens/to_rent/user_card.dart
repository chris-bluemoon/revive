import 'package:flutter/material.dart';
import 'package:revivals/services/class_store.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:provider/provider.dart';

class UserCard extends StatelessWidget {
  const UserCard(this.ownerName, this.location, {super.key});

  final String ownerName;
  final String location;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    String initialLetter = ownerName.substring(0, 1);

    // Get renter profilePicUrl from provider
    final renter = Provider.of<ItemStoreProvider>(context, listen: false).renter;
    final profilePicUrl = renter.profilePicUrl;

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.greenAccent[400],
          radius: width * 0.06,
          backgroundImage: (profilePicUrl != null && profilePicUrl.isNotEmpty)
              ? NetworkImage(profilePicUrl)
              : null,
          child: (profilePicUrl == null || profilePicUrl.isEmpty)
              ? Text(
                  initialLetter,
                  style: TextStyle(fontSize: width * 0.06, color: Colors.white),
                )
              : null,
        ),
        SizedBox(width: width * 0.02),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StyledBody(ownerName),
            StyledBody(location, weight: FontWeight.normal)
          ],
        ),
        SizedBox(width: width * 0.03),
      ],
    );
  }
}
