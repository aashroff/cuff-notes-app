import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/srs_state.dart';

class StorageService {
  static const _contentBox = 'content_cache';
  static const _versionBox = 'content_versions';
  static const _srsBox = 'srs_progress';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_contentBox);
    await Hive.openBox<int>(_versionBox);
    await Hive.openBox<String>(_srsBox);
  }

  // ── Content cache ──

  Future<void> cacheContent(String topicId, String jsonString, int version) async {
    final box = Hive.box<String>(_contentBox);
    await box.put(topicId, jsonString);
    final vBox = Hive.box<int>(_versionBox);
    await vBox.put(topicId, version);
  }

  Future<String?> getCachedContent(String topicId) async {
    final box = Hive.box<String>(_contentBox);
    return box.get(topicId);
  }

  Future<int> getContentVersion(String topicId) async {
    final box = Hive.box<int>(_versionBox);
    return box.get(topicId) ?? 0;
  }

  // ── SRS progress ──

  Future<void> saveSrsState(SrsState state) async {
    final box = Hive.box<String>(_srsBox);
    await box.put(state.cardId, json.encode(state.toJson()));
  }

  SrsState? getSrsState(String cardId) {
    final box = Hive.box<String>(_srsBox);
    final raw = box.get(cardId);
    if (raw == null) return null;
    return SrsState.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  Map<String, SrsState> getAllSrsStates() {
    final box = Hive.box<String>(_srsBox);
    final map = <String, SrsState>{};
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw != null) {
        final state = SrsState.fromJson(json.decode(raw) as Map<String, dynamic>);
        map[key as String] = state;
      }
    }
    return map;
  }

  int get totalReviewed => Hive.box<String>(_srsBox).length;

  int get totalMastered {
    final box = Hive.box<String>(_srsBox);
    int count = 0;
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw != null) {
        final state = SrsState.fromJson(json.decode(raw) as Map<String, dynamic>);
        if (state.isMastered) count++;
      }
    }
    return count;
  }
}
