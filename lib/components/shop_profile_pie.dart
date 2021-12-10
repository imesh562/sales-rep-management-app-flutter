import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sortedmap/sortedmap.dart';

import 'data.dart';

class ShopPieData {
  final _firestore = FirebaseFirestore.instance;
  List<Data> data = [];
  List<String> itemNames = [];
  Map<String, int> shopItems = SortedMap(Ordering.byValue());
  int total = 0;

  getShopPie(shopID) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("orders")
        .where('status', isEqualTo: 'enable')
        .where('shop_id', isEqualTo: shopID)
        .get();
    if (querySnapshot.docs.length > 0) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        var a = querySnapshot.docs[i];
        QuerySnapshot totalSnap = await _firestore
            .collection("order_items")
            .where('order_id', isEqualTo: a.reference.id)
            .get();
        for (int i = 0; i < totalSnap.docs.length; i++) {
          var doc = totalSnap.docs[i];
          var itemID = doc['item_id'];
          var quantity = doc['quantity'];
          if (shopItems.containsKey(itemID)) {
            shopItems.update(itemID, (dynamic val) => val + quantity);
          } else {
            shopItems[itemID] = quantity;
          }
        }
      }
      var values = shopItems.values;
      total = values.reduce((sum, element) => sum + element);
    }
  }

  getItemsNames() async {
    for (var key in shopItems.keys) {
      await _firestore.collection("items").doc(key).get().then((result) {
        itemNames.add(result.get('name'));
      });
    }
  }

  allShops() {
    var reversedList = List.from(itemNames.reversed);
    var reversedTotals = [];
    var mockTotals = [];
    int i = 0;
    int j = 0;
    var other = 0.0;
    late Color color;
    shopItems.forEach((key, value) {
      mockTotals.add(value);
      reversedTotals = List.from(mockTotals.reversed);
    });
    shopItems.forEach((key, value) {
      if (j > shopItems.length - 5 || shopItems.length < 5) {
        var percentage = double.parse(
            ((reversedTotals[i] / total) * 100).toStringAsFixed(1));
        switch (i) {
          case 0:
            color = Color(0xff0293ee);
            break;
          case 1:
            color = Color(0xfff8b250);
            break;
          case 2:
            color = Colors.purple;
            break;
          case 3:
            color = Color(0xff13d38e);
            break;
        }
        data.add(Data(
            name: reversedList.isEmpty ? "" : reversedList[i],
            percent: shopItems.isEmpty ? 0 : percentage,
            color: color));
        i++;
      } else {
        other += ((value / total) * 100);
      }
      j++;
    });
    data.add(Data(
        name: 'Other',
        percent: shopItems.isEmpty ? 0 : double.parse(other.toStringAsFixed(1)),
        color: Colors.grey));
    return data;
  }
}
