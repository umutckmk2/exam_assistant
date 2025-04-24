import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:osym/service/auth_service.dart';

import 'auth/auth_page.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'service/open_ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize OpenAI service
  await OpenAiService().initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();

  await Hive.openBox("settings");

  initializeDateFormatting('tr_TR');

  // Set preferred orientations to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'KPSS AI Asistan',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              useMaterial3: true,
            ),
            routerConfig: appRouter,
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'KPSS AI Asistan',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
          ),
          home: const AuthPage(),
        );
      },
    );
  }
}
