import 'dart:async';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/screens/payment_history.dart';
import 'package:dk_brothers/screens/payments_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';

User? loggedInUser1;

// ignore: must_be_immutable
class Payments extends StatefulWidget {
  static String id = 'payemt_screen';

  var initPayment;
  var userRoleDash;

  Payments(this.initPayment, this.userRoleDash);
  @override
  _PaymentsState createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
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
        initialIndex: widget.initPayment,
        length: 2,
        child: Scaffold(
          extendBodyBehindAppBar: false,
          appBar: appBarWithBottom(
            mediaData,
            'Payments',
            'New Payment',
            'History',
            widget.userRoleDash,
          ),
          body: TabBarView(
            children: [
              PaymentScreen(widget.userRoleDash),
              PaymentHistory(widget.userRoleDash),
            ],
          ),
        ),
      ),
    );
  }
}
