import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:revivals/models/fitting_renter.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_image.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/models/ledger.dart';
import 'package:revivals/models/message.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/services/firestore_service.dart';
import 'package:revivals/shared/secure_repo.dart';

class ItemStore extends ChangeNotifier {

  final double width = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;

  final List<Ledger> _ledgers = [];
  final List<Message> _messages = [];
  final List<ItemImage> _images = [];
  final List<Item> _items = [];
  final List<Item> _favourites = [];
  final List<String> _fittings = [];
  // final List<Item> _settings = [];
  final List<Renter> _renters = [];
  final List<ItemRenter> _itemRenters = [];
  final List<FittingRenter> _fittingRenters = [];
  Map<String, bool> _sizesFilter = {
    '4': false,
    '6': false,
    '8': false,
    '10': false,
  };
  Map<Color, bool> _coloursFilter = {
    Colors.black: false,
    Colors.white: false,
    Colors.blue: false,
    Colors.green: false,
    Colors.pink: false,
    Colors.grey: false,
    Colors.brown: false,
    Colors.yellow: false,
    Colors.purple: false,
    Colors.red: false,
    Colors.lime: false,
    Colors.cyan: false,
    Colors.teal: false
  };
    Map<String, bool> _lengthsFilter = {
    'mini': false,
    'midi': false,
    'long': false
  };
  Map<String, bool> _printsFilter = {'enthic': false, 'boho': false, 'preppy': false, 'floral' : false, 'abstract': false, 'stripes': false, 'dots': false, 'textured': false, 'none': false};
  Map<String, bool> _sleevesFilter = {'sleeveless': false, 'short sleeve': false, '3/4 sleeve': false, 'long sleeve': false};
  RangeValues _rangeValuesFilter = const RangeValues(0, 10000);

  // final List<bool> _sizesFilter = [true, true, false, false];
  // final List<bool> _sizesFilter = [true, true, false, false];
  // TODO: Revert back to late initialization if get errors with this
  // late final _user;
  Renter _user = Renter(id: '0000', email: 'dummy', name: 'no_user', size: 0, address: '', countryCode: '', phoneNum: '', favourites: [], fittings: [], settings: ['BANGKOK','CM','CM','KG'], verified: '', imagePath: '', creationDate: '');
  bool _loggedIn = false;
  // String _region = 'BANGKOK';

  get ledgers => _ledgers;
  get messages => _messages;
  get images => _images;
  get items => _items;
  get favourites => _favourites;
  get fittings => _fittings;
  get renters => _renters;
  get itemRenters => _itemRenters;
  get fittingRenters => _fittingRenters;
  get renter => _user;
  get loggedIn => _loggedIn;
  get sizesFilter => _sizesFilter;
  get coloursFilter => _coloursFilter;
  get lengthsFilter => _lengthsFilter;
  get printsFilter => _printsFilter;
  get sleevesFilter => _sleevesFilter;
  get rangeValuesFilter => _rangeValuesFilter;
  
  void sizesFilterSetter(sizeF) {
    _sizesFilter = sizeF;
  }
  void coloursFilterSetter(colourF) {
    _coloursFilter = colourF;
  }
  void lengthsFilterSetter(lengthsF) {
    _lengthsFilter = lengthsF;
  }
  void printsFilterSetter(printsF) {
    _printsFilter = printsF;
  }
  void sleevesFilterSetter(sleevesF) {
    _sleevesFilter = sleevesF;
  }
  void rangeValuesFilterSetter(rangeValuesF) {
    _rangeValuesFilter = rangeValuesF;
  }

  void resetFilters() {
    sizesFilter.updateAll((name, value) => value = false);
    rangeValuesFilterSetter(const RangeValues(0,10000));
    coloursFilter.updateAll((name, value) => value = false);
    lengthsFilter.updateAll((name, value) => value = false);
    printsFilter.updateAll((name, value) => value = false);
    sleevesFilter.updateAll((name, value) => value = false);
  }
 

  void addSettings(settings) async {
    _user.settings.add(settings);
    saveRenter(_user);
  }

  // assign the user
  void assignUser(Renter user) async {
    // await FirestoreService.addItem(item);
    _user = user;
    notifyListeners();
  }

  void addLedger(Ledger ledger) async {
    _ledgers.add(ledger);
    await FirestoreService.addLedger(ledger);
    // notifyListeners();
  }

  void addMessage(Message message) async {
    _messages.add(message);
    await FirestoreService.addMessage(message);
    notifyListeners();
  }

  void addItem(Item item) async {
    _items.add(item);
    await FirestoreService.addItem(item);
    notifyListeners();
  }

  void addRenter(Renter renter) async {
    await FirestoreService.addRenter(renter);
    _renters.add(renter);
    notifyListeners();
  }

  void saveRenter(Renter renter) async {
    await FirestoreService.updateRenter(renter);
    // _renters[0].aditem = renter.aditem;
      // _user.aditem = renter.aditem;
    notifyListeners();
    return;
  }

  void addRenterAppOnly(Renter renter) {
    _renters.add(renter);
  }
  // add itemRenter
  void addItemRenter(ItemRenter itemRenter) async {
    _itemRenters.add(itemRenter);
    await FirestoreService.addItemRenter(itemRenter);
    notifyListeners();
  }

  // add fittingRenter
  void addFittingRenter(FittingRenter fittingRenter) async {
    _fittingRenters.add(fittingRenter);
    await FirestoreService.addFittingRenter(fittingRenter);
    notifyListeners();
  }

  void fetchLedgersOnce() async {
    if (ledgers.length == 0) {
      final snapshot = await FirestoreService.getLedgersOnce();
      for (var doc in snapshot.docs) {
        _ledgers.add(doc.data());
      }
    }
  }

  void fetchMessagesOnce() async {
    if (messages.length == 0) {
      final snapshot = await FirestoreService.getMessagesOnce();
      for (var doc in snapshot.docs) {
        _messages.add(doc.data());
      }
    }
  }
  void fetchItemsOnce() async {
    log('CALLING FETCHITEMSONCE');
    if (items.length == 0) {
      // Temporary setting of email password once
      MyStore.writeToStore('fkwx gnet sbwl pgjb');
      final snapshot = await FirestoreService.getItemsOnce();
      for (var doc in snapshot.docs) {
        _items.add(doc.data());
      }
      log('ENDING FETCHITEMSONCE');
      fetchRentersOnce();
      fetchImages(); // FIXED AS fetchRenters now done here, KEEP AN EYE ON THIS, ARE WE FETCHING BEFORE USERS VERIFY IMAGE IS SET
      populateFavourites();
      populateFittings();
      // fetchImages();
      notifyListeners();
    }
  }
    void populateFavourites() {
      List favs = _user.favourites;
      _favourites.clear();
      for (Item d in _items) {
        if (favs.contains(d.id)) {
          _favourites.add(d);
        }
      }
    }
    void addFavourite(item) {
      _favourites.add(item);
      notifyListeners();
    }
    void removeFavourite(item) {
      _favourites.remove(item);
      notifyListeners();
    }
    void populateFittings() {
      List fits = _user.fittings;
      _fittings.clear();
      for (Item d in _items) {
        if (fits.contains(d.id)) {
          _fittings.add(d.id);
        }
      }
    }
    void addFitting(itemId) {
      _fittings.add(itemId);
      notifyListeners();
    }
    void removeFitting(itemId) {
      _fittings.remove(itemId);
      notifyListeners();
    }
    void clearFittings() {
      fittings.clear();
      renter.fittings = [];
      saveRenter(renter);
      notifyListeners();
    }

      Future<dynamic> setCurrentUser() async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // List<Renter> renters = this.renters;
        for (Renter r in renters) {
          if (r.email == user.email) {
            assignUser(r);
            _loggedIn = true;
          }
        }
      } else {
        _loggedIn = false;
      }
      return user;
      // return asda;
    }
  void setLoggedIn(bool loggedIn) {
    _loggedIn = loggedIn;
    if (loggedIn == false) {
      _user = Renter(id: '0000', email: 'dummy', name: 'no_user', size: 0, countryCode: '', address: '', phoneNum: '', favourites: [], fittings: [], settings: ['BANGKOK','CM','CM','KG'], verified: '', imagePath: '', creationDate: '');
      notifyListeners();
    }
  }

  void fetchItemRentersOnce() async {
    if (itemRenters.length == 0) {
      final snapshot = await FirestoreService.getItemRentersOnce();
      for (var doc in snapshot.docs) {
        _itemRenters.add(doc.data());
      }
      notifyListeners();
    }
  }
  void fetchFittingRentersOnce() async {
    if (fittingRenters.length == 0) {
      final snapshot = await FirestoreService.getFittingRentersOnce();
      for (var doc in snapshot.docs) {
        _fittingRenters.add(doc.data());
      }
      notifyListeners();
    }
  }
  void deleteLedgers() async {
      await FirestoreService.deleteLedgers();
      _ledgers.clear();
  }
  void deleteItems() async {
      await FirestoreService.deleteItems();
      _items.clear();
  }
  void deleteItemRenters() async {
      await FirestoreService.deleteItemRenters();
      _itemRenters.clear();
  }
  void deleteFittingRenters() async {
      await FirestoreService.deleteFittingRenters();
      _fittingRenters.clear();
  }

  void fetchImages() async {
    log('Item count is: ${items.length}');
    for (Item i in items) {
      for (String j in i.imageId) {
        log(j);
        final ref = FirebaseStorage.instance.ref().child(j);
        String url = '';
        try {
          url = await ref.getDownloadURL();
          ItemImage newImage = ItemImage(id: ref.fullPath,imageId: Image.network(url));
          _images.add(newImage);
          log('Item image added (for url $url), size now ${_images.length}');
        } catch (e) {
          log('Item load error: ${e.toString()} for url: $url');
        }
      }
    }
    for (Renter r in renters) {
        String verifyImagePath = r.imagePath;
        if (verifyImagePath != '') {
        final refVerifyImage =
            FirebaseStorage.instance.ref().child(verifyImagePath);
        String verifyUrl = '';
        try {
          verifyUrl = await refVerifyImage.getDownloadURL();
          ItemImage newImage = ItemImage(
              id: refVerifyImage.fullPath, imageId: Image.network(verifyUrl));
          _images.add(newImage);
          log('VerifyImage load success');
        } catch (e) {
          log('Item load error: ${e.toString()} for url: $verifyUrl');
        }} else {
          log('No image to load for user, not verified?');
        }
    }
    notifyListeners();
  }

  void fetchRentersOnce() async {
    if (renters.length == 0) {
      final snapshot = await FirestoreService.getRentersOnce();
      for (var doc in snapshot.docs) {
        _renters.add(doc.data());
        }
      }
      setCurrentUser();
    }
  void saveItemRenter(ItemRenter itemRenter) async {
    await FirestoreService.updateItemRenter(itemRenter);
    notifyListeners();
    return;
  }
  void saveFittingRenter(FittingRenter fittingRenter) async {
    await FirestoreService.updateFittingRenter(fittingRenter);
    notifyListeners();
    return;
  }
  void saveItem(Item item) async {
    await FirestoreService.updateItem(item);
    return;
  }
  void saveMessage(Message message) async {
    await FirestoreService.updateMessage(message);
    notifyListeners();
    return;
  }
}
