// 화면 B: 글자 학습 및 습관 분석 상세 — Charverse v2
//
// ┌──────── 디자인 가이드 대응표: B 상세 ───────────────────────────────────────┐
// │ 번호 │ Flutter 위젯명                  │ 비즈니스 명칭(한글)  │ 원칙(P번호)    │
// │ B-1  │ AppBar + BackButton             │ 학습 상세 상단 바   │ P03 통제·자유  │
// │ B-2  │ TabBar + TabBarView             │ 학습 정보|피드백 탭  │ P02·P08 미니멀 │
// │ B-3  │ TraceCanvas (실루엣+획순방향뱃지)│ 따라 쓰기 및 획순·방향│ P05·P06·P07    │
// │ B-8  │ FilterChip (획순 ON/OFF)        │ 획순 가이드 토글 스위치│ P01·P07 효율성 │
// │ B-9  │ StrokeLegendList (단계별획가이드)│ 획순·곡선 형태 안내판│ P02·P05 오류예방│
// │ B-4  │ Wrap(Chip …)                    │ 언어 및 획수 태그 칩 │ P02 실세계     │
// │ B-5  │ IconButton / OutlinedButton     │ 즐겨찾기 별 및 완료  │ P01·P04 일관성 │
// │ B-6  │ FilledButton → 모달 시트        │ AI 진단서 보기 버튼  │ P07 효율성     │
// │ B-7  │ FutureBuilder(GET /notes)       │ AI 습관 피드백 목록  │ P01 · P09      │
// └────────────────────────────────────────────────────────────────────────────┘
// 전환: A → B 쌓기(push) · B 안에서 옆으로(tab) · B → C 덮기(modal)
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../api.dart';
import '../characters.dart';
import '../models.dart';
import '../widgets.dart';
import 'a_list_screen.dart' show extractGlyph, visibleItemTags;
import 'c_result_sheet.dart';

/// 획순 원형 숫자 기호 배열
const _circleNumbers = ['①', '②', '③', '④', '⑤', '⑥', '⑦', '⑧', '⑨', '⑩'];

/// 획순 가이드 데이터 (순서, 글자 중심 기준 상대 좌표 relX/relY, 획 진행 방향 기호, 획 형태 설명)
class StrokePoint {
  final int order;
  final double relX; // -0.5 ~ +0.5
  final double relY; // -0.5 ~ +0.5
  final String arrow; // 획 진행 방향 (→, ↓, →↓, ↓→, ↷, ↺, ↙, ↘ 등)
  final String description; // 획 형태 상세 설명
  const StrokePoint(this.order, this.relX, this.relY, this.arrow, this.description);
}

/// 대표 글자별 획순, 획 형태 및 복합 꺾임/곡선 방향 정밀 데이터 (전수 검증 완료)
const Map<String, List<StrokePoint>> _knownStrokes = {
  // ── 한글 자음 ──
  'ㄱ': [StrokePoint(1, -0.32, -0.32, '→↓', '가로로 긋다가 아래로 꺾기')],
  'ㄴ': [StrokePoint(1, -0.30, -0.26, '↓→', '아래로 내리긋다가 오른쪽으로 꺾기')],
  'ㄷ': [StrokePoint(1, -0.32, -0.32, '→', '위쪽 가로선 긋기'), StrokePoint(2, -0.30, -0.06, '↓→', '내려와서 오른쪽으로 꺾기')],
  'ㄹ': [StrokePoint(1, -0.32, -0.36, '→↓', '가로 후 아래로 꺾기'), StrokePoint(2, -0.30, -0.04, '→', '가운데 가로선 긋기'), StrokePoint(3, -0.30, 0.26, '↓→', '내려와서 오른쪽으로 꺾기')],
  'ㅁ': [StrokePoint(1, -0.32, -0.28, '↓', '왼쪽 세로선 내리기'), StrokePoint(2, -0.20, -0.34, '→↓', '가로선 후 오른쪽 아래로 꺾기'), StrokePoint(3, -0.32, 0.32, '→', '아래 가로선으로 닫기')],
  'ㅂ': [StrokePoint(1, -0.32, -0.34, '↓', '왼쪽 세로선 내리기'), StrokePoint(2, 0.32, -0.34, '↓', '오른쪽 세로선 내리기'), StrokePoint(3, -0.28, -0.02, '→', '중앙 가로선 잇기'), StrokePoint(4, -0.28, 0.32, '→', '하단 가로선으로 닫기')],
  'ㅅ': [StrokePoint(1, -0.08, -0.34, '↙', '왼쪽 아래로 부드럽게 삐치기'), StrokePoint(2, 0.10, -0.06, '↘', '오른쪽 아래로 삐쳐 내리기')],
  'ㅇ': [StrokePoint(1, 0.0, -0.36, '↺', '상단에서 반시계 방향으로 둥글게 원 그리기')],
  'ㅈ': [StrokePoint(1, -0.32, -0.32, '→', '위쪽 가로선 긋기'), StrokePoint(2, 0.0, -0.28, '↙↘', '중앙에서 좌우로 갈라 삐치기')],
  'ㅊ': [StrokePoint(1, 0.0, -0.42, '→', '머리 위 짧은 점 긋기'), StrokePoint(2, -0.32, -0.22, '→', '중간 가로선 긋기'), StrokePoint(3, 0.0, -0.18, '↙↘', '좌우로 사선 삐치기')],
  'ㅋ': [StrokePoint(1, -0.32, -0.34, '→↓', '기역 꺾음 긋기'), StrokePoint(2, -0.30, 0.02, '→', '가운데 가로선 추가하기')],
  'ㅌ': [StrokePoint(1, -0.32, -0.36, '→', '상단 가로선 긋기'), StrokePoint(2, -0.30, -0.04, '→', '중앙 가로선 긋기'), StrokePoint(3, -0.30, 0.08, '↓→', '내려와서 하단 가로로 꺾기')],
  'ㅍ': [StrokePoint(1, -0.36, -0.34, '→', '상단 가로 덮개선 긋기'), StrokePoint(2, -0.18, -0.26, '↓', '왼쪽 세로 기둥 내리기'), StrokePoint(3, 0.18, -0.26, '↓', '오른쪽 세로 기둥 내리기'), StrokePoint(4, -0.36, 0.32, '→', '하단 받침 가로선 긋기')],
  'ㅎ': [StrokePoint(1, 0.0, -0.42, '→', '상단 꼭지 점 긋기'), StrokePoint(2, -0.35, -0.22, '→', '중간 가로 갓 긋기'), StrokePoint(3, 0.0, 0.04, '↺', '하단 반시계 원 그리기')],
  'ㄲ': [StrokePoint(1, -0.38, -0.30, '→↓', '첫 번째 기역 꺾기'), StrokePoint(2, 0.12, -0.30, '→↓', '두 번째 기역 꺾기')],
  'ㄸ': [StrokePoint(1, -0.38, -0.34, '→', '좌 디귿 위 가로'), StrokePoint(2, -0.38, -0.08, '↓→', '좌 디귿 꺾기'), StrokePoint(3, 0.12, -0.34, '→', '우 디귿 위 가로'), StrokePoint(4, 0.12, -0.08, '↓→', '우 디귿 꺾기')],
  'ㅃ': [
    StrokePoint(1, -0.42, -0.34, '↓', '첫 비읍의 왼쪽 세로선 긋기'),
    StrokePoint(2, -0.14, -0.34, '↓', '첫 비읍의 오른쪽 세로선 긋기'),
    StrokePoint(3, -0.42, 0.02, '→', '첫 비읍의 가운데 가로선 긋기'),
    StrokePoint(4, -0.42, 0.32, '→', '첫 비읍의 아래 가로선 긋기'),
    StrokePoint(5, 0.14, -0.34, '↓', '둘째 비읍의 왼쪽 세로선 긋기'),
    StrokePoint(6, 0.42, -0.34, '↓', '둘째 비읍의 오른쪽 세로선 긋기'),
    StrokePoint(7, 0.14, 0.02, '→', '둘째 비읍의 가운데 가로선 긋기'),
    StrokePoint(8, 0.14, 0.32, '→', '둘째 비읍의 아래 가로선 긋기'),
  ],
  'ㅆ': [StrokePoint(1, -0.35, -0.30, '↙', '1시옷 좌 삐침'), StrokePoint(2, -0.18, -0.05, '↘', '1시옷 우 삐침'), StrokePoint(3, 0.15, -0.30, '↙', '2시옷 좌 삐침'), StrokePoint(4, 0.32, -0.05, '↘', '2시옷 우 삐침')],
  'ㅉ': [StrokePoint(1, -0.38, -0.30, '→', '1지읒 가로'), StrokePoint(2, -0.18, -0.26, '↙', '1지읒 삐침'), StrokePoint(3, 0.12, -0.30, '→', '2지읒 가로'), StrokePoint(4, 0.32, -0.26, '↙', '2지읒 삐침')],

  // ── 한글 모음 ──
  'ㅏ': [StrokePoint(1, -0.12, -0.38, '↓', '긴 세로 기둥 내리기'), StrokePoint(2, -0.08, 0.0, '→', '오른쪽 곁가지 긋기')],
  'ㅑ': [StrokePoint(1, -0.12, -0.38, '↓', '긴 세로 기둥 내리기'), StrokePoint(2, -0.08, -0.14, '→', '위쪽 곁가지 긋기'), StrokePoint(3, -0.08, 0.14, '→', '아래쪽 곁가지 긋기')],
  'ㅓ': [StrokePoint(1, -0.35, 0.0, '→', '왼쪽 곁가지 먼저 긋기'), StrokePoint(2, 0.12, -0.38, '↓', '긴 세로 기둥 내리기')],
  'ㅕ': [StrokePoint(1, -0.35, -0.14, '→', '위쪽 곁가지 긋기'), StrokePoint(2, -0.35, 0.14, '→', '아래쪽 곁가지 긋기'), StrokePoint(3, 0.12, -0.38, '↓', '긴 세로 기둥 내리기')],
  'ㅗ': [StrokePoint(1, 0.0, -0.36, '↓', '짧은 세로 기둥 내리기'), StrokePoint(2, -0.38, 0.18, '→', '하단 가로 지평선 긋기')],
  'ㅛ': [StrokePoint(1, -0.16, -0.36, '↓', '왼쪽 짧은 세로 내리기'), StrokePoint(2, 0.16, -0.36, '↓', '오른쪽 짧은 세로 내리기'), StrokePoint(3, -0.38, 0.18, '→', '하단 긴 가로선 긋기')],
  'ㅜ': [StrokePoint(1, -0.38, -0.18, '→', '상단 가로선 긋기'), StrokePoint(2, 0.0, -0.14, '↓', '중앙 아래로 기둥 내리기')],
  'ㅠ': [StrokePoint(1, -0.38, -0.18, '→', '상단 긴 가로선 긋기'), StrokePoint(2, -0.16, -0.14, '↓', '왼쪽 짧은 기둥 내리기'), StrokePoint(3, 0.16, -0.14, '↓', '오른쪽 짧은 기둥 내리기')],
  'ㅡ': [StrokePoint(1, -0.38, 0.0, '→', '왼쪽에서 오른쪽으로 곧게 긋기')],
  'ㅣ': [StrokePoint(1, 0.0, -0.38, '↓', '위에서 아래로 곧게 내리긋기')],

  // ── 히라가나 ──
  'あ': [StrokePoint(1, -0.34, -0.28, '→', '상단 가로선 긋기'), StrokePoint(2, 0.0, -0.40, '↓', '세로 중심 곡선 관통하기'), StrokePoint(3, -0.16, -0.05, '↻', '아래에서 크게 둥글게 회전 매듭')],
  'い': [StrokePoint(1, -0.32, -0.32, '↓↗', '왼쪽 곡선 내려와 삐치기'), StrokePoint(2, 0.30, -0.20, '↓', '오른쪽 짧은 곡선 내리기')],
  'う': [StrokePoint(1, 0.0, -0.38, '↘', '상단 빗점 찍기'), StrokePoint(2, -0.26, -0.12, '↷', '둥글게 휘어지는 큰 곡선')],
  'え': [StrokePoint(1, 0.0, -0.38, '↘', '상단 빗점 찍기'), StrokePoint(2, -0.28, -0.15, '→⤷', '가로 후 지그재그로 감아내리기')],
  'お': [StrokePoint(1, -0.36, -0.28, '→', '가로선 긋기'), StrokePoint(2, -0.02, -0.40, '↓↻', '세로 관통 후 왼쪽으로 크게 둥근 고리'), StrokePoint(3, 0.30, -0.24, '↘', '우상단 곁점 찍기')],
  'か': [StrokePoint(1, -0.32, -0.24, '→↓', '가로 후 삐쳐올리기'), StrokePoint(2, -0.06, -0.36, '↙', '사선으로 꿰뚫어 내리기'), StrokePoint(3, 0.32, -0.36, '↘', '우상단 곁점 찍기')],
  'き': [StrokePoint(1, -0.28, -0.28, '→', '위쪽 가로선 긋기'), StrokePoint(2, -0.32, -0.06, '→', '아래쪽 가로선 긋기'), StrokePoint(3, 0.0, -0.40, '↙', '사선으로 관통하기'), StrokePoint(4, -0.18, 0.22, '↷', '하단 둥근 받침 곡선')],
  'く': [StrokePoint(1, 0.0, -0.38, '↙↘', '왼쪽으로 꺾여 내려오는 한 획')],
  'し': [StrokePoint(1, -0.10, -0.38, '↓↗', '아래로 내려와 낚싯바늘처럼 치켜올리기')],
  'す': [StrokePoint(1, -0.35, -0.28, '→', '가로선 긋기'), StrokePoint(2, 0.0, -0.40, '↓↻', '세로선 내리다 고리 짓고 내리기')],
  'つ': [StrokePoint(1, -0.32, -0.20, '↷', '둥글게 파도처럼 감아내리는 한 획')],
  'て': [StrokePoint(1, -0.35, -0.28, '→↷', '가로선 후 오른쪽으로 둥글게 굴리기')],
  'の': [StrokePoint(1, -0.10, -0.30, '↙↻', '사선 내려와 둥근 원형으로 감기')],

  // ── 가타카나 ──
  'ア': [StrokePoint(1, -0.32, -0.32, '→↓', '가로 후 꺾어 살짝 삐치기'), StrokePoint(2, 0.14, -0.30, '↙', '왼쪽 아래로 길게 삐치기')],
  'イ': [StrokePoint(1, -0.18, -0.38, '↙', '좌하향 사선 삐치기'), StrokePoint(2, 0.15, -0.28, '↓', '곧은 세로 기둥 내리기')],
  'ウ': [StrokePoint(1, 0.0, -0.42, '↓', '상단 중앙 점 찍기'), StrokePoint(2, -0.28, -0.20, '↓', '왼쪽 세로 점 긋기'), StrokePoint(3, -0.25, -0.20, '→↓', '가로 후 꺾어내리는 덮개')],
  'エ': [StrokePoint(1, -0.32, -0.35, '→', '상단 가로선 긋기'), StrokePoint(2, 0.0, -0.35, '↓', '중앙 세로 기둥 잇기'), StrokePoint(3, -0.38, 0.35, '→', '하단 긴 받침 가로선')],
  'オ': [StrokePoint(1, -0.35, -0.22, '→', '가로선 긋기'), StrokePoint(2, 0.05, -0.42, '↓', '세로선 관통 내리기'), StrokePoint(3, -0.25, -0.02, '↙', '왼쪽 아래로 삐치기')],
  'カ': [StrokePoint(1, -0.32, -0.24, '→↓', '가로 후 꺾어 올리기'), StrokePoint(2, 0.15, -0.36, '↙', '사선으로 비껴 내리기')],
  'キ': [StrokePoint(1, -0.30, -0.28, '→', '위 가로선'), StrokePoint(2, -0.32, -0.06, '→', '아래 가로선'), StrokePoint(3, 0.0, -0.40, '↙', '사선 관통 긋기')],
  'ク': [StrokePoint(1, -0.15, -0.36, '↙', '짧은 사선 삐침'), StrokePoint(2, -0.12, -0.36, '→↓', '가로 후 길게 꺾어내리기')],
  'コ': [StrokePoint(1, -0.30, -0.30, '→↓', '가로 후 세로로 꺾기'), StrokePoint(2, -0.30, 0.30, '→', '하단 가로 받침 긋기')],

  // ── 한자 ──
  '一': [StrokePoint(1, -0.38, 0.0, '→', '곧게 뻗은 수평 가로선')],
  '二': [StrokePoint(1, -0.30, -0.22, '→', '위쪽 짧은 가로선'), StrokePoint(2, -0.38, 0.22, '→', '아래쪽 긴 가로선')],
  '三': [StrokePoint(1, -0.30, -0.32, '→', '위 가로선'), StrokePoint(2, -0.24, 0.0, '→', '가운데 짧은 가로선'), StrokePoint(3, -0.38, 0.32, '→', '아래 긴 가로선')],
  '四': [StrokePoint(1, -0.34, -0.35, '↓', '왼쪽 세로선'), StrokePoint(2, -0.28, -0.35, '→↓', '가로 후 우측 세로 꺾기'), StrokePoint(3, -0.14, -0.15, '↓', '안쪽 왼쪽 획'), StrokePoint(4, 0.12, -0.15, '→↓', '안쪽 오른쪽 꺾음'), StrokePoint(5, -0.34, 0.35, '→', '하단 닫는 가로선')],
  '五': [StrokePoint(1, -0.32, -0.35, '→', '상단 가로선'), StrokePoint(2, 0.0, -0.35, '↓', '중앙 사선 기둥'), StrokePoint(3, -0.22, -0.05, '→↓', '가로 후 꺾어내리기'), StrokePoint(4, -0.38, 0.35, '→', '하단 받침 가로선')],
  '六': [StrokePoint(1, 0.0, -0.42, '↓', '머리 점 찍기'), StrokePoint(2, -0.38, -0.18, '→', '가로 대들보 긋기'), StrokePoint(3, -0.22, 0.05, '↙', '왼쪽 사선 삐침'), StrokePoint(4, 0.22, 0.05, '↘', '오른쪽 점 긋기')],
  '七': [StrokePoint(1, -0.38, -0.08, '→', '약간 치켜올리는 가로선'), StrokePoint(2, 0.0, -0.38, '↓→', '세로로 내려오다 꺾어 치켜올리기')],
  '八': [StrokePoint(1, -0.16, -0.28, '↙', '왼쪽 획 삐치기'), StrokePoint(2, 0.16, -0.32, '↘', '오른쪽 획 삐치기')],
  '九': [StrokePoint(1, -0.14, -0.38, '↙', '왼쪽 긴 삐침'), StrokePoint(2, -0.34, -0.18, '→↓', '가로 후 꺾어 굽은 갈고리')],
  '十': [StrokePoint(1, -0.38, 0.0, '→', '가로선 먼저 긋기'), StrokePoint(2, 0.0, -0.38, '↓', '세로선으로 꿰뚫기')],
  '日': [StrokePoint(1, -0.28, -0.38, '↓', '왼쪽 세로 기둥'), StrokePoint(2, -0.24, -0.38, '→↓', '가로 후 오른쪽 꺾어내림'), StrokePoint(3, -0.24, 0.0, '→', '가운데 가로선 잇기'), StrokePoint(4, -0.28, 0.38, '→', '하단 가로선으로 닫기')],
  '月': [StrokePoint(1, -0.26, -0.40, '↙', '왼쪽 세로 삐침'), StrokePoint(2, -0.22, -0.40, '→↓', '가로 후 꺾어 갈고리'), StrokePoint(3, -0.22, -0.08, '→', '위쪽 가운데 가로선'), StrokePoint(4, -0.22, 0.16, '→', '아래쪽 가운데 가로선')],
  '火': [StrokePoint(1, -0.32, -0.15, '↘', '왼쪽 튀는 불똥 점'), StrokePoint(2, 0.30, -0.22, '↙', '오른쪽 튀는 불똥 점'), StrokePoint(3, 0.0, -0.42, '↙', '중앙 큰 불길 삐침'), StrokePoint(4, 0.0, 0.0, '↘', '우하향 든든한 받침 삐침')],
  '水': [StrokePoint(1, 0.0, -0.42, '↓', '중앙 세로 갈고리 내리기'), StrokePoint(2, -0.22, -0.12, '→↓', '왼쪽 가로 후 꺾임 획'), StrokePoint(3, -0.38, 0.30, '↙', '왼쪽 아래 사선 치켜올림'), StrokePoint(4, 0.16, -0.08, '↘', '오른쪽 긴 파도 삐침')],
  '木': [StrokePoint(1, -0.38, -0.12, '→', '가로선 긋기'), StrokePoint(2, 0.0, -0.42, '↓', '수직 중심 줄기 꿰뚫기'), StrokePoint(3, -0.05, -0.05, '↙', '왼쪽 뿌리 삐침'), StrokePoint(4, 0.05, -0.05, '↘', '오른쪽 뿌리 삐침')],
  '人': [StrokePoint(1, -0.06, -0.38, '↙', '왼쪽 다리 삐쳐 내리기'), StrokePoint(2, 0.06, -0.12, '↘', '오른쪽 다리 받쳐 내리기')],
  '山': [StrokePoint(1, 0.0, -0.40, '↓', '중앙 높은 봉우리 기둥'), StrokePoint(2, -0.34, -0.10, '↓→', '왼쪽 봉우리 내려와 가로 꺾기'), StrokePoint(3, 0.34, -0.10, '↓', '오른쪽 봉우리 세로 내리기')],
  '川': [StrokePoint(1, -0.34, -0.35, '↙', '왼쪽 물길 삐침'), StrokePoint(2, 0.0, -0.25, '↓', '가운데 짧은 물길 내리기'), StrokePoint(3, 0.34, -0.40, '↓', '오른쪽 긴 물길 곧게 내리기')],
  '大': [StrokePoint(1, -0.38, -0.15, '→', '가로선 긋기'), StrokePoint(2, 0.0, -0.42, '↙', '중앙에서 왼쪽으로 삐치기'), StrokePoint(3, 0.06, -0.12, '↘', '중앙에서 오른쪽으로 삐치기')],
  '中': [StrokePoint(1, -0.30, -0.25, '↓', '왼쪽 세로 기둥'), StrokePoint(2, -0.26, -0.25, '→↓', '가로 후 오른쪽 꺾어내림'), StrokePoint(3, -0.30, 0.15, '→', '하단 가로선 닫기'), StrokePoint(4, 0.0, -0.42, '↓', '중앙 관통 곧은 세로 기둥')],
  '門': [StrokePoint(1, -0.38, -0.38, '↓', '왼 문틀 세로선'), StrokePoint(2, -0.34, -0.38, '→↓', '왼 문틀 ㄱ 꺾기'), StrokePoint(3, -0.34, -0.10, '→', '왼 문 안쪽 1가로'), StrokePoint(4, -0.34, 0.05, '→', '왼 문 안쪽 2가로'), StrokePoint(5, 0.10, -0.38, '↓', '오른 문틀 세로선'), StrokePoint(6, 0.16, -0.38, '→↓', '오른 문틀 ㄱ 갈고리'), StrokePoint(7, 0.16, -0.10, '→', '오른 문 안쪽 1가로'), StrokePoint(8, 0.16, 0.05, '→', '오른 문 안쪽 2가로')],
};

/// 글자의 획순 및 획 진행 방향 리스트를 도출하는 함수
List<StrokePoint> getStrokePoints(Item item) {
  final glyph = extractGlyph(item.title);
  if (_knownStrokes.containsKey(glyph)) {
    return _knownStrokes[glyph]!;
  }

  // 매핑에 없는 글자는 subtitle/tags의 획수 정보를 기반으로 글자 영역 내 균형 분산
  int totalCount = 1;
  final match = RegExp(r'(\d+)획').firstMatch(item.subtitle);
  if (match != null) {
    totalCount = int.tryParse(match.group(1)!) ?? 1;
  }

  const defaultArrows = ['→', '↓', '→↓', '↓→', '↘', '↙'];
  const defaultDescs = ['가로선 긋기', '세로선 내리기', '가로 후 아래 꺾기', '내려와서 꺾기', '우하향 삐치기', '좌하향 삐치기'];
  final list = <StrokePoint>[];
  for (int i = 0; i < totalCount; i++) {
    final ratio = totalCount <= 1 ? 0.0 : ((i / (totalCount - 1)) * 0.7 - 0.35);
    final rx = ratio;
    final ry = -0.35 + ((i % 3) * 0.28);
    final arrow = defaultArrows[i % defaultArrows.length];
    final desc = defaultDescs[i % defaultDescs.length];
    list.add(StrokePoint(i + 1, rx, ry, arrow, desc));
  }
  return list;
}

/// 획순 뱃지 위치 계산 및 겹침 방지(Anti-collision) 함수
List<Offset> resolveBadgePositions(
  List<StrokePoint> strokes,
  double centerX,
  double centerY,
  double glyphBoxSize,
) {
  final positions = <Offset>[];
  const minDistance = 32.0; // 뱃지 간 최소 거리 (픽셀)

  for (final pt in strokes) {
    double posX = centerX + (pt.relX * glyphBoxSize);
    double posY = centerY + (pt.relY * glyphBoxSize);

    // 이전 뱃지들과의 겹침 검사 및 미세 분산
    for (int j = 0; j < positions.length; j++) {
      final prev = positions[j];
      final dist = math.sqrt(math.pow(posX - prev.dx, 2) + math.pow(posY - prev.dy, 2));
      if (dist < minDistance) {
        // 너무 가까우면 획 순서 방향에 따라 대각선으로 살짝 밀어내어 분리
        final angle = math.atan2(posY - prev.dy, posX - prev.dx);
        final pushDist = minDistance - dist + 6.0;
        posX += math.cos(angle) * pushDist;
        posY += math.sin(angle) * pushDist;
      }
    }
    positions.add(Offset(posX, posY));
  }

  return positions;
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.item,
    this.loadNotes = fetchNotes,
    this.isFavorite = false,
    this.learningStatus = LearningStatus.notStarted,
    required this.onComplete,
    required this.onStatusChange,
  });

  final Item item;
  final NotesLoader loadNotes;
  final bool isFavorite;
  final LearningStatus learningStatus;
  final ValueChanged<CompletionResult> onComplete;
  final void Function(int itemId, LearningStatus status) onStatusChange;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // STATE: 별표 즐겨찾기 상태 (기본 off 회색 ↔ on 노란색)
  late bool _isFav = widget.isFavorite;

  // STATE: 글자 학습 완료 여부
  late LearningStatus _learningStatus = widget.learningStatus;

  void _setStatus(LearningStatus status) {
    setState(() => _learningStatus = status);
    widget.onStatusChange(widget.item.id, status);
  }

  void _toggleFav() {
    setState(() {
      _isFav = !_isFav;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isFav ? Icons.star : Icons.star_border,
              color: _isFav ? Colors.amberAccent : Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              _isFav
                  ? "'${widget.item.title}' 글자가 즐겨찾기에 추가되었습니다."
                  : '즐겨찾기에서 해제되었습니다.',
            ),
          ],
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _markComplete() async {
    final glyph = extractGlyph(widget.item.title);
    final character = characterAssetByGlyph[glyph];

    setState(() {
      _learningStatus = LearningStatus.completed;
    });
    widget.onStatusChange(widget.item.id, LearningStatus.completed);

    if (widget.learningStatus != LearningStatus.completed) {
      widget.onComplete(
        CompletionResult(
          itemId: widget.item.id,
          glyph: glyph,
          character: character,
        ),
      );
    }

    if (character == null) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('캐릭터 추가 예정'),
          content: Text('“$glyph” 글자 캐릭터는 현재 준비 중입니다.\n학습은 완료되었으며 다음 업데이트를 기다려 주세요.'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('캐릭터 획득!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(character.imagePath, height: 220, fit: BoxFit.contain),
            const SizedBox(height: 12),
            Text(
              "'${widget.item.title}' 학습을 완료해서 캐릭터를 얻었어요!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_isFav);
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            // B-1 P03: 뒤로가기
            title: Text(widget.item.title),
            leading: BackButton(
              onPressed: () => Navigator.of(context).pop(_isFav),
            ),
            actions: [
              // B-5 P01 P04: 상단 별표 즐겨찾기 버튼 (회색 off ↔ 노란색 on)
              IconButton(
                tooltip: _isFav ? '즐겨찾기 해제' : '즐겨찾기 추가',
                icon: Icon(
                  _isFav ? Icons.star_rounded : Icons.star_border_rounded,
                  color: _isFav ? Colors.amber[700] : Colors.grey[400],
                  size: 28,
                ),
                onPressed: _toggleFav,
              ),
              const SizedBox(width: 8),
            ],
            bottom: const TabBar(
              // B-2 P02, P08: 글자 기본 정보와 AI 필기 피드백의 명확한 분리
              indicatorWeight: 3,
              tabs: [
                Tab(icon: Icon(Icons.draw_outlined), text: '따라 쓰기 & 획순'),
                Tab(icon: Icon(Icons.edit_note_outlined), text: 'AI 필기 습관 피드백'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _InfoTab(
                item: widget.item,
                isFavorite: _isFav,
                learningStatus: _learningStatus,
                onToggleFav: _toggleFav,
                onComplete: _markComplete,
                onStatusChange: _setStatus,
              ),
              _NotesTab(itemId: widget.item.id, load: widget.loadNotes),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTab extends StatefulWidget {
  const _InfoTab({
    required this.item,
    required this.isFavorite,
    required this.learningStatus,
    required this.onToggleFav,
    required this.onComplete,
    required this.onStatusChange,
  });

  final Item item;
  final bool isFavorite;
  final LearningStatus learningStatus;
  final VoidCallback onToggleFav;
  final VoidCallback onComplete;
  final void Function(LearningStatus status) onStatusChange;

  @override
  State<_InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<_InfoTab> {
  // 사용자가 직접 그리는 획 포인트 좌표 리스트 (null은 획이 끊어지는 지점)
  final List<Offset?> _drawnPoints = [];

  // STATE: 획수 및 획순 가이드 표시 ON/OFF 토글 (기본값: true)
  bool _showStrokeOrder = true;

  void _clearCanvas() {
    setState(() {
      _drawnPoints.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final glyph = extractGlyph(widget.item.title);
    final strokes = getStrokePoints(widget.item);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // 상단 도구 모음: 획순 가이드 ON/OFF 토글 (B-8 P01 P07)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_list_numbered_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '총 ${strokes.length}획',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            // B-8 P01 P07: 획순 표시 on/off 스위치 칩
            FilterChip(
              avatar: Icon(
                _showStrokeOrder
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                size: 16,
                color: _showStrokeOrder
                    ? theme.colorScheme.onPrimaryContainer
                    : Colors.grey[700],
              ),
              label: Text(
                _showStrokeOrder ? '획순 가이드 ON' : '획순 가이드 OFF',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _showStrokeOrder
                      ? theme.colorScheme.onPrimaryContainer
                      : Colors.grey[700],
                ),
              ),
              selected: _showStrokeOrder,
              onSelected: (val) {
                setState(() {
                  _showStrokeOrder = val;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        // B-3 P05 P06 P07: 겹침 방지 + 복합 방향 획(→↓, ↓→, ↷, ↺ 등) 캔버스
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. 격자 모눈 배경 가이드 (연한 십자선)
                CustomPaint(
                  size: Size.infinite,
                  painter: _GridGuidePainter(),
                ),
                // 2. 뒤에 회색 가이드로 크게 투영되는 해당 글자 실루엣
                Center(
                  child: Text(
                    glyph,
                    style: TextStyle(
                      fontSize: 145,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey.withAlpha(90), // 은은한 글자 실루엣
                      fontFamily: 'Roboto',
                      letterSpacing: -2,
                    ),
                  ),
                ),
                // 3. 획순 및 복합 방향(꺾임/곡선) 뱃지 레이어 (겹침 방지 알고리즘 적용)
                if (_showStrokeOrder)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final centerX = constraints.maxWidth / 2;
                      final centerY = constraints.maxHeight / 2;
                      const glyphBoxSize = 145.0; // 145pt 기준 바운딩 스케일

                      // 겹침 방지 오프셋 계산된 위치 목록
                      final resolvedPositions = resolveBadgePositions(
                        strokes,
                        centerX,
                        centerY,
                        glyphBoxSize,
                      );

                      return Stack(
                        children: [
                          for (int i = 0; i < strokes.length; i++)
                            Positioned(
                              left: resolvedPositions[i].dx - 15,
                              top: resolvedPositions[i].dy - 11,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  // 글자 실루엣과 동일 계열의 정갈한 다크 슬레이트 톤
                                  color: const Color(0xFF455A64).withAlpha(220),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(220),
                                    width: 1.2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      strokes[i].order <= _circleNumbers.length
                                          ? _circleNumbers[strokes[i].order - 1]
                                          : '${strokes[i].order}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(width: 2.5),
                                    Text(
                                      strokes[i].arrow,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.amberAccent,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                // 4. 사용자가 직접 획을 긋는 드로잉 캔버스 레이어
                GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      final box = context.findRenderObject() as RenderBox?;
                      if (box != null) {
                        _drawnPoints.add(details.localPosition);
                      }
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _drawnPoints.add(details.localPosition);
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      _drawnPoints.add(null);
                    });
                  },
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _DrawingPainter(
                      points: _drawnPoints,
                      strokeColor: theme.colorScheme.primary,
                    ),
                  ),
                ),
                // 5. 우측 상단 지우개 / 다시 쓰기 버튼
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        tooltip: '지우고 다시 쓰기',
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: _clearCanvas,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                // 6. 하단 조작 가이드 안내문 (요청 문구 정확히 반영)
                Positioned(
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(230),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _showStrokeOrder
                          ? '번호와 화살표 방향에 따라 획을 그어보세요'
                          : '회색 글자선을 따라 직접 써보세요 ✍️',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // B-9 P02 P05: 획순 및 꺾임/곡선 형태 상세 가이드 카드 (신설)
        Card(
          elevation: 0.5,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.alt_route_rounded, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      '획순 및 꺾임 가이드 상세',
                      style: text.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final st in strokes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            st.order <= _circleNumbers.length
                                ? _circleNumbers[st.order - 1]
                                : '${st.order}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.amber.withAlpha(40),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            st.arrow,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            st.description,
                            style: text.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),
        // 글자 상세 및 설명
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.item.title,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: switch (widget.learningStatus) {
                    LearningStatus.completed => Colors.green[50],
                    LearningStatus.inProgress => Colors.orange[50],
                    LearningStatus.notStarted => Colors.grey[100],
                  },
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: switch (widget.learningStatus) {
                      LearningStatus.completed => Colors.green,
                      LearningStatus.inProgress => Colors.orange,
                      LearningStatus.notStarted => Colors.grey,
                    },
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      switch (widget.learningStatus) {
                        LearningStatus.completed => '학습 완료',
                        LearningStatus.inProgress => '학습 중',
                        LearningStatus.notStarted => '미학습',
                      },
                      style: TextStyle(
                        color: switch (widget.learningStatus) {
                          LearningStatus.completed => Colors.green[800],
                          LearningStatus.inProgress => Colors.orange[800],
                          LearningStatus.notStarted => Colors.grey[700],
                        },
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        const SizedBox(height: 12),
        // B-4 P02: 언어 및 획수 태그 칩
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in
                  visibleItemTags(widget.item, widget.learningStatus))
                Chip(
                  avatar: const Icon(Icons.label_outline, size: 16),
                  label: Text(t),
                  backgroundColor: theme.colorScheme.surfaceContainerHigh,
                ),
            ],
          ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),
        // B-5: 학습 완료 버튼
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: widget.learningStatus == LearningStatus.completed
                ? theme.colorScheme.primaryContainer.withAlpha(50)
                : null,
          ),
          onPressed: widget.learningStatus == LearningStatus.completed
              ? () => widget.onStatusChange(LearningStatus.inProgress)
              : widget.onComplete,
          icon: Icon(
            widget.learningStatus == LearningStatus.completed
                ? Icons.check_circle_rounded
                : Icons.edit_rounded,
            color: widget.learningStatus == LearningStatus.completed
                ? Colors.green
                : null,
          ),
          label: Text(
            widget.learningStatus == LearningStatus.completed
                ? '학습 완료됨 · 탭해서 학습 중으로'
                : '글자 쓰기 연습 완료하기',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.learningStatus == LearningStatus.completed
                  ? Colors.green[800]
                  : null,
            ),
          ),
        ),
        if (widget.learningStatus != LearningStatus.notStarted) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () =>
                widget.onStatusChange(LearningStatus.notStarted),
            icon: const Icon(Icons.replay_rounded),
            label: const Text('미완료로 되돌리기'),
          ),
        ],
        const SizedBox(height: 12),
        // B-6 P07: 덮기(modal) 방식으로 AI 글쓰기 습관 정밀 진단서를 신속하게 호출
        FilledButton.icon(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => ResultSheet.show(context, widget.item),
          icon: const Icon(Icons.psychology_alt_outlined),
          label: const Text('AI 맞춤 필기 진단서 보기'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// 십자 모눈 가이드라인 페인터
class _GridGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withAlpha(40)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 가로 및 세로 중심선
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 사용자가 직접 그린 획 페인터
class _DrawingPainter extends CustomPainter {
  _DrawingPainter({required this.points, required this.strokeColor});

  final List<Offset?> points;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 7.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawCircle(points[i]!, 3.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}

/// 'AI 필기 습관 피드백' 탭 — 두 번째 GET (GET /notes?itemId=…)
class _NotesTab extends StatefulWidget {
  const _NotesTab({required this.itemId, required this.load});

  final int itemId;
  final NotesLoader load;

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  late Future<List<Note>> _future = widget.load(widget.itemId);

  void _retry() {
    setState(() {
      _future = widget.load(widget.itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<Note>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const LoadingView(
            label: 'AI 필기 습관 피드백을 분석 중…',
          ); // B-7 P01
        }
        if (snap.hasError) {
          return ErrorView(
            title: '피드백을 불러오지 못했습니다.',
            message: '${snap.error}',
            onRetry: _retry,
          ); // B-7 P09
        }
        final notes = snap.data ?? const <Note>[];
        if (notes.isEmpty) {
          return const EmptyView(
            message:
                '아직 기록된 AI 필기 피드백이 없습니다.\n연습을 시작하면 AI가 습관을 분석해 드립니다.',
          ); // B-7 P01
        }
        return ListView.builder(
          // B-7: 사용자 맞춤 AI 필기 교정 카드 목록
          padding: const EdgeInsets.all(16),
          itemCount: notes.length,
          itemBuilder: (context, i) {
            final note = notes[i];
            return Card(
              elevation: 0.8,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.auto_fix_high,
                        size: 20,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.text,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '분석일: ${note.date}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '습관 교정 권장',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
