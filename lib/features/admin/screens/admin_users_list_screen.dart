import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/admin_provider.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/result_state.dart';
import 'admin_user_form_dialog.dart';

class AdminUsersListScreen extends StatefulWidget {
  const AdminUsersListScreen({super.key});

  @override
  State<AdminUsersListScreen> createState() => _AdminUsersListScreenState();
}

class _AdminUsersListScreenState extends State<AdminUsersListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  UserRole? _filterRole;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> _filter(List<UserModel> users) {
    var list = users;
    if (_filterRole != null) {
      list = list.where((u) => u.role == _filterRole).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((u) {
        return u.displayName.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  Color _roleColor(UserRole r) {
    switch (r) {
      case UserRole.admin:
        return AppColors.chipRed;
      case UserRole.staff:
        return AppColors.cyan;
      case UserRole.passenger:
        return AppColors.gray;
    }
  }

  String _roleLabel(UserRole r) {
    switch (r) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.staff:
        return 'Personal';
      case UserRole.passenger:
        return 'Pasajero';
    }
  }

  IconData _roleIcon(UserRole r) {
    switch (r) {
      case UserRole.admin:
        return Icons.shield;
      case UserRole.staff:
        return Icons.badge;
      case UserRole.passenger:
        return Icons.person;
    }
  }

  Future<void> _createUser() async {
    final provider = context.read<AdminProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final result = await showUserFormDialog(context);
    if (result == null || !mounted) return;

    setState(() => _isCreating = true);

    final ok = await provider.createUser(
      result.email,
      result.password,
      result.displayName,
      result.role,
    );

    if (!mounted) return;
    setState(() => _isCreating = false);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Usuario creado exitosamente' : 'Error al crear usuario',
        ),
        backgroundColor: ok ? AppColors.chipGreen : AppColors.chipRed,
      ),
    );
  }

  Future<void> _editUser(UserModel user) async {
    final provider = context.read<AdminProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final result = await showUserFormDialog(context, user: user);
    if (result == null || !mounted) return;

    final updated = user.copyWith(
      displayName: result.displayName,
      role: result.role,
      isActive: result.isActive,
    );

    final ok = await provider.updateUser(updated);
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Usuario actualizado' : 'Error al actualizar'),
        backgroundColor: ok ? AppColors.chipGreen : AppColors.chipRed,
      ),
    );
  }

  Future<void> _deleteUser(UserModel user) async {
    final provider = context.read<AdminProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Eliminar Usuario',
          style: TextStyle(color: AppColors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Eliminar a ${user.displayName}?',
              style: const TextStyle(color: AppColors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta acción eliminará el registro del usuario en la base de datos. '
              'La cuenta de autenticación permanecerá activa.',
              style: TextStyle(color: AppColors.gray, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: AppColors.gray),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'ELIMINAR',
              style: TextStyle(color: AppColors.chipRed),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await provider.deleteUser(user.uid);
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Usuario eliminado' : 'Error al eliminar'),
        backgroundColor: ok ? AppColors.chipGreen : AppColors.chipRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('GESTIÓN DE USUARIOS')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isCreating ? null : _createUser,
        backgroundColor: _isCreating ? AppColors.gray : AppColors.cyan,
        foregroundColor: AppColors.black,
        icon: _isCreating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.black,
                ),
              )
            : const Icon(Icons.person_add),
        label: Text(
          _isCreating ? 'CREANDO...' : 'NUEVO USUARIO',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: AppColors.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o email...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.gray),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.gray,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  style: const TextStyle(color: AppColors.white),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 8),
                // Filtros por rol
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('Todos', null),
                      const SizedBox(width: 8),
                      _filterChip('Admin', UserRole.admin),
                      const SizedBox(width: 8),
                      _filterChip('Personal', UserRole.staff),
                      const SizedBox(width: 8),
                      _filterChip('Pasajeros', UserRole.passenger),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Lista
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, _) {
                final state = provider.usersState;

                if (state is Loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is Error) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.chipRed,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          (state as Error).message,
                          style: const TextStyle(color: AppColors.gray),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => provider.fetchAllUsers(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is! Success<List<UserModel>>) {
                  return const SizedBox.shrink();
                }

                final filtered = _filter(
                  (state as Success<List<UserModel>>).data,
                );

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          color: AppColors.gray,
                          size: 64,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty || _filterRole != null
                              ? 'Sin resultados'
                              : 'No hay usuarios registrados',
                          style: const TextStyle(color: AppColors.gray),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchAllUsers(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _buildUserCard(filtered[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, UserRole? role) {
    final selected = _filterRole == role;
    return GestureDetector(
      onTap: () => setState(() => _filterRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.cyan.withValues(alpha: 0.15)
              : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.cyan : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.cyan : AppColors.gray,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final roleColor = _roleColor(user.role);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: roleColor.withValues(alpha: 0.15),
              child: Icon(_roleIcon(user.role), color: roleColor, size: 22),
            ),
            if (!user.isActive)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.chipRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.card, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.displayName.isEmpty ? '(Sin nombre)' : user.displayName,
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: roleColor.withValues(alpha: 0.4)),
              ),
              child: Text(
                _roleLabel(user.role),
                style: TextStyle(
                  color: roleColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 12,
                  color: AppColors.gray,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    user.email,
                    style: const TextStyle(color: AppColors.gray, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  user.isActive ? Icons.check_circle : Icons.block,
                  size: 12,
                  color: user.isActive
                      ? AppColors.chipGreen
                      : AppColors.chipRed,
                ),
                const SizedBox(width: 4),
                Text(
                  user.isActive ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    color: user.isActive
                        ? AppColors.chipGreen
                        : AppColors.chipRed,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.cyan,
                size: 20,
              ),
              tooltip: 'Editar',
              onPressed: () => _editUser(user),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.chipRed,
                size: 20,
              ),
              tooltip: 'Eliminar',
              onPressed: () => _deleteUser(user),
            ),
          ],
        ),
      ),
    );
  }
}
