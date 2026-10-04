import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/features/auth/domain/auth_state.dart';
import 'package:todo_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:todo_app/features/auth/presentation/screens/login_screen.dart';
import 'package:todo_app/widgets/custom_button.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state).thenReturn(const Unauthenticated());
    when(() => mockAuthCubit.stream).thenAnswer((_) => Stream.value(const Unauthenticated()));
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: mockAuthCubit,
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('renders email, password, and sign in button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(CustomButton), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('empty fields show validation error messages on submit', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap Sign In button without entering any values
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Email address is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });
  });
}
