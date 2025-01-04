import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/draft_item.dart';

const _draftKey = 'lost_item_drafts';

final draftListProvider =
    AsyncNotifierProvider<DraftNotifier, List<DraftItem>>(() {
  return DraftNotifier();
});

class DraftNotifier extends AsyncNotifier<List<DraftItem>> {
  late SharedPreferences _prefs;

  @override
  Future<List<DraftItem>> build() async {
    _prefs = await SharedPreferences.getInstance();
    return _loadDrafts();
  }

  Future<List<DraftItem>> _loadDrafts() async {
    if (!_prefs.containsKey(_draftKey)) {
      return [];
    }
    final draftsJson = _prefs.getStringList(_draftKey) ?? [];
    return draftsJson.map((json) {
      final Map<String, dynamic> data = jsonDecode(json);
      return DraftItem.fromJson(data);
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> _saveDrafts(List<DraftItem> drafts) async {
    try {
      final draftsJson = drafts.map((draft) {
        final Map<String, dynamic> draftMap = draft.toJson();
        // DateTimeをISOString形式で保存
        final Map<String, dynamic> cleanFormData = Map.from(draft.formData)
          ..updateAll((key, value) {
            if (value is DateTime) {
              return value.toIso8601String();
            }
            return value;
          });
        draftMap['formData'] = cleanFormData;
        return jsonEncode(draftMap);
      }).toList();
      await _prefs.setStringList(_draftKey, draftsJson);
    } catch (e) {
      print('Error saving drafts: $e');
      rethrow;
    }
  }

  Future<String> saveDraft(Map<String, dynamic> formData,
      {String? draftId}) async {
    try {
      final now = DateTime.now();
      final drafts = await _loadDrafts();

      // DateTimeをString形式に変換
      final Map<String, dynamic> cleanFormData = Map.from(formData)
        ..updateAll((key, value) {
          if (value is DateTime) {
            return value.toIso8601String();
          }
          return value;
        });

      if (draftId != null) {
        final index = drafts.indexWhere((draft) => draft.id == draftId);
        if (index != -1) {
          drafts[index] = drafts[index].copyWith(
            formData: cleanFormData,
            updatedAt: now,
          );
        }
      } else {
        final newDraft = DraftItem(
          id: const Uuid().v4(),
          formData: cleanFormData,
          createdAt: now,
          updatedAt: now,
        );
        drafts.add(newDraft);
        draftId = newDraft.id;
      }

      await _saveDrafts(drafts);
      state = AsyncData(drafts);
      return draftId!;
    } catch (e) {
      print('Error saving draft: $e');
      rethrow;
    }
  }

  Future<void> deleteDraft(String id) async {
    final drafts = await _loadDrafts();
    drafts.removeWhere((draft) => draft.id == id);
    await _saveDrafts(drafts);
    state = AsyncData(drafts);
  }

  Future<DraftItem?> getDraft(String id) async {
    final drafts = await _loadDrafts();
    try {
      final draft = drafts.firstWhere((draft) => draft.id == id);
      return draft;
    } catch (e) {
      return null;
    }
  }
}
