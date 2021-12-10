import 'dart:io';
import 'dart:typed_data';
import 'package:dk_brothers/components/decorations.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ViewQR extends StatelessWidget {
  static String id = 'viewQR';

  ViewQR(
      {required this.shopID, required this.shopName, required this.location});
  final String shopID;
  final String location;
  final String shopName;
  final _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Screenshot(
              controller: _screenshotController,
              child: Column(
                children: [
                  Text(
                    shopName,
                    style: loginBold.copyWith(
                      fontSize: 30.0,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    location,
                    style: loginLight.copyWith(fontSize: 20.0),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    padding: EdgeInsets.all(mediaData.size.height * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset.zero,
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: QrImage(
                      data: shopID,
                      embeddedImage: AssetImage(
                        'assets/images/splash.png',
                      ),
                      version: QrVersions.auto,
                      size: mediaData.size.height * 0.3,
                      errorStateBuilder: (cxt, err) {
                        return Container(
                          child: Center(
                            child: AlertDialog(
                              title: new Text("Alert!!"),
                              content: new Text("Something went wrong."),
                              actions: <Widget>[
                                new TextButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(5.0),
                padding: MaterialStateProperty.all<EdgeInsets>(
                    (EdgeInsets.all(15.0))),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFF00c1c4)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(
                      color: Color(0xFF00c1c4),
                    ),
                  ),
                ),
              ),
              onPressed: () async {
                final image = await _screenshotController.capture();
                _takeScreenshot(context, image);
              },
              child: Text(
                'SHARE',
                style: TextStyle(
                  fontFamily: 'Exo2',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takeScreenshot(BuildContext context, Uint8List? bytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final image = File('${directory.path}/$shopName.png');
      image.writeAsBytesSync(bytes!);
      await Share.shareFiles([image.path]);
    } on Exception catch (e) {
      AlertDialog(
        title: new Text("Alert!!"),
        content: new Text(e.toString()),
        actions: <Widget>[
          new TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    }
  }
}
