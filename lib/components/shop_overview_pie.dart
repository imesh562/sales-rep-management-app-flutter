import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sortedmap/sortedmap.dart';

import 'data.dart';

class PieData {
  final _firestore = FirebaseFirestore.instance;
  List<Data> data = [];
  List<String> shopNames = [];
  Map<String, double> shopAnalysis = SortedMap(Ordering.byValue());
  double total = 0;

  getDataShopPie() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("orders")
        .where('status', isEqualTo: 'enable')
        .get();
    QuerySnapshot totalSnap = await _firestore.collection("order_items").get();
    if (querySnapshot.docs.length > 0) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        var a = querySnapshot.docs[i];
        var shopID = a['shop_id'];
        var total = 0.0;
        var discountedTotal = 0.0;

        for (int i = 0; i < totalSnap.docs.length; i++) {
          var doc = totalSnap.docs[i];
          if (doc['order_id'] == a.reference.id) {
            total += doc['price'] * doc['quantity'];
            discountedTotal += (doc['price'] * doc['quantity']) -
                ((doc['discount'] / 100) * (doc['price'] * doc['quantity']));
          }
        }
        if (shopAnalysis.containsKey(shopID)) {
          if (discountedTotal < total && discountedTotal > 0) {
            shopAnalysis.update(shopID, (dynamic val) => val + discountedTotal);
          } else {
            shopAnalysis.update(shopID, (dynamic val) => val + total);
          }
        } else {
          if (discountedTotal < total && discountedTotal > 0) {
            shopAnalysis[shopID] = discountedTotal;
          } else {
            shopAnalysis[shopID] = total;
          }
        }
      }
      shopAnalysis.removeWhere((key, value) => value == 0);
      var values = shopAnalysis.values;
      if (shopAnalysis.isNotEmpty) {
        total = values.reduce((sum, element) => sum + element);
      }
    }
  }

  getShopNames() async {
    QuerySnapshot repData = await _firestore.collection("shops").get();

    for (var key in shopAnalysis.keys) {
      repData.docs.forEach((element) {
        if (element.id == key) {
          shopNames.add(element.get('shop_name'));
        }
      });
    }
  }

  allShops() {
    var reversedList = List.from(shopNames.reversed);
    var reversedTotals = [];
    var mockTotals = [];
    int i = 0;
    int j = 0;
    var other = 0.0;
    late Color color;
    shopAnalysis.forEach((key, value) {
      mockTotals.add(value);
      reversedTotals = List.from(mockTotals.reversed);
    });
    shopAnalysis.forEach((key, value) {
      if (j > shopAnalysis.length - 5 || shopAnalysis.length < 5) {
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
            percent: shopAnalysis.isEmpty ? 0 : percentage,
            color: color));
        i++;
      } else {
        other += ((value / total) * 100);
      }
      j++;
    });
    data.add(Data(
        name: 'Other',
        percent:
            shopAnalysis.isEmpty ? 0 : double.parse(other.toStringAsFixed(1)),
        color: Colors.grey));
    return data;
  }
}
