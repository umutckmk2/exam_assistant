import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// A custom page transition that provides smooth animations
class FadeTransitionPage extends CustomTransitionPage<void> {
  FadeTransitionPage({required super.child, super.key})
    : super(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          final tween = Tween(begin: begin, end: end);
          final fadeAnimation = tween.animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );
          return FadeTransition(opacity: fadeAnimation, child: child);
        },
      );
}

// A sliding transition that slides and fades content
class SlideTransitionPage extends CustomTransitionPage<void> {
  SlideTransitionPage({required super.child, super.key, Offset? beginOffset})
    : super(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final begin = beginOffset ?? const Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = tween.animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );

          // Combine sliding with fading for smoother effect
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
        // Duration for the transition
        transitionDuration: const Duration(milliseconds: 300),
      );
}

// A scale transition that grows the page into view
class ScaleTransitionPage extends CustomTransitionPage<void> {
  ScaleTransitionPage({required super.child, super.key})
    : super(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final scaleAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          return ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(scaleAnimation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
}
