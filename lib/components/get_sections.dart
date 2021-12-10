import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'data.dart';

List<PieChartSectionData> getSections(
    int touchedIndex, List<Data> alldata, MediaQueryData mediaData) {
  return alldata
      .asMap()
      .map<int, PieChartSectionData>((index, data) {
        final isTouched = index == touchedIndex;
        final double fontSize = isTouched
            ? mediaData.size.height * 0.035
            : mediaData.size.height * 0.028;
        final double radius = isTouched
            ? mediaData.size.height * 0.175
            : mediaData.size.height * 0.14;

        final value = PieChartSectionData(
          color: data.color,
          value: data.percent,
          title: '${data.percent}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
          ),
        );

        return MapEntry(index, value);
      })
      .values
      .toList();
}
