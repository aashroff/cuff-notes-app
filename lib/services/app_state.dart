import 'package:flutter/foundation.dart';
import '../models/topic.dart';
import '../models/srs_state.dart';
import '../models/reference_section.dart';
import '../services/storage_service.dart';
import '../services/content_service.dart';

/// Central app state that screens can listen to.
/// Replaces scattered setState calls for shared data like
/// topics, SRS progress, and reference sections.
class AppState extends ChangeNotifier {
  final StorageService storage;
  final ContentService content;

  List<Topic> _topics = [];
  List<ReferenceSection> _references = [];
  bool _isLoading = true;
  String? _error;

  AppState({required this.storage})
      : content = ContentService(storage);

  // ── Getters ──

  List<Topic> get topics => _topics;
  List<ReferenceSection> get references => _references;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalCards => _topics.fold(0, (sum, t) => sum + t.cards.length);
  int get totalReviewed => storage.totalReviewed;
  int get totalMastered => storage.totalMastered;

  // ── Loading ──

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _topics = await content.loadAllTopics();
      _references = await content.loadReferences();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── SRS convenience methods ──

  SrsState? getSrs(String cardId) => storage.getSrsState(cardId);

  int masteredForTopic(Topic topic) {
    return topic.cards
        .where((c) => storage.getSrsState(c.id)?.isMastered ?? false)
        .length;
  }

  int reviewedForTopic(Topic topic) {
    return topic.cards
        .where((c) => storage.getSrsState(c.id) != null)
        .length;
  }

  Future<void> saveSrs(SrsState state) async {
    await storage.saveSrsState(state);
    notifyListeners();
  }
}
