import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/design/bebia_theme.dart';
import '../../shared/widgets/bebia_components.dart';
import '../../shared/widgets/info_label.dart';
import '../../shared/widgets/profile_switcher.dart';
import '../auth/app_account_session.dart';
import '../crying/crying_form_screen.dart';
import '../diaper/diaper_form_screen.dart';
import '../feeding/feeding_form_screen.dart';
import '../family/family_connection.dart';
import '../profile/child_profile.dart';
import '../sleep/sleep_form_screen.dart';
import 'timeline_cloud_sync_service.dart';
import 'timeline_item.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key, this.loadOnInit = true});

  static const routeName = '/timeline';
  final bool loadOnInit;

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  void initState() {
    super.initState();
    AppServices.appAccountController.session.addListener(_handleContextChanged);
    AppServices.familyConnectionController.state.addListener(
      _handleContextChanged,
    );
    AppServices.childProfileController.activeProfileId.addListener(
      _handleContextChanged,
    );
    if (widget.loadOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppServices.timelineController.load(
          AppServices.timelineController.selectedFilter.value,
        );
      });
    }
  }

  @override
  void dispose() {
    AppServices.appAccountController.session.removeListener(
      _handleContextChanged,
    );
    AppServices.familyConnectionController.state.removeListener(
      _handleContextChanged,
    );
    AppServices.childProfileController.activeProfileId.removeListener(
      _handleContextChanged,
    );
    super.dispose();
  }

  void _handleContextChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _openEditForm(TimelineItem item) async {
    Widget screen;

    switch (item.type) {
      case EventType.feeding:
        screen = FeedingFormScreen(existingItem: item);
        break;
      case EventType.sleep:
        screen = SleepFormScreen(existingItem: item);
        break;
      case EventType.diaper:
        screen = DiaperFormScreen(existingItem: item);
        break;
      case EventType.crying:
        screen = CryingFormScreen(existingItem: item);
        break;
    }

    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

    if (!mounted) return;
    await AppServices.timelineController.reloadCurrent();
  }

  Future<void> _applyFilter(EventType? type) async {
    await AppServices.timelineController.load(type);
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) {
      return 'Dnes';
    }

    if (target == yesterday) {
      return 'Včera';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day.$month.$year';
  }

  String _eventTypeLabel(EventType type) {
    switch (type) {
      case EventType.feeding:
        return 'Krmení';
      case EventType.sleep:
        return 'Spánek';
      case EventType.diaper:
        return 'Přebalení';
      case EventType.crying:
        return 'Pláč';
    }
  }

  String _causeLabel(String cause) {
    switch (cause) {
      case 'hunger':
        return 'hlad';
      case 'tired':
        return 'únava';
      case 'discomfort':
        return 'diskomfort';
      case 'other':
        return 'jiné';
      case 'unknown':
        return 'nevím';
      default:
        return cause;
    }
  }

  String _nextStepLabelFromCause(String? cause) {
    switch (cause) {
      case 'hunger':
        return 'zkusit krmení';
      case 'tired':
        return 'připravit spánek';
      case 'discomfort':
        return 'zkontrolovat plenku';
      default:
        return 'uklidnění a kontakt';
    }
  }

  String? _soothingMethodLabel(String? method) {
    switch (method) {
      case 'rocking':
        return 'Houpání';
      case 'feeding':
        return 'Krmení';
      case 'carrying':
        return 'Nošení';
      case 'pacifier':
        return 'Dudlík';
      case 'other':
        return 'Jiné';
      default:
        return null;
    }
  }

  List<String> _buildSubtitleParts(TimelineItem item) {
    final parts = <String>[];

    if (item.type == EventType.crying) {
      if (item.cryingDurationMinutes != null) {
        parts.add('${item.cryingDurationMinutes} min');
      }

      final soothingLabel = _soothingMethodLabel(item.soothingMethod);
      if (soothingLabel != null) {
        parts.add('Pomohlo: $soothingLabel');
      }

      if (item.cryingResolved != null) {
        parts.add(item.cryingResolved! ? 'Uklidněno' : 'Bez uklidnění');
      }

      if (item.aiProbableCause != null) {
        final label = _causeLabel(item.aiProbableCause!);
        final confidence = item.aiConfidence;
        if (confidence != null) {
          parts.add('AI: $label (${(confidence * 100).round()} %)');
        } else {
          parts.add('AI: $label');
        }
        parts.add(
          'Další krok: ${_nextStepLabelFromCause(item.aiProbableCause)}',
        );
      }

      if (item.aiUserCorrectedCause != null &&
          item.aiUserCorrectedCause!.trim().isNotEmpty) {
        parts.add('Potvrzeno: ${_causeLabel(item.aiUserCorrectedCause!)}');
      } else if (item.aiUserConfirmedCause == true) {
        parts.add('AI příčina potvrzena');
      }

      if (item.note != null && item.note!.isNotEmpty) {
        parts.add(item.note!);
      }

      return parts;
    }

    if (item.subtitle.isNotEmpty) {
      parts.add(item.subtitle);
    }

    if (item.note != null && item.note!.isNotEmpty) {
      parts.add(item.note!);
    }

    return parts;
  }

  List<_TimelineListEntry> _buildEntries(List<TimelineItem> items) {
    final entries = <_TimelineListEntry>[];
    String? currentDayLabel;

    for (final item in items) {
      final dayLabel = _formatDayLabel(item.time);

      if (dayLabel != currentDayLabel) {
        currentDayLabel = dayLabel;
        entries.add(_TimelineHeaderEntry(dayLabel));
      }

      entries.add(_TimelineItemEntry(item));
    }

    return entries;
  }

  _TimelineDaySummary _buildTodaySummary(List<TimelineItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayItems = items.where((item) {
      final day = DateTime(item.time.year, item.time.month, item.time.day);
      return day == today;
    }).toList();

    final todayCryings = todayItems
        .where((item) => item.type == EventType.crying)
        .toList();

    final unresolvedCryings = todayCryings
        .where((item) => item.cryingResolved == false)
        .length;

    final aiConfidences = todayCryings
        .map((item) => item.aiConfidence)
        .whereType<double>()
        .toList();

    final avgAiConfidence = aiConfidences.isEmpty
        ? null
        : aiConfidences.reduce((a, b) => a + b) / aiConfidences.length;

    return _TimelineDaySummary(
      totalEvents: todayItems.length,
      cryingEvents: todayCryings.length,
      unresolvedCryings: unresolvedCryings,
      averageAiConfidence: avgAiConfidence,
    );
  }

  Widget _buildFilterChips(EventType? selectedType) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: [
          _FilterChipButton(
            label: 'Vše',
            selected: selectedType == null,
            onTap: () => _applyFilter(null),
          ),
          const SizedBox(width: 8),
          _FilterChipButton(
            label: 'Krmení',
            selected: selectedType == EventType.feeding,
            onTap: () => _applyFilter(EventType.feeding),
          ),
          const SizedBox(width: 8),
          _FilterChipButton(
            label: 'Spánek',
            selected: selectedType == EventType.sleep,
            onTap: () => _applyFilter(EventType.sleep),
          ),
          const SizedBox(width: 8),
          _FilterChipButton(
            label: 'Přebalení',
            selected: selectedType == EventType.diaper,
            onTap: () => _applyFilter(EventType.diaper),
          ),
          const SizedBox(width: 8),
          _FilterChipButton(
            label: 'Pláč',
            selected: selectedType == EventType.crying,
            onTap: () => _applyFilter(EventType.crying),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineEntry(
    BuildContext context,
    _TimelineListEntry entry,
    ColorScheme colorScheme,
  ) {
    if (entry is _TimelineHeaderEntry) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
        child: Text(
          entry.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      );
    }

    final item = (entry as _TimelineItemEntry).item;
    final subtitleParts = _buildSubtitleParts(item);
    final isCrying = item.type == EventType.crying;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(Icons.delete, color: colorScheme.onError),
        ),
        confirmDismiss: (direction) {
          return showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Smazat záznam?'),
              content: const Text('Tuto akci nelze vrátit.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Zrušit'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Smazat'),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) {
          AppServices.timelineController.delete(item.id);
        },
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => _openEditForm(item),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: isCrying
                            ? colorScheme.tertiaryContainer
                            : colorScheme.secondaryContainer,
                        foregroundColor: isCrying
                            ? colorScheme.onTertiaryContainer
                            : colorScheme.onSecondaryContainer,
                        child: Icon(_iconFor(item.type)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _eventTypeLabel(item.type),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatTime(item.time),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: subtitleParts
                          .map((part) => InfoLabel(label: part))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accountSession = AppServices.appAccountController.session.value;
    final familyState = AppServices.familyConnectionController.state.value;
    final activeProfile = AppServices.childProfileController.activeProfile;
    final usesLargeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    final profileBarHeight = usesLargeText ? 116.0 : 92.0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(profileBarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: profileBarHeight,
          titleSpacing: 0,
          title: const ProfileSwitcher(
            embedded: true,
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
          ),
        ),
      ),
      body: ValueListenableBuilder<List<TimelineItem>>(
        valueListenable: AppServices.timelineController.items,
        builder: (context, items, _) {
          return ValueListenableBuilder<EventType?>(
            valueListenable: AppServices.timelineController.selectedFilter,
            builder: (context, selectedType, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: AppServices.timelineController.isLoading,
                builder: (context, isLoading, _) {
                  return ValueListenableBuilder<String?>(
                    valueListenable: AppServices.timelineController.error,
                    builder: (context, error, _) {
                      final syncPayload = AppServices.timelineCloudSyncService
                          .buildPayload(
                            session: accountSession,
                            familyState: familyState,
                            activeProfile: activeProfile,
                            items: items,
                          );
                      final syncPlan = AppServices.timelineCloudSyncService
                          .buildPlan(syncPayload);

                      final slivers = <Widget>[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primaryContainer.withValues(
                                      alpha: 0.32,
                                    ),
                                    colorScheme.surface,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Přehled',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Události podle času. Klepnutím záznam upravíte.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: _TimelineFamilyContextCard(
                              session: accountSession,
                              familyState: familyState,
                              activeProfile: activeProfile,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: BebiaCard(
                              padding: EdgeInsets.zero,
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: BebiaSpace.md,
                                ),
                                childrenPadding: const EdgeInsets.fromLTRB(
                                  BebiaSpace.md,
                                  0,
                                  BebiaSpace.md,
                                  BebiaSpace.md,
                                ),
                                leading: const Icon(Icons.cloud_outlined),
                                title: const Text('Synchronizace'),
                                subtitle: const Text(
                                  'Stav rodinného sdílení a cloudový plán',
                                ),
                                children: [
                                  _TimelineShareReadinessCard(
                                    session: accountSession,
                                    familyState: familyState,
                                    activeProfile: activeProfile,
                                    payload: syncPayload,
                                  ),
                                  const SizedBox(height: BebiaSpace.sm),
                                  _TimelineCloudPreviewCard(
                                    payload: syncPayload,
                                    plan: syncPlan,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _buildFilterChips(selectedType),
                        ),
                      ];

                      if (isLoading) {
                        slivers.add(
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      } else if (error != null) {
                        slivers.add(
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(error),
                              ),
                            ),
                          ),
                        );
                      } else if (items.isEmpty) {
                        slivers.add(
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                  'Zatím nejsou k dispozici žádné záznamy.',
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        final entries = _buildEntries(items);
                        final summary = _buildTodaySummary(items);
                        slivers
                          ..add(
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  4,
                                  16,
                                  12,
                                ),
                                child: _TimelineSummaryCard(summary: summary),
                              ),
                            ),
                          )
                          ..add(
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                110,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildTimelineEntry(
                                    context,
                                    entries[index],
                                    colorScheme,
                                  ),
                                  childCount: entries.length,
                                ),
                              ),
                            ),
                          );
                      }

                      return CustomScrollView(slivers: slivers);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconFor(EventType type) {
    switch (type) {
      case EventType.feeding:
        return Icons.local_drink_outlined;
      case EventType.sleep:
        return Icons.bedtime_outlined;
      case EventType.diaper:
        return Icons.baby_changing_station_outlined;
      case EventType.crying:
        return Icons.campaign_outlined;
    }
  }
}

abstract class _TimelineListEntry {}

class _TimelineHeaderEntry extends _TimelineListEntry {
  _TimelineHeaderEntry(this.title);

  final String title;
}

class _TimelineItemEntry extends _TimelineListEntry {
  _TimelineItemEntry(this.item);

  final TimelineItem item;
}

class _TimelineDaySummary {
  const _TimelineDaySummary({
    required this.totalEvents,
    required this.cryingEvents,
    required this.unresolvedCryings,
    required this.averageAiConfidence,
  });

  final int totalEvents;
  final int cryingEvents;
  final int unresolvedCryings;
  final double? averageAiConfidence;
}

class _TimelineShareReadinessCard extends StatelessWidget {
  const _TimelineShareReadinessCard({
    required this.session,
    required this.familyState,
    required this.activeProfile,
    required this.payload,
  });

  final AppAccountSession session;
  final FamilyConnectionState familyState;
  final ChildProfile? activeProfile;
  final TimelineCloudSyncPayload payload;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final title = !session.isSignedIn
        ? 'Timeline čeká na rodičovský účet'
        : activeProfile == null
        ? 'Timeline čeká na aktivní dítě'
        : !familyState.isConnected
        ? 'Timeline čeká na aktivní rodinu'
        : payload.canSync
        ? 'Timeline je připravená pro sdílení'
        : 'Timeline ještě není připravená pro sync';

    final subtitle = !session.isSignedIn
        ? 'Bez rodičovského účtu nebude možné bezpečně sdílet události mezi dvěma telefony.'
        : activeProfile == null
        ? 'Vyber dítě, aby bylo jasné, které události se mají sdílet.'
        : !familyState.isConnected
        ? 'Rodina musí být nejdřív aktivní, teprve potom má smysl sdílet timeline.'
        : payload.canSync
        ? 'Aktivní dítě i jeho události už mají tvar připravený pro cloudové sdílení.'
        : 'Některé podmínky pro sdílenou timeline ještě chybí.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              InfoLabel(
                label: payload.canSync ? 'Připraveno' : 'Kontrolní režim',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle),
          if (activeProfile != null) ...[
            const SizedBox(height: 10),
            Text(
              'Aktivní dítě: ${activeProfile!.name}',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineFamilyContextCard extends StatelessWidget {
  const _TimelineFamilyContextCard({
    required this.session,
    required this.familyState,
    required this.activeProfile,
  });

  final AppAccountSession session;
  final FamilyConnectionState familyState;
  final ChildProfile? activeProfile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasFamily =
        familyState.familyId != null && familyState.familyId!.isNotEmpty;
    final activeProfileLinked =
        activeProfile != null &&
        activeProfile!.familyId == familyState.familyId;

    final title = !session.isSignedIn
        ? 'Timeline běží bez rodinného účtu'
        : !hasFamily
        ? 'Timeline ještě není navázaná na rodinu'
        : activeProfile == null
        ? 'Vyber dítě pro sdílenou timeline'
        : activeProfileLinked
        ? 'Pracuješ ve sdíleném rodinném kontextu'
        : 'Aktivní dítě ještě není ve sdílené rodině';

    final subtitle = !session.isSignedIn
        ? 'Události fungují lokálně, ale sdílení mezi rodiči zatím není připravené.'
        : !hasFamily
        ? 'Rodina ještě není založená nebo aktivovaná, takže timeline zůstává pouze na tomto zařízení.'
        : activeProfile == null
        ? 'Jakmile vybereš dítě, bude jasné, které záznamy patří do sdílené rodiny.'
        : activeProfileLinked
        ? 'Aktivní profil dítěte už patří do stejné rodiny jako pozvánka a další pečující osoby.'
        : 'Události se sice zapisují k aktivnímu dítěti, ale toto dítě ještě není přiřazené do aktuální rodiny.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              InfoLabel(
                label: activeProfileLinked ? 'Sdílená rodina' : 'Lokální režim',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (session.isSignedIn)
                InfoLabel(label: 'Rodič ${session.user!.displayName}'),
              if (hasFamily) InfoLabel(label: 'Rodina ${familyState.familyId}'),
              if (activeProfile != null)
                InfoLabel(label: 'Dítě ${activeProfile!.name}'),
              if (familyState.hasInvite)
                InfoLabel(
                  label:
                      'Pozvánka ${_inviteStatusLabel(familyState.inviteStatus)}',
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _inviteStatusLabel(FamilyInviteStatus status) {
    switch (status) {
      case FamilyInviteStatus.none:
        return 'bez pozvánky';
      case FamilyInviteStatus.draft:
        return 'návrh';
      case FamilyInviteStatus.waitingForAcceptance:
        return 'čeká';
      case FamilyInviteStatus.accepted:
        return 'přijatá';
      case FamilyInviteStatus.connected:
        return 'aktivní';
    }
  }
}

class _TimelineCloudPreviewCard extends StatelessWidget {
  const _TimelineCloudPreviewCard({required this.payload, required this.plan});

  final TimelineCloudSyncPayload payload;
  final TimelineSyncPlanPreview plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Náhled cloudové timeline',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(plan.summary),
            if (payload.blockers.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...payload.blockers.map(
                (blocker) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('• $blocker'),
                ),
              ),
            ],
            const SizedBox(height: 14),
            _TimelinePreviewLine(
              label: 'familyId',
              value: payload.familyId ?? 'neuvedeno',
            ),
            _TimelinePreviewLine(
              label: 'childId',
              value: payload.childId ?? 'neuvedeno',
            ),
            _TimelinePreviewLine(
              label: 'childName',
              value: payload.childName ?? 'neuvedeno',
            ),
            _TimelinePreviewLine(
              label: 'authorUserId',
              value: payload.authorUserId ?? 'neuvedeno',
            ),
            _TimelinePreviewLine(
              label: 'itemCount',
              value: '${payload.items.length}',
            ),
            const SizedBox(height: 14),
            Text(
              'Backend plán',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...plan.operations.map(
              (operation) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            operation.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(operation.description),
                          const SizedBox(height: 6),
                          InfoLabel(
                            label: operation.isReady
                                ? 'Připraveno'
                                : 'Blokováno',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelinePreviewLine extends StatelessWidget {
  const _TimelinePreviewLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _TimelineSummaryCard extends StatelessWidget {
  const _TimelineSummaryCard({required this.summary});

  final _TimelineDaySummary summary;

  @override
  Widget build(BuildContext context) {
    final confidence = summary.averageAiConfidence;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            InfoLabel(label: 'Dnes ${summary.totalEvents} záznamů'),
            InfoLabel(label: 'Pláč ${summary.cryingEvents}x'),
            InfoLabel(label: 'Neuklidněno ${summary.unresolvedCryings}x'),
            if (confidence != null)
              InfoLabel(label: 'AI jistota ${(confidence * 100).round()} %'),
          ],
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
