// 화면 A: 글자 도감 및 학습 목록 (GET /items) — Charverse v2
//
// ┌──────── 디자인 가이드 대응표: A 목록 ───────────────────────────────────────┐
// │ 번호 │ Flutter 위젯명                    │ 비즈니스 명칭(한글) │ 원칙(P번호)   │
// │ A-1  │ AppBar + BackButton               │ 도감 상단 바        │ P03·P04 일관성│
// │ A-7  │ ListView / GridView (HubCard)     │ 언어·즐겨찾기 허브  │ P02·P07·P08   │
// │ A-9  │ TextField (SearchBar)             │ 실시간 글자 검색창  │ P05·P07 효율성│
// │ A-2  │ ListView.separated (CharacterTile)│ 컴팩트 글자 리스트  │ P06 재인·P08  │
// │ A-8  │ IconButton (Star on/off)          │ 즐겨찾기 별 버튼    │ P01·P04 일관성│
// │ A-4  │ LoadingView                       │ 도감 불러오는 중    │ P01 가시성    │
// │ A-5  │ ErrorView + FilledButton          │ 도감 오류·다시 시도 │ P09 오류 복구 │
// │ A-6  │ EmptyView                         │ 빈 목록·검색결과없음│ P01 가시성    │
// └────────────────────────────────────────────────────────────────────────────┘
// 전환: A → B 는 쌓기(Navigator.push). 적응형: LayoutBuilder 600dp 분기 1곳(A-2 ↔ A-3).
// P번호 = 닐슨 원칙 번호 (docs/디자인가이드.md 2장). 그 원칙을 보여 주는 위젯 줄 끝에 `// A-4 P01` 처럼 단다.
import 'package:flutter/material.dart';

import '../api.dart';
import '../characters.dart';
import '../models.dart';
import '../widgets.dart';
import 'b_detail_screen.dart';
import 'd_collection_screen.dart';

void _discardCompletion(CompletionResult _) {}

/// 이 너비 이상이면 넓은 화면 배치 (Material 3 window size class: medium ≥ 600dp)
const wideBreakpoint = 600.0;

const _hiraganaRows = <String, String>{
  'あ행': 'あいうえお',
  'か행': 'かきくけこがぎぐげご',
  'さ행': 'さしすせそざじずぜぞ',
  'た행': 'たちつてとだじづでど',
  'な행': 'なにぬねの',
  'は행': 'はひふへほばびぶべぼぱぴぷぺぽ',
  'ま행': 'まみむめも',
  'や행': 'やゆよ',
  'ら행': 'らりるれろ',
  'わ행': 'わをん',
};

const _katakanaRows = <String, String>{
  'ア행': 'アイウエオ',
  'カ행': 'カキクケコガギグゲゴ',
  'サ행': 'サシスセソザジズゼゾ',
  'タ행': 'タチツテトダジヅデド',
  'ナ행': 'ナニヌネノ',
  'ハ행': 'ハヒフヘホバビブベボパピプペポ',
  'マ행': 'マミムメモ',
  'ヤ행': 'ヤユヨ',
  'ラ행': 'ラリルレロ',
  'ワ행': 'ワヲン',
};

/// 제목 문자열에서 핵심 유니코드 글자(괄호 안의 문자)를 정밀 추출
String extractGlyph(String title) {
  final match = RegExp(r'\(([^)]+)\)').firstMatch(title);
  if (match != null) {
    return match.group(1)!.trim();
  }
  return title.isNotEmpty ? title[0] : '';
}

List<String> visibleItemTags(Item item, [LearningStatus? status]) {
  final glyph = extractGlyph(item.title);
  final tags = item.tags
      .where((tag) =>
          tag != '오십음도' &&
          tag != '히라가나' &&
          tag != '가타카나')
      .toList();

  final rows = item.tags.contains('히라가나')
      ? _hiraganaRows
      : item.tags.contains('가타카나')
          ? _katakanaRows
          : const <String, String>{};
  if (status != null) {
    tags.add(switch (status) {
      LearningStatus.notStarted => '미학습',
      LearningStatus.inProgress => '학습 중',
      LearningStatus.completed => '학습 완료',
    });
  }
  for (final entry in rows.entries) {
    if (entry.value.contains(glyph)) {
      tags.add(entry.key);
      break;
    }
  }
  return tags;
}

/// 메인 허브 메뉴 메타데이터 (한글 'ㄱㄴㄷ', 히라가나 'あ', 가타카나 'ア', 한자 '文', 즐겨찾기 '⭐')
const _hubCategories = [
  (
    key: '한글',
    name: '한글',
    english: 'Hangul',
    desc: '자음 19자 · 모음 21자 (총 40자)',
    badge: '40자',
    glyphIcon: 'ㄱㄴㄷ',
    color: Color(0xFF3F51B5),
    preview: 'ㄱ ㄴ ㄷ ㄹ … ㅏ ㅑ ㅓ ㅕ',
  ),
  (
    key: '히라가나',
    name: '히라가나',
    english: 'Hiragana',
    desc: '일본어 기본 오십음도 (총 46자)',
    badge: '46자',
    glyphIcon: 'あ',
    color: Color(0xFFE91E63),
    preview: 'あ い う え お … わ を ん',
  ),
  (
    key: '가타카나',
    name: '가타카나',
    english: 'Katakana',
    desc: '외래어 표기 오십음도 (총 46자)',
    badge: '46자',
    glyphIcon: 'ア',
    color: Color(0xFF009688),
    preview: 'ア イ ウ エ オ … ワ ヲ ン',
  ),
  (
    key: '한자',
    name: '한자',
    english: 'Hanja',
    desc: '일상 필수 기초 한자 30선',
    badge: '30자',
    glyphIcon: '文',
    color: Color(0xFF795548),
    preview: '一 二 三 四 … 日 月 火 水',
  ),
  (
    key: '즐겨찾기',
    name: '즐겨찾기',
    english: 'Favorites',
    desc: '내가 별표(⭐)로 보관한 글자 모아보기',
    badge: '보관함',
    glyphIcon: '⭐',
    color: Color(0xFFF57F17),
    preview: '⭐ 즐겨찾기한 글자를 한곳에서 집중 복습',
  ),
];

class ListScreen extends StatefulWidget {
  const ListScreen({
    super.key,
    this.load = fetchItems,
    this.loadNotes = fetchNotes,
    this.completedGlyphs = const {},
    this.unviewedCharacterCount = 0,
    this.learningStatuses = const {},
    this.onStartLearning,
    this.onStatusChange,
    this.onComplete = _discardCompletion,
    this.onOpenCollection,
  });

  final ItemsLoader load;
  final NotesLoader loadNotes;
  final Map<int, String> completedGlyphs;
  final int unviewedCharacterCount;
  final Map<int, LearningStatus> learningStatuses;
  final ValueChanged<int>? onStartLearning;
  final void Function(int itemId, LearningStatus status)? onStatusChange;
  final ValueChanged<CompletionResult> onComplete;
  final VoidCallback? onOpenCollection;

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Future<List<Item>> _future = widget.load();

  // STATE: 선택된 메인 허브 메뉴 (null: 첫 화면 허브 뷰 / '한글'|'히라가나'|'가타카나'|'한자'|'즐겨찾기')
  String? _selectedCategory;

  // STATE: 글자 검색어 필터링
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // STATE: 즐겨찾기 글자 ID 집합 (기본 실행 상태: 빈 상태 유지)
  final Set<int> _favoriteIds = {};

  // STATE: 선택된 일반 태그 필터
  String? _selectedTag;

  // STATE: 선택된 획수 필터
  String? _selectedStrokeTag;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 다시 시도 = Future만 새로 만드는 setState
  void _retry() {
    setState(() {
      _future = widget.load();
    });
  }

  Future<void> _openCollection() async {
    if (widget.onOpenCollection != null) {
      widget.onOpenCollection!();
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CollectionScreen(
          completedGlyphs: widget.completedGlyphs.values.toSet().toList()
            ..sort(),
          selectedGlyph: null,
          unviewedGlyphs: const {},
          onCharacterViewed: (_) {},
          onThemeSelection: (_, _) {},
        ),
      ),
    );
  }

  void _toggleFavorite(int itemId) {
    setState(() {
      if (_favoriteIds.contains(itemId)) {
        _favoriteIds.remove(itemId);
      } else {
        _favoriteIds.add(itemId);
      }
    });
  }

  void _open(Item item) async {
    widget.onStartLearning?.call(item.id);
    final updatedFav = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DetailScreen(
          item: item,
          loadNotes: widget.loadNotes,
          isFavorite: _favoriteIds.contains(item.id),
          learningStatus:
              widget.learningStatuses[item.id] ?? LearningStatus.notStarted,
          onStatusChange: widget.onStatusChange ?? (_, _) {},
          onComplete: widget.onComplete,
        ),
      ),
    );

    if (updatedFav != null && mounted) {
      setState(() {
        if (updatedFav) {
          _favoriteIds.add(item.id);
        } else {
          _favoriteIds.remove(item.id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHubView = _selectedCategory == null;

    return PopScope(
      canPop: isHubView,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !isHubView) {
          // 글자 리스트에서 뒤로가기 시 메인 허브로 안전하게 복귀 (P03 사용자 통제)
          setState(() {
            _selectedCategory = null;
            _searchQuery = '';
            _searchController.clear();
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // A-1 P03 P04: 허브에서는 로고, 리스트에서는 뒤로가기 및 타이틀
          leading: isHubView
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: '메인 메뉴로 복귀',
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isHubView ? 'Charverse' : '$_selectedCategory 글자 목록',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                isHubView
                    ? '글자를 학습하며 세계를 넓혀가자'
                    : (_selectedCategory == '즐겨찾기'
                        ? '보관한 중요 글자를 복습하세요'
                        : '원하는 글자를 선택하여 직접 써보며 학습하세요'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              key: const ValueKey('characterCollectionButton'),
              tooltip: '내 캐릭터 보관함',
              onPressed: _openCollection,
              icon: Badge(
                isLabelVisible: widget.unviewedCharacterCount > 0,
                label: Text('${widget.unviewedCharacterCount}'),
                child: const Icon(Icons.pets_rounded),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: FutureBuilder<List<Item>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const LoadingView(
                label: '글자 데이터를 불러오고 있습니다…',
              ); // A-4 P01
            }
            if (snap.hasError) {
              return ErrorView(
                title: '글자 목록을 불러오지 못했습니다.',
                message: '${snap.error}',
                onRetry: _retry,
              ); // A-5 P09
            }
            final allItems = snap.data ?? const <Item>[];

            // 1단계 (첫 화면): 언어 4종 + 즐겨찾기 메뉴만 표시 (단일 글자는 숨김)
            if (isHubView) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final progressByCategory = <String, String>{};
                  for (final cat in _hubCategories) {
                    final categoryItems = cat.key == '즐겨찾기'
                        ? allItems
                            .where((item) => _favoriteIds.contains(item.id))
                            .toList()
                        : allItems.where((item) {
                            return item.tags.contains(cat.key) ||
                                item.title.contains(cat.key);
                          }).toList();
                    final learnedCount = categoryItems
                        .where((item) {
                          final status = widget.learningStatuses[item.id] ??
                              LearningStatus.notStarted;
                          return status == LearningStatus.inProgress ||
                              status == LearningStatus.completed;
                        })
                        .length;
                    progressByCategory[cat.key] =
                        '$learnedCount/${categoryItems.length}';
                  }
                  return _HubListView(
                    favoriteCount: _favoriteIds.length,
                    progressByCategory: progressByCategory,
                    onSelectCategory: (cat) {
                      setState(() {
                        _selectedCategory = cat;
                        _searchQuery = '';
                        _selectedTag = null;
                        _selectedStrokeTag = null;
                        _searchController.clear();
                      });
                    },
                  ); // A-7 P02 P07 P08
                },
              );
            }

            // 2단계 (진입 후): 선택된 언어 또는 즐겨찾기 항목 필터링
            List<Item> baseItems;
            if (_selectedCategory == '즐겨찾기') {
              baseItems =
                  allItems.where((it) => _favoriteIds.contains(it.id)).toList();
            } else {
              baseItems = allItems.where((it) {
                return it.tags.contains(_selectedCategory) ||
                    it.title.contains(_selectedCategory!);
              }).toList();
            }

            // 실시간 검색어 필터링
            var filteredItems = _searchQuery.trim().isEmpty
                ? baseItems
                : baseItems.where((it) {
                    final q = _searchQuery.trim().toLowerCase();
                    final glyph = extractGlyph(it.title).toLowerCase();
                    return it.title.toLowerCase().contains(q) ||
                        it.subtitle.toLowerCase().contains(q) ||
                        glyph.contains(q) ||
                        it.tags.any((t) => t.toLowerCase().contains(q));
                  }).toList();

            final availableTags = {
              for (final item in baseItems)
                for (final tag in visibleItemTags(
                  item,
                  widget.learningStatuses[item.id] ?? LearningStatus.notStarted,
                ))
                  tag,
            }.toList();
            final strokeTags = availableTags
                .where((tag) => RegExp(r'^\d+획$').hasMatch(tag))
                .toSet()
                .toList()
              ..sort((left, right) => int.parse(left.replaceAll('획', ''))
                  .compareTo(int.parse(right.replaceAll('획', ''))));
            final generalTags = availableTags
                .where((tag) => !strokeTags.contains(tag))
                .toList()
              ..sort();
            if (_selectedTag != null && !generalTags.contains(_selectedTag)) {
              _selectedTag = null;
            }
            if (_selectedStrokeTag != null &&
                !strokeTags.contains(_selectedStrokeTag)) {
              _selectedStrokeTag = null;
            }
            if (_selectedTag != null) {
              filteredItems = filteredItems
                  .where((item) => visibleItemTags(
                        item,
                        widget.learningStatuses[item.id] ??
                            LearningStatus.notStarted,
                      ).contains(_selectedTag))
                  .toList();
            }
            if (_selectedStrokeTag != null) {
              filteredItems = filteredItems
                  .where((item) =>
                      visibleItemTags(item).contains(_selectedStrokeTag))
                  .toList();
            }

            // 학습 완료한 글자는 캐릭터 유무와 관계없이 항상 마지막에 둔다.
            filteredItems.sort((left, right) {
              final leftCompleted =
                  widget.learningStatuses[left.id] == LearningStatus.completed;
              final rightCompleted =
                  widget.learningStatuses[right.id] == LearningStatus.completed;
              return leftCompleted == rightCompleted
                  ? left.id.compareTo(right.id)
                  : (leftCompleted ? 1 : -1);
            });

            return Column(
              children: [
                // A-9 P05 P07: 실시간 글자 검색창
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: theme.colorScheme.surface,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "'$_selectedCategory' 글자, 발음, 획 검색…",
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withAlpha(128),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                if (generalTags.isNotEmpty || strokeTags.isNotEmpty)
                  SizedBox(
                    height: 48,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final tag in <String?>[null, ...generalTags]) ...[
                            FilterChip(
                              showCheckmark: false,
                              selected: _selectedTag == tag,
                              label: Text(tag ?? '전체'),
                              onSelected: (_) => setState(() {
                                _selectedTag = tag;
                              }),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (strokeTags.isNotEmpty)
                            Container(
                              height: 32,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: _selectedStrokeTag == null
                                    ? theme.colorScheme.surfaceContainerLow
                                    : theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedStrokeTag,
                                  hint: Text(
                                    '획수',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  iconSize: 18,
                                  padding: EdgeInsets.zero,
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('전체 획수'),
                                    ),
                                    for (final tag in strokeTags)
                                      DropdownMenuItem<String>(
                                        value: tag,
                                        child: Text(tag),
                                      ),
                                  ],
                                  onChanged: (tag) => setState(() {
                                    _selectedStrokeTag = tag;
                                  }),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                // 검색 결과 헤더 안내
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory == '즐겨찾기'
                            ? '보관된 글자 총 ${filteredItems.length}개'
                            : '$_selectedCategory 학습 글자 (${filteredItems.length}개)',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        Text(
                          "'$_searchQuery' 검색 결과",
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                // A-2 P06 P08: 컴팩트한 글자 리스트
                Expanded(
                  child: filteredItems.isEmpty
                      ? EmptyView(
                          message: _selectedCategory == '즐겨찾기' &&
                                  _searchQuery.isEmpty
                              ? '아직 즐겨찾기한 글자가 없습니다.\n글자 목록에서 별(⭐)을 눌러 추가해 보세요!'
                              : "'$_searchQuery' 검색 결과가 없습니다.",
                        ) // A-6 P01
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: filteredItems.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final item = filteredItems[i];
                            final isFav = _favoriteIds.contains(item.id);
                            final learningStatus =
                                widget.learningStatuses[item.id] ??
                                    LearningStatus.notStarted;
                            final completedGlyph =
                                widget.completedGlyphs[item.id];
                            final character = completedGlyph == null
                                ? null
                                : characterAssetByGlyph[completedGlyph];
                            return CharacterListTile(
                              item: item,
                              isFavorite: isFav,
                              learningStatus: learningStatus,
                              character: character,
                              onToggleFavorite: () => _toggleFavorite(item.id),
                              onTap: () => _open(item),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A-7 P02 P07 P08: 첫 화면 언어 4종 + ⭐ 즐겨찾기 메인 허브 뷰
class _HubListView extends StatefulWidget {
  const _HubListView({
    required this.favoriteCount,
    required this.progressByCategory,
    required this.onSelectCategory,
  });

  final int favoriteCount;
  final Map<String, String> progressByCategory;
  final ValueChanged<String> onSelectCategory;

  @override
  State<_HubListView> createState() => _HubListViewState();
}

class _HubListViewState extends State<_HubListView> {
  late final List<String> _orderedKeys =
      _hubCategories.map((category) => category.key).toList();

  Map<String, Object> _categoryByKey(String key) {
    final category = _hubCategories.firstWhere((item) => item.key == key);
    return {
      'key': category.key,
      'name': category.name,
      'english': category.english,
      'desc': category.desc,
      'badge': category.badge,
      'glyphIcon': category.glyphIcon,
      'color': category.color,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_stories, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '학습할 문자 영역을 선택하세요',
                      style: text.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '영역을 선택해 학습하고, 우측 = 핸들을 드래그해 순서를 바꾸세요.',
                style: text.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            buildDefaultDragHandles: false,
            itemCount: _orderedKeys.length,
            onReorderItem: (oldIndex, newIndex) {
              setState(() {
                final key = _orderedKeys.removeAt(oldIndex);
                _orderedKeys.insert(newIndex, key);
              });
            },
            itemBuilder: (context, index) {
              final category = _categoryByKey(_orderedKeys[index]);
              final key = category['key'] as String;
              final name = category['name'] as String;
              final english = category['english'] as String;
              final description = category['desc'] as String;
              final glyphIcon = category['glyphIcon'] as String;
              final color = category['color'] as Color;
              final progress = widget.progressByCategory[key] ?? '0/0';

              return Padding(
                key: ValueKey('hub-$key'),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => widget.onSelectCategory(key),
                    child: Container(
                      decoration: BoxDecoration(
                        border:
                            Border(left: BorderSide(color: color, width: 6)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: color.withAlpha(35),
                            child: Text(
                              glyphIcon,
                              style: TextStyle(
                                color: color,
                                fontSize: glyphIcon.length > 2 ? 14 : 20,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        english,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  key == '즐겨찾기'
                                      ? '${widget.favoriteCount}개 단어'
                                      : '$progress 학습',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 44,
                            child: ReorderableDragStartListener(
                              index: index,
                              key: ValueKey('drag-$key'),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Icon(
                                  Icons.drag_handle_rounded,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A-2 P06 P08: 컴팩트한 글자 리스트 타일
class CharacterListTile extends StatelessWidget {
  const CharacterListTile({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.learningStatus,
    required this.character,
    required this.onToggleFavorite,
    required this.onTap,
  });

  final Item item;
  final bool isFavorite;
  final LearningStatus learningStatus;
  final CharacterAsset? character;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final glyph = extractGlyph(item.title);
    final isCompleted = learningStatus == LearningStatus.completed;
    final statusLabel = switch (learningStatus) {
      LearningStatus.notStarted => '미학습',
      LearningStatus.inProgress => '학습 중',
      LearningStatus.completed => '학습 완료',
    };
    final statusColor = switch (learningStatus) {
      LearningStatus.notStarted => theme.colorScheme.outline,
      LearningStatus.inProgress => Colors.orange[800]!,
      LearningStatus.completed => Colors.green[700]!,
    };

    return Card(
      elevation: 0.8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted
              ? Colors.green.withAlpha(160)
              : theme.colorScheme.outlineVariant.withAlpha(100),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // 가독성 좋은 두꺼운 대형 유니코드 폰트 박스 (P06 기억보다 재인)
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withAlpha(35)
                      : theme.colorScheme.primaryContainer.withAlpha(120),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(60),
                  ),
                ),
                alignment: Alignment.center,
                child: character == null
                    ? Text(
                        glyph,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                          fontFamily: 'Roboto',
                        ),
                      )
                    : Image.asset(character!.imagePath, fit: BoxFit.contain),
              ),
              const SizedBox(width: 14),
              // 중앙 글자명 및 부제/태그 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.title,
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.tags.length > 1) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.tags[1],
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(22),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: statusColor.withAlpha(140)),
                      ),
                      child: Text(
                        statusLabel,
                        style: text.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // A-8 P01 P04: 별 표시 즐겨찾기 (기본 off 회색 별 ↔ on 노란 별)
              IconButton(
                tooltip: isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isFavorite ? Colors.amber[700] : Colors.grey[400],
                  size: 26,
                ),
                onPressed: onToggleFavorite,
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 하위 호환을 위한 타입 별칭
typedef ItemCard = CharacterListTile;
typedef CharacterCard = CharacterListTile;
