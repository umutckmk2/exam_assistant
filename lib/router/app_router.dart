import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_page.dart';
import '../pages/home_page.dart';
import '../pages/lessons_page.dart';
import '../pages/my_account_page.dart';
import '../pages/question_page.dart';
import '../pages/statistics_page.dart';
import '../pages/topics_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/auth',
      pageBuilder:
          (context, state) => const NoTransitionPage(child: AuthPage()),
    ),
    GoRoute(
      path: '/account',
      name: 'account',
      builder: (context, state) => const MyAccountPage(),
    ),
    GoRoute(
      path: '/question/:categoryId/:lessonId/:topicId',
      name: 'question',
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId'] ?? '';
        final lessonId = state.pathParameters['lessonId'] ?? '';
        final topicId = state.pathParameters['topicId'] ?? '';
        return QuestionPage(
          categoryId: categoryId,
          lessonId: lessonId,
          topicId: topicId,
        );
      },
    ),
    GoRoute(
      path: '/statistics',
      name: 'statistics',
      builder: (context, state) => const StatisticsPage(),
    ),
    GoRoute(
      path: '/category/:categoryId/lessons',
      name: 'lessons',
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId'] ?? '';
        final categoryName = state.pathParameters['categoryName'] ?? '';
        return LessonsPage(categoryId: categoryId, categoryName: categoryName);
      },
    ),
    GoRoute(
      path: '/category/:categoryId/lessons/:lessonId/topics',
      name: 'topics',
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId'] ?? '';
        final lessonId = state.pathParameters['lessonId'] ?? '';
        return TopicsPage(categoryId: categoryId, lessonId: lessonId);
      },
    ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Sayfa bulunamadı!', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ana Sayfaya Dön'),
              ),
            ],
          ),
        ),
      ),
);
