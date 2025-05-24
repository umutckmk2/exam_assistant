import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_page.dart';
import '../pages/ask_question_page.dart';
import '../pages/cheat_sheets_page.dart';
import '../pages/home_page.dart';
import '../pages/lessons_page.dart';
import '../pages/premium_page.dart';
import '../pages/question_history_page.dart';
import '../pages/question_response_page.dart';
import '../pages/questions_page.dart';
import '../pages/statistics_page.dart';
import '../widgets/safe_area_wrapper.dart';
import 'custom_transitions.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder:
          (context, state) => FadeTransitionPage(
            child: SafeAreaWrapper(child: const HomePage()),
          ),
    ),
    GoRoute(
      path: '/auth',
      pageBuilder:
          (context, state) =>
              NoTransitionPage(child: SafeAreaWrapper(child: const AuthPage())),
    ),
    GoRoute(
      path: '/premium',
      name: 'premium',
      pageBuilder:
          (context, state) => SlideTransitionPage(
            child: SafeAreaWrapper(child: const PremiumPage()),
          ),
    ),
    GoRoute(
      path: '/cheat-sheets',
      name: 'cheat-sheets',
      pageBuilder:
          (context, state) => SlideTransitionPage(
            child: SafeAreaWrapper(child: CheatSheetsPage()),
          ),
    ),
    GoRoute(
      path: '/statistics',
      name: 'statistics',
      pageBuilder:
          (context, state) => SlideTransitionPage(
            child: SafeAreaWrapper(child: const StatisticsPage()),
          ),
    ),
    GoRoute(
      path: '/question-history',
      name: 'question-history',
      pageBuilder:
          (context, state) => SlideTransitionPage(
            child: SafeAreaWrapper(child: const QuestionHistoryPage()),
          ),
    ),
    GoRoute(
      path: '/ask-question',
      name: 'ask-question',
      pageBuilder:
          (context, state) => SlideTransitionPage(
            child: SafeAreaWrapper(child: const AskQuestionPage()),
          ),
    ),
    GoRoute(
      path: '/question-response/:questionId',
      name: 'question-response',
      pageBuilder: (context, state) {
        final questionId = state.pathParameters['questionId'] ?? '';
        return SlideTransitionPage(
          child: SafeAreaWrapper(
            child: QuestionResponsePage(questionId: questionId),
          ),
        );
      },
    ),
    GoRoute(
      path: '/category/:categoryId/lessons',
      name: 'lessons',
      pageBuilder: (context, state) {
        final categoryId = state.pathParameters['categoryId'] ?? '';
        final categoryName = state.pathParameters['categoryName'] ?? '';
        return SlideTransitionPage(
          child: SafeAreaWrapper(
            child: LessonsPage(
              categoryId: categoryId,
              categoryName: categoryName,
            ),
          ),
        );
      },
      routes: [
        GoRoute(
          path: ':lessonId/questions/:topicId/:subTopicId',
          name: 'question',
          pageBuilder: (context, state) {
            final categoryId = state.pathParameters['categoryId'] ?? '';
            final lessonId = state.pathParameters['lessonId'] ?? '';
            final topicId = state.pathParameters['topicId'] ?? '';
            final subTopicId = state.pathParameters['subTopicId'] ?? '';
            return ScaleTransitionPage(
              child: SafeAreaWrapper(
                child: QuestionPage(
                  categoryId: categoryId,
                  lessonId: lessonId,
                  topicId: topicId,
                  subTopicId: subTopicId == 'null' ? null : subTopicId,
                ),
              ),
            );
          },
        ),
      ],
    ),
  ],
  errorBuilder:
      (context, state) => SafeAreaWrapper(
        child: Scaffold(
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
      ),
);
