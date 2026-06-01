import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/admin_provider.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  Map<String, int> _flightsByDay = {};
  Map<String, int> _bookingsByMonth = {};
  Map<String, int> _statusDist = {};
  List<MapEntry<String, int>> _topRoutes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _loading = true);
    final p = context.read<AdminProvider>();
    final results = await Future.wait([
      p.flightsByDayOfWeek(),
      p.bookingsByMonth(),
      p.flightStatusDistribution(),
      p.topRoutes(),
    ]);
    if (mounted) {
      setState(() {
        _flightsByDay = results[0] as Map<String, int>;
        _bookingsByMonth = results[1] as Map<String, int>;
        _statusDist = results[2] as Map<String, int>;
        _topRoutes = results[3] as List<MapEntry<String, int>>;
        _loading = false;
      });
    }
  }

  static const _dayOrder = [
    'Lun', 'Mar', 'Mi\u00E9', 'Jue', 'Vie', 'S\u00E1b', 'Dom',
  ];
  static const _monthOrder = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  static const _pieColors = [
    AppColors.cyan,
    AppColors.orange,
    AppColors.chipGreen,
    AppColors.blue,
    AppColors.chipRed,
    AppColors.chipYellow,
    AppColors.chipPurple,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('REPORTES')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReports,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _sectionTitle('Vuelos por D\u00EDa'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: _buildBarChart(),
                  ),
                  const Divider(height: 32),
                  _sectionTitle('Reservas por Mes'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: _buildLineChart(),
                  ),
                  const Divider(height: 32),
                  _sectionTitle('Distribuci\u00F3n de Estados'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: _buildPieChart(),
                  ),
                  const Divider(height: 32),
                  _sectionTitle('Top 5 Rutas'),
                  const SizedBox(height: 8),
                  _buildTopRoutesTable(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.rajdhani(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.cyan,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildBarChart() {
    final spots = _dayOrder
        .map((d) => _flightsByDay[d] ?? 0)
        .toList();
    final maxY = spots.reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY < 1 ? 1 : maxY * 1.2,
        minY: 0,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= _dayOrder.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  _dayOrder[i],
                  style: const TextStyle(
                    color: AppColors.gray,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(
                    color: AppColors.gray,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxY < 1 ? 1 : maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.cardBorder,
            strokeWidth: 0.5,
          ),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(spots.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: spots[i].toDouble(),
                color: AppColors.cyan.withValues(alpha: 0.85),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLineChart() {
    final spots = _monthOrder
        .asMap()
        .entries
        .map((e) => FlSpot(
              e.key.toDouble(),
              (_bookingsByMonth[e.value] ?? 0).toDouble(),
            ))
        .toList();
    final maxY = spots
            .map((s) => s.y)
            .reduce((a, b) => a > b ? a : b)
            .toDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: maxY < 1 ? 1 : maxY * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: AppColors.orange,
            barWidth: 3,
            isCurved: true,
            preventCurveOverShooting: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.orange.withValues(alpha: 0.1),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= _monthOrder.length) {
                  return const SizedBox.shrink();
                }
                if (i % 2 != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _monthOrder[i],
                    style: const TextStyle(
                      color: AppColors.gray,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(
                    color: AppColors.gray,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxY < 1 ? 1 : maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.cardBorder,
            strokeWidth: 0.5,
          ),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: true),
      ),
    );
  }

  Widget _buildPieChart() {
    if (_statusDist.isEmpty) {
      return const Center(
        child: Text(
          'Sin datos',
          style: TextStyle(color: AppColors.gray),
        ),
      );
    }

    final total = _statusDist.values.fold(0, (a, b) => a + b);
    final entries = _statusDist.entries.toList();
    final colorMap = <String, Color>{};
    for (var i = 0; i < entries.length; i++) {
      colorMap[entries[i].key] = _pieColors[i % _pieColors.length];
    }

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: entries.map((e) {
                final pct = total > 0 ? (e.value / total * 100) : 0.0;
                return PieChartSectionData(
                  value: e.value.toDouble(),
                  color: colorMap[e.key]!,
                  title: '${pct.toInt()}%',
                  titleStyle: const TextStyle(
                    color: AppColors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  radius: 50,
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 30,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entries.map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colorMap[e.key],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _statusDisplay(e.key),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _statusDisplay(String s) {
    switch (s) {
      case 'scheduled':
        return 'Programado';
      case 'boarding':
        return 'Abordando';
      case 'departed':
        return 'Despegado';
      case 'arrived':
        return 'Arribado';
      case 'cancelled':
        return 'Cancelado';
      case 'delayed':
        return 'Demorado';
      default:
        return s;
    }
  }

  Widget _buildTopRoutesTable() {
    if (_topRoutes.isEmpty) {
      return const Text(
        'Sin datos de rutas',
        style: TextStyle(color: AppColors.gray),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surface),
        dataRowColor: WidgetStateProperty.all(Colors.transparent),
        columnSpacing: 24,
        columns: const [
          DataColumn(
            label: Text(
              'Ruta',
              style: TextStyle(
                color: AppColors.cyan,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          DataColumn(
            numeric: true,
            label: Text(
              'Reservas',
              style: TextStyle(
                color: AppColors.cyan,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
        rows: _topRoutes
            .map(
              (e) => DataRow(cells: [
                DataCell(
                  Text(
                    e.key,
                    style: const TextStyle(color: AppColors.white, fontSize: 13),
                  ),
                ),
                DataCell(
                  Text(
                    '${e.value}',
                    style: const TextStyle(color: AppColors.orange, fontSize: 13),
                  ),
                ),
              ]),
            )
            .toList(),
      ),
    );
  }
}
