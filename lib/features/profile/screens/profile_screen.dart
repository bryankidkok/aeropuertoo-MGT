import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_routes.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/booking_provider.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/booking_model.dart';
import '../../../shared/models/result_state.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Color _avatarColor(String uid) {
    final hash = uid.hashCode;
    final colors = [
      AppColors.cyan,
      AppColors.blue,
      AppColors.orange,
      AppColors.chipPurple,
      AppColors.chipGreen,
      AppColors.chipYellow,
    ];
    return colors[hash.abs() % colors.length];
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    return name.trim()[0].toUpperCase();
  }

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmado';
      case BookingStatus.checkedIn:
        return 'Check-in';
      case BookingStatus.boarded:
        return 'Abordado';
      case BookingStatus.cancelled:
        return 'Cancelado';
      case BookingStatus.noShow:
        return 'No Show';
    }
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return AppColors.chipGreen;
      case BookingStatus.checkedIn:
        return AppColors.cyan;
      case BookingStatus.boarded:
        return AppColors.chipPurple;
      case BookingStatus.cancelled:
        return AppColors.chipRed;
      case BookingStatus.noShow:
        return AppColors.orange;
    }
  }

  Future<void> _showEditDialog(AuthProvider auth) async {
    final user = auth.user;
    if (user == null) return;

    _nameController.text = user.displayName;
    _phoneController.text = '';

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Text(
          'EDITAR PERFIL',
          style: GoogleFonts.rajdhani(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.gray),
                ),
                style: const TextStyle(color: AppColors.white),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nombre requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.gray),
                ),
                style: const TextStyle(color: AppColors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: AppColors.gray),
            ),
          ),
          TextButton(
            onPressed: _saving
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _saving = true);
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update({'displayName': _nameController.text.trim()});
                      if (ctx.mounted) Navigator.of(ctx).pop(true);
                    } catch (_) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Error al guardar')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _saving = false);
                    }
                  },
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'GUARDAR',
                    style: TextStyle(color: AppColors.cyan),
                  ),
          ),
        ],
      ),
    );

    if (saved == true && mounted) {
      await auth.checkAuthState();
    }
  }

  Future<bool> _confirmSignOut() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            title: Text(
              'CERRAR SESIÓN',
              style: GoogleFonts.rajdhani(
                color: AppColors.chipRed,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: const Text(
              '¿Estás seguro de que deseas cerrar sesión?',
              style: TextStyle(color: AppColors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(
                  'CANCELAR',
                  style: TextStyle(color: AppColors.gray),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'CERRAR SESIÓN',
                  style: TextStyle(color: AppColors.chipRed),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PERFIL')),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.state is Loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cyan),
            );
          }

          if (auth.state is Error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.chipRed,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      auth.errorMessage ?? 'Error desconocido',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.chipRed,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = auth.user;
          if (user == null) {
            return const Center(
              child: Text(
                'Usuario no disponible',
                style: TextStyle(color: AppColors.gray),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              children: [
                _buildAvatarSection(user),
                const SizedBox(height: 24),
                if (user.role == UserRole.passenger)
                  _buildPassengerSection(user.uid),
                if (user.role == UserRole.staff) _buildStaffSection(),
                if (user.role == UserRole.admin) _buildAdminSection(),
                const SizedBox(height: 24),
                _buildButtonsSection(auth),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Widget _buildAvatarSection(UserModel user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: _avatarColor(user.uid),
          child: Text(
            _initials(user.displayName),
            style: GoogleFonts.rajdhani(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.displayName,
          style: GoogleFonts.rajdhani(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.gray),
        ),
        const SizedBox(height: 8),
        Chip(
          label: Text(
            user.role.name.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          backgroundColor: AppColors.cyan,
          side: BorderSide.none,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildPassengerSection(String uid) {
    return Consumer<BookingProvider>(
      builder: (context, bp, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (bp.state is Idle) {
            bp.fetchBookingsByPassenger(uid);
          }
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MIS VUELOS',
              style: GoogleFonts.rajdhani(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.cyan,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            if (bp.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: AppColors.cyan),
                ),
              )
            else if (bp.bookings.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  'No tienes reservas',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: AppColors.gray, fontSize: 14),
                ),
              )
            else
              ...bp.bookings.take(5).map((b) => _buildBookingCard(b)),
          ],
        );
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final dateStr =
        '${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.flightNumber,
                  style: GoogleFonts.rajdhani(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.gray),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor(booking.status).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _statusLabel(booking.status),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _statusColor(booking.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ASIGNACIÓN',
          style: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.cyan,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.settings_outlined,
                color: AppColors.cyan,
                size: 32,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terminal 1',
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Turno: Matutino',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ESTADÍSTICAS',
          style: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.cyan,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('Vuelos', '24', Icons.flight_takeoff),
              _statItem('Pasajeros', '1,280', Icons.people),
              _statItem('Puertas', '12', Icons.meeting_room),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.cyan, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.gray),
        ),
      ],
    );
  }

  Widget _buildButtonsSection(AuthProvider auth) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showEditDialog(auth),
            child: const Text('EDITAR PERFIL'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () async {
              final confirmed = await _confirmSignOut();
              if (confirmed && mounted) {
                await auth.signOut();
                if (mounted) context.go(AppRoutes.login);
              }
            },
            child: Text(
              'CERRAR SESIÓN',
              style: GoogleFonts.inter(
                color: AppColors.chipRed,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
