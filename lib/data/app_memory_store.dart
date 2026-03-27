import 'package:flutter/material.dart';
import '../features/feeding/feeding_model.dart';
import '../features/timeline/timeline_item.dart';

class AppMemoryStore {
  static final List<FeedingRecord> feedingRecords = [];

  static final ValueNotifier<List<TimelineItem>> timelineItems =
      ValueNotifier([]);
}