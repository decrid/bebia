import 'package:flutter/material.dart';
import '../../core/app_services.dart';
import '../timeline/timeline_item.dart';

class CryingFormScreen extends StatefulWidget {
  const CryingFormScreen({super.key});

  @override
  State<CryingFormScreen> createState() => _CryingFormScreenState();
}

class _CryingFormScreenState extends State<CryingFormScreen> {
  double _intensity = 3;

  Future<void> _save() async {
    final now = DateTime.now();

    final item = TimelineItem()
      ..type = EventType.crying
      ..time = now
      ..title = 'Pláč'
      ..subtitle = 'Intenzita: ${_intensity.toInt()}';

    await AppServices.timelineController.add(item);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pláč'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Intenzita pláče'),
            Slider(
              value: _intensity,
              min: 1,
              max: 5,
              divisions: 4,
              label: _intensity.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _intensity = value;
                });
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Uložit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}