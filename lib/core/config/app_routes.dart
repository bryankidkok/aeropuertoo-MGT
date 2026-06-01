import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/flights/screens/home_screen.dart';
import '../../features/flights/screens/flight_detail_screen.dart';
import '../../features/flights/screens/search_results_screen.dart';
import '../../features/bookings/screens/create_booking_screen.dart';
import '../../features/bookings/screens/my_bookings_screen.dart';
import '../../features/bookings/screens/checkin_screen.dart';
import '../../features/operations/screens/operations_dashboard_screen.dart';
import '../../features/operations/screens/gates_management_screen.dart';
import '../../features/operations/screens/incidents_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/screens/notifications_screen.dart';
import '../../shared/screens/splash_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_flights_list_screen.dart';
import '../../features/admin/screens/admin_airlines_list_screen.dart';
import '../../features/admin/screens/admin_aircrafts_list_screen.dart';
import '../../features/admin/screens/admin_gates_list_screen.dart';
import '../../features/admin/screens/admin_terminals_list_screen.dart';
import '../../features/admin/screens/admin_passengers_list_screen.dart';
import '../../features/admin/screens/admin_employees_list_screen.dart';
import '../../features/admin/screens/admin_maintenance_list_screen.dart';
import '../../features/admin/screens/admin_reports_screen.dart';
import '../../features/admin/screens/admin_settings_screen.dart';
import '../../features/admin/screens/admin_users_list_screen.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/result_state.dart';

abstract class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String register = '/register';
  static const String home = '/home';
  static const String flights = '/flights';
  static const String flightDetail = '/flights/:id';
  static const String bookings = '/bookings';
  static const String createBooking = '/bookings/create/:flightId';
  static const String bookingDetail = '/bookings/:id';
  static const String checkin = '/checkin';
  static const String operations = '/operations';
  static const String admin = '/admin';
  static const String adminFlights = '/admin/flights';
  static const String adminAirlines = '/admin/airlines';
  static const String adminAircrafts = '/admin/aircrafts';
  static const String adminGates = '/admin/gates';
  static const String adminTerminals = '/admin/terminals';
  static const String adminPassengers = '/admin/passengers';
  static const String adminEmployees = '/admin/employees';
  static const String adminMaintenance = '/admin/maintenance';
  static const String adminReports = '/admin/reports';
  static const String adminSettings = '/admin/settings';
  static const String adminUsers = '/admin/users';
  static const String gates = '/gates';
  static const String incidents = '/incidents';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      refreshListenable: authProvider,
      initialLocation: splash,
      redirect: (context, state) {
        final location = state.uri.path;
        final state_ = authProvider.state;

        if (state_ is Loading) return null;

        if (state_ is Idle || state_ is Error) {
          if (location == login ||
              location == register ||
              location == forgotPassword)
            return null;
          return login;
        }

        final role = authProvider.user!.role;
        final isAuthRoute =
            location == login ||
            location == register ||
            location == forgotPassword;

        if (location == splash || isAuthRoute) return home;

        if (location.startsWith('/admin') && role != UserRole.admin)
          return home;
        if (role == UserRole.passenger &&
            (location == operations ||
                location == '/gates' ||
                location == '/incidents'))
          return home;

        return null;
      },
      routes: [
        GoRoute(
          path: splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: forgotPassword,
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: register,
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: flights,
          name: 'flights',
          builder: (context, state) => const SearchResultsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              name: 'flightDetail',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return FlightDetailScreen(flightId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: bookings,
          name: 'bookings',
          builder: (context, state) => const MyBookingsScreen(),
        ),
        GoRoute(
          path: '/bookings/create/:flightId',
          name: 'createBooking',
          builder: (context, state) {
            final flightId = state.pathParameters['flightId'] ?? '';
            return CreateBookingScreen(flightId: flightId);
          },
        ),
        GoRoute(
          path: '/bookings/:id',
          name: 'bookingDetail',
          builder: (context, state) => const MyBookingsScreen(),
        ),
        GoRoute(
          path: checkin,
          name: 'checkin',
          builder: (context, state) => const CheckinScreen(),
        ),
        GoRoute(
          path: operations,
          name: 'operations',
          builder: (context, state) => const OperationsDashboardScreen(),
        ),
        GoRoute(
          path: '/gates',
          name: 'gates',
          builder: (context, state) => const GatesManagementScreen(),
        ),
        GoRoute(
          path: '/incidents',
          name: 'incidents',
          builder: (context, state) => const IncidentsScreen(),
        ),
        GoRoute(
          path: admin,
          name: 'admin',
          builder: (context, state) => const AdminDashboardScreen(),
          routes: [
            GoRoute(
              path: 'flights',
              name: 'adminFlights',
              builder: (context, state) => const AdminFlightsListScreen(),
            ),
            GoRoute(
              path: 'airlines',
              name: 'adminAirlines',
              builder: (context, state) => const AdminAirlinesListScreen(),
            ),
            GoRoute(
              path: 'aircrafts',
              name: 'adminAircrafts',
              builder: (context, state) => const AdminAircraftsListScreen(),
            ),
            GoRoute(
              path: 'gates',
              name: 'adminGates',
              builder: (context, state) => const AdminGatesListScreen(),
            ),
            GoRoute(
              path: 'terminals',
              name: 'adminTerminals',
              builder: (context, state) => const AdminTerminalsListScreen(),
            ),
            GoRoute(
              path: 'passengers',
              name: 'adminPassengers',
              builder: (context, state) => const AdminPassengersListScreen(),
            ),
            GoRoute(
              path: 'employees',
              name: 'adminEmployees',
              builder: (context, state) => const AdminEmployeesListScreen(),
            ),
            GoRoute(
              path: 'maintenance',
              name: 'adminMaintenance',
              builder: (context, state) => const AdminMaintenanceListScreen(),
            ),
            GoRoute(
              path: 'reports',
              name: 'adminReports',
              builder: (context, state) => const AdminReportsScreen(),
            ),
            GoRoute(
              path: 'settings',
              name: 'adminSettings',
              builder: (context, state) => const AdminSettingsScreen(),
            ),
            GoRoute(
              path: 'users',
              name: 'adminUsers',
              builder: (context, state) => const AdminUsersListScreen(),
            ),
          ],
        ),
        GoRoute(
          path: profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],
    );
  }
}
