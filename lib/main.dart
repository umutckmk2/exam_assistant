import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'auth/auth_page.dart';
import 'firebase_options.dart';
import 'model/app_user.dart';
import 'router/app_router.dart';
import 'service/ad_service.dart';
import 'service/auth_service.dart';
import 'service/goals_service.dart';
import 'service/notification_service.dart';
import 'service/open_ai_service.dart';
import 'service/premium_service.dart';
import 'service/user_service.dart';
import 'widgets/app_splash_screen.dart';

///ca-app-pub-5309874269430815~9068794476
///ca-app-pub-5309874269430815/7235696418
void main() async {
  // Preserve splash screen until initialization is complete
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Load environment variables
  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();

  await Hive.openBox("settings");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize OpenAI service
  await OpenAiService().initialize();

  // Initialize Google Mobile Ads
  await AdService.instance.initialize();

  // Initialize notifications
  await NotificationService().initialize();

  initializeDateFormatting('tr_TR');

  // Set preferred orientations to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Remove splash screen when initialization is done
  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

final userNotifier = ValueNotifier<AppUser?>(null);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Register app lifecycle events observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove app lifecycle event observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check if the user is authenticated
      final currentUser = AuthService().currentUser;
      if (currentUser != null) {
        // Verify subscription status and reschedule notification
        _verifySubscriptionAndRescheduleNotification(currentUser.uid);
      }
    }
  }

  Future<void> _verifySubscriptionAndRescheduleNotification(
    String userId,
  ) async {
    try {
      // Verify subscription status
      await PremiumService.instance.verifySubscriptionStatus(userId);

      // Reschedule notification
      final dailyGoal = await GoalsService.instance.getTodayGoal();
      await NotificationService().scheduleDailyGoalReminder(dailyGoal);
    } catch (e) {
      debugPrint(
        'Error verifying subscription and rescheduling notification: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, userSnapshot) {
        if (userSnapshot.hasData && userSnapshot.data != null) {
          return FutureBuilder(
            future: Future.microtask(() async {
              final userId = AuthService().currentUser!.uid;

              final user = await UserService().getUserDetails(userId);

              await GoalsService.instance.saveMissingRecords();

              // Schedule notification for daily goal
              final dailyGoal = await GoalsService.instance.getTodayGoal();
              await NotificationService().scheduleDailyGoalReminder(dailyGoal);

              return user;
            }),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                userNotifier.value = snapshot.data;
                return ValueListenableBuilder(
                  valueListenable: userNotifier,
                  builder: (_, user, __) {
                    return FutureBuilder(
                      future: PremiumService.instance.verifySubscriptionStatus(
                        userSnapshot.data!.uid,
                      ),
                      builder: (_, premiumSnapshot) {
                        print("premiumSnapshot: ${premiumSnapshot.data}");

                        return MaterialApp.router(
                          debugShowCheckedModeBanner: false,
                          title: 'YKS Asistan',
                          theme: ThemeData(
                            colorScheme: ColorScheme.fromSeed(
                              seedColor: Colors.green,
                            ),
                            useMaterial3: true,
                          ),
                          routerConfig: appRouter,
                        );
                      },
                    );
                  },
                );
              }
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'YKS Asistan',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
                  useMaterial3: true,
                ),
                home: const AppSplashScreen(),
              );
            },
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'YKS Asistan',
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
