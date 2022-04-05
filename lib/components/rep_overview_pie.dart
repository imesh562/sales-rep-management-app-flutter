import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sortedmap/sortedmap.dart';

import 'data.dart';

class RepOverviewData {
  final _firestore = FirebaseFirestore.instance;
  List<Data> data = [];
  List<String> repNames = [];
  Map<String, double> repAnalysis = SortedMap(Ordering.byValue());
  double total = 0;

  getDataRepPie() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("orders")
        .where('status', isEqualTo: 'enable')
        .get();

    QuerySnapshot totalSnap = await _firestore.collection("order_items").get();

    if (querySnapshot.docs.length > 0) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        var a = querySnapshot.docs[i];
        var repID = a['rep_id'];
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
        if (repAnalysis.containsKey(repID)) {
          if (discountedTotal < total && discountedTotal > 0) {
            repAnalysis.update(repID, (dynamic val) => val + discountedTotal);
          } else {
            repAnalysis.update(repID, (dynamic val) => val + total);
          }
        } else {
          if (discountedTotal < total && discountedTotal > 0) {
            repAnalysis[repID] = discountedTotal;
          } else {
            repAnalysis[repID] = total;
          }
        }
      }
      repAnalysis.removeWhere((key, value) => value == 0);
      var values = repAnalysis.values;
      if (repAnalysis.isNotEmpty) {
        total = values.reduce((sum, element) => sum + element);
      }
    }
  }

  getRepNames() async {
    QuerySnapshot repData = await _firestore.collection("users").get();

    for (var key in repAnalysis.keys) {
      repData.docs.forEach((element) {
        if (element.id == key) {
          repNames.add(element.get('name'));
        }
      });
    }
  }

  allReps() {
    var reversedList = List.from(repNames.reversed);
    var reversedTotals = [];
    var mockTotals = [];
    int i = 0;
    int j = 0;
    var other = 0.0;
    late Color color;
    repAnalysis.forEach((key, value) {
      mockTotals.add(value);
      reversedTotals = List.from(mockTotals.reversed);
    });
    repAnalysis.forEach((key, value) {
      if (j > repAnalysis.length - 5 || repAnalysis.length < 5) {
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
            percent: repAnalysis.isEmpty ? 0 : percentage,
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
            repAnalysis.isEmpty ? 0 : double.parse(other.toStringAsFixed(1)),
        color: Colors.grey));
    return data;
  }
}
