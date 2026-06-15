import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:expense_user/view_models/auth_view_model.dart';
import 'package:expense_user/views/auth/login_screen.dart';
import 'package:expense_user/views/auth/register_screen.dart';

class FakeAuthViewModel extends ChangeNotifier implements AuthViewModel {
  @override
  bool get isLoading {
    return false;
  }

  @override
  String? get error {
    return null;
  }

  @override
  Future<bool> login(String email, String password) async {
    return true;
  }

  @override
  Future<bool> register(String email, String password) async {
    return true;
  }

  @override
  Future<void> logout() async {}
}

void main() {
  Widget buildTestApp(Widget child) {
    return ChangeNotifierProvider<AuthViewModel>.value(
      value: FakeAuthViewModel(),
      child: MaterialApp(home: child),
    );
  }

  testWidgets('Login screen shows Coming soon snackbar from Forgot password button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp(const LoginScreen()));

    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);

    await tester.tap(find.text('Forgot password?'));
    await tester.pump();

    expect(find.text('Coming soon'), findsOneWidget);
  });

  testWidgets('Password visibility toggle works on login and register screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp(const LoginScreen()));

    Checkbox rememberCheckbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(rememberCheckbox.value, isFalse);

    await tester.tap(find.text('Remember me'));
    await tester.pump();

    rememberCheckbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(rememberCheckbox.value, isTrue);

    Finder loginPasswordFieldFinder = find.byType(TextField).at(1);
    TextField loginPasswordField = tester.widget<TextField>(loginPasswordFieldFinder);
    expect(loginPasswordField.obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    loginPasswordField = tester.widget<TextField>(loginPasswordFieldFinder);
    expect(loginPasswordField.obscureText, isFalse);

    await tester.pumpWidget(buildTestApp(const RegisterScreen()));
    await tester.pumpAndSettle();

    Finder registerPasswordFieldFinder = find.byType(TextField).at(1);
    TextField registerPasswordField = tester.widget<TextField>(registerPasswordFieldFinder);
    expect(registerPasswordField.obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    registerPasswordField = tester.widget<TextField>(registerPasswordFieldFinder);
    expect(registerPasswordField.obscureText, isFalse);
  });
}
