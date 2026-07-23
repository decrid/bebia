import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_version_provider.dart';
import '../../core/design/bebia_theme.dart';
import '../../core/settings/bebia_preferences.dart';
import '../../shared/widgets/bebia_components.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.controller, this.appVersionProvider});

  final BebiaSettingsController? controller;
  final BebiaAppVersionProvider? appVersionProvider;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<BebiaAppVersion> _appVersion;

  BebiaSettingsController get _controller =>
      widget.controller ?? BebiaSettingsController.instance;

  @override
  void initState() {
    super.initState();
    _appVersion = _loadAppVersion();
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appVersionProvider != widget.appVersionProvider) {
      _appVersion = _loadAppVersion();
    }
  }

  Future<BebiaAppVersion> _loadAppVersion() async {
    try {
      return await (widget.appVersionProvider ??
              const PackageInfoAppVersionProvider())
          .load();
    } on Object {
      return const BebiaAppVersion.unavailable();
    }
  }

  Future<void> _showAppearance() async {
    final current = _controller.preferences.appearance;
    final selected = await showModalBottomSheet<BebiaAppearance>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BebiaModalSurface(
        title: 'Vzhled aplikace',
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(
            BebiaSpace.md,
            BebiaSpace.xs,
            BebiaSpace.md,
            BebiaSpace.lg,
          ),
          children: BebiaAppearance.values.map((appearance) {
            final (label, description, icon) = switch (appearance) {
              BebiaAppearance.system => (
                'Podle systému',
                'Automaticky respektuje nastavení telefonu',
                Icons.brightness_auto_outlined,
              ),
              BebiaAppearance.light => (
                'Světlý',
                'Jasný vzhled pro denní používání',
                Icons.light_mode_outlined,
              ),
              BebiaAppearance.dark => (
                'Tmavý',
                'Klidnější vzhled při péči v noci',
                Icons.dark_mode_outlined,
              ),
            };
            final isSelected = current == appearance;
            return Padding(
              padding: const EdgeInsets.only(bottom: BebiaSpace.xs),
              child: BebiaCard(
                onTap: () => Navigator.pop(sheetContext, appearance),
                borderColor: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : null,
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: Row(
                  children: <Widget>[
                    Icon(icon),
                    const SizedBox(width: BebiaSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(description),
                        ],
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle_rounded),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
    if (selected == null || selected == current) return;
    await _feedback();
    await _save(_controller.setAppearance(selected));
  }

  Future<void> _setDensity(bool compact) async {
    await _feedback();
    await _save(
      _controller.setContentDensity(
        compact ? BebiaContentDensity.compact : BebiaContentDensity.comfortable,
      ),
    );
  }

  Future<void> _setReduceMotion(bool value) async {
    await _feedback();
    await _save(_controller.setReduceMotion(value));
  }

  Future<void> _setHaptics(bool value) async {
    if (value) await HapticFeedback.selectionClick();
    await _save(_controller.setHapticsEnabled(value));
  }

  Future<void> _feedback() async {
    if (_controller.preferences.hapticsEnabled) {
      await HapticFeedback.selectionClick();
    }
  }

  Future<void> _save(Future<bool> operation) async {
    final saved = await operation;
    if (!mounted || saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_controller.lastError ?? 'Změnu nelze uložit.')),
    );
  }

  Future<void> _reset() async {
    final confirmed = await showBebiaConfirmDialog(
      context,
      title: 'Obnovit výchozí nastavení?',
      message:
          'Obnoví se pouze vzhled a chování aplikace. Záznamy, profily dětí '
          'ani rodinné propojení se nesmažou.',
      confirmLabel: 'Obnovit nastavení',
    );
    if (!confirmed || !mounted) return;
    await _feedback();
    await _save(_controller.reset());
    if (mounted && _controller.lastError == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Výchozí nastavení bylo obnoveno.')),
      );
    }
  }

  String _appearanceLabel(BebiaAppearance appearance) {
    return switch (appearance) {
      BebiaAppearance.system => 'Podle systému',
      BebiaAppearance.light => 'Světlý',
      BebiaAppearance.dark => 'Tmavý',
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (!_controller.initialized) {
          return const BebiaPage(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final preferences = _controller.preferences;
        final compact =
            preferences.contentDensity == BebiaContentDensity.compact;
        return BebiaPage(
          child: ListView(
            key: const PageStorageKey<String>('settings-list'),
            padding: EdgeInsets.zero,
            children: <Widget>[
              const BebiaScreenHeader(
                title: 'Nastavení',
                subtitle: 'Přizpůsobte si Bebia pro klidnější každodenní péči.',
              ),
              const SizedBox(height: BebiaSpace.lg),
              if (_controller.lastError != null) ...<Widget>[
                BebiaInfoBanner(
                  icon: Icons.sync_problem_rounded,
                  title: 'Nastavení není synchronizované',
                  message: _controller.lastError!,
                ),
                const SizedBox(height: BebiaSpace.md),
              ],
              const BebiaSectionHeader(title: 'Vzhled a zobrazení'),
              BebiaSettingsTile(
                icon: Icons.palette_outlined,
                title: 'Vzhled',
                subtitle: _appearanceLabel(preferences.appearance),
                onTap: _showAppearance,
              ),
              const SizedBox(height: BebiaSpace.xs),
              BebiaSettingsTile(
                icon: Icons.density_medium_outlined,
                title: 'Kompaktní zobrazení',
                subtitle: compact
                    ? 'Více informací na obrazovce'
                    : 'Vzdušnější rozestupy a pohodlnější čtení',
                onTap: () => _setDensity(!compact),
                trailing: Switch(value: compact, onChanged: _setDensity),
              ),
              const SizedBox(height: BebiaSpace.lg),
              const BebiaSectionHeader(title: 'Pohodlí a přístupnost'),
              BebiaSettingsTile(
                icon: Icons.motion_photos_off_outlined,
                title: 'Omezit pohyb',
                subtitle: preferences.reduceMotion
                    ? 'Přechody jsou potlačené'
                    : 'Jemné přechody pomáhají s orientací',
                onTap: () => _setReduceMotion(!preferences.reduceMotion),
                trailing: Switch(
                  value: preferences.reduceMotion,
                  onChanged: _setReduceMotion,
                ),
              ),
              const SizedBox(height: BebiaSpace.xs),
              BebiaSettingsTile(
                icon: Icons.vibration_outlined,
                title: 'Haptická odezva',
                subtitle: preferences.hapticsEnabled
                    ? 'Krátká odezva u hlavních voleb'
                    : 'Bez vibrací při ovládání',
                onTap: () => _setHaptics(!preferences.hapticsEnabled),
                trailing: Switch(
                  value: preferences.hapticsEnabled,
                  onChanged: _setHaptics,
                ),
              ),
              const SizedBox(height: BebiaSpace.lg),
              const BebiaSectionHeader(title: 'Soukromí a data'),
              const BebiaInfoBanner(
                icon: Icons.shield_outlined,
                title: 'Vaše data zůstávají oddělená',
                message:
                    'Reset nastavení nikdy nemaže profily ani záznamy. '
                    'Rodinná synchronizace se řídí pouze vaším existujícím '
                    'propojením účtu.',
              ),
              const SizedBox(height: BebiaSpace.lg),
              const BebiaSectionHeader(title: 'Obnova'),
              BebiaSettingsTile(
                icon: Icons.restart_alt_rounded,
                title: 'Obnovit výchozí nastavení',
                subtitle: 'Nemění profily, události ani rodinné propojení',
                onTap: _reset,
              ),
              const SizedBox(height: BebiaSpace.lg),
              const BebiaSectionHeader(title: 'O aplikaci'),
              BebiaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Bebia',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: BebiaSpace.xs),
                    const Text(
                      'Přehledný pomocník pro krmení, spánek, přebalování, '
                      'pláč a společnou péči o dítě.',
                    ),
                    const SizedBox(height: BebiaSpace.sm),
                    FutureBuilder<BebiaAppVersion>(
                      future: _appVersion,
                      builder: (context, snapshot) {
                        final version = snapshot.data;
                        if (version == null) {
                          return const Text('Načítám verzi…');
                        }
                        return Text(version.displayLabel);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 104),
            ],
          ),
        );
      },
    );
  }
}
