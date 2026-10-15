import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login/login_screen.dart';
import '../../screens/auth/register/register_screen.dart';
import '../../screens/auth/forgot_password/forgot_password_screen.dart';
import '../../screens/auth/forgot_password/password_reset_success_screen.dart';
import '../../screens/citizen/citizen_shell_screen.dart';
import '../../screens/citizen/report/report_wizard_screen.dart';
import '../../screens/citizen/complaint_details/citizen_complaint_details_screen.dart';
import '../../screens/citizen/resolution/resolution_details_screen.dart';
import '../../screens/citizen/notifications/notifications_screen.dart';
import '../../screens/citizen/profile/edit_profile_screen.dart';
import '../../screens/citizen/profile/settings_screen.dart';
import '../../screens/officer/officer_shell_screen.dart';
import '../../screens/officer/complaint/officer_complaint_details_screen.dart';
import '../../screens/officer/resolution/complete_resolution_screen.dart';
import '../../screens/officer/map/officer_map_screen.dart';
import '../../screens/officer/notifications/officer_notifications_screen.dart';
import '../../screens/admin/admin_shell_screen.dart';
import '../../screens/admin/complaints/admin_complaint_details_screen.dart';
import '../../screens/admin/departments/department_details_screen.dart';
import '../../screens/admin/users/user_details_screen.dart';
import '../../screens/admin/analytics/city_analytics_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/auth/splash',
  routes: [
    // --- AUTHENTICATION & ONBOARDING ---
    GoRoute(
      path: '/auth/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/auth/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/auth/reset-success',
      builder: (context, state) => const PasswordResetSuccessScreen(),
    ),

    // --- CITIZEN PORTAL ---
    GoRoute(
      path: '/citizen',
      builder: (context, state) => const CitizenShellScreen(initialTab: 0),
    ),
    GoRoute(
      path: '/citizen/map',
      builder: (context, state) => const CitizenShellScreen(initialTab: 1),
    ),
    GoRoute(
      path: '/citizen/my-reports',
      builder: (context, state) => const CitizenShellScreen(initialTab: 2),
    ),
    GoRoute(
      path: '/citizen/notifications',
      builder: (context, state) => const CitizenNotificationsScreen(),
    ),
    GoRoute(
      path: '/citizen/profile',
      builder: (context, state) => const CitizenShellScreen(initialTab: 4),
    ),
    GoRoute(
      path: '/citizen/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/citizen/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/citizen/report/step-1',
      builder: (context, state) => const ReportWizardScreen(initialStep: 1),
    ),
    GoRoute(
      path: '/citizen/complaint/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'CP-88492';
        return CitizenComplaintDetailsScreen(complaintId: id);
      },
    ),
    GoRoute(
      path: '/citizen/complaint/:id/resolution',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'CP-88492';
        return ResolutionDetailsScreen(complaintId: id);
      },
    ),

    // --- OFFICER PORTAL ---
    GoRoute(
      path: '/officer',
      builder: (context, state) => const OfficerShellScreen(initialTab: 0),
    ),
    GoRoute(
      path: '/officer/assigned',
      builder: (context, state) => const OfficerShellScreen(initialTab: 1),
    ),
    GoRoute(
      path: '/officer/map',
      builder: (context, state) {
        final complaintId = state.uri.queryParameters['complaintId'];
        return OfficerMapScreen(initialComplaintId: complaintId);
      },
    ),
    GoRoute(
      path: '/officer/alerts',
      builder: (context, state) => const OfficerNotificationsScreen(),
    ),
    GoRoute(
      path: '/officer/profile',
      builder: (context, state) => const OfficerShellScreen(initialTab: 4),
    ),
    GoRoute(
      path: '/officer/complaint/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'CP-88492';
        return OfficerComplaintDetailsScreen(complaintId: id);
      },
    ),
    GoRoute(
      path: '/officer/resolve/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'CP-88492';
        return CompleteResolutionScreen(complaintId: id);
      },
    ),

    // --- ADMIN PORTAL ---
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminShellScreen(initialTab: 0),
    ),
    GoRoute(
      path: '/admin/complaints',
      builder: (context, state) => const AdminShellScreen(initialTab: 1),
    ),
    GoRoute(
      path: '/admin/complaint/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'CP-88492';
        return AdminComplaintDetailsScreen(complaintId: id);
      },
    ),
    GoRoute(
      path: '/admin/department/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'dept_roads';
        return DepartmentDetailsScreen(departmentId: id);
      },
    ),
    GoRoute(
      path: '/admin/user/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'user_1';
        return UserDetailsScreen(userId: id);
      },
    ),
    GoRoute(
      path: '/admin/analytics',
      builder: (context, state) => const CityAnalyticsScreen(),
    ),
  ],
);
