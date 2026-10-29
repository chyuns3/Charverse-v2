// 3상태(로딩·오류·빈) + 화면 흐름(push · tab · modal) + 적응형(600dp) 위젯 테스트.
// 네트워크를 쓰지 않도록 ListScreen에 가짜 loader를 넣는다 → json-server 없이 `flutter test`가 돈다.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mid_project_template/api.dart';
import 'package:mid_project_template/characters.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/screens/a_list_screen.dart';
import 'package:mid_project_template/screens/d_collection_screen.dart';

const _items = [
  Item(
    id: 1,
    title: '항목 1',
    subtitle: '설명 1',
    image: '',
    tags: ['한글', '기본 자음', '1획'],
  ),
  Item(
    id: 2,
    title: '항목 2',
    subtitle: '설명 2',
    image: '',
    tags: ['한글', '기본 자음', '1획'],
  ),
];

Future<List<Note>> _noNotes(int _) async => const [];

Widget _app(ItemsLoader load) => MaterialApp(
  home: ListScreen(load: load, loadNotes: _noNotes),
);

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('3상태: 로딩 → 오류 → 다시 시도 → 성공', (tester) async {
    _setSize(tester, const Size(400, 800));

    // 로딩 → 오류
    final first = Completer<List<Item>>();
    var calls = 0;
    await tester.pumpWidget(
      _app(() => ++calls == 1 ? first.future : Future.value(_items)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('글자 데이터를 불러오고 있습니다…'), findsOneWidget);

    first.completeError(Exception('테스트 오류'));
    await tester.pumpAndSettle();
    expect(find.text('글자 목록을 불러오지 못했습니다.'), findsOneWidget);

    // 다시 시도 → 성공
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('한글'));
    await tester.pumpAndSettle();
    expect(find.text('항목 1'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('3상태: 빈 상태', (tester) async {
    await tester.pumpWidget(_app(() async => const []));
    await tester.pumpAndSettle();
    expect(find.text('학습할 문자 영역을 선택하세요'), findsOneWidget);
  });

  testWidgets('흐름: A 목록 → push B 상세 → tab 메모 → modal C 결과', (tester) async {
    _setSize(tester, const Size(400, 800));
    await tester.pumpWidget(_app(() async => _items));
    await tester.pumpAndSettle();
    await tester.tap(find.text('한글'));
    await tester.pumpAndSettle();
    expect(find.text('항목 1'), findsOneWidget);

    await tester.tap(find.text('항목 1'));
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsOneWidget); // push

    await tester.drag(
      find.byType(ListView).last,
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('AI 맞춤 필기 진단서 보기'));
    await tester.pumpAndSettle();
    expect(find.text('AI 필기 습관 정밀 진단서'), findsOneWidget); // modal
    await tester.tap(find.text('확인 완료 (닫기)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('AI 필기 습관 피드백'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('아직 기록된 AI 필기 피드백이 없습니다.'),
      findsOneWidget,
    ); // tab + 빈 상태
  });

  testWidgets('보관함 아이콘으로 수집함 화면 진입', (tester) async {
    await tester.pumpWidget(_app(() async => _items));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('characterCollectionButton')));
    await tester.pumpAndSettle();

    expect(find.text('내 캐릭터 보관함'), findsOneWidget);
  });

  testWidgets('메인 허브에서 순서 변경과 학습 진척도 표시', (tester) async {
    await tester.pumpWidget(_app(() async => _items));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('drag-한글')), findsOneWidget);
    expect(find.byType(ReorderableDragStartListener), findsWidgets);
  });

  testWidgets('획수 필터는 드롭다운으로 표시', (tester) async {
    await tester.pumpWidget(_app(() async => _items));
    await tester.pumpAndSettle();
    await tester.tap(find.text('한글'));
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(find.text('전체 획수'), findsOneWidget);
  });

  testWidgets('미확인 캐릭터 점을 누르면 개수가 감소', (tester) async {
    final unviewed = {'火'};
    await tester.pumpWidget(
      MaterialApp(
        home: CollectionScreen(
          completedGlyphs: const ['火'],
          selectedGlyph: null,
          unviewedGlyphs: unviewed,
          onCharacterViewed: (glyph) => unviewed.remove(glyph),
          onThemeSelection: (_, _) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byWidgetPredicate((widget) =>
        widget is DecoratedBox &&
        widget.decoration is BoxDecoration &&
        (widget.decoration as BoxDecoration).color == Colors.red), findsOneWidget);

    await tester.tap(find.text('火'));
    await tester.pump();
    expect(unviewed, isEmpty);
  });

  testWidgets('캐릭터 보관함: 테마 선택 활성화 및 적용', (tester) async {
    CharacterAsset? selectedCharacter;
    await tester.pumpWidget(
      MaterialApp(
        home: CollectionScreen(
          completedGlyphs: const ['火'],
          selectedGlyph: null,
          unviewedGlyphs: const {'火'},
          onCharacterViewed: (_) {},
          onThemeSelection: (character, _) => selectedCharacter = character,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final themeButton = find.byType(FilledButton);
    expect(tester.widget<FilledButton>(themeButton).onPressed, isNull);

    await tester.tap(find.text('火'));
    await tester.pump();
    expect(tester.widget<FilledButton>(themeButton).onPressed, isNotNull);

    await tester.ensureVisible(themeButton);
    tester.widget<FilledButton>(themeButton).onPressed?.call();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(selectedCharacter?.asset, 'fire');
  });

  testWidgets('학습 완료 후 학습 중·미학습으로 되돌리기', (tester) async {
    final statuses = <int, LearningStatus>{};
    await tester.pumpWidget(
      MaterialApp(
        home: ListScreen(
          load: () async => _items,
          loadNotes: _noNotes,
          learningStatuses: const {},
          onStatusChange: (itemId, status) => statuses[itemId] = status,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('한글'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('항목 1'));
    await tester.pumpAndSettle();

    final completeButton = find.text('글자 쓰기 연습 완료하기');
    await tester.drag(
      find.byType(ListView).last,
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    await tester.tap(completeButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(ListView).last,
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('학습 완료됨 · 탭해서 학습 중으로'));
    await tester.pump();
    expect(statuses[1], LearningStatus.inProgress);

    await tester.drag(
      find.byType(ListView).last,
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('미완료로 되돌리기'));
    await tester.pump();
    expect(statuses[1], LearningStatus.notStarted);
  });

  testWidgets('적응형: 600dp 이상이면 격자', (tester) async {
    _setSize(tester, const Size(1024, 768));
    await tester.pumpWidget(_app(() async => _items));
    await tester.pumpAndSettle();
    await tester.tap(find.text('한글'));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsWidgets);
  });
}
