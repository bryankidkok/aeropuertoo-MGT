import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/models/user_model.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().user?.role;

    // Admin: barra igual que pasajero + botón Panel Admin al final
    if (role == UserRole.admin) {
      return Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.cyan,
          unselectedItemColor: AppColors.gray,
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex >= _adminItems.length ? 0 : currentIndex,
          onTap: (i) => _navigateAdmin(context, i),
          items: _adminItems,
        ),
      );
    }

    // Staff
    if (role == UserRole.staff) {
      return Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.cyan,
          unselectedItemColor: AppColors.gray,
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex >= _staffItems.length ? 0 : currentIndex,
          onTap: (i) => _navigateStaff(context, i),
          items: _staffItems,
        ),
      );
    }

    // Pasajero (default)
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.cyan,
        unselectedItemColor: AppColors.gray,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex >= _passengerItems.length ? 0 : currentIndex,
        onTap: (i) => _navigatePassenger(context, i),
        items: _passengerItems,
      ),
    );
  }

  // ── Items ─────────────────────────────────────────────────────────

  static const _passengerItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Inicio',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
    BottomNavigationBarItem(
      icon: Icon(Icons.book_online_outlined),
      activeIcon: Icon(Icons.book_online),
      label: 'Reservas',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];

  static const _staffItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.meeting_room_outlined),
      activeIcon: Icon(Icons.meeting_room),
      label: 'Puertas',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.warning_amber_outlined),
      activeIcon: Icon(Icons.warning),
      label: 'Incidencias',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];

  // Admin ve lo mismo que pasajero + acceso directo al panel
  static const _adminItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Inicio',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
    BottomNavigationBarItem(
      icon: Icon(Icons.book_online_outlined),
      activeIcon: Icon(Icons.book_online),
      label: 'Reservas',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Perfil',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shield_outlined, color: Color(0xFFFF6B35)),
      activeIcon: Icon(Icons.shield, color: Color(0xFFFF6B35)),
      label: 'Admin',
    ),
  ];

  // ── Navegación ────────────────────────────────────────────────────

  void _navigatePassenger(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/flights');
      case 2:
        context.go('/bookings');
      case 3:
        context.go('/profile');
    }
  }

  void _navigateStaff(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/operations');
      case 1:
        context.go('/gates');
      case 2:
        context.go('/incidents');
      case 3:
        context.go('/profile');
    }
  }

  void _navigateAdmin(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/flights');
      case 2:
        context.go('/bookings');
      case 3:
        context.go('/profile');
      case 4:
        context.go('/admin'); // Panel de administración
    }
  }
}
