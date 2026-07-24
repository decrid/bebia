import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum BebiaLaunchSection { home, timeline, add }

@immutable
class BebiaLaunchTarget {
  const BebiaLaunchTarget({required this.section, this.eventType});

  final BebiaLaunchSection section;
  final String? eventType;

  static BebiaLaunchTarget? parse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final segments = raw.split('/');
    if (segments.length > 2) return null;
    final section = switch (segments.first) {
      'home' => BebiaLaunchSection.home,
      'timeline' => BebiaLaunchSection.timeline,
      'add' => BebiaLaunchSection.add,
      _ => null,
    };
    if (section == null) return null;
    final eventType = segments.length == 2 ? segments[1] : null;
    const supportedEventTypes = <String>{
      'feeding',
      'sleep',
      'diaper',
      'crying',
    };
    if (eventType != null && !supportedEventTypes.contains(eventType)) {
      return null;
    }
    if (section == BebiaLaunchSection.home && eventType != null) return null;
    if (section == BebiaLaunchSection.add && eventType == null) return null;
    return BebiaLaunchTarget(section: section, eventType: eventType);
  }
}

class BebiaPlatformBridge {
  BebiaPlatformBridge();

  static const MethodChannel _channel = MethodChannel(
    'com.example.bebia/platform',
  );

  final ValueNotifier<BebiaLaunchTarget?> launchTarget =
      ValueNotifier<BebiaLaunchTarget?>(null);

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    _initialized = true;
    _channel.setMethodCallHandler(_handleNativeCall);

    try {
      final target = await _channel.invokeMethod<String>(
        'getInitialLaunchTarget',
      );
      _publishLaunchTarget(target);
    } on MissingPluginException {
      // Platform integration is intentionally optional in tests and desktop.
    } on PlatformException {
      // A launch target is a convenience; startup must remain available.
    }
  }

  Future<void> syncWidgetSnapshot(Map<String, Object?> snapshot) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('syncWidgetSnapshot', snapshot);
    } on MissingPluginException {
      // Platform integration is intentionally optional in tests and desktop.
    } on PlatformException {
      // Widget synchronization is derived data and must not block a save.
    }
  }

  BebiaLaunchTarget? consumeLaunchTarget() {
    final target = launchTarget.value;
    launchTarget.value = null;
    return target;
  }

  Future<Object?> _handleNativeCall(MethodCall call) async {
    if (call.method == 'openLaunchTarget') {
      _publishLaunchTarget(call.arguments as String?);
    }
    return null;
  }

  void _publishLaunchTarget(String? raw) {
    final target = BebiaLaunchTarget.parse(raw);
    if (target != null) launchTarget.value = target;
  }
}
