import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

import '../../core/app_services.dart';
import '../timeline/timeline_item.dart';
import 'ai_crying_analysis_result.dart';
import 'crying_source.dart';

class CryingFormScreen extends StatefulWidget {
  const CryingFormScreen({
    super.key,
    this.existingItem,
  });

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
        _durationController.text =
            existingItem.cryingDurationMinutes.toString();
      }

      _soothingMethod = existingItem.soothingMethod;
      _cryingResolved = existingItem.cryingResolved ?? false;
      _audioSamplePath = existingItem.audioSamplePath;

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
      default:
        return cause;
    }
  }

  void _invalidateAiPreview() {
    if (_aiPreview == null && _aiPreviewError == null) return;

    setState(() {
      _aiPreview = null;
      _aiPreviewError = null;
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
    final durationMinutes =
        durationText.isEmpty ? null : int.tryParse(durationText);

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
      ..aiSignalsSerialized = widget.existingItem?.aiSignalsSerialized;
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
  }

  Future<void> _save() async {
    if (_isRecording) return;

    final item = _buildDraftItem();

    final aiResult =
        _aiPreview ??
        await AppServices.cryingAiService.analyzeCryingItem(item);

    item
      ..aiCryProbability = aiResult.cryProbability
      ..aiProbableCause = aiResult.probableCause
      ..aiConfidence = aiResult.confidence
      ..aiModelVersion = aiResult.modelVersion
      ..aiAnalyzedAt = DateTime.now()
      ..aiSignalsSerialized =
          aiResult.signals.isEmpty ? null : aiResult.signals.join(' | ');

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

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Upravit pláč' : 'Pláč'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
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
                          _invalidateAiPreview();
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Délka pláče (min)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _invalidateAiPreview(),
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
                          DropdownMenuItem(
                            value: 'other',
                            child: Text('Jiné'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _soothingMethod = value;
                          });
                          _invalidateAiPreview();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Co pomohlo uklidnit',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Dítě se uklidnilo'),
                        value: _cryingResolved,
                        onChanged: (value) {
                          setState(() {
                            _cryingResolved = value;
                          });
                          _invalidateAiPreview();
                        },
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Audio vzorek',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ElevatedButton(
                                    onPressed: (_isRecording || _isAudioBusy)
                                        ? null
                                        : _startRecording,
                                    child: const Text('Spustit nahrávání'),
                                  ),
                                  ElevatedButton(
                                    onPressed: (!_isRecording || _isAudioBusy)
                                        ? null
                                        : _stopRecording,
                                    child: const Text('Zastavit nahrávání'),
                                  ),
                                  TextButton(
                                    onPressed: (!hasAudio && !_isRecording) ||
                                            _isAudioBusy
                                        ? null
                                        : _clearRecording,
                                    child: const Text('Odebrat audio'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _audioStatus ??
                                    (hasAudio
                                        ? 'Audio vzorek je připraven pro budoucí AI analýzu'
                                        : 'Zatím není nahrán žádný audio vzorek'),
                              ),
                            ],
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
                              const Text(
                                'AI preview',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (_isAnalyzingAi || _isRecording)
                                      ? null
                                      : _analyzeAiPreview,
                                  child: Text(
                                    _isAnalyzingAi
                                        ? 'Probíhá analýza...'
                                        : 'Analyzovat AI',
                                  ),
                                ),
                              ),
                              if (_aiPreviewError != null) ...[
                                const SizedBox(height: 12),
                                Text(_aiPreviewError!),
                              ],
                              if (_aiPreview != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Detekce pláče: ${_aiPreview!.cryDetected ? 'ano' : 'ne'}',
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Pravděpodobnost pláče: ${(_aiPreview!.cryProbability * 100).round()} %',
                                ),
                                if (_aiPreview!.probableCause != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Odhad příčiny: ${_cryingCauseLabel(_aiPreview!.probableCause!)}',
                                  ),
                                ],
                                if (_aiPreview!.confidence != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Jistota příčiny: ${(_aiPreview!.confidence! * 100).round()} %',
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  'Model: ${_aiPreview!.modelVersion}',
                                ),
                                if (_aiPreview!.signals.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Signály:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ..._aiPreview!.signals.map(
                                    (signal) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text('• $signal'),
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
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