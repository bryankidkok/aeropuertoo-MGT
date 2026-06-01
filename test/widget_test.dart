import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:aeropuerto_app/core/theme/app_theme.dart';
import 'package:aeropuerto_app/core/config/app_routes.dart';
import 'package:aeropuerto_app/shared/providers/auth_provider.dart';
import 'package:aeropuerto_app/shared/providers/flight_provider.dart';
import 'package:aeropuerto_app/shared/providers/booking_provider.dart';
import 'package:aeropuerto_app/shared/providers/operations_provider.dart';
import 'package:aeropuerto_app/shared/providers/admin_provider.dart';

void main() {
  testWidgets('App renders without error', (tester) async {
    final authProvider = AuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider(create: (_) => FlightProvider()),
          ChangeNotifierProvider(create: (_) => BookingProvider()),
          ChangeNotifierProvider(create: (_) => OperationsProvider()),
          ChangeNotifierProvider(create: (_) => AdminProvider()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark,
          routerConfig: AppRoutes.createRouter(authProvider),
        ),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
