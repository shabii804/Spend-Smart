import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:spendsmart/screens/forgot_password_screen.dart';
import 'package:spendsmart/screens/login_screen.dart';
import 'package:spendsmart/screens/register_screen.dart';
import 'package:spendsmart/providers/user_provider.dart';

void main() {
  testWidgets('LoginScreen pumps without crashing', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('RegisterScreen pumps without crashing', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Create Account'), findsWidgets);
  });

  testWidgets('ForgotPasswordScreen pumps without crashing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ForgotPasswordScreen(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Reset Password'), findsOneWidget);
  });
}
