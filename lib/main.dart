// Charverse v2 — GAI3008 중간고사 (UI만 구현)
// 부제: 글자를 학습하며 세계를 넓혀가자
//
// ┌──────── 디자인 가이드 대응표: 앱 뼈대 ──────────────────────────────────────┐
// │ 번호 │ Flutter 위젯명        │ 비즈니스 명칭(한글)      │ 원칙(P번호)       │
// │ S-1  │ MaterialApp           │ Charverse                │ —                 │
// │ S-2  │ ThemeData(seedColor)  │ Charverse 브랜드 색      │ P04 일관성과 표준 │
// └────────────────────────────────────────────────────────────────────────────┘
// 화면 흐름(docs/디자인가이드.md 1장과 같게):
//   A 글자 도감 목록 ──쌓기(push)──▶ B 학습 상세 [옆으로(tab): 글자 정보 | AI 필기 피드백] ──덮기(modal)──▶ C AI 습관 진단서
// 기획 문서에 없는 화면은 만들지 않는다(감점). 화면을 늘리면 이 주석·가이드도 같이 고친다.
import 'package:flutter/material.dart';

import 'characters.dart';
import 'screens/a_list_screen.dart';
import 'screens/d_collection_screen.dart';

const _defaultThemeColor = Color(0xFF5C6BC0);
final _navigatorKey = GlobalKey<NavigatorState>();

void main() => runApp(const CharverseApp());

class CharverseApp extends StatefulWidget {
  const CharverseApp({super.key});

  @override
  State<CharverseApp> createState() => _CharverseAppState();
}

class _CharverseAppState extends State<CharverseApp> {
  final Map<int, String> _completedGlyphs = {};
  final Set<String> _unviewedCharacterGlyphs = {};
  final Map<int, LearningStatus> _learningStatuses = {};
  CharacterAsset? _themeCharacter;
  Color _themeColor = _defaultThemeColor;

  void _startLearning(int itemId) {
    if (_learningStatuses[itemId] == LearningStatus.completed) return;
    setState(() => _learningStatuses[itemId] = LearningStatus.inProgress);
  }

  void _changeLearningStatus(int itemId, LearningStatus status) {
    setState(() => _learningStatuses[itemId] = status);
  }

  void _saveCompletion(CompletionResult result) {
    setState(() {
      _learningStatuses[result.itemId] = LearningStatus.completed;
      if (result.character != null) {
        _completedGlyphs[result.itemId] = result.glyph;
        _unviewedCharacterGlyphs.add(result.glyph);
      }
    });
  }

  void _markCharacterViewed(String glyph) {
    setState(() => _unviewedCharacterGlyphs.remove(glyph));
  }

  void _applyTheme(CharacterAsset? character, Color color) {
    setState(() {
      _themeCharacter = character;
      _themeColor = character == null ? _defaultThemeColor : color;
    });
  }

  Future<void> _openCollection() async {
    await _navigatorKey.currentState?.push<CompletionResult>(
      MaterialPageRoute<CompletionResult>(
        builder: (_) => CollectionScreen(
          completedGlyphs: _completedGlyphs.values.toSet().toList()
            ..sort(),
          selectedGlyph: _themeCharacter?.glyph,
          unviewedGlyphs: _unviewedCharacterGlyphs,
          onCharacterViewed: _markCharacterViewed,
          onThemeSelection: _applyTheme,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Charverse', // S-1
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: _themeColor,
        useMaterial3: true,
      ),
      home: ListScreen(
        completedGlyphs: _completedGlyphs,
        unviewedCharacterCount: _unviewedCharacterGlyphs.length,
        learningStatuses: _learningStatuses,
        onStartLearning: _startLearning,
        onStatusChange: _changeLearningStatus,
        onComplete: _saveCompletion,
        onOpenCollection: _openCollection,
      ),
    );
  }
}
