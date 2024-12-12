import 'package:collection/collection.dart';
import 'package:flutter_combine_chart/models/bar_chart_data.dart';

class ChartDataGroup {
  final List<BarChartData> barData;
  final List<double> lineValues;
  final List<String> labels;

  ChartDataGroup({
    List<BarChartData>? barData,
    List<double>? lineValues,
    List<String>? labels
  }): barData = barData ?? const [],
        lineValues = lineValues ?? [],
        labels = labels ?? [];

  @override
  bool operator ==(Object other) => other is ChartDataGroup &&
      const DeepCollectionEquality().equals(labels, other.labels);

  @override
  int get hashCode => barData.hashCode ^ lineValues.hashCode ^ labels.hashCode;
}