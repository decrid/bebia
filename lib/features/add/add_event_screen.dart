import 'package:flutter/material.dart';

import '../../core/design/bebia_theme.dart';
import '../../shared/widgets/bebia_components.dart';
import '../crying/crying_form_screen.dart';
import '../diaper/diaper_form_screen.dart';
import '../feeding/feeding_form_screen.dart';
import '../sleep/sleep_form_screen.dart';

class AddEventScreen extends StatelessWidget {
  const AddEventScreen({super.key});

  Future<void> _open(BuildContext context, Widget screen) async {
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nový záznam')),
      body: BebiaPage(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const BebiaScreenHeader(
              title: 'Co se právě stalo?',
              subtitle:
                  'Vyberte typ události. Podrobnosti můžete kdykoli upravit.',
            ),
            const SizedBox(height: BebiaSpace.lg),
            BebiaEventActionTile(
              icon: Icons.local_drink_outlined,
              color: context.bebia.feeding,
              title: 'Krmení',
              subtitle: 'Čas, způsob a případně množství',
              onTap: () => _open(context, const FeedingFormScreen()),
            ),
            const SizedBox(height: BebiaSpace.xs),
            BebiaEventActionTile(
              icon: Icons.bedtime_outlined,
              color: context.bebia.sleep,
              title: 'Spánek',
              subtitle: 'Začátek, konec a kvalita odpočinku',
              onTap: () => _open(context, const SleepFormScreen()),
            ),
            const SizedBox(height: BebiaSpace.xs),
            BebiaEventActionTile(
              icon: Icons.baby_changing_station_outlined,
              color: context.bebia.diaper,
              title: 'Přebalení',
              subtitle: 'Typ pleny a poznámka k péči',
              onTap: () => _open(context, const DiaperFormScreen()),
            ),
            const SizedBox(height: BebiaSpace.xs),
            BebiaEventActionTile(
              icon: Icons.graphic_eq_rounded,
              color: context.bebia.crying,
              title: 'Pláč',
              subtitle: 'Kontext, délka a volitelná analýza zvuku',
              onTap: () => _open(context, const CryingFormScreen()),
            ),
            const SizedBox(height: BebiaSpace.xxl),
          ],
        ),
      ),
    );
  }
}
