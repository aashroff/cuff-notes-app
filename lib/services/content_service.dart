import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/topic.dart';
import '../models/reference_section.dart';
import 'storage_service.dart';

class ContentService {
  static const _baseUrl =
      'https://raw.githubusercontent.com/aashroff/cuffnotes-content/main/content';

  // Fallback topic IDs if manifest cannot be loaded
  static const _fallbackTopicIds = [
    'theft',
    'assault',
    'public_order',
    'asb',
    'pace',
    'drones',
    'criminal_damage',
  ];

  final StorageService _storage;

  ContentService(this._storage);

  /// Fetch the list of topic IDs from the remote manifest,
  /// falling back to cache, then bundled asset, then hardcoded list.
  Future<List<String>> _getTopicIds() async {
    // 1. Try GitHub manifest
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/manifest.json'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final topics = (data['topics'] as List<dynamic>).cast<String>();
        await _storage.cacheContent(
            'manifest', response.body, data['version'] as int? ?? 1);
        return topics;
      }
    } catch (_) {}

    // 2. Try cached manifest
    try {
      final cached = await _storage.getCachedContent('manifest');
      if (cached != null) {
        final data = json.decode(cached) as Map<String, dynamic>;
        return (data['topics'] as List<dynamic>).cast<String>();
      }
    } catch (_) {}

    // 3. Try bundled manifest
    try {
      final raw = await rootBundle.loadString('assets/content/manifest.json');
      final data = json.decode(raw) as Map<String, dynamic>;
      return (data['topics'] as List<dynamic>).cast<String>();
    } catch (_) {}

    // 4. Hardcoded fallback
    return _fallbackTopicIds;
  }

  /// Load all topics dynamically based on the manifest.
  Future<List<Topic>> loadAllTopics() async {
    final topicIds = await _getTopicIds();
    final topics = <Topic>[];
    for (final id in topicIds) {
      try {
        topics.add(await loadTopic(id));
      } catch (_) {
        // Skip topics that fail to load rather than crashing
      }
    }
    return topics;
  }

  Future<Topic> loadTopic(String topicId) async {
    // 1. Try fetching from GitHub
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/$topicId.json'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final cachedVersion = await _storage.getContentVersion(topicId);
        final remoteVersion = data['version'] as int? ?? 1;
        if (remoteVersion > cachedVersion) {
          await _storage.cacheContent(topicId, response.body, remoteVersion);
        }
        return Topic.fromJson(data);
      }
    } catch (_) {}

    // 2. Try loading from local cache
    try {
      final cached = await _storage.getCachedContent(topicId);
      if (cached != null) {
        return Topic.fromJson(json.decode(cached) as Map<String, dynamic>);
      }
    } catch (_) {}

    // 3. Fall back to bundled asset
    final raw = await rootBundle.loadString('assets/content/$topicId.json');
    return Topic.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  /// Load reference sections (GOWISELY, Necessity, etc.)
  Future<List<ReferenceSection>> loadReferences() async {
    // 1. Try GitHub
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/reference.json'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final cachedVersion = await _storage.getContentVersion('reference');
        final remoteVersion = data['version'] as int? ?? 1;
        if (remoteVersion > cachedVersion) {
          await _storage.cacheContent(
              'reference', response.body, remoteVersion);
        }
        return _parseReferences(data);
      }
    } catch (_) {}

    // 2. Try cache
    try {
      final cached = await _storage.getCachedContent('reference');
      if (cached != null) {
        return _parseReferences(
            json.decode(cached) as Map<String, dynamic>);
      }
    } catch (_) {}

    // 3. Bundled asset
    try {
      final raw =
          await rootBundle.loadString('assets/content/reference.json');
      return _parseReferences(json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return [];
    }
  }

  List<ReferenceSection> _parseReferences(Map<String, dynamic> data) {
    return (data['sections'] as List<dynamic>)
        .map((s) => ReferenceSection.fromJson(s as Map<String, dynamic>))
        .toList();
  }
}