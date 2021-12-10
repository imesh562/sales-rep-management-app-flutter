import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineTitles {
  static getTitleData(MediaQueryData mediaData, String chartType) {
    return FlTitlesData(
      show: true,
      topTitles: SideTitles(
        showTitles: false,
      ),
      bottomTitles: SideTitles(
        showTitles: true,
        reservedSize: 35,
        getTextStyles: (context, value) => const TextStyle(
          color: Color(0xff68737d),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        getTitles: (value) {
          if (chartType == 'Monthly') {
            switch (value.toInt()) {
              case 0:
                return 'JAN';
              case 3:
                return 'APR';
              case 6:
                return 'JUL';
              case 9:
                return 'OCT';
              case 11:
                return 'DEC';
            }
          }
          if (chartType == 'Weekly') {
            switch (value.toInt()) {
              case 0:
                return 'W 1';
              case 1:
                return 'W 2';
              case 2:
                return 'W 3';
              case 3:
                return 'W 4';
              case 4:
                return 'W 5';
            }
          }
          if (chartType == 'Daily') {
            switch (value.toInt()) {
              case 0:
                return 'D 1';
              case 1:
                return 'D 2';
              case 2:
                return 'D 3';
              case 3:
                return 'D 4';
              case 4:
                return 'D 5';
              case 5:
                return 'D 6';
              case 6:
                return 'D 7';
            }
          }
          return '';
        },
        margin: 8,
      ),
      rightTitles: SideTitles(
        showTitles: false,
      ),
      leftTitles: SideTitles(
        showTitles: true,
        getTextStyles: (context, value) => const TextStyle(
          color: Color(0xff67727d),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        getTitles: (value) {
          if (chartType == 'Monthly') {
            switch (value.toInt()) {
              case 1:
                return '40K';
              case 2:
                return '80K';
              case 3:
                return '120K';
              case 4:
                return '160K';
              case 5:
                return '200K';
            }
          }
          if (chartType == 'Weekly') {
            switch (value.toInt()) {
              case 1:
                return '20K';
              case 2:
                return '40K';
              case 3:
                return '60K';
              case 4:
                return '80K';
              case 5:
                return '100K';
            }
          }
          if (chartType == 'Daily') {
            switch (value.toInt()) {
              case 1:
                return '10K';
              case 2:
                return '20K';
              case 3:
                return '30K';
              case 4:
                return '40K';
              case 5:
                return '50K';
            }
          }
          return '';
        },
        reservedSize: 35,
        margin: 12,
      ),
    );
  }

  static titlesShopProfile(MediaQueryData mediaData, String chartType) {
    return FlTitlesData(
      show: true,
      topTitles: SideTitles(
        showTitles: false,
      ),
      bottomTitles: SideTitles(
        showTitles: true,
        reservedSize: 35,
        getTextStyles: (context, value) => const TextStyle(
          color: Color(0xff68737d),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        getTitles: (value) {
          if (chartType == 'Monthly') {
            switch (value.toInt()) {
              case 0:
                return 'JAN';
              case 3:
                return 'APR';
              case 6:
                return 'JUL';
              case 9:
                return 'OCT';
              case 11:
                return 'DEC';
            }
          }
          if (chartType == 'Weekly') {
            switch (value.toInt()) {
              case 0:
                return 'W 1';
              case 1:
                return 'W 2';
              case 2:
                return 'W 3';
              case 3:
                return 'W 4';
              case 4:
                return 'W 5';
            }
          }
          if (chartType == 'Daily') {
            switch (value.toInt()) {
              case 0:
                return 'D 1';
              case 1:
                return 'D 2';
              case 2:
                return 'D 3';
              case 3:
                return 'D 4';
              case 4:
                return 'D 5';
              case 5:
                return 'D 6';
              case 6:
                return 'D 7';
            }
          }
          return '';
        },
        margin: 8,
      ),
      rightTitles: SideTitles(
        showTitles: false,
      ),
      leftTitles: SideTitles(
        showTitles: true,
        getTextStyles: (context, value) => const TextStyle(
          color: Color(0xff67727d),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        getTitles: (value) {
          if (chartType == 'Monthly') {
            switch (value.toInt()) {
              case 1:
                return '10K';
              case 2:
                return '20K';
              case 3:
                return '30K';
              case 4:
                return '40K';
              case 5:
                return '50K';
            }
          }
          if (chartType == 'Weekly') {
            switch (value.toInt()) {
              case 1:
                return '5K';
              case 2:
                return '10K';
              case 3:
                return '15K';
              case 4:
                return '20K';
              case 5:
                return '25K';
            }
          }
          if (chartType == 'Daily') {
            switch (value.toInt()) {
              case 1:
                return '2K';
              case 2:
                return '4K';
              case 3:
                return '6K';
              case 4:
                return '8K';
              case 5:
                return '10K';
            }
          }
          return '';
        },
        reservedSize: 35,
        margin: 12,
      ),
    );
  }
}
