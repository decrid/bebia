import '../../core/app_services.dart';
import 'timeline_item.dart';

abstract interface class TimelineFormSubmission {
  bool get hasActiveProfile;

  Future<void> save(TimelineItem item, {required bool isEdit});
}

class AppTimelineFormSubmission implements TimelineFormSubmission {
  const AppTimelineFormSubmission();

  @override
  bool get hasActiveProfile =>
      AppServices.childProfileController.activeProfile != null;

  @override
  Future<void> save(TimelineItem item, {required bool isEdit}) {
    return isEdit
        ? AppServices.timelineController.update(item)
        : AppServices.timelineController.add(item);
  }
}
