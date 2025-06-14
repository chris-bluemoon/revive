import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/providers/create_item_provider.dart';
import 'package:revivals/screens/create/create_item.dart';
import 'package:revivals/screens/help_centre/faqs.dart';
import 'package:revivals/screens/profile/accounts/accounts.dart';
import 'package:revivals/screens/profile/my_account.dart';
import 'package:revivals/screens/profile/my_admin.dart';
import 'package:revivals/screens/profile/my_sales.dart';
import 'package:revivals/screens/profile/my_transactions.dart';
import 'package:revivals/screens/profile/verify/verify_id.dart';
import 'package:revivals/screens/sign_up/google_sign_in.dart';
import 'package:revivals/shared/line.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:revivals/shared/whatsapp.dart';

class ProfileLanding extends StatefulWidget {
  const ProfileLanding(this.user, this.signOutFromGoogle, {super.key});

  final User? user;
  final Function() signOutFromGoogle;

  @override
  State<ProfileLanding> createState() => _ProfileLandingState();
}

class _ProfileLandingState extends State<ProfileLanding> {
  Future<void> shareApp() async {
    const String appLink = 'https://my google play link';
    const String message = 'Check out my new app $appLink';
  }

  ValueNotifier userCredential = ValueNotifier('');

  cancelLogOut(context) async {
    Navigator.pop(context);
  }

  goBack(context) async {
    bool result = await widget.signOutFromGoogle();

    if (result) {
      userCredential.value = '';

      Provider.of<ItemStoreProvider>(context, listen: false).setLoggedIn(false);

      // setState((context) {});
      // Navigator.pushReplacement<void, void>(
      //   context,
      //   MaterialPageRoute<void>(
      //     builder: (BuildContext context) => const HomePage(),
      //   ),
      //   Navigator.pop(context);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // List<Item> allItems = Provider.of<ItemStoreProvider>(context, listen: false).items;
    Renter renter =
        Provider.of<ItemStoreProvider>(context, listen: false).renter;

    double width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 0),
        child: Consumer<ItemStoreProvider>(builder: (context, value, child) {
          if (Provider.of<ItemStoreProvider>(context, listen: false).loggedIn ==
              true) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledHeading(
                    'PERSONAL (${Provider.of<ItemStoreProvider>(context, listen: false).renter.name})',
                    weight: FontWeight.normal,
                    color: Colors.grey),
                // Text('PERSONAL (${user!.displayName!})', style: const TextStyle(fontSize: 16)),
                SizedBox(height: width * 0.04),
                GestureDetector(
                  onTap: () {
                    String userN =
                        Provider.of<ItemStoreProvider>(context, listen: false)
                            .renter
                            .name;
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => (MyAccount(userN: userN))));
                  },
                  child: Row(
                    children: [
                      SizedBox(width: width * 0.01),
                      Icon(Icons.account_circle_outlined, size: width * 0.05),
                      SizedBox(width: width * 0.01),
                      const StyledBody('USER PROFILE',
                          weight: FontWeight.normal),
                    ],
                  ),
                ),
                Divider(
                  height: width * 0.05,
                  indent: 50,
                  color: Colors.grey[200],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => (const MyTransactions())));
                  },
                  child: Row(
                    children: [
                      SizedBox(width: width * 0.01),
                      Icon(Icons.fact_check_outlined, size: width * 0.05),
                      SizedBox(width: width * 0.01),
                      const StyledBody('MY ORDERS', weight: FontWeight.normal),
                    ],
                  ),
                ),
                Divider(
                  height: width * 0.05,
                  indent: 50,
                  color: Colors.grey[200],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => (const MySales())));
                  },
                  child: Row(
                    children: [
                      SizedBox(width: width * 0.01),
                      Icon(Icons.sell_outlined, size: width * 0.05),
                      SizedBox(width: width * 0.01),
                      const StyledBody('MY SALES', weight: FontWeight.normal),
                    ],
                  ),
                ),
                Divider(
                  height: width * 0.05,
                  indent: 50,
                  color: Colors.grey[200],
                ),
                // GestureDetector(
                //   onTap: () {
                //     Navigator.of(context).push(MaterialPageRoute(
                //         builder: (context) => (const MyFittings(false))));
                //   },
                //   child: Row(
                //     children: [
                //       SizedBox(width: width * 0.01),
                //       Icon(Icons.straighten_outlined, size: width * 0.05),
                //       SizedBox(width: width * 0.01),
                //       const StyledBody('FITTINGS', weight: FontWeight.normal),
                //     ],
                //   ),
                // ),
                // Divider(
                //   height: width * 0.05,
                //   indent: 50,
                //   color: Colors.grey[200],
                // ),
                GestureDetector(
                  onTap: () {
                    final cip = Provider.of<CreateItemProvider>(context, listen: false);
                    cip.reset();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const CreateItem(item: null)),
                    );
                  },
                  child: Row(
                    children: [
                      SizedBox(width: width * 0.01),
                      Icon(Icons.create_new_folder_outlined,
                          size: width * 0.05),
                      SizedBox(width: width * 0.01),
                      const StyledBody('CREATE ITEM',
                          weight: FontWeight.normal),
                    ],
                  ),
                ),
                Divider(
                  height: width * 0.05,
                  indent: 50,
                  color: Colors.grey[200],
                ),
                GestureDetector(
                  onTap: () {
                    shareApp();
                  },
                  child: Row(
                    children: [
                      SizedBox(width: width * 0.01),
                      Icon(Icons.group_add_outlined, size: width * 0.05),
                      SizedBox(width: width * 0.01),
                      const StyledBody('REFER A FRIEND',
                          weight: FontWeight.normal),
                    ],
                  ),
                ),
                Divider(
                  height: width * 0.05,
                  indent: 50,
                  color: Colors.grey[200],
                ),

                // Comment out the SETTINGS section
                // GestureDetector(
                //   onTap: () {
                //     Navigator.of(context).push(MaterialPageRoute(
                //         builder: (context) => (const Settings())));
                //   },
                //   child: Row(
                //     children: [
                //       SizedBox(width: width * 0.01),
                //       Icon(Icons.settings_outlined, size: width * 0.05),
                //       SizedBox(width: width * 0.01),
                //       const StyledBody('SETTINGS', weight: FontWeight.normal),
                //     ],
                //   ),
                // ),
                // Divider(
                //   height: width * 0.05,
                //   indent: 50,
                //   color: Colors.grey[200],
                // ),
                if (Provider.of<ItemStoreProvider>(context, listen: false)
                        .renter
                        .verified ==
                    'not started')
                  Divider(
                    height: width * 0.05,
                    indent: 50,
                    color: Colors.grey[200],
                  ),
                if (Provider.of<ItemStoreProvider>(context, listen: false)
                        .renter
                        .verified ==
                    'not started')
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => (const VerifyId())));
                    },
                    child: Row(
                      children: [
                        SizedBox(width: width * 0.01),
                        Icon(Icons.verified_user_outlined, size: width * 0.05),
                        SizedBox(width: width * 0.01),
                        const StyledBody('VERIFY ID',
                            weight: FontWeight.normal),
                      ],
                    ),
                  ),
                Divider(
                  height: width * 0.05,
                  indent: 50,
                  color: Colors.grey[200],
                ),
                // GestureDetector(
                //   onTap: () {
                //     Navigator.of(context).push(MaterialPageRoute(
                //         builder: (context) => (ItemResults(
                //             'myItems',
                //             Provider.of<ItemStoreProvider>(context,
                //                     listen: false)
                //                 .renter
                //                 .id))));
                //   },
                //   child: Row(
                //     children: [
                //       SizedBox(width: width * 0.01),
                //       Icon(Icons.image_outlined, size: width * 0.05),
                //       SizedBox(width: width * 0.01),
                //       const StyledBody('MY ITEMS', weight: FontWeight.normal),
                //     ],
                //   ),
                // ),
                // Divider(
                //   height: width * 0.05,
                //   indent: 50,
                //   color: Colors.grey[200],
                // ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => (const Accounts())));
                  },
                  child: Row(
                    children: [
                      SizedBox(width: width * 0.01),
                      Icon(Icons.image_outlined, size: width * 0.05),
                      SizedBox(width: width * 0.01),
                      const StyledBody('ACCOUNTS', weight: FontWeight.normal),
                    ],
                  ),
                ),
                SizedBox(height: width * 0.06),
                const StyledHeading('SUPPORT',
                    weight: FontWeight.normal, color: Colors.grey),
                SizedBox(height: width * 0.04),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => (const FAQs())));
                  },
                  child: Row(
                    children: [
                      SizedBox(width: width * 0.01),
                      Icon(Icons.help_outline, size: width * 0.05),
                      SizedBox(width: width * 0.01),
                      const StyledBody('FAQ', weight: FontWeight.normal),
                    ],
                  ),
                ),
                Divider(
                  height: width * 0.05,
                  indent: 50,
                  color: Colors.grey[200],
                ),
                GestureDetector(
                  onTap: () async {
                    // chatWithUsWhatsApp(context);
                    await chatWithUsLine(context);
                  },
                  child: Row(
                    children: [
                      SizedBox(width: width * 0.01),
                      Icon(Icons.chat_bubble_outline, size: width * 0.05),
                      SizedBox(width: width * 0.01),
                      const StyledBody('CHAT WITH US',
                          weight: FontWeight.normal),
                    ],
                  ),
                ),
                Divider(
                  height: width * 0.05,
                  indent: 50,
                  color: Colors.grey[200],
                ),
                GestureDetector(
                  onTap: () => showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0))),
                      actions: [
                        // ElevatedButton(
                        // onPressed: () {cancelLogOut(context);},
                        // child: const Text('CANCEL', style: TextStyle(color: Colors.black)),),
                        ElevatedButton(
                          style: ButtonStyle(
                              foregroundColor:
                                  WidgetStateProperty.all(Colors.white),
                              backgroundColor:
                                  const WidgetStatePropertyAll<Color>(
                                      Colors.black),
                              shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(0)),
                                      side: BorderSide(color: Colors.black)))),
                          onPressed: () async {
                            await goBack(context);
                            if (mounted) Navigator.of(context).pop();
                          },
                          child: const StyledHeading(
                            'OK',
                            weight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      backgroundColor: Colors.white,
                      title: const Center(
                          child: StyledHeading("Successfully logged out",
                              weight: FontWeight.normal)),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: width * 0.01),
                      Icon(Icons.exit_to_app, size: width * 0.05),
                      SizedBox(width: width * 0.01),
                      const StyledBody('SIGN OUT', weight: FontWeight.normal),
                    ],
                  ),
                ),
                SizedBox(height: width * 0.04),
                Divider(
                  height: width * 0.1,
                  indent: 50,
                  endIndent: 50,
                  color: Colors.black,
                ),
                if (Provider.of<ItemStoreProvider>(context, listen: false)
                        .renter
                        .type ==
                    "ADMIN")
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => (const MyAdmin())));
                    },
                    child: Row(
                      children: [
                        SizedBox(width: width * 0.01),
                        Icon(Icons.description_outlined, size: width * 0.05),
                        SizedBox(width: width * 0.01),
                        const StyledBody('ADMIN', weight: FontWeight.normal),
                      ],
                    ),
                  ),
              ],
            );
          } else {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => (const GoogleSignInScreen())));
              },
              child: Row(
                children: [
                  SizedBox(width: width * 0.01),
                  Icon(Icons.login_outlined, size: width * 0.05),
                  SizedBox(width: width * 0.01),
                  const StyledBody('SIGN IN / CREATE ACCOUNT',
                      weight: FontWeight.normal),
                ],
              ),
            );
          }
        }),
      ),
    );
  }
}

// Send a LINE
Future<void> chatWithUsLine(BuildContext context) async {
  try {
    await openLineApp(context
        // phone: '+6591682725',
        // text: 'Hello Unearthed Support...',
        );
  } on Exception catch (e) {
    if (context.mounted) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: const Text("Attention"),
                content: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(e.toString()),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Close'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ));
    }
  }
}

// Send a Whatsapp
void chatWithUsWhatsApp(BuildContext context) async {
  try {
    await openWhatsApp(
      phone: '+65 91682725',
      text: 'Hello Unearthed Support...',
    );
  } on Exception catch (e) {
    if (context.mounted) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: const Text("Attention"),
                content: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(e.toString()),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Close'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ));
    }
  }
}
