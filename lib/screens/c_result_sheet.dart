// 화면 C: AI 글쓰기 습관 정밀 진단서 — 덮기(modal) · Charverse v2
//
// ┌──────── 디자인 가이드 대응표: C 진단서(임의) ───────────────────────────────┐
// │ 번호 │ Flutter 위젯명                   │ 비즈니스 명칭(한글)  │ 원칙(P번호)   │
// │ C-1  │ showModalBottomSheet + 손잡이    │ 진단서 모달 시트     │ P03 통제·자유 │
// │ C-2  │ Text(bodyMedium)                 │ 진단 리포트 타이틀   │ P02 실세계    │
// │ C-3  │ ListTile × 3                     │ 교정 분석 리스트     │ P09 오류 진단 │
// │ C-4  │ Text(bodySmall, 회색)            │ AI 진단 예시 고지    │ P10 도움말    │
// └────────────────────────────────────────────────────────────────────────────┘
//
// ⚠ 실제 계산·추천·검색 로직 없음 (안내문 5장: "실제 비즈니스 로직"은 감점).
//   어떤 항목에서 열어도 아래 _presetResults(사전 정의된 AI 진단 결과)를 그대로 보여 준다.
//   진짜 AI 생성/분석은 앱 외부 또는 향후 기능(기획 문서의 "AI 활용 기회")으로만 설명한다.
import 'package:flutter/material.dart';

import '../models.dart';

/// 사전 정의된 AI 글쓰기 습관 정밀 진단 예시 데이터
const _presetResults = [
  (
    icon: Icons.trending_up,
    title: '획의 방향성: 상향 경사 보정 필요',
    detail: '가로획을 그을 때 수평 기준 오른쪽으로 약 12도 상승하는 습관이 있습니다. 의도적으로 수평을 유지해 보세요.',
  ),
  (
    icon: Icons.format_list_numbered,
    title: '획순 준수율: 중간 매듭 획순 주의',
    detail: '전체 획순 중 2번째 획과 3번째 획을 뒤바꿔 쓰는 빈도가 높습니다. 획순 가이드를 재확인해 주세요.',
  ),
  (
    icon: Icons.balance,
    title: '글자 균형도: 우측 치우침 현상',
    detail: '글자의 무게 중심이 사분면 기준 우하단에 쏠려 있습니다. 중심 획의 기점을 5% 좌측으로 이동해 보세요.',
  ),
];

class ResultSheet extends StatelessWidget {
  const ResultSheet({super.key, required this.baseItem});

  final Item baseItem;

  /// 덮기(modal): 지금 화면 위에 잠깐 띄우고 닫는다.
  static Future<void> show(BuildContext context, Item item) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true, // C-1 P03: 손잡이를 제공하여 아래로 스와이프해 닫을 수 있도록 지원
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ResultSheet(baseItem: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.psychology,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI 필기 습관 정밀 진단서',
                        style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      // C-2 P02: 진단 대상 및 기준 안내
                      Text(
                        "'${baseItem.title}' 필기 패턴 분석 리포트",
                        style: text.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // C-3 P09: 항목별 교정 분석 3가지
            for (final r in _presetResults)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Icon(r.icon, size: 20, color: theme.colorScheme.onSecondaryContainer),
                  ),
                  title: Text(
                    r.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      r.detail,
                      style: text.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            // C-4 P10: AI 예시 결과 및 한계 고지
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '※ 본 리포트는 초급 학습자 필기 오류 데이터를 기반으로 사전 생성된 AI 가상 진단 보고서입니다. (중간고사 UI 프로토타입 규정 준수)',
                      style: text.bodySmall?.copyWith(color: Colors.grey[700], fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // C-1 P03: 닫기 버튼
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인 완료 (닫기)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
