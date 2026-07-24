import 'package:bebia/core/platform/bebia_platform_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('widget launch targets accept only known app sections', () {
    final timeline = BebiaLaunchTarget.parse('timeline/feeding');
    final add = BebiaLaunchTarget.parse('add/sleep');

    expect(timeline?.section, BebiaLaunchSection.timeline);
    expect(timeline?.eventType, 'feeding');
    expect(add?.section, BebiaLaunchSection.add);
    expect(add?.eventType, 'sleep');
    expect(BebiaLaunchTarget.parse('timeline/unknown'), isNull);
    expect(BebiaLaunchTarget.parse('add'), isNull);
    expect(BebiaLaunchTarget.parse('home/feeding'), isNull);
    expect(BebiaLaunchTarget.parse('settings/delete-data'), isNull);
    expect(BebiaLaunchTarget.parse(null), isNull);
  });
}
