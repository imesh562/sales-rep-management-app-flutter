import 'dart:async';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/screens/new_order.dart';
import 'package:dk_brothers/screens/order_history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';

User? loggedInUser1;

// ignore: must_be_immutable
class OrderScreen extends StatefulWidget {
  static String id = 'order_screen';

  var iniTab;
  var userRoleDash;

  OrderScreen(this.iniTab, this.userRoleDash);
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
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
          appBar: appBarWithBottom(
              mediaData, 'Orders', 'New Order', 'History', widget.userRoleDash),
          body: TabBarView(
            children: [
              NewOrder(widget.userRoleDash),
              OrderHistory(widget.userRoleDash),
            ],
          ),
        ),
      ),
    );
  }
}
