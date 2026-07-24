import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

import '../../core/app_services.dart';
import '../../core/audio_capture_service.dart';
import '../../core/design/bebia_theme.dart';
import '../../shared/widgets/bebia_components.dart';
import '../../shared/widgets/info_label.dart';
import '../../shared/widgets/event_form_context_card.dart';
import '../../shared/widgets/profile_switcher.dart';
import '../timeline/event_time_validation.dart';
import '../timeline/timeline_item.dart';
import '../timeline/timeline_form_submission.dart';
import 'ai_crying_analysis_result.dart';
import 'crying_source.dart';

typedef CryingAnalysisCallback =
    Future<AiCryingAnalysisResult> Function(TimelineItem item);

class CryingFormScreen extends StatefulWidget {
  const CryingFormScreen({
    super.key,
    this.existingItem,
    this.audioCapture,
    this.submission,
    this.analyzeCrying,
  });

  final TimelineItem? existingItem;
  final AudioCapture? audioCapture;
  final TimelineFormSubmission? submission;
  final CryingAnalysisCallback? analyzeCrying;

  @override
  State<CryingFormScreen> createState() => _CryingFormScreenState();
}

class _CryingFormScreenState extends State<CryingFormScreen> {
  late final AudioCapture _audioCapture;
  late final bool _ownsAudioCapture;
  late final String? _originalAudioPath;
  double _intensity = 3;
  DateTime _selectedTime = DateTime.now();
  final TextEditingController _durationController = TextEditingController();
  String? _soothingMethod;
  bool _cryingResolved = false;

  String? _audioSamplePath;
  bool _isRecording = false;
  bool _isAudioBusy = false;
  bool _recordingSessionRequested = false;
  bool _retainAudioAfterDispose = false;
  String? _audioStatus;

  AiCryingAnalysisResult? _aiPreview;
  bool _isAnalyzingAi = false;
  bool _isSaving = false;
  String? _aiPreviewError;

  bool? _aiUserConfirmedCry;
  bool? _aiUserConfirmedCause;
  String? _aiUserCorrectedCause;

  bool get _isEdit => widget.existingItem != null;
  TimelineFormSubmission get _submission =>
      widget.submission ?? const AppTimelineFormSubmission();

  Future<AiCryingAnalysisResult> _analyzeCrying(TimelineItem item) {
    return widget.analyzeCrying?.call(item) ??
        AppServices.cryingAiService.analyzeCryingItem(item);
  }

  @override
  void initState() {
    super.initState();
    _ownsAudioCapture = widget.audioCapture == null;
    _audioCapture = widget.audioCapture ?? AudioCaptureService();
    _originalAudioPath = widget.existingItem?.audioSamplePath;

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
      initialDate: clampEventPickerInitialDate(_selectedTime),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );

    if (pickedTime == null || !mounted) return;

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
      final result = await _analyzeCrying(_buildDraftItem());

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
      _isRecording = false;
      _recordingSessionRequested = true;
      _audioStatus = null;
    });

    try {
      final path = await _audioCapture.startRecording();

      if (!mounted) {
        await _releaseAudioResourcesAfterDispose();
        return;
      }

      setState(() {
        _isRecording = true;
        _audioSamplePath = path;
        _audioStatus = 'Nahrávání běží';
      });

      _invalidateAiPreview();
      _resetAiFeedback();
    } on AudioPermissionDeniedException catch (error) {
      if (!mounted) return;

      setState(() {
        _recordingSessionRequested = false;
        _audioStatus = error.message;
      });
    } on AudioCaptureException catch (error) {
      if (!mounted) return;

      setState(() {
        _recordingSessionRequested = false;
        _audioStatus = error.message;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _recordingSessionRequested = false;
        _audioStatus = 'Nepodařilo se spustit nahrávání: $error';
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
      final path = await _audioCapture.stopRecording();

      if (!mounted) return;

      setState(() {
        _isRecording = false;
        _recordingSessionRequested = false;
        _audioSamplePath = path ?? _audioSamplePath;
        _audioStatus = _audioSamplePath == null
            ? 'Nahrávání bylo zastaveno'
            : 'Audio vzorek je uložen';
      });

      _invalidateAiPreview();
      _resetAiFeedback();
    } on AudioCaptureException catch (error) {
      if (!mounted) return;

      setState(() {
        _audioStatus = error.message;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _audioStatus = 'Nepodařilo se zastavit nahrávání: $error';
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

    final pathToDelete = _audioSamplePath;
    setState(() {
      _isAudioBusy = true;
    });

    try {
      if (_isRecording) {
        await _audioCapture.cancelRecording();
      }
      if (pathToDelete != null &&
          pathToDelete.isNotEmpty &&
          pathToDelete != _originalAudioPath) {
        await _audioCapture.deleteRecording(pathToDelete);
      }
      if (!mounted) return;

      setState(() {
        _isRecording = false;
        _recordingSessionRequested = false;
        _audioSamplePath = null;
        _audioStatus = 'Audio vzorek byl odebrán';
      });
      _invalidateAiPreview();
      _resetAiFeedback();
    } catch (error) {
      var recorderStillActive = _isRecording;
      try {
        recorderStillActive = await _audioCapture.isRecording();
      } catch (_) {
        // Zachováme poslední známý stav, když ani kontrola recorderu neuspěje.
      }
      if (!mounted) return;
      setState(() {
        _isRecording = recorderStillActive;
        _recordingSessionRequested = recorderStillActive;
        _audioStatus = 'Audio vzorek se nepodařilo odebrat: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAudioBusy = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (_isRecording || _isSaving) return;
    if (!_submission.hasActiveProfile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nejdřív vyber profil dítěte, ke kterému chceš událost uložit.',
          ),
        ),
      );
      return;
    }

    final durationText = _durationController.text.trim();
    final durationMinutes = durationText.isEmpty
        ? null
        : int.tryParse(durationText);
    if (durationText.isNotEmpty &&
        (durationMinutes == null || durationMinutes <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Délka pláče musí být kladné celé číslo v minutách.'),
        ),
      );
      return;
    }

    if (isEventTimeInFuture(_selectedTime)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(futureEventMessage('Pláč'))));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final item = _buildDraftItem();
      final aiResult = _aiPreview ?? await _analyzeCrying(item);

      item
        ..aiCryProbability = aiResult.cryProbability
        ..aiProbableCause = aiResult.probableCause
        ..aiConfidence = aiResult.confidence
        ..aiModelVersion = aiResult.modelVersion
        ..aiAnalyzedAt = DateTime.now()
        ..aiSignalsSerialized = aiResult.signals.isEmpty
            ? null
            : aiResult.signals.join(' | ');

      await _submission.save(item, isEdit: _isEdit);

      final originalAudioPath = _originalAudioPath;
      if (originalAudioPath != null &&
          originalAudioPath.isNotEmpty &&
          originalAudioPath != _audioSamplePath) {
        try {
          await _audioCapture.deleteRecording(originalAudioPath);
        } catch (_) {
          // Záznam je uložený; úklid starého temp souboru je best effort.
        }
      }
      _retainAudioAfterDispose = true;
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pláč se nepodařilo uložit. Zkus to znovu.'),
        ),
      );
      return;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }

    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }
  }

  Future<void> _releaseAudioResourcesAfterDispose() async {
    final pathToDelete = _audioSamplePath;
    try {
      if (_recordingSessionRequested) {
        await _audioCapture.cancelRecording();
      }
      if (!_retainAudioAfterDispose &&
          pathToDelete != null &&
          pathToDelete.isNotEmpty &&
          pathToDelete != _originalAudioPath) {
        await _audioCapture.deleteRecording(pathToDelete);
      }
    } catch (_) {
      // Widget už není aktivní; důležité je nenechat chybu uniknout do zóny.
    } finally {
      _recordingSessionRequested = false;
      if (_ownsAudioCapture) {
        try {
          await (_audioCapture as AudioCaptureService).dispose();
        } catch (_) {
          // Ani chyba platformního dispose nesmí uniknout z lifecycle úklidu.
        }
      }
    }
  }

  @override
  void dispose() {
    final hasTemporaryAudio =
        !_retainAudioAfterDispose &&
        _audioSamplePath != null &&
        _audioSamplePath!.isNotEmpty &&
        _audioSamplePath != _originalAudioPath;
    if (_recordingSessionRequested || hasTemporaryAudio || _ownsAudioCapture) {
      unawaited(_releaseAudioResourcesAfterDispose());
    }
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileSwitcherHeight =
        MediaQuery.textScalerOf(context).scale(1) >= 1.5 ? 84.0 : 56.0;
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(_isEdit ? 'Upravit pláč' : 'Pláč'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(profileSwitcherHeight),
          child: const ProfileSwitcher(
            embedded: true,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          ),
        ),
      ),
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
                      const EventFormContextCard(),
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
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Intenzita pláče',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  InfoLabel(label: '${_intensity.toInt()}/5'),
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
                        key: const Key('crying-duration-field'),
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
                                    key: const Key('crying-start-recording'),
                                    onPressed: (_isRecording || _isAudioBusy)
                                        ? null
                                        : _startRecording,
                                    icon: const Icon(Icons.mic_none_rounded),
                                    label: const Text('Spustit nahrávání'),
                                  ),
                                  ElevatedButton.icon(
                                    key: const Key('crying-stop-recording'),
                                    onPressed: (!_isRecording || _isAudioBusy)
                                        ? null
                                        : _stopRecording,
                                    icon: const Icon(
                                      Icons.stop_circle_outlined,
                                    ),
                                    label: const Text('Zastavit'),
                                  ),
                                  TextButton(
                                    key: const Key('crying-clear-recording'),
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
                                key: const Key('crying-audio-status'),
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
                    onPressed: _isRecording || _isSaving ? null : _save,
                    child: Text(
                      _isSaving
                          ? 'Ukládám…'
                          : _isEdit
                          ? 'Uložit změny'
                          : 'Uložit',
                    ),
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
    return BebiaFormIntroCard(
      accent: context.bebia.crying,
      title: title,
      subtitle: subtitle,
      trailing: InfoLabel(label: trailingLabel),
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
            InfoLabel(
              label: cryDetected ? 'Pláč detekován' : 'Pláč nepotvrzen',
            ),
            InfoLabel(
              label: 'Pravděpodobnost ${(cryProbability * 100).round()} %',
            ),
            if (probableCause != null)
              InfoLabel(label: 'Příčina: $probableCause'),
            if (confidence != null)
              InfoLabel(
                label: '${confidenceLabel!} ${(confidence! * 100).round()} %',
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
                .map((signal) => InfoLabel(label: signal))
                .toList(),
          ),
        ],
      ],
    );
  }
}
