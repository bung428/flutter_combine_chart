import 'dart:math';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_combine_chart/models/donut_chart_data.dart';

class DonutChart extends StatelessWidget {
  final double? width;
  final double? height;
  final double? size;
  final String total;

  const DonutChart({
    super.key,
    this.width,
    this.height,
    this.size,
    required this.total
  });

  @override
  Widget build(BuildContext context) {
    final _width = size ?? width ?? 0;
    final _height = size ?? height ?? 0;
    return SizedBox(
      width: _width,
      height: _height,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(_width, _height),
            painter: DonutChartPainter(
                data: [
                  DonutChartData(type: 'type1', value: 10, color: Colors.redAccent),
                  DonutChartData(type: 'type2', value: 20, color: Colors.orangeAccent),
                  DonutChartData(type: 'type3', value: 3, color: Colors.yellowAccent),
                  DonutChartData(type: 'type4', value: 43, color: Colors.greenAccent),
                ]
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text('$total분'),
          )
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<DonutChartData> data;

  DonutChartPainter({super.repaint, required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final painterList = data
        .map((e) => PainterData(
        paint: Paint()
          ..color = e.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
        value: e.value
    )).toList();

    const totalValue = 100;
    const fullAngle = 2 * pi;
    const gapAngle = 0.1;
    var startAngle = 0.0;

    for (final painter in painterList) {
      final sweepAngle = (painter.value / totalValue) * fullAngle;
      final path = Path()..addArc(rect, startAngle, sweepAngle - gapAngle);

      canvas.drawPath(path, painter.paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) =>
      const DeepCollectionEquality().equals(data, oldDelegate.data);
}