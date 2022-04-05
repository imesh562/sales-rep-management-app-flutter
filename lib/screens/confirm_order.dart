import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/components/exception_manage.dart';
import 'package:dk_brothers/screens/print_screen.dart';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

User? loggedInUser1;
String selectedID = "";
String selectedName = "";

// ignore: must_be_immutable
class ConfirmOrder extends StatefulWidget {
  static String id = 'confirm_order';
  Map itemList;
  var userRole;

  ConfirmOrder(this.itemList, this.userRole);
  @override
  _ConfirmOrderState createState() => _ConfirmOrderState();
}

class _ConfirmOrderState extends State<ConfirmOrder> {
  late StreamSubscription subscription;
  bool showSpinner = false;
  final _firestore = FirebaseFirestore.instance;

  GlobalKey<FormState> _key = GlobalKey();
  GlobalKey<FormState> _amountKey = GlobalKey();
  GlobalKey<FormState> _discountKey = GlobalKey();

  TextEditingController paymentController = TextEditingController();

  late String shopName;
  late String telNum;
  late String location;
  late String chequeNum;
  late String bankName;
  DateTime? selectedDate;

  double total = 0;
  double discountedTotal = 0;

  List orderMap = [];
  List freeMap = [];
  List discountList = [];

  Color btnColor1 = Color(0xFF2aa7df);
  Color btnColor2 = Color(0xFF2aa7df);
  Color btnColor3 = Color(0xFF2aa7df);
  var paymentMethod = "";
  late double amount;
  int discount = 0;
  int freeQuantity = 0;
  int itemDiscount = 0;
  late int orderID = 0;
  late String repName;
  late String repNameFull;
  bool internet = true;
  bool shopExist = false;

  @override
  void initState() {
    super.initState();
    subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      checkConnection(hasInternet, context);
      checkInternet(hasInternet);
    });
    loggedInUser1 = FirebaseAuth.instance.currentUser;
    waitingList(widget.itemList);
  }

  colorAssign() {
    btnColor1 = widget.userRole.toString() == 'admin'
        ? Color(0xFF509877)
        : Color(0xFF2aa7df);
    btnColor2 = widget.userRole.toString() == 'admin'
        ? Color(0xFF509877)
        : Color(0xFF2aa7df);
    btnColor3 = widget.userRole.toString() == 'admin'
        ? Color(0xFF509877)
        : Color(0xFF2aa7df);
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
        appBar: appBarComponenet(mediaData, 'Confirm Order'),
        body: Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(
                  mediaData.size.width * 0.025,
                ),
                margin: EdgeInsets.only(
                  left: mediaData.size.width * 0.04,
                  right: mediaData.size.width * 0.04,
                  top: mediaData.size.width * 0.025,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: boxShadowsReps(),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              right: mediaData.size.width * 0.025,
                              left: mediaData.size.width * 0.025),
                          child: ShopDropDown(_firestore),
                          width: mediaData.size.width * 0.65,
                          height: mediaData.size.height * 0.075,
                        ),
                        TextButton(
                          onPressed: () {
                            Alert(
                                context: context,
                                title: "Add New Shop",
                                style: AlertStyle(
                                  titleStyle: TextStyle(
                                    fontFamily: 'Exo2',
                                  ),
                                ),
                                content: Form(
                                  key: _key,
                                  child: Column(
                                    children: <Widget>[
                                      TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'Shop Name',
                                          labelStyle: TextStyle(
                                            fontFamily: 'Exo2',
                                          ),
                                        ),
                                        onChanged: (value) async {
                                          if (this.mounted)
                                            setState(() {
                                              shopName = value;
                                            });
                                        },
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Shop Name is required";
                                          } else if (value.length < 2) {
                                            return "Shop Name should have at least 2 characters.";
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                      TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'Contact Number',
                                          counterText: "",
                                          labelStyle: TextStyle(
                                            fontFamily: 'Exo2',
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (this.mounted)
                                            setState(() {
                                              telNum = value;
                                            });
                                        },
                                        keyboardType: TextInputType.number,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        maxLength: 10,
                                        validator: (value) {
                                          bool mobileValid = RegExp(
                                                  r'(^(?:[+0]9)?[0-9]{10,12}$)')
                                              .hasMatch(value!);
                                          if (value.isEmpty) {
                                            return "Contact Number is required";
                                          } else if (!mobileValid) {
                                            return "Please enter a valid Contact number";
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                      TextFormField(
                                        onChanged: (value) {
                                          if (this.mounted)
                                            setState(() {
                                              location = value;
                                            });
                                        },
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Location is required";
                                          } else if (value.length < 3) {
                                            return "Location should have at least 2 characters.";
                                          } else {
                                            return null;
                                          }
                                        },
                                        decoration: InputDecoration(
                                            labelText: 'Location',
                                            labelStyle: TextStyle(
                                              fontFamily: 'Exo2',
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                buttons: [
                                  DialogButton(
                                    onPressed: () async {
                                      bool validation = false;
                                      // ignore: unnecessary_null_comparison
                                      if (_key.currentState!.validate() !=
                                          null) {
                                        validation =
                                            _key.currentState!.validate();
                                      }
                                      if (validation) {
                                        QuerySnapshot querySnapshot =
                                            await _firestore
                                                .collection("shops")
                                                .get();
                                        var list = querySnapshot.docs;
                                        for (var element in list) {
                                          if (element['shop_name'] ==
                                              shopName) {
                                            shopExist = true;
                                            break;
                                          } else {
                                            shopExist = false;
                                          }
                                        }
                                        if (shopExist) {
                                          Alert(
                                            context: context,
                                            type: AlertType.warning,
                                            title: "Warning",
                                            desc: "Shop already exists.",
                                            buttons: [
                                              DialogButton(
                                                child: Text(
                                                  "Ok",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop();
                                                },
                                                width: 120,
                                              )
                                            ],
                                          ).show();
                                        } else {
                                          _sendToServer();
                                        }
                                      }
                                    },
                                    child: Text(
                                      "Submit",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: mediaData.size.height * 0.025,
                                        fontFamily: 'Exo2',
                                      ),
                                    ),
                                  )
                                ]).show();
                          },
                          child: Icon(Icons.add_business,
                              size: mediaData.size.height * 0.05,
                              color: widget.userRole.toString() == 'admin'
                                  ? Color(0xFF7a459d)
                                  : Color(0xFF7a459d)),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: mediaData.size.height * 0.015),
                              child: Text(
                                'Payment',
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: mediaData.size.height * 0.026),
                              ),
                            ),
                            Container(
                              height: mediaData.size.height * 0.1,
                              width: mediaData.size.width * 0.485,
                              child: Form(
                                key: _amountKey,
                                child: TextFormField(
                                  controller: paymentController,
                                  style: TextStyle(
                                      fontSize: mediaData.size.height * 0.03),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  decoration: kDefaultTextField,
                                  validator: (value) {
                                    final numericRegex = RegExp(
                                        r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
                                    final numericRegex1 =
                                        RegExp(r'^[0-9]+[0-9]*$');
                                    if (value!.isEmpty) {
                                      return "Payment amount is required";
                                    } else if (!numericRegex.hasMatch(value) ||
                                        !numericRegex1.hasMatch(value)) {
                                      return 'Enter a valid value';
                                    } else {
                                      return null;
                                    }
                                  },
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      if (this.mounted)
                                        setState(() {
                                          amount = double.parse(value);
                                          if (double.parse(value) > 0 &&
                                              paymentMethod == 'credit') {
                                            btnColor1 =
                                                widget.userRole.toString() ==
                                                        'admin'
                                                    ? Color(0xFF509877)
                                                    : Color(0xFF2aa7df);
                                            btnColor2 =
                                                widget.userRole.toString() ==
                                                        'admin'
                                                    ? Color(0xFF509877)
                                                    : Color(0xFF2aa7df);
                                            btnColor3 =
                                                widget.userRole.toString() ==
                                                        'admin'
                                                    ? Color(0xFF509877)
                                                    : Color(0xFF2aa7df);
                                            paymentMethod = "";
                                          }
                                        });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: mediaData.size.width * 0.05,
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: mediaData.size.height * 0.015),
                              child: Text(
                                'Discount',
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: mediaData.size.height * 0.026),
                              ),
                            ),
                            Container(
                              height: mediaData.size.height * 0.1,
                              width: mediaData.size.width * 0.3,
                              child: Form(
                                key: _discountKey,
                                child: TextFormField(
                                  style: TextStyle(
                                      fontSize: mediaData.size.height * 0.03),
                                  initialValue: '0',
                                  maxLength: 2,
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.number,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  decoration: kDefaultTextField.copyWith(
                                    suffixIcon: Icon(
                                      FontAwesomeIcons.percent,
                                      size: mediaData.size.height * 0.03,
                                      color:
                                          widget.userRole.toString() == 'admin'
                                              ? Color(0xFF509877)
                                              : Color(0xFF2aa7df),
                                    ),
                                  ),
                                  validator: (value) {
                                    final numericRegex = RegExp(
                                        r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
                                    final numericRegex1 =
                                        RegExp(r'^[0-9]+[0-9]*$');
                                    if (value!.isEmpty) {
                                      return "Discount percentage is required";
                                    } else if (!numericRegex.hasMatch(value) ||
                                        !numericRegex1.hasMatch(value)) {
                                      return 'Enter a valid value';
                                    } else if (int.parse(value) > 100) {
                                      return 'Enter a valid value';
                                    } else {
                                      return null;
                                    }
                                  },
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      if (this.mounted)
                                        setState(() {
                                          discount = int.parse(value);
                                          discountList.clear();
                                        });
                                    }
                                    calculateDiscount();
                                    if (this.mounted)
                                      setState(() {
                                        if (value == '0' || value.isEmpty) {
                                          discount = 0;
                                          discountedTotal = 0;
                                        }
                                      });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: roundButton(btnColor1, mediaData),
                          onPressed: () {
                            if (paymentMethod != 'cash') {
                              if (this.mounted)
                                setState(() {
                                  btnColor1 =
                                      widget.userRole.toString() == 'admin'
                                          ? Color(0xFF7a459d)
                                          : Color(0xFF7a459d);
                                  btnColor2 =
                                      widget.userRole.toString() == 'admin'
                                          ? Color(0xFF509877)
                                          : Color(0xFF2aa7df);
                                  btnColor3 =
                                      widget.userRole.toString() == 'admin'
                                          ? Color(0xFF509877)
                                          : Color(0xFF2aa7df);
                                  paymentMethod = 'cash';
                                });
                            }
                          },
                          child: Text(
                            'Cash',
                            style: TextStyle(
                              fontFamily: 'Exo2',
                              fontSize: mediaData.size.height * 0.026,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: mediaData.size.width * 0.045,
                        ),
                        ElevatedButton(
                          style: roundButton(btnColor2, mediaData),
                          onPressed: () {
                            chequeForm(mediaData);
                          },
                          child: Text(
                            'Cheque',
                            style: TextStyle(
                              fontFamily: 'Exo2',
                              fontSize: mediaData.size.height * 0.026,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: mediaData.size.width * 0.045,
                        ),
                        ElevatedButton(
                          style: roundButton(btnColor3, mediaData),
                          onPressed: () {
                            if (paymentMethod != 'credit') {
                              if (this.mounted)
                                setState(() {
                                  btnColor1 =
                                      widget.userRole.toString() == 'admin'
                                          ? Color(0xFF509877)
                                          : Color(0xFF2aa7df);
                                  btnColor2 =
                                      widget.userRole.toString() == 'admin'
                                          ? Color(0xFF509877)
                                          : Color(0xFF2aa7df);
                                  btnColor3 =
                                      widget.userRole.toString() == 'admin'
                                          ? Color(0xFF7a459d)
                                          : Color(0xFF7a459d);
                                  paymentMethod = 'credit';
                                  paymentController.text = '0';
                                  amount = 0;
                                });
                            }
                          },
                          child: Text(
                            'Credit',
                            style: TextStyle(
                              fontFamily: 'Exo2',
                              fontSize: mediaData.size.height * 0.026,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                      vertical: mediaData.size.height * 0.01),
                  itemCount: orderMap.length,
                  itemBuilder: (context, index) {
                    Map itemList = orderMap[index];
                    var name = itemList['name'];
                    var quantity = itemList['quantity'];
                    var price = itemList['price'];
                    var total = quantity * price;
                    return FocusedMenuHolder(
                      openWithTap: true,
                      menuWidth: MediaQuery.of(context).size.width * 0.50,
                      blurSize: 5.0,
                      menuItemExtent: 45,
                      menuBoxDecoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius:
                              BorderRadius.all(Radius.circular(15.0))),
                      duration: Duration(milliseconds: 100),
                      animateMenuItems: true,
                      blurBackgroundColor: Colors.black54,
                      menuOffset:
                          10.0, // Offset value to show menuItem from the selected item
                      bottomOffsetHeight: mediaData.size.height *
                          0.1, // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
                      menuItems: <FocusedMenuItem>[
                        FocusedMenuItem(
                          title: Text("Add Freebies"),
                          trailingIcon: Icon(FontAwesomeIcons.plus),
                          onPressed: () {
                            Alert(
                                context: context,
                                title: "Add Freebies",
                                style: AlertStyle(
                                  titleStyle: TextStyle(
                                    fontFamily: 'Exo2',
                                  ),
                                ),
                                content: Form(
                                  key: _key,
                                  child: Column(
                                    children: <Widget>[
                                      TextFormField(
                                        initialValue: getFreeItems(
                                            itemList['id'].toString()),
                                        decoration: InputDecoration(
                                          labelText: 'Amount',
                                          counterText: "",
                                          labelStyle: TextStyle(
                                            fontFamily: 'Exo2',
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (value.isNotEmpty) {
                                            if (this.mounted)
                                              setState(() {
                                                freeQuantity = int.parse(value);
                                              });
                                          }
                                        },
                                        keyboardType: TextInputType.number,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        maxLength: 10,
                                        validator: (value) {
                                          bool numValid = RegExp(
                                                  r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$')
                                              .hasMatch(value!);
                                          if (value.isEmpty) {
                                            return "An Amount is required";
                                          } else if (!numValid) {
                                            return "Please enter a valid number";
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                buttons: [
                                  DialogButton(
                                    onPressed: () {
                                      bool validation = false;
                                      // ignore: unnecessary_null_comparison
                                      if (_key.currentState!.validate() !=
                                          null) {
                                        validation =
                                            _key.currentState!.validate();
                                      }
                                      // ignore: unnecessary_statements
                                      if (validation) {
                                        Map freeItem = {
                                          'id': itemList['id'],
                                          'name': itemList['name'],
                                          'english_name':
                                              itemList['english_name'],
                                          'quantity': freeQuantity,
                                        };
                                        freeMap.removeWhere((item) =>
                                            item['id'] == itemList['id']);
                                        if (this.mounted)
                                          setState(() {
                                            freeMap.add(freeItem);
                                            freeQuantity = 0;
                                          });
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                      }
                                    },
                                    child: Text(
                                      "Submit",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: mediaData.size.height * 0.025,
                                        fontFamily: 'Exo2',
                                      ),
                                    ),
                                  )
                                ]).show();
                          },
                        ),
                        FocusedMenuItem(
                          title: Text("Add a Discount"),
                          trailingIcon: Icon(FontAwesomeIcons.percentage),
                          onPressed: () {
                            Alert(
                                context: context,
                                title: "Add a Discount",
                                style: AlertStyle(
                                  titleStyle: TextStyle(
                                    fontFamily: 'Exo2',
                                  ),
                                ),
                                content: Form(
                                  key: _key,
                                  child: Column(
                                    children: <Widget>[
                                      TextFormField(
                                        initialValue: getDiscounts(
                                            itemList['id'].toString()),
                                        decoration: InputDecoration(
                                          labelText: 'Discount',
                                          counterText: "",
                                          suffixIcon:
                                              Icon(FontAwesomeIcons.percentage),
                                          labelStyle: TextStyle(
                                            fontFamily: 'Exo2',
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (value.isNotEmpty) {
                                            if (this.mounted)
                                              setState(() {
                                                itemDiscount = int.parse(value);
                                              });
                                          }
                                        },
                                        keyboardType: TextInputType.number,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        maxLength: 2,
                                        validator: (value) {
                                          bool numValid = RegExp(
                                                  r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$')
                                              .hasMatch(value!);
                                          if (value.isEmpty) {
                                            return "Discount is required";
                                          } else if (!numValid) {
                                            return "Please enter a valid number";
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                buttons: [
                                  DialogButton(
                                    onPressed: () {
                                      bool validation = false;
                                      // ignore: unnecessary_null_comparison
                                      if (_key.currentState!.validate() !=
                                          null) {
                                        validation =
                                            _key.currentState!.validate();
                                      }
                                      // ignore: unnecessary_statements
                                      if (validation) {
                                        Map discountItems = {
                                          'id': itemList['id'],
                                          'quantity': quantity,
                                          'price': price,
                                          'discount': itemDiscount,
                                        };
                                        if (discountList
                                            .where((data) =>
                                                data['id'] == itemList['id'])
                                            .any((element) => true)) {
                                          discountList.removeWhere((item) =>
                                              item['id'] == itemList['id']);
                                        }
                                        if (this.mounted)
                                          setState(() {
                                            discountList.add(discountItems);
                                            itemDiscount = 0;
                                          });
                                        calculateDiscount();
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                      }
                                    },
                                    child: Text(
                                      "Submit",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: mediaData.size.height * 0.025,
                                        fontFamily: 'Exo2',
                                      ),
                                    ),
                                  )
                                ]).show();
                          },
                        ),
                      ],
                      onPressed: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadiusDirectional.circular(25.0),
                          boxShadow: boxShadowsReps(),
                          color: Colors.white,
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: mediaData.size.height * 0.02,
                          vertical: mediaData.size.height * 0.005,
                        ),
                        child: ListTile(
                          leading: Padding(
                            padding: EdgeInsets.only(
                              top: mediaData.size.height * 0.01,
                            ),
                            child: Text((index + 1).toString()),
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                              fontSize: mediaData.size.height * 0.023,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: freeMap
                                  .where((data) =>
                                      data['id'] == itemList['id'] &&
                                      data['quantity'] > 0)
                                  .any((element) => true)
                              ? discountList
                                      .where((data) =>
                                          data['id'] == itemList['id'] &&
                                          data['discount'] > 0 &&
                                          data['discount'] != discount)
                                      .any((element) => true)
                                  ? RichText(
                                      text: TextSpan(
                                        text: "Rs. $price * $quantity ",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize:
                                              mediaData.size.height * 0.019,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: '-' +
                                                  discountList
                                                      .where((data) =>
                                                          data['id'] ==
                                                          itemList['id'])
                                                      .first['discount']
                                                      .toString() +
                                                  "%  ",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize:
                                                    mediaData.size.height *
                                                        0.019,
                                              )),
                                          TextSpan(
                                              text: '+' +
                                                  freeMap
                                                      .where((data) =>
                                                          data['id'] ==
                                                          itemList['id'])
                                                      .first['quantity']
                                                      .toString() +
                                                  " Free",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize:
                                                    mediaData.size.height *
                                                        0.019,
                                              )),
                                        ],
                                      ),
                                    )
                                  : RichText(
                                      text: TextSpan(
                                        text: "Rs. $price * $quantity + ",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize:
                                              mediaData.size.height * 0.019,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: freeMap
                                                      .where((data) =>
                                                          data['id'] ==
                                                          itemList['id'])
                                                      .first['quantity']
                                                      .toString() +
                                                  " Free",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize:
                                                    mediaData.size.height *
                                                        0.019,
                                              )),
                                        ],
                                      ),
                                    )
                              : discountList
                                      .where((data) =>
                                          data['id'] == itemList['id'] &&
                                          data['discount'] > 0 &&
                                          data['discount'] != discount)
                                      .any((element) => true)
                                  ? RichText(
                                      text: TextSpan(
                                        text: "Rs. $price * $quantity ",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize:
                                              mediaData.size.height * 0.019,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: '-' +
                                                  discountList
                                                      .where((data) =>
                                                          data['id'] ==
                                                          itemList['id'])
                                                      .first['discount']
                                                      .toString() +
                                                  "%",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize:
                                                    mediaData.size.height *
                                                        0.019,
                                              )),
                                        ],
                                      ),
                                    )
                                  : Text("Rs. $price * $quantity"),
                          trailing: checkItemDiscount(itemList['id']) < total &&
                                  checkItemDiscount(itemList['id']) > 0
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'Rs. ',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                mediaData.size.height * 0.02),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: total.toStringAsFixed(2),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  mediaData.size.height * 0.02,
                                              color: Colors.black,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Rs. ' +
                                          checkItemDiscount(itemList['id'])
                                              .toStringAsFixed(2),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              mediaData.size.height * 0.02),
                                    ),
                                  ],
                                )
                              : discount == 0 ||
                                      checkItemDiscount(itemList['id']) == total
                                  ? Text(
                                      'Rs. ' + total.toStringAsFixed(2),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              mediaData.size.height * 0.02),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: 'Rs. ',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    mediaData.size.height *
                                                        0.02),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: total.toStringAsFixed(2),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      mediaData.size.height *
                                                          0.02,
                                                  color: Colors.black,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'Rs. ' +
                                              ((total) -
                                                      ((discount / 100) *
                                                          (total)))
                                                  .toStringAsFixed(2),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  mediaData.size.height * 0.02),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                    );
                  },
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
                            Alert(
                              context: context,
                              type: AlertType.warning,
                              title: "Confirm",
                              desc: "Confirm the order?",
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Yes",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () async {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    bool amountCheck = false;
                                    bool discountCheck = false;
                                    // ignore: unnecessary_null_comparison
                                    if (_amountKey.currentState!.validate() !=
                                        null) {
                                      amountCheck =
                                          _amountKey.currentState!.validate();
                                    }
                                    // ignore: unnecessary_null_comparison
                                    if (_discountKey.currentState!.validate() !=
                                        null) {
                                      discountCheck =
                                          _discountKey.currentState!.validate();
                                    }
                                    // ignore: unnecessary_statements
                                    if (amountCheck && discountCheck) {
                                      if (this.mounted)
                                        setState(() {
                                          showSpinner = true;
                                        });
                                      try {
                                        await _discount();
                                        await getOrderData();
                                        _orderConfirm(selectedID, paymentMethod,
                                            context, selectedName);
                                        // ignore: unused_catch_clause
                                      } on Exception catch (e) {
                                        showTopSnackBar(
                                            context,
                                            CustomSnackBar.error(
                                              message: 'ERROR',
                                              textStyle: TextStyle(
                                                fontFamily: 'Exo2',
                                                fontSize: 20.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                            showOutAnimationDuration:
                                                Duration(milliseconds: 500));
                                        if (this.mounted)
                                          setState(() {
                                            showSpinner = false;
                                          });
                                      }
                                      if (this.mounted)
                                        setState(() {
                                          showSpinner = false;
                                        });
                                    }
                                  },
                                  color: Colors.deepOrange,
                                ),
                                DialogButton(
                                  child: Text(
                                    "No",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  },
                                  color: Color(0xFF5B9FDE),
                                )
                              ],
                            ).show();
                          },
                          icon: Icon(Icons.check),
                          label: Text(
                            'Confirm',
                            style: TextStyle(
                                fontSize: mediaData.size.height * 0.026),
                          ),
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor:
                                widget.userRole.toString() == 'admin'
                                    ? Color(0xFF509877)
                                    : Color(0xFF2aa7df),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: mediaData.size.width * 0.17,
                      ),
                      discountedTotal < total && discountedTotal > 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'Rs. ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            mediaData.size.height * 0.022),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: total.toStringAsFixed(2),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              mediaData.size.height * 0.022,
                                          color: Colors.black,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Total: Rs. ' +
                                      (discountedTotal).toStringAsFixed(2),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: mediaData.size.height * 0.024),
                                ),
                              ],
                            )
                          : Text(
                              'Total: Rs. ' + total.toStringAsFixed(2),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: mediaData.size.height * 0.026),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> waitingList(itemList) async {
    await orderList(itemList);
    getTotal();
    colorAssign();
  }

  Future<void> orderList(Map itemList) async {
    late DocumentSnapshot itemData;
    if (this.mounted)
      setState(() {
        showSpinner = true;
      });
    for (var key in itemList.keys) {
      if (itemList[key] > 0) {
        await _firestore
            .collection('items')
            .doc(key)
            .get()
            .then((value) => itemData = value);
        var itemMap = {
          'id': key,
          'name': itemData['name'],
          'price': itemData['price'],
          'english_name': itemData['english_name'],
          'quantity': itemList[key],
          'discount': 0,
        };
        if (this.mounted)
          setState(() {
            orderMap.add(itemMap);
          });
      }
    }
    if (this.mounted)
      setState(() {
        showSpinner = false;
      });
  }

  void getTotal() {
    for (var i = 0; i < orderMap.length; i++) {
      var map = orderMap[i];
      double price = map['price'].toDouble();
      int quantity = map['quantity'];
      if (this.mounted)
        setState(() {
          total += price * quantity;
        });
    }
  }

  getOrderData() async {
    if (this.mounted)
      setState(() {
        orderID = 0;
      });
    List maxNum = [];

    QuerySnapshot querySnapshot = await _firestore.collection("orders").get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      var a = querySnapshot.docs[i];
      maxNum.add(int.parse(a.id));
    }
    if (querySnapshot.docs.length > 0) {
      var largest = maxNum[0];
      for (var i = 0; i < maxNum.length; i++) {
        if (maxNum[i] > largest) {
          largest = maxNum[i];
        }
      }
      if (this.mounted)
        setState(() {
          orderID = largest;
          orderID++;
        });
    } else {
      if (this.mounted)
        setState(() {
          orderID = 1;
        });
    }

    await _firestore
        .collection("users")
        .doc(loggedInUser1!.uid)
        .get()
        .then((result) {
      var name = result.get('name');
      List<String> wordList = name.split(" ");
      if (this.mounted)
        setState(() {
          repName = wordList[0];
          repNameFull = name;
        });
    });
  }

  _orderToDB() async {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    DateTime time = new DateTime(
        now.year, now.month, now.day, now.hour, now.minute, now.second);
    if (paymentMethod == 'cash') {
      try {
        await _firestore.collection('payments').doc().set({
          'shop_id': selectedID,
          'date': date.toString().substring(0, 10),
          'time': time.toString().substring(10, 19),
          'shop_name': selectedName,
          'payment': total > amount ? amount : total,
          'payment_total': amount,
          'payment_method': paymentMethod,
          'rep_name': repNameFull,
          'rep_id': loggedInUser1!.uid,
          'order_id': orderID.toString(),
          'status': 'enable',
        });

        QuerySnapshot querySnapshot = await _firestore
            .collection("payments")
            .where('order_id', isEqualTo: orderID.toString())
            .get();
        String paymentId = querySnapshot.docs[0].id;

        await _firestore.collection('orders').doc(orderID.toString()).set({
          'shop_id': selectedID,
          'date': date.toString().substring(0, 10),
          'time': time.toString().substring(10, 19),
          'shop_name': selectedName,
          'discount': discount,
          'payment': total > amount ? amount : total,
          'payment_total': amount,
          'payment_method': paymentMethod,
          'payment_id': paymentId,
          'rep_name': repNameFull,
          'rep_id': loggedInUser1!.uid,
          'status': 'enable',
        });
      } catch (e) {
        ExceptionManagement.registerExceptions(
          context: context,
          error: e.toString(),
        );
      }
    }
    if (paymentMethod == 'cheque') {
      try {
        await _firestore.collection('payments').doc().set({
          'shop_id': selectedID,
          'date': date.toString().substring(0, 10),
          'time': time.toString().substring(10, 19),
          'shop_name': selectedName,
          'payment': total > amount ? amount : total,
          'payment_total': amount,
          'payment_method': paymentMethod,
          'rep_name': repNameFull,
          'rep_id': loggedInUser1!.uid,
          'order_id': orderID.toString(),
          'cheque_num': chequeNum,
          'bank': bankName,
          'withdrawDate': selectedDate,
          'cheque_status': 'pending',
          'status': 'enable',
        });

        QuerySnapshot querySnapshot = await _firestore
            .collection("payments")
            .where('order_id', isEqualTo: orderID.toString())
            .get();
        String paymentId = querySnapshot.docs[0].id;

        await _firestore.collection('orders').doc(orderID.toString()).set({
          'shop_id': selectedID,
          'date': date.toString().substring(0, 10),
          'time': time.toString().substring(10, 19),
          'shop_name': selectedName,
          'discount': discount,
          'payment': total > amount ? amount : total,
          'payment_total': amount,
          'payment_method': paymentMethod,
          'payment_id': paymentId,
          'cheque_num': chequeNum,
          'bank': bankName,
          'withdrawDate': selectedDate,
          'rep_name': repNameFull,
          'rep_id': loggedInUser1!.uid,
          'status': 'enable',
        });
      } catch (e) {
        ExceptionManagement.registerExceptions(
          context: context,
          error: e.toString(),
        );
      }
    }

    if (paymentMethod == 'credit') {
      if (this.mounted)
        setState(() {
          amount = 0;
        });
      try {
        await _firestore.collection('orders').doc(orderID.toString()).set({
          'shop_id': selectedID,
          'date': date.toString().substring(0, 10),
          'time': time.toString().substring(10, 19),
          'shop_name': selectedName,
          'discount': discount,
          'payment': total > amount ? amount : total,
          'payment_total': amount,
          'payment_method': paymentMethod,
          'rep_name': repNameFull,
          'rep_id': loggedInUser1!.uid,
          'status': 'enable',
        });
      } catch (e) {
        ExceptionManagement.registerExceptions(
          context: context,
          error: e.toString(),
        );
      }
    }

    if (orderMap.isNotEmpty) {
      orderMap.forEach((element) async {
        try {
          await _firestore.collection('order_items').doc().set({
            'item_id': element['id'],
            'name': element['name'],
            'price': element['price'],
            'english_name': element['english_name'],
            'quantity': element['quantity'],
            'discount': element['discount'],
            'order_id': orderID.toString(),
          });
        } catch (e) {
          ExceptionManagement.registerExceptions(
            context: context,
            error: e.toString(),
          );
        }
      });
    }
    if (freeMap.isNotEmpty) {
      freeMap.forEach((element) async {
        if (int.parse(element['quantity'].toString()) > 0) {
          try {
            await _firestore.collection('free_items').doc().set({
              'item_id': element['id'],
              'name': element['name'],
              'english_name': element['english_name'],
              'quantity': element['quantity'],
              'order_id': orderID.toString(),
            });
          } catch (e) {
            ExceptionManagement.registerExceptions(
              context: context,
              error: e.toString(),
            );
          }
        }
      });
    }
  }

  _discount() {
    if (discountList.isNotEmpty) {
      for (final element in orderMap) {
        for (final element1 in discountList) {
          if (element["id"] != element1['id']) {
            orderMap.where((x) => x["id"] == element["id"]).first["discount"] =
                discount;
          } else {
            orderMap.where((x) => x["id"] == element1['id']).first["discount"] =
                element1['discount'];
            break;
          }
        }
      }
    } else {
      for (final element in orderMap) {
        orderMap.where((x) => x["id"] == element["id"]).first["discount"] =
            discount;
      }
    }
  }

  _orderConfirm(String selectedID, String paymentMethod, BuildContext context,
      String selectedName) async {
    if (selectedID == "" || paymentMethod == "") {
      Alert(
        context: context,
        type: AlertType.warning,
        title: "Warning",
        desc: "Please select a shop and Payment method",
        buttons: [
          DialogButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            width: 120,
          )
        ],
      ).show();
    } else {
      if (internet) {
        await _orderToDB();
        if (paymentMethod == 'cash') {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(
              builder: (BuildContext context) {
                return PrintScreen(
                  orderMap,
                  discountedTotal < total && discountedTotal > 0
                      ? discountedTotal
                      : total,
                  amount,
                  selectedName,
                  'Cash',
                  orderID,
                  repName,
                  freeMap,
                  widget.userRole,
                );
              },
            ),
          );
        }
        if (paymentMethod == 'cheque') {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(
              builder: (BuildContext context) {
                return PrintScreen.cheque(
                  orderMap,
                  discountedTotal < total && discountedTotal > 0
                      ? discountedTotal
                      : total,
                  amount,
                  selectedName,
                  'Cheque',
                  orderID,
                  repName,
                  freeMap,
                  widget.userRole,
                );
              },
            ),
          );
        }
        if (paymentMethod == 'credit') {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(
              builder: (BuildContext context) {
                return PrintScreen.credit(
                  orderMap,
                  discountedTotal < total && discountedTotal > 0
                      ? discountedTotal
                      : total,
                  amount,
                  selectedName,
                  'Credit',
                  orderID,
                  repName,
                  freeMap,
                  widget.userRole,
                );
              },
            ),
          );
        }
      } else {
        Alert(
          context: context,
          type: AlertType.warning,
          title: "Warning",
          desc: "No Internet",
          buttons: [
            DialogButton(
              child: Text(
                "Ok",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              width: 120,
            )
          ],
        ).show();
      }
    }
  }

  String getFreeItems(String itemID) {
    String freebies = '0';
    freeMap.forEach((element) {
      if (element['id'] == itemID) {
        freebies = element['quantity'].toString();
      }
    });
    return freebies;
  }

  getDiscounts(String itemID) {
    String percentage = '0';
    discountList.forEach((element) {
      if (element['id'] == itemID) {
        percentage = element['discount'].toString();
      }
    });
    return percentage;
  }

  double checkItemDiscount(String itemList) {
    double itemDiscountedTotal = 0;
    discountList.forEach((element) {
      if (element['id'] == itemList) {
        int percentage = int.parse(element['discount'].toString());
        double price = double.parse(element['price'].toString());
        int quantity = int.parse(element['quantity'].toString());

        itemDiscountedTotal =
            (price * quantity) - ((percentage / 100) * (price * quantity));
      }
    });
    return itemDiscountedTotal;
  }

  chequeForm(MediaQueryData mediaData) {
    Alert(
        context: context,
        title: "Cheque Details",
        style: AlertStyle(
          titleStyle: TextStyle(
            fontFamily: 'Exo2',
          ),
        ),
        content: Form(
          key: _key,
          child: Column(
            children: <Widget>[
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cheque Number',
                  labelStyle: TextStyle(
                    fontFamily: 'Exo2',
                  ),
                ),
                onSaved: (value) {
                  if (this.mounted)
                    setState(() {
                      chequeNum = value!;
                    });
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  final number = num.tryParse(value!);
                  if (value.isEmpty) {
                    return "Cheque Number is required";
                  } else if (value.length != 6) {
                    return "Cheque Number should have 6 characters.";
                  } else if (number == null) {
                    return "Cheque Number is not valid.";
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                onSaved: (value) {
                  if (this.mounted)
                    setState(() {
                      bankName = value!;
                    });
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Bank name is required";
                  } else if (value.length < 3) {
                    return "Bank name should have at least 2 characters.";
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                    labelText: 'Bank',
                    labelStyle: TextStyle(
                      fontFamily: 'Exo2',
                    )),
              ),
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.only(top: 10.0, right: 10.0)),
                      onPressed: () {
                        _selectDate(context);
                      },
                      icon: Icon(Icons.calendar_today),
                      label: selectedDate == null
                          ? Text("Withdraw Date")
                          : Text("Withdraw Date: " +
                              selectedDate.toString().substring(0, 10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              bool validation = false;
              // ignore: unnecessary_null_comparison
              if (_key.currentState!.validate() != null) {
                validation = _key.currentState!.validate();
              }
              if (selectedDate == null) {
                Fluttertoast.showToast(
                    msg: "Please select a Withdraw Date",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1);
              }
              // ignore: unnecessary_statements
              if (validation && selectedDate != null) {
                _key.currentState!.save();
                if (this.mounted)
                  setState(() {
                    btnColor1 = widget.userRole.toString() == 'admin'
                        ? Color(0xFF509877)
                        : Color(0xFF2aa7df);
                    btnColor2 = widget.userRole.toString() == 'admin'
                        ? Color(0xFF7a459d)
                        : Color(0xFF7a459d);
                    btnColor3 = widget.userRole.toString() == 'admin'
                        ? Color(0xFF509877)
                        : Color(0xFF2aa7df);
                    paymentMethod = 'cheque';
                  });
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            child: Text(
              "Submit",
              style: TextStyle(
                color: Colors.white,
                fontSize: mediaData.size.height * 0.025,
                fontFamily: 'Exo2',
              ),
            ),
          )
        ]).show();
  }

  _selectDate(BuildContext context) async {
    DateTime now = new DateTime.now();
    DateTime finalDate = new DateTime(now.year, now.month, now.day);
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: finalDate,
      firstDate: finalDate,
      currentDate: finalDate,
      lastDate: new DateTime(now.year + 5, now.month, now.day),
    );
    if (selected != null) {
      if (this.mounted)
        setState(() {
          selectedDate = selected;
        });
    }
  }

  _sendToServer() async {
    if (this.mounted)
      setState(() {
        showSpinner = true;
      });
    try {
      await _firestore.collection('shops').doc().set({
        'location': location,
        'shop_name': shopName,
        'status': 'enable',
        'tel_number': telNum,
        'rep_id': loggedInUser1!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (this.mounted)
        setState(() {
          showSpinner = false;
        });
      Navigator.of(context, rootNavigator: true).pop();
      Alert(
        context: context,
        type: AlertType.success,
        title: "Successful",
        desc: "Shop added successfuly",
        buttons: [
          DialogButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            width: 120,
          )
        ],
      ).show();
    } catch (e) {
      if (this.mounted)
        setState(() {
          showSpinner = false;
        });
      ExceptionManagement.registerExceptions(
        context: context,
        error: e.toString(),
      );
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void calculateDiscount() {
    if (discountList.isEmpty && discount > 0) {
      if (this.mounted)
        setState(() {
          discountedTotal = total - ((discount / 100) * total);
        });
    }
    if (discountList.isNotEmpty && discount == 0) {
      discountedTotal = 0;
      var availability = 0;
      for (final element in orderMap) {
        for (final element1 in discountList) {
          if (element["id"] == element1['id']) {
            var itemTotal = element1['quantity'] * element1['price'];
            if (this.mounted)
              setState(() {
                discountedTotal +=
                    itemTotal - ((element1['discount'] / 100) * itemTotal);
                availability = 1;
              });
            break;
          } else {
            availability = 0;
          }
        }
        if (availability == 0) {
          discountedTotal += element['quantity'] * element['price'];
        }
      }
    }
    if (discountList.isNotEmpty && discount > 0) {
      discountedTotal = 0;
      var availability = 0;
      for (final element in orderMap) {
        for (final element1 in discountList) {
          if (element["id"] == element1['id']) {
            var itemTotal = element1['quantity'] * element1['price'];
            if (this.mounted)
              setState(() {
                discountedTotal +=
                    itemTotal - ((element1['discount'] / 100) * itemTotal);
                availability = 1;
              });
            break;
          } else {
            availability = 0;
          }
        }
        if (availability == 0) {
          var iTotal = element['quantity'] * element['price'];
          discountedTotal += iTotal - ((discount / 100) * iTotal);
        }
      }
    }
  }

  void checkInternet(bool hasInternet) {
    if (this.mounted)
      setState(() {
        internet = hasInternet;
      });
  }
}

// ignore: must_be_immutable
class ShopDropDown extends StatefulWidget {
  ShopDropDown(this.firestore);
  FirebaseFirestore firestore;
  @override
  _ShopDropDownState createState() => _ShopDropDownState();
}

class _ShopDropDownState extends State<ShopDropDown> {
  List<String> shopNameList = [];
  List<String> shopIDList = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.firestore
          .collection('shops')
          .orderBy('shop_name', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          shopNameList.clear();
          shopIDList.clear();
          final shops = snapshot.data!.docs.reversed;
          for (var shop in shops) {
            final shopName = shop['shop_name'];
            final shopStatus = shop['status'];
            final shopID = shop.reference.id;
            if (shopStatus != 'disable') {
              shopNameList.add(shopName);
              shopIDList.add(shopID);
            }
          }
          return TextDropdownFormField(
            options: shopNameList,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.arrow_drop_down),
              labelText: "Select Shop",
              labelStyle: TextStyle(
                fontFamily: 'Exo2',
              ),
              contentPadding: EdgeInsets.all(
                MediaQuery.of(context).size.height * 0.02,
              ),
            ),
            onChanged: (dynamic value) {
              var listIndex = shopNameList.indexOf(value);
              if (this.mounted)
                setState(() {
                  selectedName = value;
                  selectedID = shopIDList[listIndex];
                });
            },
            dropdownHeight: MediaQuery.of(context).size.height * 0.4,
          );
        }
        return TextDropdownFormField(
          options: [],
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.arrow_drop_down),
            labelText: "No Shops",
            labelStyle: TextStyle(
              fontFamily: 'Exo2',
            ),
          ),
          dropdownHeight: 120,
        );
      },
    );
  }
}
