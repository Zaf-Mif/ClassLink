import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/courses/presentation/screens/student_home_screen.dart';
import 'features/courses/presentation/screens/teacher_home_screen.dart';
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
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is AuthAuthenticated) {
              switch (state.user.role) {
                case 'student':
                  return StudentHomeScreen(user: state.user);
                case 'teacher':
                  return TeacherHomeScreen(user: state.user);
                case 'admin':
                  return const AdminDashboardScreen();
              }
            }
            return const LoginScreen();
          },
        ),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/admin-dashboard': (_) => const AdminDashboardScreen(),
        },
      ),
    );
  }
}