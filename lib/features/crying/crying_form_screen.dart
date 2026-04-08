import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

import '../../core/app_services.dart';
import '../timeline/timeline_item.dart';
import 'ai_crying_analysis_result.dart';
import 'crying_source.dart';

class CryingFormScreen extends StatefulWidget {
  const CryingFormScreen({super.key, this.existingItem});

  final TimelineItem? existingItem;

  @override
  State<CryingFormScreen> createState() => _CryingFormScreenState();
}

class _CryingFormScreenState extends State<CryingFormScreen> {
  double _intensity = 3;
  DateTime _selectedTime = DateTime.now();
  final TextEditingController _durationController = TextEditingController();
  String? _soothingMethod;
  bool _cryingResolved = false;

  String? _audioSamplePath;
  bool _isRecording = false;
  bool _isAudioBusy = false;
  String? _audioStatus;

  AiCryingAnalysisResult? _aiPreview;
  bool _isAnalyzingAi = false;
  String? _aiPreviewError;

  bool? _aiUserConfirmedCry;
  bool? _aiUserConfirmedCause;
  String? _aiUserCorrectedCause;

  bool get _isEdit => widget.existingItem != null;

  @override
  void initState() {
    super.initState();

    final existingItem = widget.existingItem;
    if (existingItem != null) {
      _selectedTime = existingItem.time;

      if (existingItem.cryingIntensity != null) {
        _intensity = existingItem.cryingIntensity!.toDouble();
      } else {
        final prefix = 'Intenzita: ';
        if (existingItem.subtitle.startsWith(prefix)) {
          final value = int.tryParse(
            existingItem.subtitle.replaceFirst(prefix, '').trim(),
          );
          if (value != null && value >= 1 && value <= 5) {
            _intensity = value.toDouble();
          }
        }
      }

      if (existingItem.cryingDurationMinutes != null) {
        _durationController.text = existingItem.cryingDurationMinutes
            .toString();
      }

      _soothingMethod = existingItem.soothingMethod;
      _cryingResolved = existingItem.cryingResolved ?? false;
      _audioSamplePath = existingItem.audioSamplePath;
      _aiUserConfirmedCry = existingItem.aiUserConfirmedCry;
      _aiUserConfirmedCause = existingItem.aiUserConfirmedCause;
      _aiUserCorrectedCause = existingItem.aiUserCorrectedCause;

      if (_audioSamplePath != null && _audioSamplePath!.isNotEmpty) {
        _audioStatus = 'Audio vzorek je uložen';
      }
    }
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
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

  String _confidenceLabel(double confidence) {
    if (confidence >= 0.8) return 'Vysoká jistota';
    if (confidence >= 0.55) return 'Střední jistota';
    return 'Nižší jistota';
  }

  void _invalidateAiPreview() {
    if (_aiPreview == null && _aiPreviewError == null) return;

    setState(() {
      _aiPreview = null;
      _aiPreviewError = null;
    });
  }

  void _resetAiFeedback() {
    setState(() {
      _aiUserConfirmedCry = null;
      _aiUserConfirmedCause = null;
      _aiUserCorrectedCause = null;
    });
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });

    _invalidateAiPreview();
    _resetAiFeedback();
  }

  String _buildSubtitle(int intensity, int? durationMinutes) {
    final parts = <String>[
      'Intenzita: $intensity',
      if (durationMinutes != null) '$durationMinutes min',
    ];

    return parts.join(' • ');
  }

  TimelineItem _buildDraftItem() {
    final durationText = _durationController.text.trim();
    final durationMinutes = durationText.isEmpty
        ? null
        : int.tryParse(durationText);

    return TimelineItem()
      ..id = widget.existingItem?.id ?? Isar.autoIncrement
      ..type = EventType.crying
      ..time = _selectedTime
      ..title = 'Pláč'
      ..subtitle = _buildSubtitle(_intensity.toInt(), durationMinutes)
      ..cryingIntensity = _intensity.toInt()
      ..cryingDurationMinutes = durationMinutes
      ..soothingMethod = _soothingMethod
      ..cryingResolved = _cryingResolved
      ..cryingSource = widget.existingItem?.cryingSource ?? CryingSource.manual
      ..aiCryProbability = widget.existingItem?.aiCryProbability
      ..aiProbableCause = widget.existingItem?.aiProbableCause
      ..aiConfidence = widget.existingItem?.aiConfidence
      ..aiModelVersion = widget.existingItem?.aiModelVersion
      ..aiAnalyzedAt = widget.existingItem?.aiAnalyzedAt
      ..audioSamplePath = _audioSamplePath
      ..aiSignalsSerialized = widget.existingItem?.aiSignalsSerialized
      ..aiUserConfirmedCry = _aiUserConfirmedCry
      ..aiUserConfirmedCause = _aiUserConfirmedCause
      ..aiUserCorrectedCause = _aiUserCorrectedCause;
  }

  Future<void> _analyzeAiPreview() async {
    if (_isAnalyzingAi || _isRecording) return;

    setState(() {
      _isAnalyzingAi = true;
      _aiPreviewError = null;
    });

    try {
      final result = await AppServices.cryingAiService.analyzeCryingItem(
        _buildDraftItem(),
      );

      if (!mounted) return;

      setState(() {
        _aiPreview = result;
        _aiUserConfirmedCry = null;
        _aiUserConfirmedCause = null;
        _aiUserCorrectedCause = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _aiPreviewError = 'Nepodařilo se provést AI analýzu: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzingAi = false;
        });
      }
    }
  }

  Future<void> _startRecording() async {
    if (_isAudioBusy || _isRecording) return;

    setState(() {
      _isAudioBusy = true;
      _audioStatus = null;
    });

    try {
      final path = await AppServices.audioCaptureService.startRecording();

      if (!mounted) return;

      setState(() {
        _isRecording = true;
        _audioSamplePath = path;
        _audioStatus = 'Nahrávání běží';
      });

      _invalidateAiPreview();
      _resetAiFeedback();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _audioStatus = 'Nepodařilo se spustit nahrávání: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAudioBusy = false;
        });
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_isAudioBusy || !_isRecording) return;

    setState(() {
      _isAudioBusy = true;
    });

    try {
      final path = await AppServices.audioCaptureService.stopRecording();

      if (!mounted) return;

      setState(() {
        _isRecording = false;
        _audioSamplePath = path ?? _audioSamplePath;
        _audioStatus = _audioSamplePath == null
            ? 'Nahrávání bylo zastaveno'
            : 'Audio vzorek je uložen';
      });

      _invalidateAiPreview();
      _resetAiFeedback();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _audioStatus = 'Nepodařilo se zastavit nahrávání: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAudioBusy = false;
        });
      }
    }
  }

  Future<void> _clearRecording() async {
    if (_isAudioBusy) return;

    if (_isRecording) {
      setState(() {
        _isAudioBusy = true;
      });

      try {
        await AppServices.audioCaptureService.cancelRecording();
      } catch (_) {
      } finally {
        if (mounted) {
          setState(() {
            _isRecording = false;
            _isAudioBusy = false;
          });
        }
      }
    }

    setState(() {
      _audioSamplePath = null;
      _audioStatus = 'Audio vzorek byl odebrán';
    });

    _invalidateAiPreview();
    _resetAiFeedback();
  }

  Future<void> _save() async {
    if (_isRecording) return;

    final item = _buildDraftItem();

    final aiResult =
        _aiPreview ?? await AppServices.cryingAiService.analyzeCryingItem(item);

    item
      ..aiCryProbability = aiResult.cryProbability
      ..aiProbableCause = aiResult.probableCause
      ..aiConfidence = aiResult.confidence
      ..aiModelVersion = aiResult.modelVersion
      ..aiAnalyzedAt = DateTime.now()
      ..aiSignalsSerialized = aiResult.signals.isEmpty
          ? null
          : aiResult.signals.join(' | ');

    if (_isEdit) {
      await AppServices.timelineController.update(item);
    } else {
      await AppServices.timelineController.add(item);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasAudio = _audioSamplePath != null && _audioSamplePath!.isNotEmpty;
    final showCauseFeedback =
        _aiPreview != null &&
        _aiPreview!.probableCause != null &&
        _aiUserConfirmedCry != false;
    final usableConfidence = _aiPreview?.confidence;
    final sourceLabel = CryingSource.label(
      widget.existingItem?.cryingSource ?? CryingSource.manual,
    );

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Upravit pláč' : 'Pláč')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _IntroCard(
                        title: _isEdit
                            ? 'Upravit záznam pláče'
                            : 'Nový záznam pláče',
                        subtitle:
                            'Nejdřív zapiš základ. Audio i AI můžeš přidat hned nebo až podle potřeby.',
                        trailingLabel: sourceLabel,
                      ),
                      const SizedBox(height: 14),
                      _SectionTitle(
                        title: 'Základ záznamu',
                        subtitle: 'Jen to nejdůležitější o situaci.',
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: ListTile(
                          title: const Text('Čas události'),
                          subtitle: Text(_formatDateTime(_selectedTime)),
                          trailing: TextButton(
                            onPressed: _pickDateTime,
                            child: const Text('Změnit'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Intenzita pláče',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Chip(label: Text('${_intensity.toInt()}/5')),
                                ],
                              ),
                              Slider(
                                value: _intensity,
                                min: 1,
                                max: 5,
                                divisions: 4,
                                onChanged: (value) {
                                  setState(() {
                                    _intensity = value;
                                  });
                                  _invalidateAiPreview();
                                  _resetAiFeedback();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Délka pláče (min)',
                          hintText: 'Např. 8',
                        ),
                        onChanged: (_) {
                          _invalidateAiPreview();
                          _resetAiFeedback();
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _soothingMethod,
                        items: const [
                          DropdownMenuItem(
                            value: 'rocking',
                            child: Text('Houpání'),
                          ),
                          DropdownMenuItem(
                            value: 'feeding',
                            child: Text('Krmení'),
                          ),
                          DropdownMenuItem(
                            value: 'carrying',
                            child: Text('Nošení'),
                          ),
                          DropdownMenuItem(
                            value: 'pacifier',
                            child: Text('Dudlík'),
                          ),
                          DropdownMenuItem(value: 'other', child: Text('Jiné')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _soothingMethod = value;
                          });
                          _invalidateAiPreview();
                          _resetAiFeedback();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Co pomohlo uklidnit',
                        ),
                      ),
                      const SizedBox(height: 6),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Dítě se uklidnilo'),
                        value: _cryingResolved,
                        onChanged: (value) {
                          setState(() {
                            _cryingResolved = value;
                          });
                          _invalidateAiPreview();
                          _resetAiFeedback();
                        },
                      ),
                      const SizedBox(height: 18),
                      _SectionTitle(
                        title: 'Audio',
                        subtitle:
                            'Volitelné. Pomůže budoucí i aktuální AI analýze.',
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: (_isRecording || _isAudioBusy)
                                        ? null
                                        : _startRecording,
                                    icon: const Icon(Icons.mic_none_rounded),
                                    label: const Text('Spustit nahrávání'),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: (!_isRecording || _isAudioBusy)
                                        ? null
                                        : _stopRecording,
                                    icon: const Icon(
                                      Icons.stop_circle_outlined,
                                    ),
                                    label: const Text('Zastavit'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        (!hasAudio && !_isRecording) ||
                                            _isAudioBusy
                                        ? null
                                        : _clearRecording,
                                    child: const Text('Odebrat audio'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _audioStatus ??
                                    (hasAudio
                                        ? 'Audio vzorek je připraven pro AI analýzu.'
                                        : 'Zatím není nahrán žádný audio vzorek.'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SectionTitle(
                        title: 'AI výstup',
                        subtitle:
                            'Nejprve zkus odhad, potom můžeš výsledek potvrdit.',
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (_isAnalyzingAi || _isRecording)
                                      ? null
                                      : _analyzeAiPreview,
                                  child: Text(
                                    _isAnalyzingAi
                                        ? 'Probíhá analýza...'
                                        : 'Spustit AI analýzu',
                                  ),
                                ),
                              ),
                              if (_aiPreviewError != null) ...[
                                const SizedBox(height: 12),
                                Text(_aiPreviewError!),
                              ],
                              if (_aiPreview != null) ...[
                                const SizedBox(height: 14),
                                _AiResultSummary(
                                  cryDetected: _aiPreview!.cryDetected,
                                  cryProbability: _aiPreview!.cryProbability,
                                  probableCause:
                                      _aiPreview!.probableCause == null
                                      ? null
                                      : _cryingCauseLabel(
                                          _aiPreview!.probableCause!,
                                        ),
                                  confidence: usableConfidence,
                                  confidenceLabel: usableConfidence == null
                                      ? null
                                      : _confidenceLabel(usableConfidence),
                                  modelVersion: _aiPreview!.modelVersion,
                                  signals: _aiPreview!.signals,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (_aiPreview != null) ...[
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Potvrzení výsledku',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 12),
                                const Text('Je to opravdu pláč?'),
                                RadioGroup<bool>(
                                  groupValue: _aiUserConfirmedCry,
                                  onChanged: (value) {
                                    setState(() {
                                      _aiUserConfirmedCry = value;
                                      if (value == false) {
                                        _aiUserConfirmedCause = null;
                                        _aiUserCorrectedCause = null;
                                      }
                                    });
                                  },
                                  child: Column(
                                    children: const [
                                      RadioListTile<bool>(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text('Ano'),
                                        value: true,
                                      ),
                                      RadioListTile<bool>(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text('Ne'),
                                        value: false,
                                      ),
                                    ],
                                  ),
                                ),
                                if (showCauseFeedback) ...[
                                  const SizedBox(height: 8),
                                  const Text('Sedí odhad příčiny?'),
                                  RadioGroup<bool>(
                                    groupValue: _aiUserConfirmedCause,
                                    onChanged: (value) {
                                      setState(() {
                                        _aiUserConfirmedCause = value;
                                        if (value == true) {
                                          _aiUserCorrectedCause = null;
                                        }
                                      });
                                    },
                                    child: Column(
                                      children: const [
                                        RadioListTile<bool>(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text('Ano'),
                                          value: true,
                                        ),
                                        RadioListTile<bool>(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text('Ne'),
                                          value: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_aiUserConfirmedCause == false) ...[
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      initialValue: _aiUserCorrectedCause,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'hunger',
                                          child: Text('Hlad'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'tired',
                                          child: Text('Únava'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'discomfort',
                                          child: Text('Diskomfort'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'other',
                                          child: Text('Jiné'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'unknown',
                                          child: Text('Nevím'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _aiUserCorrectedCause = value;
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Správná příčina',
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isRecording ? null : _save,
                    child: Text(_isEdit ? 'Uložit změny' : 'Uložit'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({
    required this.title,
    required this.subtitle,
    required this.trailingLabel,
  });

  final String title;
  final String subtitle;
  final String trailingLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF1F1), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              Chip(label: Text(trailingLabel)),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

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
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(subtitle),
      ],
    );
  }
}

class _AiResultSummary extends StatelessWidget {
  const _AiResultSummary({
    required this.cryDetected,
    required this.cryProbability,
    required this.probableCause,
    required this.confidence,
    required this.confidenceLabel,
    required this.modelVersion,
    required this.signals,
  });

  final bool cryDetected;
  final double cryProbability;
  final String? probableCause;
  final double? confidence;
  final String? confidenceLabel;
  final String modelVersion;
  final List<String> signals;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: Text(cryDetected ? 'Pláč detekován' : 'Pláč nepotvrzen'),
            ),
            Chip(
              label: Text(
                'Pravděpodobnost ${(cryProbability * 100).round()} %',
              ),
            ),
            if (probableCause != null)
              Chip(label: Text('Příčina: $probableCause')),
            if (confidence != null)
              Chip(
                label: Text(
                  '${confidenceLabel!} ${(confidence! * 100).round()} %',
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Model: $modelVersion'),
        if (signals.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Hlavní signály',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: signals
                .map(
                  (signal) => Chip(
                    label: Text(signal),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
