import 'package:flutter/material.dart';

import '../characters.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({
    super.key,
    required this.completedGlyphs,
    required this.selectedGlyph,
    required this.unviewedGlyphs,
    required this.onCharacterViewed,
    required this.onThemeSelection,
  });

  final List<String> completedGlyphs;
  final String? selectedGlyph;
  final Set<String> unviewedGlyphs;
  final ValueChanged<String> onCharacterViewed;
  final void Function(CharacterAsset?, Color) onThemeSelection;

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  String? _selectedGlyph;

  @override
  void initState() {
    super.initState();
    _selectedGlyph = widget.selectedGlyph;
  }

  void _toggleTheme() {
    final glyph = _selectedGlyph;
    if (glyph == null) return;

    final character = characterAssetByGlyph[glyph]!;
    final isRemovingTheme = widget.selectedGlyph == glyph;
    final color =
        isRemovingTheme ? const Color(0x00000000) : character.themeColor;

    widget.onThemeSelection(isRemovingTheme ? null : character, color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCharacter = _selectedGlyph == null
        ? null
        : characterAssetByGlyph[_selectedGlyph];

    return Scaffold(
      appBar: AppBar(title: const Text('내 캐릭터 보관함')),
      body: widget.completedGlyphs.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  '아직 획득한 캐릭터가 없습니다.\n글씨를 완성한 후 학습을 완료해 보세요.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 600
                    ? (constraints.maxWidth / 180).floor().clamp(3, 5)
                    : 2;
                return Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 160,
                        ),
                        itemCount: widget.completedGlyphs.length,
                        itemBuilder: (context, index) {
                          final glyph = widget.completedGlyphs[index];
                          final character = characterAssetByGlyph[glyph]!;
                          final isSelected = _selectedGlyph == glyph;
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isSelected
                                  ? BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    )
                                  : BorderSide(
                                      color: theme.colorScheme.outlineVariant,
                                    ),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() => _selectedGlyph = glyph);
                                widget.onCharacterViewed(glyph);
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Column(
                                children: [
                                  Expanded(
                                    child: Image.asset(
                                      character.imagePath,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    color: isSelected
                                        ? theme.colorScheme.primaryContainer
                                        : theme.colorScheme.surfaceContainerLow,
                                    child: Text(
                                      character.name,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? theme.colorScheme.onPrimaryContainer
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                                  ),
                                  if (widget.unviewedGlyphs.contains(glyph))
                                    const Positioned(
                                      top: 8,
                                      right: 8,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: SizedBox(width: 10, height: 10),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: FilledButton.icon(
                          onPressed:
                              selectedCharacter == null ? null : _toggleTheme,
                          icon: Icon(
                            widget.selectedGlyph == _selectedGlyph
                                ? Icons.remove_circle_outline
                                : Icons.palette_outlined,
                          ),
                          label: Text(
                            widget.selectedGlyph == _selectedGlyph
                                ? '테마 선택 해제'
                                : '테마로 선택하기',
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
