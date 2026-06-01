import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'core/services/firebase_service.dart';
import 'core/config/app_routes.dart';
import 'core/config/seed_data.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/flight_provider.dart';
import 'shared/providers/booking_provider.dart';
import 'shared/providers/operations_provider.dart';
import 'shared/providers/admin_provider.dart';
import 'shared/providers/notifications_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D0D),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await initializeDateFormatting('es', null);

  final firebaseReady = await FirebaseService().initialize();

  if (kDebugMode && firebaseReady) {
    try {
      await seedFirestoreData();
    } catch (e) {
      debugPrint('Seed data error (non-fatal): $e');
    }
  }

  runApp(AeropuertoApp(firebaseReady: firebaseReady));
}

class AeropuertoApp extends StatelessWidget {
  final bool firebaseReady;

  const AeropuertoApp({super.key, required this.firebaseReady});

  @override
  Widget build(BuildContext context) {
    if (!firebaseReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: _FirebaseErrorScreen(),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FlightProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => OperationsProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
      ],
      child: _AppEntry(),
    );
  }
}

class _AppEntry extends StatefulWidget {
  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRoutes.createRouter(context.read<AuthProvider>());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: MaterialApp.router(
        title: 'Aeropuerto MGT',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: _router,
      ),
    );
  }
}

class _FirebaseErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, color: Color(0xFFFF6B35), size: 64),
              const SizedBox(height: 20),
              Text(
                'Error de Configuración',
                style: GoogleFonts.rajdhani(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No se pudo conectar con Firebase.\n'
                'Asegúrate de haber colocado google-services.json\n'
                'o GoogleService-Info.plist en las carpetas correctas.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFFA0A0A0),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
