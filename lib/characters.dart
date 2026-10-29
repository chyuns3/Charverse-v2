import 'package:flutter/material.dart';

const characterAssetByGlyph = <String, CharacterAsset>{
  'ㅅ': CharacterAsset(glyph: 'ㅅ', name: 'ㅅ', asset: 'deer', themeColor: Color(0xFFCDA68A)),
  '火': CharacterAsset(glyph: '火', name: '火', asset: 'fire', themeColor: Color(0xFFD68163)),
  'い': CharacterAsset(glyph: 'い', name: 'い', asset: 'dog', themeColor: Color(0xFFE1B67B)),
  'キ': CharacterAsset(glyph: 'キ', name: 'キ', asset: 'fox', themeColor: Color(0xFFE58B69)),
};

@immutable
class CharacterAsset {
  const CharacterAsset({
    required this.glyph,
    required this.name,
    required this.asset,
    required this.themeColor,
  });

  final String glyph;
  final String name;
  final String asset;
  final Color themeColor;

  String get imagePath => 'assets/characters/$asset.png';
}

enum LearningStatus { notStarted, inProgress, completed }

@immutable
class CompletionResult {
  const CompletionResult({
    required this.itemId,
    required this.glyph,
    required this.character,
  });

  final int itemId;
  final String glyph;
  final CharacterAsset? character;
}

