import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:office_management/features/login/pages/login_page.dart';
import 'package:office_management/features/login/pages/signup_page.dart';
import 'package:office_management/features/login/pages/auth_page.dart';
import 'package:office_management/features/dashboard/pages/dashboard_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      themeMode: ThemeMode.light,
      appBuilder: (context) {
        return MaterialApp(
          theme: Theme.of(context),
          initialRoute: '/auth',
          routes: {
            '/auth': (context) => const AuthPage(),
            '/login': (context) => const LoginPage(),
            '/signup': (context) => const SignupPage(),
            '/dashboard': (context) => const DashboardPage(),
          },
          builder: (context, child) {
            return ShadAppBuilder(child: child);
          },
        );
      },
    );
  }
}
