import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_image.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/services/class_store.dart';
import 'package:revivals/shared/get_country_price.dart';
import 'package:revivals/shared/loading.dart';
import 'package:revivals/shared/styled_text.dart';

// ignore: must_be_immutable
class ItemCard extends StatefulWidget {
  const ItemCard(this.item, this.isDesigner, this.isFittingScreen, {super.key});

  final Item item;
  final bool isDesigner;
  final bool isFittingScreen;

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  late String imageName;

  late String itemName;

  late String brandName;

  late String itemType;

  bool isFav = false;

  String capitalize(string) {
    return string.codeUnitAt(0).toUpperCase() +
        string.substring(1).toLowerCase();
  }

  // String setItemImage() {
  //   itemType = toBeginningOfSentenceCase(widget.item.type.replaceAll(RegExp(' +'), '_'));
  //   // itemType = widget.item.type.replaceAll(RegExp(' +'), '_');
  //   itemName = widget.item.name.replaceAll(RegExp(' +'), '_');
  //   brandName = widget.item.brand.replaceAll(RegExp(' +'), '_');
  //   try {
  //     imageName = '${brandName}_${itemName}_${itemType}_1.jpg';
  //   } catch(e) {
  //     imageName = 'SUNDRESS_Emilia_Dress_1.jpg';
  //   }
  //   return imageName;
  // }

  bool isAFav(Item d, List favs) {
    if (favs.contains(d)) {
      return true;
    } else {
      return false;
    }
  }

  void _toggleFav() {
    setState(() {
      if (isFav == true) {
        isFav = false;
      } else {
        isFav = true;
      }
    });
  }

  String convertedRentPrice = '-1';
  String convertedBuyPrice = '-1';
  String convertedRRPPrice = '-1';
  String symbol = '?';

  Image? myImage;

  @override
  void initState() {
    // List currListOfFavs =
    //     Provider.of<ItemStoreProvider>(context, listen: false).favourites;
    // isFav = isAFav(widget.item, currListOfFavs);
    // Future.delayed(const Duration(seconds: 5));

    //ynt added first [if condition] to handle empty imageId
    //but still don't understand following [loop] and [second if condition]

    if (widget.item.imageId.isNotEmpty) {
      for (ItemImage i
          in Provider.of<ItemStoreProvider>(context, listen: false).images) {
        if (i.id == widget.item.imageId[0]) {
          thisImage = i.imageId;
        }
      }
    }
    super.initState();
  }

  int getPricePerDay(noOfDays) {
    String country = 'BANGKOK';

    int oneDayPrice = widget.item.rentPriceDaily;

    if (country == 'BANGKOK') {
      oneDayPrice = widget.item.rentPriceDaily;
    } else {
      oneDayPrice = int.parse(convertFromTHB(widget.item.rentPriceDaily, country));
    }

    if (noOfDays == 3) {
      int threeDayPrice = (oneDayPrice * 0.8).toInt() - 1;
      if (country == 'BANGKOK') {
        return (threeDayPrice ~/ 100) * 100 + 100;
      } else {
        return (threeDayPrice ~/ 5) * 5 + 5;
      }
    }
    if (noOfDays == 5) {
      int fiveDayPrice = (oneDayPrice * 0.6).toInt() - 1;
      if (country == 'BANGKOK') {
        return (fiveDayPrice ~/ 100) * 100 + 100;
      } else {
        return (fiveDayPrice ~/ 5) * 5 + 5;
      }
    }
    return oneDayPrice;
  }

  void setPrice() {
      String country = 'BANGKOK';
    if (country == 'BANGKOK') {
      convertedRentPrice = getPricePerDay(5).toString();
      convertedBuyPrice = convertFromTHB(widget.item.buyPrice, country);
      convertedRRPPrice = convertFromTHB(widget.item.rrp, country);
      symbol = getCurrencySymbol(country);
    } else {
      convertedRentPrice = getPricePerDay(5).toString();
      convertedBuyPrice = widget.item.buyPrice.toString();
      convertedRRPPrice = widget.item.rrp.toString();
      symbol = globals.thb;
    }
  }

  String getSize(sizeArray) {
    String formattedSize = 'N/A';
    if (sizeArray.length == 1) {
      formattedSize = sizeArray.first;
    }
    if (sizeArray.length == 2) {
      String firstSize;
      String secondSize;
      firstSize = sizeArray.elementAt(0);
      secondSize = sizeArray.elementAt(1);
      formattedSize = '$firstSize-$secondSize';
    }
    return formattedSize;
  }

  String thisImage = 'assets/img/items2/No_Image_Available.jpg';
// Widget createImage(String imageName) {
//   return Image.asset(imageName,
//       errorBuilder: (context, object, stacktrace) =>
//           Image.asset('assets/img/items2/No_Image_Available.jpg'));
// }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    List currListOfFavs =
        Provider.of<ItemStoreProvider>(context, listen: false).favourites;
    isFav = isAFav(widget.item, currListOfFavs);
    setPrice();
    return Card(
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(width * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isDesigner)
              Center(child: StyledHeading(widget.item.brand)),
            SizedBox(height: width * 0.02),
            // Image.asset('assets/img/items2/${setItemImage()}', width: 200, height: 600),
            Expanded(
              child: Center(
                  // child: (Provider.of<ItemStoreProvider>(context, listen: false).images == null) ? createImage('assets/img/items2/${setItemImage()}')
                  // : Provider.of<ItemStoreProvider>(context, listen: false).images[0]
                  // child: (cardImage.imageId == null) ? createImage('assets/img/items2/${setItemImage()}')
                  // : cardImage.imageId
                  child: CachedNetworkImage(
                imageUrl: thisImage,
                placeholder: (context, url) => const Loading(),
                errorWidget: (context, url, error) =>
                    Image.asset('assets/img/items2/No_Image_Available.jpg'),
              )),
            ),
            // Image.asset('assets/img/items2/${setItemImage()}', fit: BoxFit.fill),
            Row(
              // mainAxisAlignment: MainAxisAlignment.left,
              children: [
                SizedBox(
                    width: width * 0.3,
                    height: width * 0.15,
                    child: Container(
                        alignment: Alignment.centerLeft,
                        child: StyledHeading(widget.item.name))),
                const Expanded(child: SizedBox()),
                if (widget.item.status != 'submitted ')
                  if (!widget.isFittingScreen)
                    (isFav)
                        ? IconButton(
                            // (widget.item.status != 'submission') (!widget.isFittingScreen) (isFav) ? IconButton(
                            icon: Icon(Icons.favorite, size: width * 0.05),
                            color: Colors.red,
                            onPressed: () {
                              _toggleFav();
                              Renter toSave = Provider.of<ItemStoreProvider>(
                                      context,
                                      listen: false)
                                  .renter;
                              toSave.favourites.remove(widget.item.id);
                              Provider.of<ItemStoreProvider>(context,
                                      listen: false)
                                  .saveRenter(toSave);
                              Provider.of<ItemStoreProvider>(context,
                                      listen: false)
                                  .removeFavourite(widget.item);
                            })
                        : IconButton(
                            icon: Icon(Icons.favorite_border_outlined,
                                size: width * 0.05),
                            onPressed: () {
                              _toggleFav();
                              Renter toSave = Provider.of<ItemStoreProvider>(
                                      context,
                                      listen: false)
                                  .renter;
                              toSave.favourites.add(widget.item.id);
                              Provider.of<ItemStoreProvider>(context,
                                      listen: false)
                                  .saveRenter(toSave);
                              Provider.of<ItemStoreProvider>(context,
                                      listen: false)
                                  .addFavourite(widget.item);
                            }),
              ],
            ),
            // StyledBody('Size UK ${widget.item.size.toString()}', weight: FontWeight.normal),
            StyledBody('Size UK ${getSize(widget.item.size)}',
                weight: FontWeight.normal),
            // StyledText('Size: ${item.size.toString()}'),
            // int convertedRentPrice = convertFromTHB(${widget.item.rentPriceDaily}, 'SGD');
            if (widget.item.bookingType == 'both' ||
                widget.item.bookingType == 'rental')
              StyledBody('Rent from $convertedRentPrice$symbol per day',
                  weight: FontWeight.normal),
            if (widget.item.bookingType == 'both' ||
                widget.item.bookingType == 'buy')
              StyledBody('Buy for $convertedBuyPrice$symbol',
                  weight: FontWeight.normal),
            StyledBodyStrikeout('RRP $convertedRRPPrice$symbol',
                weight: FontWeight.normal),
          ],
        ),
      ),
    );
  }
}
