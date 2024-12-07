import 'package:flutter/material.dart';

class BarChartData {
  final double value;
  final Color color;
  final double barWidth;

  BarChartData({
    required this.value,
    this.color = const Color(0xffff9f7c),
    this.barWidth = 9,
  });
}
