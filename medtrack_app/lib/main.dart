import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/state/auth_provider.dart';
import 'core/api_service.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'med_list_screen.dart';

void main() {
  runApp(const MedTrackApp());
}

class MedTrackApp extends StatelessWidget {
  const MedTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(api)..restoreSession(),
        ),
      ],
      child: MaterialApp(
        title: "MedTrack",
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        initialRoute: "/login",
        routes: {
          "/login": (_) => const LoginScreen(),
          "/register": (_) => const RegisterScreen(),
          "/meds": (_) => const MedListScreen(),
        },
      ),
    );
  }
}
