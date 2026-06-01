import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/admin_provider.dart';
import '../../../shared/models/employee_model.dart';
import '../../../shared/models/result_state.dart';
import 'admin_employee_form_dialog.dart';

class AdminEmployeesListScreen extends StatefulWidget {
  const AdminEmployeesListScreen({super.key});

  @override
  State<AdminEmployeesListScreen> createState() => _AdminEmployeesListScreenState();
}

class _AdminEmployeesListScreenState extends State<AdminEmployeesListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllEmployees();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EmployeeModel> _filter(List<EmployeeModel> employees) {
    if (_searchQuery.isEmpty) return employees;
    final q = _searchQuery.toLowerCase();
    return employees.where((e) {
      return e.firstName.toLowerCase().contains(q) ||
          e.lastName.toLowerCase().contains(q) ||
          e.email.toLowerCase().contains(q) ||
          e.role.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _deleteEmployee(EmployeeModel e) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar Empleado', style: TextStyle(color: AppColors.white)),
        content: Text(
          '¿Eliminar a ${e.fullName}?',
          style: const TextStyle(color: AppColors.gray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR', style: TextStyle(color: AppColors.gray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ELIMINAR', style: TextStyle(color: AppColors.chipRed)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    final ok = await context.read<AdminProvider>().deleteEmployee(e.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Empleado eliminado' : 'Error al eliminar'),
          backgroundColor: ok ? AppColors.chipGreen : AppColors.chipRed,
        ),
      );
    }
  }

  void _openForm({EmployeeModel? employee}) {
    showEmployeeFormDialog(context, employee: employee);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('EMPLEADOS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: AppColors.cyan),
            tooltip: 'AGREGAR',
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, email o rol...',
                prefixIcon: const Icon(Icons.search, color: AppColors.gray),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.gray),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (_, provider, _) {
                final state = provider.employeesState;
                return switch (state) {
                  Loading() => const Center(child: CircularProgressIndicator()),
                  Error(message: final msg) => Center(
                      child: Text(msg, style: const TextStyle(color: AppColors.chipRed)),
                    ),
                  Success(data: final employees) => _buildList(_filter(employees)),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<EmployeeModel> employees) {
    if (employees.isEmpty) {
      return const Center(
        child: Text('No se encontraron empleados', style: TextStyle(color: AppColors.gray)),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<AdminProvider>().fetchAllEmployees(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: employees.length,
        itemBuilder: (_, i) => _buildCard(employees[i]),
      ),
    );
  }

  Widget _buildCard(EmployeeModel e) {
    final roleColor = _roleColor(e.role);
    final roleLabel = _roleLabel(e.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  e.fullName,
                  style: GoogleFonts.rajdhani(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              _statusChip(e.isActive),
            ],
          ),
          const SizedBox(height: 6),
          _infoRow(Icons.email_outlined, e.email),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: roleColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  roleLabel,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: roleColor, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(width: 8),
              if (e.assignedTerminalId != null && e.assignedTerminalId!.isNotEmpty)
                Text(
                  'Terminal: ${e.assignedTerminalId}',
                  style: const TextStyle(fontSize: 12, color: AppColors.gray),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionButton(Icons.edit, AppColors.cyan, () => _openForm(employee: e)),
              const SizedBox(width: 8),
              _actionButton(Icons.delete, AppColors.chipRed, () => _deleteEmployee(e)),
            ],
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.cyan;
      case 'staff':
        return AppColors.chipYellow;
      default:
        return AppColors.chipPurple;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'ADMIN';
      case 'staff':
        return 'STAFF';
      default:
        return role.toUpperCase();
    }
  }

  Widget _statusChip(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: active ? AppColors.chipGreen.withValues(alpha: 0.15) : AppColors.chipRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: active ? AppColors.chipGreen.withValues(alpha: 0.5) : AppColors.chipRed.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        active ? 'ACTIVO' : 'INACTIVO',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: active ? AppColors.chipGreen : AppColors.chipRed,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.gray),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.gray),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
