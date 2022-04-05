import 'dart:async';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:location/location.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

User? loggedInUser1;

// ignore: must_be_immutable
class PrintScreen extends StatefulWidget {
  static String id = 'print_screen';

  var orderMap;
  var total;
  var amount;
  var selectedName;
  var payemntType;
  var orderID;
  var repName;
  var freeMap;

  var userRole;

  PrintScreen(
    this.orderMap,
    this.total,
    this.amount,
    this.selectedName,
    this.payemntType,
    this.orderID,
    this.repName,
    this.freeMap,
    this.userRole,
  );
  PrintScreen.cheque(
    this.orderMap,
    this.total,
    this.amount,
    this.selectedName,
    this.payemntType,
    this.orderID,
    this.repName,
    this.freeMap,
    this.userRole,
  );
  PrintScreen.credit(
    this.orderMap,
    this.total,
    this.amount,
    this.selectedName,
    this.payemntType,
    this.orderID,
    this.repName,
    this.freeMap,
    this.userRole,
  );
  @override
  _PrintScreenState createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  late StreamSubscription subscription;
  bool showSpinner = false;

  BlueThermalPrinter printer = BlueThermalPrinter.instance;
  List<BluetoothDevice> devices = [];
  String? selectedDevice;

  late String orderTime;
  String _devicesMsg = '';
  late double balance;
  String route = '';
  DateTime? nextVisit;
  late List<String> wordList;

  @override
  void initState() {
    super.initState();
    getDevices();
    subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      checkConnection(hasInternet, context);
    });
    loggedInUser1 = FirebaseAuth.instance.currentUser;
    wordList = widget.repName.split(" ");
  }

  void getDevices() async {
    if (this.mounted)
      setState(() {
        devices.clear();
      });
    bool? blueStatus = await checkBluetooth();
    bool gpsStatus = await checkGPS();
    if (blueStatus! && gpsStatus) {
      List<BluetoothDevice> mockList = await printer.getBondedDevices();
      if (this.mounted)
        setState(() {
          devices = mockList;
        });
      if (devices.isEmpty) {
        if (this.mounted)
          setState(() {
            _devicesMsg = 'No Devices Found';
          });
      }
    } else {
      if (this.mounted)
        setState(() {
          _devicesMsg = 'Turn On Bluetooth and Location';
        });
    }
  }

  Future<bool?> checkBluetooth() async {
    return await printer.isOn;
  }

  Future<bool> checkGPS() async {
    var location = Location();
    return await location.serviceEnabled();
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
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: appBarComponenet(mediaData, 'Print Bill'),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(
                mediaData.size.width * 0.025,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: mediaData.size.width * 0.04,
                vertical: mediaData.size.width * 0.05,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: boxShadowsReps(),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: mediaData.size.height * 0.065,
                    width: mediaData.size.width * 0.68,
                    child: TextFormField(
                      style: TextStyle(fontSize: mediaData.size.height * 0.025),
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.text,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: kDefaultTextField.copyWith(hintText: 'Route'),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (this.mounted)
                            setState(() {
                              route = value.toString();
                            });
                        }
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _selectDate(context);
                    },
                    child: Icon(
                      Icons.calendar_today,
                      size: mediaData.size.height * 0.05,
                      color: Color(
                        0xFF509877,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            devices.isEmpty
                ? Expanded(
                    child: Container(
                      padding: EdgeInsets.all(
                        mediaData.size.width * 0.025,
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: mediaData.size.width * 0.04,
                        vertical: mediaData.size.height * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: boxShadowsReps(),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: mediaData.size.height * 0.01),
                            child: Text(
                              'Select the Printer',
                              style: TextStyle(
                                  fontFamily: 'Exo2',
                                  fontSize: mediaData.size.height * 0.025,
                                  color: widget.userRole.toString() == 'admin'
                                      ? Color(0xFF509877)
                                      : Color(0xFF2aa7df),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                _devicesMsg,
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontSize: mediaData.size.height * 0.02,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: Container(
                      padding: EdgeInsets.all(
                        mediaData.size.width * 0.025,
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: mediaData.size.width * 0.04,
                        vertical: mediaData.size.height * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: boxShadowsReps(),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: mediaData.size.height * 0.01),
                            child: Text(
                              'Select the Printer',
                              style: TextStyle(
                                  fontFamily: 'Exo2',
                                  fontSize: mediaData.size.height * 0.025,
                                  color: widget.userRole.toString() == 'admin'
                                      ? Color(0xFF509877)
                                      : Color(0xFF2aa7df),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: devices.length,
                              itemBuilder: (c, i) {
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: mediaData.size.height * 0.005),
                                  decoration: new BoxDecoration(
                                    boxShadow: boxShadowsReps(),
                                    borderRadius: BorderRadius.circular(
                                        mediaData.size.width * 0.05),
                                    color: selectedDevice ==
                                            devices[i].address.toString()
                                        ? widget.userRole.toString() == 'admin'
                                            ? Color(0xFF509877)
                                            : Color(0xFF2aa7df)
                                        : Colors.white,
                                  ),
                                  child: ListTile(
                                    leading: Icon(Icons.print),
                                    title: Text(devices[i].name.toString()),
                                    subtitle:
                                        Text(devices[i].address.toString()),
                                    onTap: () async {
                                      await getOrderData();
                                      bool? conectivity =
                                          await printer.isConnected;
                                      try {
                                        if (conectivity == true) {
                                          await printer.disconnect();
                                          await printer.connect(devices[i]);
                                          if (this.mounted)
                                            setState(() {
                                              selectedDevice =
                                                  devices[i].address;
                                            });
                                        } else {
                                          await printer.connect(devices[i]);
                                          if (this.mounted)
                                            setState(() {
                                              selectedDevice =
                                                  devices[i].address;
                                            });
                                        }
                                        // ignore: unused_catch_clause
                                      } on Exception catch (e) {
                                        showTopSnackBar(
                                            context,
                                            CustomSnackBar.error(
                                              message: 'Connectivity Error',
                                              textStyle: TextStyle(
                                                fontFamily: 'Exo2',
                                                fontSize: 20.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                            showOutAnimationDuration:
                                                Duration(milliseconds: 500));
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(mediaData.size.height * 0.02),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () async {
                          getDevices();
                        },
                        icon: Icon(Icons.refresh),
                        label: Text(
                          'Scan',
                          style: TextStyle(
                              fontSize: mediaData.size.height * 0.026),
                        ),
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: widget.userRole.toString() == 'admin'
                              ? Color(0xFF509877)
                              : Color(0xFF2aa7df),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: mediaData.size.width * 0.075,
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () async {
                          if (selectedDevice != null) {
                            _printBill();
                          } else {
                            Alert(
                              context: context,
                              type: AlertType.warning,
                              title: "Warning",
                              desc: "Please select a printing device",
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Ok",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  },
                                  width: 120,
                                )
                              ],
                            ).show();
                          }
                        },
                        icon: Icon(Icons.print_rounded),
                        label: Text(
                          'Print',
                          style: TextStyle(
                              fontSize: mediaData.size.height * 0.026),
                        ),
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: widget.userRole.toString() == 'admin'
                              ? Color(0xFF7a459d)
                              : Color(0xFF7a459d),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _printBill() async {
    printer.isConnected.then(
      (isConnected) {
        if (isConnected!) {
          printer.printCustom("NANDANA BAKEHOUSE", 4, 1);
          printer.printCustom(
              'Manufacturer and Distributors of Bakery Products', 1, 1);
          printer.printCustom(
              '................................................................',
              0,
              0);
          printer.printCustom(
              'DK Brothers, No: 40 B5, Aladeniya Road, Muruthalawa.', 0, 1);
          printer.printCustom('081-2410289 / 071-6460159', 0, 1);
          printer.printCustom(
              '................................................................',
              0,
              0);
          printer.printCustom("Invoice", 3, 1);
          printer.printCustom(
              "ID: " +
                  widget.orderID.toString() +
                  "                                     Rep: " +
                  wordList[0],
              0,
              0);
          printer.printCustom(
              "Date: " +
                  orderTime +
                  "                 Type: " +
                  widget.payemntType,
              0,
              0);
          if (nextVisit != null) {
            printer.printCustom(
                "Date of Next Visit: " +
                    nextVisit.toString().substring(0, 10) +
                    "            Route: " +
                    route,
                0,
                0);
          } else {
            printer.printCustom(
                "Date of Next Visit:                       Route: " + route,
                0,
                0);
          }
          printer.printCustom("Customer: " + widget.selectedName, 0, 0);
          printer.printCustom(
              '................................................................',
              0,
              0);
          printer.printCustom(
              '| Name | Quan | Disc |                         | Rate | Amount |',
              0,
              0);
          printer.printCustom(
              '................................................................',
              0,
              0);
          for (var i = 0; i < widget.orderMap.length; i++) {
            Map itemList = widget.orderMap[i];
            var name = itemList['english_name'];
            var quantity = itemList['quantity'];
            var price = itemList['price'];
            var discount = itemList['discount'];
            var itemTotal = quantity * price;
            var discountedTotal = itemTotal - ((discount / 100) * itemTotal);
            var discountedPrice = price - ((discount / 100) * price);
            printer.printCustom(
                name +
                    '  ' +
                    quantity.toString() +
                    'pcs  ' +
                    '  ' +
                    discount.toString() +
                    '%',
                0,
                0);
            printer.printCustom(
                discountedPrice.toString() +
                    '    ' +
                    discountedTotal.toString(),
                0,
                2);
            printer.printCustom(
                '................................................................',
                0,
                0);
          }
          for (var i = 0; i < widget.freeMap.length; i++) {
            Map itemList = widget.freeMap[i];
            var name = itemList['english_name'];
            var quantity = itemList['quantity'];
            printer.printCustom(
                'Free ' + name + '  ' + quantity.toString() + 'pcs', 0, 0);
          }
          if (widget.freeMap.isNotEmpty) {
            printer.printCustom(
                '................................................................',
                0,
                0);
          }
          printer.printCustom('Net Total:    ' + widget.total.toString(), 0, 2);
          if (widget.payemntType == 'Credit') {
            printer.printCustom('Payment:    Credit', 0, 2);
          } else {
            printer.printCustom(
                'Payment:    ' + widget.amount.toString(), 0, 2);
          }
          printer.printCustom('Balance:    ' + balance.toString(), 0, 2);
          printer.printNewLine();
          printer.printCustom('.............................', 0, 0);
          printer.printCustom('          Signature', 0, 0);
          printer.printCustom(
              '................................................................',
              0,
              0);
          printer.printCustom("Thank You", 2, 1);
          printer.printNewLine();
          printer.printNewLine();
          printer.paperCut();
        }
      },
    );
  }

  getOrderData() async {
    DateTime now = new DateTime.now();
    DateTime finalDate = new DateTime(
        now.year, now.month, now.day, now.hour, now.minute, now.second);
    var fDate = finalDate.toString();
    if (this.mounted)
      setState(() {
        orderTime = fDate.substring(0, 19);
      });

    if (this.mounted)
      setState(() {
        balance = widget.amount - widget.total;
      });
  }

  _selectDate(BuildContext context) async {
    DateTime now = new DateTime.now();
    DateTime finalDate = new DateTime(now.year, now.month, now.day);
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: finalDate,
      firstDate: finalDate,
      currentDate: finalDate,
      lastDate: new DateTime(now.year, now.month + 3, now.day),
    );
    if (selected != null) {
      if (this.mounted)
        setState(() {
          nextVisit = selected;
        });
    }
  }
}
