import 'dart:io';

import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final bool isEdit;
  final VoidCallback onClicked;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    required this.onClicked,
    this.isEdit = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return Center(
      child: Stack(
        children: [
          buildImage(mediaData),
          Positioned(
            bottom: 0,
            right: 4,
            child: buildEditIcon(Colors.lightBlue),
          ),
        ],
      ),
    );
  }

  Widget buildImage(MediaQueryData mediaData) {
    if (imagePath.isNotEmpty && imagePath != 'null') {
      final image = NetworkImage(imagePath);
      return ClipOval(
        child: Material(
          color: Colors.transparent,
          child: Ink.image(
            image: image,
            fit: BoxFit.cover,
            width: mediaData.size.height * 0.175,
            height: mediaData.size.height * 0.175,
            child: InkWell(
              onTap: onClicked,
            ),
          ),
        ),
      );
    } else {
      return ClipOval(
        child: Material(
          color: Colors.transparent,
          child: Ink.image(
            image: AssetImage('assets/images/saleREP.png'),
            fit: BoxFit.cover,
            width: mediaData.size.height * 0.175,
            height: mediaData.size.height * 0.175,
            child: InkWell(
              onTap: onClicked,
            ),
          ),
        ),
      );
    }
  }

  buildEditIcon(Color color) {
    return buildCircle(
      color: Colors.white,
      all: 3,
      child: buildCircle(
        color: color,
        all: 8,
        child: Icon(
          isEdit ? Icons.add_a_photo : Icons.edit,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) {
    return ClipOval(
      child: Container(
        child: child,
        color: color,
        padding: EdgeInsets.all(all),
      ),
    );
  }
}

class ProfileWidget2 extends StatelessWidget {
  final File image;
  final bool isEdit;
  final VoidCallback onClicked;

  const ProfileWidget2({
    Key? key,
    required this.image,
    required this.onClicked,
    this.isEdit = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return Center(
      child: Stack(
        children: [
          buildImage(mediaData),
          Positioned(
            bottom: 0,
            right: 4,
            child: buildEditIcon(Colors.lightBlue),
          ),
        ],
      ),
    );
  }

  Widget buildImage(MediaQueryData mediaData) {
    // ignore: unnecessary_null_comparison
    if (image != null) {
      return ClipOval(
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: onClicked,
            child: Image.file(
              image,
              width: mediaData.size.height * 0.175,
              height: mediaData.size.height * 0.175,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return ClipOval(
        child: Material(
          color: Colors.transparent,
          child: Ink.image(
            image: AssetImage('assets/images/saleREP.png'),
            fit: BoxFit.cover,
            width: mediaData.size.height * 0.175,
            height: mediaData.size.height * 0.175,
            child: InkWell(
              onTap: onClicked,
            ),
          ),
        ),
      );
    }
  }

  buildEditIcon(Color color) {
    return buildCircle(
      color: Colors.white,
      all: 3,
      child: buildCircle(
        color: color,
        all: 8,
        child: Icon(
          isEdit ? Icons.add_a_photo : Icons.edit,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) {
    return ClipOval(
      child: Container(
        child: child,
        color: color,
        padding: EdgeInsets.all(all),
      ),
    );
  }
}
