import 'package:flutter/material.dart';
import 'data.dart';

// ignore: must_be_immutable
class IndicatorsWidget extends StatefulWidget {
  List<Data> alldata;
  var mediaData;
  var isMain;

  IndicatorsWidget(this.alldata, this.mediaData, this.isMain);

  @override
  _IndicatorsWidgetState createState() => _IndicatorsWidgetState();
}

class _IndicatorsWidgetState extends State<IndicatorsWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.alldata
          .map(
            (data) => Container(
              padding: EdgeInsets.symmetric(
                  vertical: widget.mediaData.size.height * 0.005),
              child: widget.isMain
                  ? MainbuildIndicator(
                      color: data.color,
                      text: data.name,
                    )
                  : buildIndicator(
                      color: data.color,
                      text: data.name,
                    ),
            ),
          )
          .toList(),
    );
  }

  Widget buildIndicator({
    required Color color,
    required String text,
    bool isSquare = false,
    double size = 16,
    Color textColor = const Color(0xff505050),
  }) =>
      Row(
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          )
        ],
      );

  // ignore: non_constant_identifier_names
  Widget MainbuildIndicator({
    required Color color,
    required String text,
    bool isSquare = false,
    double size = 16,
    Color textColor = Colors.white,
  }) =>
      Row(
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          )
        ],
      );
}
