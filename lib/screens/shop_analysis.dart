import 'dart:async';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/screens/shop_overview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';

import 'all_shops.dart';

User? loggedInUser1;

// ignore: must_be_immutable
class ShopAnalysis extends StatefulWidget {
  static String id = 'order_screen';

  var iniTab;

  ShopAnalysis(this.iniTab);
  @override
  _ShopAnalysisState createState() => _ShopAnalysisState();
}

class _ShopAnalysisState extends State<ShopAnalysis> {
  late StreamSubscription subscription;
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      checkConnection(hasInternet, context);
    });
    loggedInUser1 = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: DefaultTabController(
        initialIndex: widget.iniTab,
        length: 2,
        child: Scaffold(
          extendBodyBehindAppBar: false,
          appBar: appBarWithBottomDefault(
              mediaData, 'Shop Analysis', 'Overview', 'Shops'),
          body: TabBarView(
            children: [
              ShopOverview(),
              AllShops(),
            ],
          ),
        ),
      ),
    );
  }
}
