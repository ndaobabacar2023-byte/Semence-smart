import 'package:flutter_test/flutter_test.dart';
import 'package:agriadvisor/src/app.dart';
import 'package:agriadvisor/screens/splash_screen.dart';
import 'package:agriadvisor/screens/type_culture_screen.dart';

void main() {
  testWidgets('AgriAdvisor app has a title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final titleFinder = find.text('AgriAdvisor');
    expect(titleFinder, findsOneWidget);
  });

  testWidgets('Splash screen is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('Login screen is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final loginButtonFinder = find.text('Se connecter');
    expect(loginButtonFinder, findsOneWidget);
  });

  testWidgets('TypeCultureScreen is displayed after login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Simulate a login action
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.byType(TypeCultureScreen), findsOneWidget);
  });
}
