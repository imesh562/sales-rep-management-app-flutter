import 'package:dk_brothers/screens/items_screen.dart';
import 'package:dk_brothers/screens/sales_rep_screen.dart';
import 'package:dk_brothers/screens/shop_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/bottom_nav.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
  //runApp((DevicePreview(builder: (context) => MyApp())));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        BottomNavBar.id: (context) => BottomNavBar(),
        ShopRegister.id: (context) => ShopRegister(),
        SalesRep.id: (context) => SalesRep(),
        ItemsList.id: (context) => ItemsList(),
      },
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'DK Brothers',
      theme: ThemeData().copyWith(
        primaryColor: Color(0xFF0A0E21),
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null
          ? LoginScreen.id
          : BottomNavBar.id,
    );
  }
}
