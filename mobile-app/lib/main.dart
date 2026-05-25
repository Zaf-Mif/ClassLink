import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/otp_screen.dart';
import 'features/courses/presentation/screens/search_screen.dart';
import 'features/courses/presentation/screens/notifications_screen.dart';
import 'injection/injection_container.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Admin Dashboard - Coming Soon')));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const ClassLinkApp());
}

class ClassLinkApp extends StatelessWidget {
  const ClassLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>()..add(CheckAuthStatus()),
      child: MaterialApp(
        title: 'ClassLink',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/otp': (_) => const OtpScreen(email: 'student@astu.edu.et'),
          '/search': (_) => const SearchScreen(),
          '/notifications': (_) => const NotificationsScreen(),
          '/admin-dashboard': (_) => const AdminDashboardScreen(),
        },
      ),
    );
  }
}