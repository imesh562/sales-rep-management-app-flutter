import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

BoxDecoration loginBackground() {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFCBE3FF),
        Color(0xFF5B9FDE),
      ],
    ),
  );
}

BoxDecoration topCardsBG1(String img) {
  return BoxDecoration(
    borderRadius: BorderRadiusDirectional.circular(25.0),
    image: DecorationImage(
      image: AssetImage(img),
      fit: BoxFit.cover,
    ),
  );
}

BoxDecoration topCardsBGDash(String img) {
  return BoxDecoration(
      borderRadius: BorderRadiusDirectional.circular(25.0),
      image: DecorationImage(
        image: AssetImage(img),
        fit: BoxFit.cover,
      ));
}

BoxDecoration topCardsBG(Color color1, Color color2) {
  return BoxDecoration(
    borderRadius: BorderRadiusDirectional.circular(25.0),
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color1,
        color2,
      ],
    ),
  );
}

BoxDecoration shopProfile(imgLocation) {
  return BoxDecoration(
    borderRadius: BorderRadiusDirectional.circular(25.0),
    image: DecorationImage(
      alignment: Alignment.center,
      image: AssetImage(
        imgLocation,
      ),
      fit: BoxFit.cover,
    ),
  );
}

List<BoxShadow> boxShadows() {
  return [
    BoxShadow(
      color: Colors.grey,
      offset: Offset.zero,
      blurRadius: 15,
      spreadRadius: 3,
    ),
  ];
}

List<BoxShadow> boxShadowsReps() {
  return [
    BoxShadow(
      color: Colors.grey,
      offset: Offset.zero,
      blurRadius: 10,
      spreadRadius: 1,
    ),
  ];
}

const loginLight = TextStyle(
  fontFamily: 'Exo2',
  fontSize: 15.0,
  color: Color(0xFF8D8E98),
);

const loginBold = TextStyle(
  fontFamily: 'Exo2',
  fontSize: 20.0,
  fontWeight: FontWeight.bold,
);

const loginCredentials = TextStyle(
  fontSize: 15.0,
  color: Color(0xFF8D8E98),
);

const kLoginFields = InputDecoration(
  labelText: 'Enter Text',
  labelStyle: loginCredentials,
  suffixIcon: Icon(
    FontAwesomeIcons.userAlt,
    color: Color(0xFF5B9FDE),
  ),
  errorStyle: TextStyle(fontSize: 12, height: 0.3),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFCBE3FF)),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF5B9FDE)),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  counterText: "",
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const kRegisterFields = InputDecoration(
  labelText: 'Enter Text',
  labelStyle: loginCredentials,
  suffixIcon: Icon(
    FontAwesomeIcons.userAlt,
    color: Color(0xFF5B9FDE),
  ),
  errorStyle: TextStyle(fontSize: 12, height: 0.3),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFb8dbdb)),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF158E85)),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  counterText: "",
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const kDefaultTextField = InputDecoration(
  errorStyle: TextStyle(fontSize: 12, height: 1),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  counterText: "",
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const kTargetField = InputDecoration(
  hintText: 'Target',
  errorStyle: TextStyle(fontSize: 12, height: 1),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  counterText: "",
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const kPaymentTextField = InputDecoration(
  hintText: 'Payment',
  errorStyle: TextStyle(fontSize: 12, height: 1),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  counterText: "",
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

ButtonStyle roundButton(Color btnColor, MediaQueryData mediaData) {
  return ElevatedButton.styleFrom(
    minimumSize:
        Size(mediaData.size.width * 0.25, mediaData.size.height * 0.05),
    elevation: 5.0,
    primary: btnColor,
    padding: EdgeInsets.all(15.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
      side: BorderSide(
        color: btnColor,
      ),
    ),
  );
}

ButtonStyle datesButtons(Color btnColor, MediaQueryData mediaData) {
  return ElevatedButton.styleFrom(
    minimumSize:
        Size(mediaData.size.width * 0.225, mediaData.size.height * 0.04),
    elevation: 5.0,
    primary: btnColor,
    padding: EdgeInsets.all(12.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
      side: BorderSide(color: Color(0xff02d39a), width: 3),
    ),
  );
}

ButtonStyle roundButton1(Color btnColor, MediaQueryData mediaData) {
  return ElevatedButton.styleFrom(
    minimumSize: Size(mediaData.size.width * 0.1, mediaData.size.height * 0.05),
    elevation: 5.0,
    primary: btnColor,
    padding: EdgeInsets.all(15.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
      side: BorderSide(
        color: btnColor,
      ),
    ),
  );
}

const krepReg = TextStyle(
  fontFamily: 'Exo2',
  fontSize: 30.0,
  color: Colors.white,
);
