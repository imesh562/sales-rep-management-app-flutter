import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

AppBar appBarComponenet(mediaData, topBarText) {
  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: mediaData.size.height * 0.065,
    backgroundColor: Colors.white,
    centerTitle: true,
    elevation: 10.0,
    title: Text(
      topBarText,
      style: TextStyle(
        fontSize: mediaData.size.height * 0.03,
        color: Color(0xFF5B9FDE),
        fontFamily: 'Exo2',
        fontWeight: FontWeight.bold,
      ),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(25.0),
      ),
    ),
  );
}

AppBar appBarWithBottom(mediaData, topBarText, tab1, tab2, userRole) {
  return AppBar(
    bottom: TabBar(
      indicatorColor: userRole.toString() == 'admin'
          ? Color(0xFF7a459d)
          : Color(0xFF7a459d),
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: Colors.black,
      labelStyle: TextStyle(
        fontFamily: 'Exo2',
        fontWeight: FontWeight.bold,
        fontSize: mediaData.size.height * 0.023,
      ),
      tabs: [
        Tab(text: tab1),
        Tab(text: tab2),
      ],
    ),
    automaticallyImplyLeading: false,
    toolbarHeight: mediaData.size.height * 0.065,
    backgroundColor: Colors.white,
    centerTitle: true,
    elevation: 10.0,
    title: Text(
      topBarText,
      style: TextStyle(
        fontSize: mediaData.size.height * 0.03,
        color: Color(0xFF5B9FDE),
        fontFamily: 'Exo2',
        fontWeight: FontWeight.bold,
      ),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(25.0),
      ),
    ),
  );
}

AppBar appBarWithBottomDefault(mediaData, topBarText, tab1, tab2) {
  return AppBar(
    bottom: TabBar(
      indicatorColor: Color(0xff02d39a),
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: Colors.black,
      labelStyle: TextStyle(
        fontFamily: 'Exo2',
        fontWeight: FontWeight.bold,
        fontSize: mediaData.size.height * 0.023,
      ),
      tabs: [
        Tab(text: tab1),
        Tab(text: tab2),
      ],
    ),
    automaticallyImplyLeading: false,
    toolbarHeight: mediaData.size.height * 0.065,
    backgroundColor: Colors.white,
    centerTitle: true,
    elevation: 10.0,
    title: Text(
      topBarText,
      style: TextStyle(
        fontSize: mediaData.size.height * 0.03,
        color: Color(0xFF5B9FDE),
        fontFamily: 'Exo2',
        fontWeight: FontWeight.bold,
      ),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(25.0),
      ),
    ),
  );
}

void checkConnection(bool hasInternet, BuildContext context) async {
  if (!hasInternet) {
    showTopSnackBar(
        context,
        CustomSnackBar.error(
          message: 'No internet connection',
          textStyle: TextStyle(
            fontFamily: 'Exo2',
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
        showOutAnimationDuration: Duration(milliseconds: 500));
  } else {
    showTopSnackBar(
      context,
      CustomSnackBar.success(
        message: 'Logged in Successfully',
        textStyle: TextStyle(
          fontFamily: 'Exo2',
          fontSize: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ClipperCustom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.9);
    path.quadraticBezierTo(
      0,
      size.height,
      size.width * 0.1,
      size.height,
    );
    path.lineTo(size.width * 0.4, size.height);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width * 0.6,
      size.height * 0.9,
    );
    path.lineTo(size.width * 0.9, size.height * 0.6);
    path.quadraticBezierTo(
      size.width,
      size.height * 0.5,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class ClipperCustom2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.6);
    path.quadraticBezierTo(
      size.width,
      size.height * 0.5,
      size.width * 0.6,
      size.height * 0.95,
    );
    path.lineTo(size.width * 0.55, size.height);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width * 0.55,
      size.height,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class ClipperCustom3 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 4, size.height, size.width / 2, size.height);
    path.quadraticBezierTo(size.width - (size.width / 4), size.height,
        size.width, size.height - 40);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
