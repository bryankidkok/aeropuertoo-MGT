import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/admin_provider.dart';
import '../../../core/config/app_routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, int> _counts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final provider = context.read<AdminProvider>();
    final counts = await provider.loadDashboardCounts();
    if (mounted) {
      setState(() {
        _counts = counts;
        _loading = false;
      });
    }
  }

  void _navigateTo(String route) => context.push(route);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('PANEL DE CONTROL'),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.cyan.withValues(alpha: 0.4),
                ),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.cyan,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.cyan),
            tooltip: 'Vista Cliente',
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: _GridPainter()),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildWelcomeCard(user?.displayName ?? 'Admin'),
                      const SizedBox(height: 20),
                      _buildSectionTitle('MÉTRICAS DEL SISTEMA'),
                      const SizedBox(height: 12),
                      _buildMetricsGrid(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('ACCESO RÁPIDO'),
                      const SizedBox(height: 12),
                      _buildQuickAccessGrid(),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final displayName =
        context.read<AuthProvider>().user?.displayName ?? 'Admin';

    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.cyan, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.cyan.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.shield,
                    color: AppColors.cyan,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: GoogleFonts.rajdhani(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ADMINISTRADOR',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.cyan,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(Icons.flight_takeoff, 'Vuelos', () {
                  Navigator.pop(context);
                  _navigateTo('/admin/flights');
                }),
                _drawerItem(Icons.business, 'Aerolíneas', () {
                  Navigator.pop(context);
                  _navigateTo('/admin/airlines');
                }),
                _drawerItem(Icons.flight, 'Aeronaves', () {
                  Navigator.pop(context);
                  _navigateTo('/admin/aircrafts');
                }),
                _drawerItem(Icons.meeting_room, 'Puertas', () {
                  Navigator.pop(context);
                  _navigateTo('/admin/gates');
                }),
                _drawerItem(Icons.location_city, 'Terminales', () {
                  Navigator.pop(context);
                  _navigateTo('/admin/terminals');
                }),
                _drawerItem(Icons.people, 'Pasajeros', () {
                  Navigator.pop(context);
                  _navigateTo('/admin/passengers');
                }),
                _drawerItem(Icons.badge, 'Empleados', () {
                  Navigator.pop(context);
                  _navigateTo('/admin/employees');
                }),
                _drawerItem(Icons.build, 'Mantenimiento', () {
                  Navigator.pop(context);
                  _navigateTo('/admin/maintenance');
                }),
                _drawerItem(Icons.manage_accounts, 'Usuarios', () {
                  Navigator.pop(context);
                  _navigateTo('/admin/users');
                }),
                _drawerItem(Icons.bar_chart, 'Reportes', () {
                  Navigator.pop(context);
                  _navigateTo('/admin/reports');
                }),
                _drawerItem(Icons.settings, 'Configuración', () {
                  Navigator.pop(context);
                  _navigateTo('/admin/settings');
                }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: InkWell(
              onTap: () => context.go(AppRoutes.home),
              child: Row(
                children: [
                  const Icon(Icons.visibility, color: AppColors.cyan, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Vista Cliente',
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      color: AppColors.cyan,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.cyan),
      title: Text(
        text,
        style: GoogleFonts.rajdhani(
          fontSize: 16,
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildWelcomeCard(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.card, AppColors.card.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.cyan.withValues(alpha: 0.2),
            child: const Icon(Icons.shield, color: AppColors.cyan, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido, $name',
                  style: GoogleFonts.rajdhani(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Panel de Administración del Aeropuerto',
                  style: TextStyle(fontSize: 13, color: AppColors.gray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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

  Widget _buildMetricsGrid() {
    final metrics = [
      _MetricData(
        'Vuelos Hoy',
        _counts['flightsToday'] ?? 0,
        Icons.flight_takeoff,
        AppColors.cyan,
      ),
      _MetricData(
        'Pasajeros',
        _counts['passengers'] ?? 0,
        Icons.people,
        AppColors.orange,
      ),
      _MetricData(
        'Puertas Activas',
        _counts['activeGates'] ?? 0,
        Icons.meeting_room,
        AppColors.chipGreen,
      ),
      _MetricData(
        'Incidencias',
        _counts['openIncidents'] ?? 0,
        Icons.warning_amber,
        AppColors.chipRed,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: metrics.length,
      itemBuilder: (_, i) => _buildMetricCard(metrics[i]),
    );
  }

  Widget _buildMetricCard(_MetricData m) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                m.label,
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(m.icon, color: m.color, size: 22),
            ],
          ),
          Text(
            '${m.count}',
            style: GoogleFonts.rajdhani(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    final items = [
      _QuickAccess('Vuelos', Icons.flight_takeoff, '/admin/flights'),
      _QuickAccess('Aerolíneas', Icons.business, '/admin/airlines'),
      _QuickAccess('Aeronaves', Icons.flight, '/admin/aircrafts'),
      _QuickAccess('Puertas', Icons.meeting_room, '/admin/gates'),
      _QuickAccess('Terminales', Icons.location_city, '/admin/terminals'),
      _QuickAccess('Pasajeros', Icons.people, '/admin/passengers'),
      _QuickAccess('Empleados', Icons.badge, '/admin/employees'),
      _QuickAccess('Mantenimiento', Icons.build, '/admin/maintenance'),
      _QuickAccess('Usuarios', Icons.manage_accounts, '/admin/users'),
      _QuickAccess('Reportes', Icons.bar_chart, '/admin/reports'),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) => _buildQuickAccessItem(item)).toList(),
    );
  }

  Widget _buildQuickAccessItem(_QuickAccess item) {
    return InkWell(
      onTap: () => _navigateTo(item.route),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: (MediaQuery.of(context).size.width - 42) / 3,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: AppColors.cyan, size: 24),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A2E).withValues(alpha: 0.3)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MetricData {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  _MetricData(this.label, this.count, this.icon, this.color);
}

class _QuickAccess {
  final String label;
  final IconData icon;
  final String route;
  _QuickAccess(this.label, this.icon, this.route);
}
