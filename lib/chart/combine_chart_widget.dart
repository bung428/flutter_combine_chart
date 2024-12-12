import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_combine_chart/models/chart_data_group.dart';

class AppChartWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double? size;
  final double? maxY;
  final double? gridStep;
  final ChartDataGroup chartDataGroup;

  const AppChartWidget({
    super.key,
    this.width = double.infinity,
    this.height = 200,
    this.size,
    this.maxY,
    this.gridStep,
    required this.chartDataGroup
  });

  @override
  Widget build(BuildContext context) {
    final _width = size ?? width ?? 0;
    final _height = size ?? height ?? 0;
    final paddingLeft = approximateTextWidth('100', const TextStyle(
      color: Color(0xff7d7d7d),
      fontWeight: FontWeight.w400,
      fontSize: 12,
      height: 16 / 12,
    ));
    return SizedBox(
      width: _width,
      height: _height,
      child: CustomPaint(
        size: Size(_width, _height),
        painter: ChartPainter(
            paddingLeft: paddingLeft,
            maxY: maxY ?? 100,
            gridStep: gridStep ?? 20,
            chartData: chartDataGroup
        ),
      ),
    );
  }

  double approximateTextWidth(String text, TextStyle style) {
    final double fontSize = style.fontSize ?? 14.0;
    const double characterWidthFactor = 0.6; // 폰트에 따라 조정 필요
    return fontSize * text.length * characterWidthFactor;
  }
}

class ChartPainter extends CustomPainter {
  final double maxY;
  final double gridStep;
  final double paddingLeft;
  final ChartDataGroup? chartData;

  ChartPainter({
    required this.paddingLeft,
    this.maxY = 100,
    this.gridStep = 20,
    this.chartData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartMaxY = maxY + (gridStep / 2);
    const axisStrokeWidth = 1.0;
    final Paint axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = axisStrokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint gridPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final Paint linePaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint dotPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    const xLabelStyle = TextStyle(
      color: Color(0xff7d7d7d),
      fontWeight: FontWeight.w400,
      fontSize: 11,
      height: 16 / 11,
    );

    const yLabelStyle = TextStyle(
      color: Color(0xff7d7d7d),
      fontWeight: FontWeight.w400,
      fontSize: 12,
      height: 16 / 12,
    );

    final paddingLeft = this.paddingLeft + 5.0;
    const paddingBottom = 0;

    final chartWidth = size.width - paddingLeft;
    final chartHeight = size.height - paddingBottom;

    const extraPaddingTop = 20; // 여유 공간 추가
    final adjustedChartHeight = chartHeight - extraPaddingTop;

    double barWidth = 0;

    // Draw Y-axis
    canvas.drawLine(
      Offset(paddingLeft, 0),
      Offset(paddingLeft, adjustedChartHeight),
      axisPaint,
    );

    // Draw X-axis
    canvas.drawLine(
      Offset(paddingLeft, adjustedChartHeight),
      Offset(size.width, adjustedChartHeight),
      axisPaint,
    );

    const labelMaxWidth = 30.0;
    for (double i = 0; i <= chartMaxY; i += gridStep) {
      final double y = adjustedChartHeight - (i / chartMaxY) * adjustedChartHeight;
      if (i > 0) {
        drawDashedLine(
            canvas: canvas,
            p1: Offset(paddingLeft + axisStrokeWidth, y),
            p2: Offset(size.width, y),
            dashWidth: 1,
            dashSpace: 1,
            paint: gridPaint
        );
      }

      final textSpan = TextSpan(
          text: i.toInt().toString(),
          style: yLabelStyle
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: labelMaxWidth);
      textPainter.paint(
        canvas,
        Offset(paddingLeft - textPainter.width - 5, y - textPainter.height / 2),
      );
    }

    final chartData = this.chartData;
    if (chartData == null) return;
    // x - labels
    if (chartData.labels.isNotEmpty) {
      final int itemCount = chartData.labels.length;
      barWidth = chartWidth / (itemCount * 2);
      for (int i = 0; i < itemCount; i++) {
        final double x = paddingLeft + (i * 2 + 1) * barWidth;

        final textSpan = TextSpan(
          text: chartData.labels[i],
          style: xLabelStyle,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, adjustedChartHeight + 5),
        );
      }
    }

    // bar chart
    final barData = chartData.barData;
    if (barData.isNotEmpty && barWidth != 0) {
      for (int i = 0; i < barData.length; i++) {
        final double x = paddingLeft + (i * 2 + 1) * barWidth;
        final double y = adjustedChartHeight - (barData[i].value / chartMaxY) * adjustedChartHeight;

        final RRect bar = RRect.fromRectAndCorners(
          Rect.fromLTWH(x - barWidth / 2, y - 1, barWidth, adjustedChartHeight - y),
          topLeft: const Radius.circular(8),
          topRight: const Radius.circular(8),
        );
        final Paint paint = Paint()
          ..color = barData[i].color
          ..style = PaintingStyle.fill;

        canvas.drawRRect(bar, paint);
      }
    }

    // line chart
    final lineData = chartData.lineValues;
    if (lineData.isNotEmpty) {
      final Path linePath = Path();
      for (int i = 0; i < lineData.length; i++) {
        final double x = paddingLeft + (i * 2 + 1) * barWidth;
        final double y = adjustedChartHeight - (lineData[i] / chartMaxY) * adjustedChartHeight;
        if (i == 0) {
          linePath.moveTo(x, y);
        } else {
          linePath.lineTo(x, y);
        }
        _drawHollowDot(canvas, x, y, 4.5, dotPaint);
      }
      canvas.drawPath(linePath, linePaint);
    }
  }

  void _drawHollowDot(Canvas canvas, double x, double y, double radius, Paint paint) {
    canvas.drawCircle(Offset(x, y), radius, paint);

    final Paint whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(x, y), radius - 2, whitePaint);
  }

  void drawDashedLine({
    required Canvas canvas,
    required Offset p1,
    required Offset p2,
    required int dashWidth,
    required int dashSpace,
    required Paint paint
  }) {
    var dx = p2.dx - p1.dx;
    var dy = p2.dy - p1.dy;

    final magnitude = sqrt(dx * dx + dy * dy);
    dx = dx / magnitude;
    dy = dy / magnitude;

    final steps = magnitude ~/ (dashWidth + dashSpace);
    var startX = p1.dx;
    var startY = p1.dy;

    for (int i = 0; i < steps; i++) {
      final endX = startX + dx * dashWidth;
      final endY = startY + dy * dashWidth;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
      startX += dx * (dashWidth + dashSpace);
      startY += dy * (dashWidth + dashSpace);
    }
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) => chartData != oldDelegate.chartData;
}