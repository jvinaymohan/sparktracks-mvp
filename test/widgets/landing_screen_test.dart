import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sparktracks_mvp/providers/auth_provider.dart';
import 'package:sparktracks_mvp/screens/landing/landing_screen.dart';

void main() {
  group('Landing Screen Widget Tests', () {
    testWidgets('Landing screen should display welcome message', (WidgetTester tester) async {
      // Create a mock AuthProvider
      final authProvider = AuthProvider();

      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LandingScreen(),
          ),
        ),
      );

      // Verify that welcome text appears
      expect(find.textContaining('Welcome'), findsOneWidget);
    });

    testWidgets('Landing screen should have Sign Up button', (WidgetTester tester) async {
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LandingScreen(),
          ),
        ),
      );

      // Verify Sign Up button exists
      expect(find.textContaining('Sign Up'), findsWidgets);
    });

    testWidgets('Landing screen should have Login button', (WidgetTester tester) async {
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LandingScreen(),
          ),
        ),
      );

      // Verify Login button exists
      expect(find.textContaining('Login'), findsWidgets);
    });

    testWidgets('Landing screen should display app name', (WidgetTester tester) async {
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LandingScreen(),
          ),
        ),
      );

      // Verify app name appears
      expect(find.textContaining('Sparktracks'), findsWidgets);
    });

    testWidgets('Landing screen should be scrollable', (WidgetTester tester) async {
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
            child: const LandingScreen(),
          ),
        ),
      );

      // Verify scrollable widget exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}

