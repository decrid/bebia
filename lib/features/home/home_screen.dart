import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../crying/crying_analysis_result.dart';
import '../diaper/diaper_form_screen.dart';
import '../feeding/feeding_form_screen.dart';
import '../predictions/prediction_model.dart';
import '../recommendations/recommendation_model.dart';
import '../recommendations/recommendations_screen.dart';
import '../sleep/sleep_form_screen.dart';
import '../timeline/timeline_item.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Recommendation>> _futureRecommendations;
  late Future<CryingAnalysisResult?> _futureCryingAnalysis;
  late Future<List<Prediction>> _futurePredictions;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
    _loadCryingAnalysis();
    _loadPredictions();
    AppServices.timelineController.load();
  }

  void _loadRecommendations() {
    _futureRecommendations = AppServices.recommendationService
        .getRecommendations();
  }

  void _loadCryingAnalysis() {
    _futureCryingAnalysis = AppServices.cryingAnalysisService
        .analyzeLatestCrying();
  }

  void _loadPredictions() {
    _futurePredictions = AppServices.predictionService.getPredictions();
  }

  Future<void> _refresh() async {
    await AppServices.timelineController.load();

    setState(() {
      _loadRecommendations();
      _loadCryingAnalysis();
      _loadPredictions();
    });

    await Future.wait([
      _futureRecommendations,
      _futureCryingAnalysis,
      _futurePredictions,
    ]);
  }

  Future<void> _openForm(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

    if (!mounted) return;
    await _refresh();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatPredictionTime(DateTime? time) {
    if (time == null) return '-';

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _predictionWindowLabel(DateTime? time) {
    if (time == null) return 'Bez odhadu';

    final diff = time.difference(DateTime.now()).inMinutes;
    if (diff <= 15) return 'Teď';
    if (diff <= 60) return 'Do hodiny';
    return 'Později';
  }

  String _recommendationPriorityLabel(double score) {
    if (score >= 0.8) return 'Vysoká priorita';
    if (score >= 0.55) return 'Střední priorita';
    return 'Nízká priorita';
  }

  String _cryingCauseLabel(String cause) {
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

  String _confidenceLabel(double confidence) {
    if (confidence >= 0.8) return 'Vysoká jistota';
    if (confidence >= 0.55) return 'Střední jistota';
    return 'Nižší jistota';
  }

  Color _confidenceColor(BuildContext context, double confidence) {
    if (confidence >= 0.8) return Colors.redAccent;
    if (confidence >= 0.55) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }

  Future<void> _handleAnalysisNextStep(CryingAnalysisResult analysis) async {
    switch (analysis.nextStepType) {
      case CryingNextStepType.feeding:
        await _openForm(const FeedingFormScreen());
        return;
      case CryingNextStepType.sleep:
        await _openForm(const SleepFormScreen());
        return;
      case CryingNextStepType.diaper:
        await _openForm(const DiaperFormScreen());
        return;
      case CryingNextStepType.soothing:
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tip: zkuste chování, nošení nebo jemné houpání.'),
          ),
        );
        return;
    }
  }

  List<String> _buildTimelineSummary(TimelineItem item) {
    final parts = <String>[];

    if (item.type == EventType.crying) {
      if (item.aiProbableCause != null) {
        parts.add('AI: ${_cryingCauseLabel(item.aiProbableCause!)}');
      }

      if (item.cryingResolved != null) {
        parts.add(item.cryingResolved! ? 'Uklidněno' : 'Bez uklidnění');
      }

      if (item.cryingDurationMinutes != null) {
        parts.add('${item.cryingDurationMinutes} min');
      }

      final soothingLabel = _soothingMethodLabel(item.soothingMethod);
      if (soothingLabel != null) {
        parts.add('Pomohlo: $soothingLabel');
      }
    } else if (item.subtitle.isNotEmpty) {
      parts.add(item.subtitle);
    }

    return parts.take(3).toList();
  }

  IconData _eventIcon(EventType type) {
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

  Widget _buildSignalChips(List<String> signals) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: signals
          .map(
            (signal) =>
                Chip(label: Text(signal), visualDensity: VisualDensity.compact),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Bebia')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          children: [
            const SizedBox(height: 12),
            const _SectionHeader(
              title: 'Co je teď důležité',
              subtitle: 'AI pohled na poslední pláč a nejbližší očekávání.',
            ),
            const SizedBox(height: 10),
            FutureBuilder<CryingAnalysisResult?>(
              future: _futureCryingAnalysis,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        'Analýzu pláče se nepodařilo načíst: ${snapshot.error}',
                      ),
                    ),
                  );
                }

                final analysis = snapshot.data;
                if (analysis == null) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'Jakmile přidáš záznam pláče, zobrazí se tady stručný AI souhrn.',
                      ),
                    ),
                  );
                }

                final confidenceColor = _confidenceColor(
                  context,
                  analysis.confidence,
                );

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: confidenceColor.withValues(
                                alpha: 0.14,
                              ),
                              foregroundColor: confidenceColor,
                              child: const Icon(Icons.psychology_alt_outlined),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pravděpodobná příčina: ${_cryingCauseLabel(analysis.probableCause)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Jistota ${(analysis.confidence * 100).round()} % • ${_confidenceLabel(analysis.confidence)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (analysis.signals.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Rozhodující signály',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          _buildSignalChips(analysis.signals.take(4).toList()),
                        ],
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                analysis.nextStepTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(analysis.nextStepDescription),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: FilledButton.tonalIcon(
                                  onPressed: () =>
                                      _handleAnalysisNextStep(analysis),
                                  icon: const Icon(Icons.arrow_forward_rounded),
                                  label: const Text('Provést krok'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: _SectionHeader(
                    title: 'Asistent dne',
                    subtitle: 'Krátké kroky, které mají teď největší smysl.',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecommendationsScreen(),
                      ),
                    );
                  },
                  child: const Text('Všechna'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Prediction>>(
              future: _futurePredictions,
              builder: (context, predictionSnapshot) {
                if (predictionSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                return FutureBuilder<List<Recommendation>>(
                  future: _futureRecommendations,
                  builder: (context, recommendationSnapshot) {
                    if (recommendationSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    if (predictionSnapshot.hasError ||
                        recommendationSnapshot.hasError) {
                      final error =
                          predictionSnapshot.error ??
                          recommendationSnapshot.error;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text('Asistenta se nepodařilo načíst: $error'),
                        ),
                      );
                    }

                    final predictions = (predictionSnapshot.data ?? []).take(2);
                    final recommendations = (recommendationSnapshot.data ?? [])
                        .take(2);

                    final items = <_AssistantAgendaItem>[
                      ...predictions.map(
                        (prediction) => _AssistantAgendaItem(
                          icon: Icons.schedule_outlined,
                          title: prediction.title,
                          subtitle:
                              'Odhad ${_formatPredictionTime(prediction.predictedTime)} • jistota ${(prediction.confidence * 100).round()} %',
                          badge: _predictionWindowLabel(
                            prediction.predictedTime,
                          ),
                        ),
                      ),
                      ...recommendations.map(
                        (recommendation) => _AssistantAgendaItem(
                          icon: Icons.lightbulb_outline,
                          title: recommendation.title,
                          subtitle: recommendation.description,
                          badge: _recommendationPriorityLabel(
                            recommendation.score,
                          ),
                        ),
                      ),
                    ];

                    if (items.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Text(
                            'Zatím nejsou k dispozici žádné kroky asistenta.',
                          ),
                        ),
                      );
                    }

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: items
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _AssistantAgendaCard(item: item),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 10),
            const _SectionHeader(
              title: 'Poslední záznamy',
              subtitle: 'Jen to nejnovější, ať se rychle zorientuješ.',
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<bool>(
              valueListenable: AppServices.timelineController.isLoading,
              builder: (context, isLoading, child) {
                if (isLoading) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                return ValueListenableBuilder<String?>(
                  valueListenable: AppServices.timelineController.error,
                  builder: (context, error, child) {
                    if (error != null) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text(error),
                        ),
                      );
                    }

                    return ValueListenableBuilder<List<TimelineItem>>(
                      valueListenable: AppServices.timelineController.items,
                      builder: (context, items, child) {
                        if (items.isEmpty) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(18),
                              child: Text('Zatím nemáš žádné události.'),
                            ),
                          );
                        }

                        final recentItems = items.take(4).toList();

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: recentItems.map((item) {
                                final summary = _buildTimelineSummary(item);
                                final isLast = identical(
                                  item,
                                  recentItems.last,
                                );

                                return Container(
                                  decoration: BoxDecoration(
                                    border: isLast
                                        ? null
                                        : Border(
                                            bottom: BorderSide(
                                              color: colorScheme.outlineVariant
                                                  .withValues(alpha: 0.30),
                                            ),
                                          ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: colorScheme
                                          .secondaryContainer
                                          .withValues(alpha: 0.9),
                                      foregroundColor:
                                          colorScheme.onSecondaryContainer,
                                      child: Icon(_eventIcon(item.type)),
                                    ),
                                    title: Text(_eventTypeLabel(item.type)),
                                    subtitle: summary.isEmpty
                                        ? null
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2,
                                            ),
                                            child: Text(summary.join(' • ')),
                                          ),
                                    trailing: Text(
                                      _formatTime(item.time),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _AssistantAgendaItem {
  const _AssistantAgendaItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
}

class _AssistantAgendaCard extends StatelessWidget {
  const _AssistantAgendaCard({required this.item});

  final _AssistantAgendaItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              child: Icon(item.icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(item.subtitle),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Chip(visualDensity: VisualDensity.compact, label: Text(item.badge)),
          ],
        ),
      ),
    );
  }
}
