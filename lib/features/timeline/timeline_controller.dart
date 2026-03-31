import 'package:flutter/foundation.dart';

import '../../data/repositories/timeline_repository.dart';
import 'timeline_item.dart';

class TimelineController {
  TimelineController(this._repository);

  final TimelineRepository _repository;

  final ValueNotifier<List<TimelineItem>> items =
      ValueNotifier<List<TimelineItem>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);
  final ValueNotifier<EventType?> selectedFilter = ValueNotifier<EventType?>(
    null,
  );

  Future<void> load([EventType? type]) async {
    isLoading.value = true;
    error.value = null;

    if (type != selectedFilter.value) {
      selectedFilter.value = type;
    }

    try {
      final data = await _repository.getFiltered(type);
      items.value = data;
    } catch (e) {
      error.value = 'Nepodařilo se načíst timeline: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reloadCurrent() async {
    await load(selectedFilter.value);
  }

  Future<void> add(TimelineItem item) async {
    error.value = null;

    try {
      await _repository.addItem(item);
      await reloadCurrent();
    } catch (e) {
      error.value = 'Nepodařilo se uložit záznam: $e';
    }
  }

  Future<void> update(TimelineItem item) async {
    error.value = null;

    try {
      await _repository.updateItem(item);
      await reloadCurrent();
    } catch (e) {
      error.value = 'Nepodařilo se upravit záznam: $e';
    }
  }

  Future<void> delete(int id) async {
    error.value = null;

    try {
      await _repository.deleteItem(id);
      await reloadCurrent();
    } catch (e) {
      error.value = 'Nepodařilo se smazat záznam: $e';
    }
  }

  void dispose() {
    items.dispose();
    isLoading.dispose();
    error.dispose();
    selectedFilter.dispose();
  }
}