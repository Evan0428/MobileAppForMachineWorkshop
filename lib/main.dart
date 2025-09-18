import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth.dart';
import 'state.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/job_detail_screen.dart';
import 'screens/sign_off_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GearUpApp());
}

class GearUpApp extends StatelessWidget {
  const GearUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()..load()),
        ChangeNotifierProvider(create: (_) => JobListController()..load()),
      ],
      child: MaterialApp(
        title: 'GearUp Workshop',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF246BFD)),
          appBarTheme: const AppBarTheme(centerTitle: true),
          inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
        ),
        home: const _RootGate(),
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          JobDetailScreen.routeName: (_) => const JobDetailScreen(),
          SignOffScreen.routeName: (_) => const SignOffScreen(),
        },
      ),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (!auth.ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return auth.isLoggedIn ? const DashboardScreen() : const LoginScreen();
  }
}
