import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arab_tili_for_d/app.dart';
import 'package:arab_tili_for_d/data/local_learning_store.dart';
import 'package:arab_tili_for_d/screens/home/today_tab.dart';
import 'package:arab_tili_for_d/screens/lesson/lesson_screen.dart';
import 'package:arab_tili_for_d/screens/lesson/mcq_question.dart';

Future<LocalLearningStore> _createStore() async {
  SharedPreferences.setMockInitialValues({});
  return LocalLearningStore(await SharedPreferences.getInstance());
}

void _setPhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
}

Future<void> _launchApp(WidgetTester tester, LocalLearningStore store) async {
  await tester.pumpWidget(ArabTiliApp(store: store));
  await tester.pump(const Duration(seconds: 3));
  await _pumpUi(tester);
}

Future<void> _pumpUi(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _centerOn(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pump();
  await _pumpUi(tester);
}

void main() {
  test(
    'the default learner name is Malikam, including the old default',
    () async {
      SharedPreferences.setMockInitialValues({'learnerName': 'Do‘stim'});
      final store = LocalLearningStore(await SharedPreferences.getInstance());

      expect(store.learnerName, 'Malikam');
    },
  );

  testWidgets('words and weekly report fit a phone screen', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    final store = await _createStore();
    await _launchApp(tester, store);

    await tester.tap(find.byIcon(Icons.style_outlined));
    await _pumpUi(tester);
    expect(find.text("So'zlar olami"), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Yutuqlar'));
    await _pumpUi(tester);
    expect(find.text('Haftalik hisobot'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('name and theme are saved on this device', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    final store = await _createStore();
    await _launchApp(tester, store);

    expect(find.text('Assalomu alaykum, Malikam! 🌸'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await _pumpUi(tester);
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField), 'Zuhra');
    await tester.tap(find.text('Saqlash'));
    await _pumpUi(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Assalomu alaykum, Zuhra! 🌸'), findsOneWidget);
    expect(store.learnerName, 'Zuhra');

    await tester.tap(find.byTooltip('Qorong‘i rejim'));
    await _pumpUi(tester);
    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Yorug‘ rejim'), findsOneWidget);
    expect(store.isDarkMode, isTrue);
  });

  testWidgets(
    'daily learning saves mistakes, rewards once, and reviews due words',
    (WidgetTester tester) async {
      _setPhoneSize(tester);
      final store = await _createStore();
      await _launchApp(tester, store);

      final startLessonFinder = find.text('Boshlash ✨');
      await tester.scrollUntilVisible(
        startLessonFinder,
        500,
        scrollable: find
            .descendant(
              of: find.byType(TodayTab),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await _centerOn(tester, startLessonFinder);
      final startButtonFinder = find.ancestor(
        of: startLessonFinder,
        matching: find.byType(FilledButton),
      );
      expect(
        tester.widget<FilledButton>(startButtonFinder).onPressed,
        isNotNull,
      );
      await tester.tap(startButtonFinder);
      await tester.pump();
      await _pumpUi(tester);
      expect(find.byType(LessonScreen), findsOneWidget);
      final session = tester.widget<LessonScreen>(find.byType(LessonScreen));
      final questions = session.questions;
      expect(questions, isNotEmpty);

      final firstQuestion = questions.first;
      final wrongAnswer = firstQuestion.options.firstWhere(
        (option) => option != firstQuestion.correctAnswer,
      );
      await tester.tap(find.text(wrongAnswer));
      await tester.pump(const Duration(milliseconds: 250));
      expect(store.mistakeCount, 1);
      expect(find.text('Sal qoldi! 🌱'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 400));

      while (find.byType(McqQuestion).evaluate().isNotEmpty) {
        final currentQuestion = tester
            .widget<McqQuestion>(find.byType(McqQuestion))
            .question;
        await tester.tap(find.text(currentQuestion.correctAnswer));
        await tester.pump(const Duration(milliseconds: 1200));
        await tester.pump(const Duration(milliseconds: 350));
      }

      expect(store.completedToday, isTrue);
      expect(store.learnedWordIds, containsAll(questions.map((q) => q.id)));
      expect(store.streakDays, 1);
      expect(store.totalXp, 20 * questions.length);
      expect(find.text('Darsni muvaffaqiyatli tugatdingiz!'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey =
          '${today.year.toString().padLeft(4, '0')}-'
          '${today.month.toString().padLeft(2, '0')}-'
          '${today.day.toString().padLeft(2, '0')}';
      await prefs.setString(
        'reviewSchedule',
        jsonEncode({firstQuestion.id: todayKey}),
      );

      await tester.tap(find.text('Uyga qaytish'));
      await _pumpUi(tester);
      expect(find.text('6 / 6 ta so‘z'), findsOneWidget);

      final notebookButton = find.text('Qiyin so‘zlar');
      await tester.scrollUntilVisible(
        notebookButton,
        450,
        scrollable: find
            .descendant(
              of: find.byType(TodayTab),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(notebookButton);
      await _pumpUi(tester);
      expect(find.text(firstQuestion.correctAnswer), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Yopish'));
      await _pumpUi(tester);

      final reviewCard = find.text('Takrorlash vaqti');
      await tester.scrollUntilVisible(
        reviewCard,
        450,
        scrollable: find
            .descendant(
              of: find.byType(TodayTab),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Takrorlash'));
      await _pumpUi(tester);
      final reviewSession = tester.widget<LessonScreen>(
        find.byType(LessonScreen),
      );
      expect(reviewSession.isReview, isTrue);
      expect(reviewSession.questions, hasLength(1));

      final reviewQuestion = tester
          .widget<McqQuestion>(find.byType(McqQuestion))
          .question;
      await tester.tap(find.text(reviewQuestion.correctAnswer));
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.text('Takrorlashni tugatdingiz!'), findsOneWidget);
      expect(store.dueWordIds, isEmpty);
      expect(store.totalXp, 20 * questions.length);
      expect(store.streakDays, 1);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}
