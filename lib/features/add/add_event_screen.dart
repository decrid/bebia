import 'package:flutter/material.dart';

import '../crying/crying_form_screen.dart';
import '../diaper/diaper_form_screen.dart';
import '../feeding/feeding_form_screen.dart';
import '../sleep/sleep_form_screen.dart';

class AddEventScreen extends StatelessWidget {
  static const routeName = '/add';

  const AddEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Přidat záznam')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _AddEventButton(
              title: 'Krmení',
              icon: Icons.local_drink_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedingFormScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _AddEventButton(
              title: 'Spánek',
              icon: Icons.bedtime_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SleepFormScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _AddEventButton(
              title: 'Přebalení',
              icon: Icons.baby_changing_station_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DiaperFormScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _AddEventButton(
              title: 'Pláč',
              icon: Icons.campaign_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CryingFormScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddEventButton extends StatelessWidget {
  const _AddEventButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, size: 28),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
