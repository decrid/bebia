import '../timeline/timeline_item.dart';
import 'cry_detection_result.dart';

abstract class CryDetectionService {
  Future<CryDetectionResult> detect(TimelineItem cryingItem);
}