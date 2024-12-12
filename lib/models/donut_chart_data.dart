import 'package:flutter/material.dart';

class DonutChartData {
  final String type;
  final int value;
  final Color color;

  DonutChartData({required this.type, required this.value, required this.color});
}

class PainterData {
  final Paint paint;
  final int value;

  PainterData({required this.paint, required this.value});
}