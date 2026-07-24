import 'package:flutter/foundation.dart';

import '../../data/repositories/timeline_repository.dart';
import '../profile/child_profile_controller.dart';
import 'timeline_item.dart';

class TimelineController {
  TimelineController(this._repository, this._childProfileController) {
    _childProfileController.activeProfileId.addListener(_handleChildChange);
  }

  final TimelineRepository _repository;
  final ChildProfileController _childProfileController;

  final ValueNotifier<List<TimelineItem>> items =
      ValueNotifier<List<TimelineItem>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);
  final ValueNotifier<int> revision = ValueNotifier<int>(0);
  final ValueNotifier<EventType?> selectedFilter = ValueNotifier<EventType?>(
    null,
  );

  int _loadGeneration = 0;

  String? get _activeChildId => _childProfileController.activeProfileId.value;

  void _handleChildChange() {
    load(selectedFilter.value);
  }

  Future<void> load([EventType? type]) async {
    final generation = ++_loadGeneration;
    isLoading.value = true;
    error.value = null;

    if (type != selectedFilter.value) {
      selectedFilter.value = type;
    }

    try {
      final childId = _activeChildId;
      final data = await _repository.getFiltered(type, childId: childId);
      if (generation != _loadGeneration) return;
      items.value = data;
    } catch (e) {
      if (generation != _loadGeneration) return;
      error.value = 'Nepodařilo se načíst přehled.';
    } finally {
      if (generation == _loadGeneration) {
        isLoading.value = false;
      }
    }
  }

  Future<void> reloadCurrent() async {
    await load(selectedFilter.value);
  }

  Future<void> add(TimelineItem item) async {
    error.value = null;

    try {
      await _repository.addItem(item, childId: _activeChildId);
      await reloadCurrent();
      revision.value++;
    } catch (e) {
      error.value = 'Nepodařilo se uložit záznam.';
      rethrow;
    }
  }

  Future<void> update(TimelineItem item) async {
    error.value = null;

    try {
      await _repository.updateItem(item, fallbackChildId: _activeChildId);
      await reloadCurrent();
      revision.value++;
    } catch (e) {
      error.value = 'Nepodařilo se upravit záznam.';
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    error.value = null;

    try {
      await _repository.deleteItem(id);
      await reloadCurrent();
      revision.value++;
    } catch (e) {
      error.value = 'Nepodařilo se smazat záznam.';
      rethrow;
    }
  }

  void dispose() {
    _childProfileController.activeProfileId.removeListener(_handleChildChange);
    items.dispose();
    isLoading.dispose();
    error.dispose();
    revision.dispose();
    selectedFilter.dispose();
  }
}
