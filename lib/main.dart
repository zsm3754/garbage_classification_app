import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_page.dart';
import 'screens/home/home_page.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const GarbageApp(),
    ),
  );
}

class GarbageApp extends StatelessWidget {
  const GarbageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MaterialApp(
          title: '绿意分类',
          theme: ThemeData(
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            useMaterial3: true,
          ),
          home: authProvider.isAuthenticated ? const MainNavigation() : const LoginPage(),
        );
      },
    );
  }
}
