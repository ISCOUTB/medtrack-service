import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/medication_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_medication_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, MedicationService>(
          create: (ctx) => MedicationService(null, null),
          update: (ctx, auth, previous) =>
              MedicationService(auth.token, auth.userId),
        ),
      ],
      child: Consumer<AuthService>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MedTrack',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              primary: Colors.teal,
              secondary: Colors.tealAccent,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.teal, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            cardTheme: const CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              color: Colors.white,
              surfaceTintColor: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              centerTitle: true,
              elevation: 0,
            ),
          ),
          home: auth.isAuthenticated
              ? const HomeScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                          ConnectionState.waiting
                      ? const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        )
                      : const LoginScreen(),
                ),
          routes: {
            LoginScreen.routeName: (ctx) => const LoginScreen(),
            RegisterScreen.routeName: (ctx) => const RegisterScreen(),
            AddMedicationScreen.routeName: (ctx) => const AddMedicationScreen(),
          },
        ),
      ),
    );
  }
}
