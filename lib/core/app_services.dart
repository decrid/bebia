import '../data/repositories/timeline_repository.dart';
import '../features/timeline/timeline_controller.dart';

class AppServices {
  static final TimelineController timelineController =
      TimelineController(TimelineRepository());
}