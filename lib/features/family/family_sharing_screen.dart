import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_services.dart';
import '../../core/design/bebia_theme.dart';
import '../../shared/widgets/info_label.dart';
import '../auth/app_account_provider.dart';
import '../auth/app_account_session.dart';
import '../auth/app_account_setup_screen.dart';
import 'family_cloud_sync_service.dart';
import 'family_connection.dart';
import 'family_remote_sync_executor.dart';
import 'family_sync_orchestration_service.dart';
import 'family_sync_strategy.dart';
import 'family_test_sync_service.dart';
import 'family_workspace_snapshot.dart';

enum _FamilySetupStage { signIn, createFamily, invitePartner, connected }

class FamilySharingScreen extends StatefulWidget {
  const FamilySharingScreen({super.key, this.loadOnInit = true});

  final bool loadOnInit;

  @override
  State<FamilySharingScreen> createState() => _FamilySharingScreenState();
}

class _FamilySharingScreenState extends State<FamilySharingScreen> {
  final TextEditingController _partnerCodeController = TextEditingController();
  final TextEditingController _partnerNameController = TextEditingController();
  final TextEditingController _partnerRoleController = TextEditingController(
    text: 'Rodič',
  );
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController(
    text: 'Rodič',
  );
  FamilyTestSyncReport? _testSyncReport;
  FamilyRemoteSyncExecutionReport? _backendExecutionReport;
  bool _isRunningTestSync = false;
  bool _isRunningBackendSync = false;

  @override
  void initState() {
    super.initState();
    if (widget.loadOnInit) {
      AppServices.familyConnectionController.load();
    }
  }

  @override
  void dispose() {
    _partnerCodeController.dispose();
    _partnerNameController.dispose();
    _partnerRoleController.dispose();
    _nameController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _createInvite() async {
    await AppServices.familyConnectionController.createInvite();
  }

  Future<void> _markInviteShared() async {
    await AppServices.familyConnectionController.markInviteShared();
  }

  Future<void> _markInviteAccepted() async {
    await AppServices.familyConnectionController.markInviteAccepted();
  }

  Future<void> _markConnected() async {
    await AppServices.familyConnectionController.markConnected();
  }

  Future<void> _copyInviteCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pozvánkový kód byl zkopírován.')),
    );
  }

  Future<void> _addCaregiver() async {
    await AppServices.familyConnectionController.addCaregiver(
      name: _nameController.text,
      role: _roleController.text,
    );

    if (!mounted) {
      return;
    }

    if (AppServices.familyConnectionController.error.value == null) {
      _nameController.clear();
      _roleController.text = 'Rodič';
    }
  }

  Future<void> _acceptInviteCode() async {
    await AppServices.familyConnectionController.acceptInviteCode(
      inviteCode: _partnerCodeController.text,
      caregiverName: _partnerNameController.text,
      caregiverRole: _partnerRoleController.text,
    );

    if (!mounted) {
      return;
    }

    if (AppServices.familyConnectionController.error.value == null) {
      _partnerCodeController.clear();
      _partnerNameController.clear();
      _partnerRoleController.text = 'Rodič';
    }
  }

  Future<void> _assignChildToCurrentFamily(String childId) async {
    final familyId =
        AppServices.familyConnectionController.state.value.familyId;
    if (familyId == null || familyId.isEmpty) {
      return;
    }

    try {
      await AppServices.childProfileController.assignProfileToFamily(
        profileId: childId,
        familyId: familyId,
      );
    } catch (_) {
      if (!mounted) return;
      final message =
          AppServices.childProfileController.error.value ??
          'Dítě se nepodařilo přidat do rodiny. Zkus to znovu.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _removeChildFromCurrentFamily(String childId) async {
    try {
      await AppServices.childProfileController.removeProfileFromFamily(childId);
    } catch (_) {
      if (!mounted) return;
      final message =
          AppServices.childProfileController.error.value ??
          'Dítě se nepodařilo odebrat z rodiny. Zkus to znovu.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openAccountSetup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AppAccountSetupScreen()),
    );
  }

  Future<void> _runTestSync() async {
    setState(() {
      _isRunningTestSync = true;
    });

    try {
      final session = AppServices.appAccountController.session.value;
      final familyState = AppServices.familyConnectionController.state.value;
      final workspace = AppServices.familyWorkspaceService.buildSnapshot(
        session: session,
        familyState: familyState,
        childProfiles: AppServices.childProfileController.profiles.value,
      );
      final familyPayload = AppServices.familyCloudSyncService.buildPayload(
        session: session,
        familyState: familyState,
        workspace: workspace,
      );
      final familyPlan = AppServices.familySyncOrchestrationService.buildPlan(
        familyPayload,
      );

      final activeProfile = AppServices.childProfileController.activeProfile;
      final timelineItems = await AppServices.timelineRepository.getAll(
        childId: activeProfile?.id,
      );
      final timelinePayload = AppServices.timelineCloudSyncService.buildPayload(
        session: session,
        familyState: familyState,
        activeProfile: activeProfile,
        items: timelineItems,
      );
      final timelinePlan = AppServices.timelineCloudSyncService.buildPlan(
        timelinePayload,
      );

      final report = AppServices.familyTestSyncService.buildReport(
        familyPayload: familyPayload,
        familyPlan: familyPlan,
        timelinePayload: timelinePayload,
        timelinePlan: timelinePlan,
        backendConfigured: AppServices.firebaseBootstrapService.isConfigured,
        hasRemoteFamilyRepository: AppServices.remoteFamilyRepository != null,
        hasRemoteTimelineRepository:
            AppServices.remoteTimelineRepository != null,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _testSyncReport = report;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRunningTestSync = false;
        });
      }
    }
  }

  Future<void> _runBackendSyncTest() async {
    setState(() {
      _isRunningBackendSync = true;
    });

    try {
      final session = AppServices.appAccountController.session.value;
      final familyState = AppServices.familyConnectionController.state.value;
      final workspace = AppServices.familyWorkspaceService.buildSnapshot(
        session: session,
        familyState: familyState,
        childProfiles: AppServices.childProfileController.profiles.value,
      );
      final familyPayload = AppServices.familyCloudSyncService.buildPayload(
        session: session,
        familyState: familyState,
        workspace: workspace,
      );
      final familyPlan = AppServices.familySyncOrchestrationService.buildPlan(
        familyPayload,
      );

      final report = await AppServices.familyRemoteSyncExecutor.execute(
        payload: familyPayload,
        plan: familyPlan,
        backendConfigured: AppServices.firebaseBootstrapService.isConfigured,
        remoteRepository: AppServices.remoteFamilyRepository,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _backendExecutionReport = report;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            report.isSuccessful
                ? 'Backend test rodiny proběhl úspěšně.'
                : report.wasExecuted
                ? 'Backend test doběhl, ale narazil na chybu.'
                : 'Backend test zůstal jen v kontrolním režimu.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRunningBackendSync = false;
        });
      }
    }
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day.$month.$year v $hour:$minute';
  }

  _FamilySetupStage _resolveStage({
    required AppAccountSession session,
    required FamilyConnectionState state,
  }) {
    if (!session.isSignedIn) {
      return _FamilySetupStage.signIn;
    }
    if (state.familyId == null || state.familyId!.isEmpty) {
      return _FamilySetupStage.createFamily;
    }
    if (!state.isConnected) {
      return _FamilySetupStage.invitePartner;
    }
    return _FamilySetupStage.connected;
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppServices.familyConnectionController;
    final colorScheme = Theme.of(context).colorScheme;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(10, 0, 10, 6),
      child: AnimatedPadding(
        duration: BebiaMotion.resolve(
          BebiaMotion.standard,
          reduceMotion: context.bebia.reduceMotion,
        ),
        curve: BebiaMotion.enter,
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            widthFactor: 1,
            heightFactor: 0.94,
            child: Material(
              color: colorScheme.surface,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(32),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.16),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Rodinné sdílení',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ValueListenableBuilder<AppAccountSession>(
                        valueListenable:
                            AppServices.appAccountController.session,
                        builder: (context, session, _) {
                          return ValueListenableBuilder<FamilyConnectionState>(
                            valueListenable: controller.state,
                            builder: (context, state, _) {
                              final stage = _resolveStage(
                                session: session,
                                state: state,
                              );
                              final workspace = AppServices
                                  .familyWorkspaceService
                                  .buildSnapshot(
                                    session: session,
                                    familyState: state,
                                    childProfiles: AppServices
                                        .childProfileController
                                        .profiles
                                        .value,
                                  );
                              final syncPayload = AppServices
                                  .familyCloudSyncService
                                  .buildPayload(
                                    session: session,
                                    familyState: state,
                                    workspace: workspace,
                                  );
                              final syncPlan = AppServices
                                  .familySyncOrchestrationService
                                  .buildPlan(syncPayload);

                              return ListView(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  22,
                                ),
                                children: [
                                  _SharingHeaderCard(
                                    session: session,
                                    stage: stage,
                                    state: state,
                                  ),
                                  const SizedBox(height: 16),
                                  _SetupStateCard(
                                    session: session,
                                    state: state,
                                    stage: stage,
                                    onOpenSetup: _openAccountSetup,
                                    onCreateInvite: _createInvite,
                                    onMarkInviteShared: _markInviteShared,
                                    onMarkInviteAccepted: _markInviteAccepted,
                                    onMarkConnected: _markConnected,
                                  ),
                                  const SizedBox(height: 16),
                                  _WorkspacePreviewCard(
                                    workspace: workspace,
                                    onAssignChild: _assignChildToCurrentFamily,
                                    onRemoveChild:
                                        _removeChildFromCurrentFamily,
                                  ),
                                  const SizedBox(height: 16),
                                  Card(
                                    child: ExpansionTile(
                                      leading: const Icon(
                                        Icons.settings_suggest_outlined,
                                      ),
                                      title: const Text(
                                        'Podrobnosti synchronizace',
                                      ),
                                      subtitle: const Text(
                                        'Stav cloudu, testy a technický plán',
                                      ),
                                      childrenPadding:
                                          const EdgeInsets.fromLTRB(
                                            16,
                                            0,
                                            16,
                                            16,
                                          ),
                                      children: [
                                        _AccountReadinessCard(
                                          session: session,
                                          onOpenSetup: _openAccountSetup,
                                        ),
                                        const SizedBox(height: 12),
                                        const _SyncRealityCard(),
                                        const SizedBox(height: 12),
                                        const _InviteLifecycleCard(),
                                        const SizedBox(height: 12),
                                        _CloudSyncPreviewCard(
                                          payload: syncPayload,
                                        ),
                                        const SizedBox(height: 12),
                                        _SyncPlanPreviewCard(plan: syncPlan),
                                        const SizedBox(height: 12),
                                        _TestSyncCard(
                                          report: _testSyncReport,
                                          isRunning: _isRunningTestSync,
                                          onRun: _runTestSync,
                                          backendReport:
                                              _backendExecutionReport,
                                          isRunningBackend:
                                              _isRunningBackendSync,
                                          onRunBackend: _runBackendSyncTest,
                                        ),
                                        const SizedBox(height: 12),
                                        const _SyncRoadmapCard(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ValueListenableBuilder<bool>(
                                    valueListenable: controller.isLoading,
                                    builder: (context, isLoading, _) {
                                      return _InviteCard(
                                        session: session,
                                        state: state,
                                        isLoading: isLoading,
                                        onCreateInvite: _createInvite,
                                        onMarkInviteShared: _markInviteShared,
                                        onMarkInviteAccepted:
                                            _markInviteAccepted,
                                        onCopyInviteCode: _copyInviteCode,
                                        onCancelInvite: controller.cancelInvite,
                                        onMarkConnected: _markConnected,
                                        formatDateTime: _formatDateTime,
                                      );
                                    },
                                  ),
                                  if (state.hasInvite &&
                                      !state.isConnected) ...[
                                    const SizedBox(height: 16),
                                    ValueListenableBuilder<bool>(
                                      valueListenable: controller.isLoading,
                                      builder: (context, isLoading, _) {
                                        return _JoinByInviteCard(
                                          state: state,
                                          isLoading: isLoading,
                                          codeController:
                                              _partnerCodeController,
                                          nameController:
                                              _partnerNameController,
                                          roleController:
                                              _partnerRoleController,
                                          onAccept: _acceptInviteCode,
                                        );
                                      },
                                    ),
                                  ],
                                  if (state.familyId != null &&
                                      state.familyId!.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    _CaregiverForm(
                                      nameController: _nameController,
                                      roleController: _roleController,
                                      onSubmit: _addCaregiver,
                                    ),
                                    const SizedBox(height: 16),
                                    _CaregiverList(
                                      caregivers: state.caregivers,
                                      onRemove: controller.removeCaregiver,
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  ValueListenableBuilder<String?>(
                                    valueListenable: controller.error,
                                    builder: (context, error, _) {
                                      if (error == null) {
                                        return const SizedBox.shrink();
                                      }
                                      return Text(
                                        error,
                                        style: TextStyle(
                                          color: colorScheme.error,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SharingHeaderCard extends StatelessWidget {
  const _SharingHeaderCard({
    required this.session,
    required this.stage,
    required this.state,
  });

  final AppAccountSession session;
  final _FamilySetupStage stage;
  final FamilyConnectionState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final title = switch (stage) {
      _FamilySetupStage.signIn => 'Nejdřív přihlas rodiče',
      _FamilySetupStage.createFamily => 'Rodina čeká na založení',
      _FamilySetupStage.invitePartner => 'Pozvi druhého rodiče',
      _FamilySetupStage.connected => 'Rodinný prostor je připravený',
    };

    final label = switch (stage) {
      _FamilySetupStage.signIn => 'Krok 1',
      _FamilySetupStage.createFamily => 'Krok 2',
      _FamilySetupStage.invitePartner => 'Krok 3',
      _FamilySetupStage.connected => 'Připraveno',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.62),
            colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primary.withValues(alpha: 0.14),
                foregroundColor: colorScheme.primary,
                child: const Icon(Icons.diversity_1_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              InfoLabel(label: label),
            ],
          ),
          const SizedBox(height: 12),
          Text(_headerTextFor(state)),
          if (session.isSignedIn) ...[
            const SizedBox(height: 10),
            Text(
              'Aktivní rodič: ${session.user!.displayName}',
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

  String _headerTextFor(FamilyConnectionState state) {
    switch (state.inviteStatus) {
      case FamilyInviteStatus.none:
        return 'Tady připravíš rodinu, pozvánku i další pečující osoby. Po zapnutí cloud syncu na tom poběží skutečné sdílení mezi dvěma telefony.';
      case FamilyInviteStatus.draft:
        return 'Rodina už existuje a pozvánka je připravená. Další krok je kód opravdu sdílet s druhým rodičem.';
      case FamilyInviteStatus.waitingForAcceptance:
        return 'Pozvánka už byla odeslaná. Teď čekáš, až ji druhý rodič přijme.';
      case FamilyInviteStatus.accepted:
        return 'Pozvánka už byla přijatá. Poslední krok je dokončit aktivaci společné rodiny.';
      case FamilyInviteStatus.connected:
        return 'Rodina je lokálně aktivní a připravená na další krok s budoucí cloudovou synchronizací.';
    }
  }
}

class _SetupStateCard extends StatelessWidget {
  const _SetupStateCard({
    required this.session,
    required this.state,
    required this.stage,
    required this.onOpenSetup,
    required this.onCreateInvite,
    required this.onMarkInviteShared,
    required this.onMarkInviteAccepted,
    required this.onMarkConnected,
  });

  final AppAccountSession session;
  final FamilyConnectionState state;
  final _FamilySetupStage stage;
  final Future<void> Function() onOpenSetup;
  final Future<void> Function() onCreateInvite;
  final Future<void> Function() onMarkInviteShared;
  final Future<void> Function() onMarkInviteAccepted;
  final Future<void> Function() onMarkConnected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final title = switch (stage) {
      _FamilySetupStage.signIn => '1. Přihlásit rodiče',
      _FamilySetupStage.createFamily => '2. Založit rodinu',
      _FamilySetupStage.invitePartner => '3. Dokončit pozvánku',
      _FamilySetupStage.connected => 'Rodina je připravená',
    };

    final description = switch (stage) {
      _FamilySetupStage.signIn =>
        'Bez rodičovského účtu nepůjde bezpečně sdílet data mezi dvěma telefony. Začni ukázkovým přihlášením nebo otevři nastavení účtu.',
      _FamilySetupStage.createFamily =>
        'Jakmile je rodič přihlášený, Bebia může vytvořit rodinný prostor a připravit první pozvánku.',
      _FamilySetupStage.invitePartner => _inviteStepDescription(state),
      _FamilySetupStage.connected =>
        'Rodina už má hotový celý lokální tok od vytvoření přes přijetí až po aktivaci.',
    };

    final Widget action = switch (stage) {
      _FamilySetupStage.signIn => FilledButton.tonalIcon(
        onPressed: () {
          onOpenSetup();
        },
        icon: const Icon(Icons.login_rounded),
        label: const Text('Otevřít účet a synchronizaci'),
      ),
      _FamilySetupStage.createFamily => FilledButton.icon(
        onPressed: () {
          onCreateInvite();
        },
        icon: const Icon(Icons.group_add_outlined),
        label: const Text('Vytvořit rodinu a pozvánku'),
      ),
      _FamilySetupStage.invitePartner => _inviteActionFor(state),
      _FamilySetupStage.connected => FilledButton.tonalIcon(
        onPressed: () {
          onOpenSetup();
        },
        icon: const Icon(Icons.verified_user_outlined),
        label: const Text('Zkontrolovat stav účtu'),
      ),
    };

    return Card(
      color: colorScheme.primaryContainer.withValues(alpha: 0.32),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 14),
            action,
            if (session.isSignedIn && state.familyId != null) ...[
              const SizedBox(height: 12),
              Text(
                'Lokální ID rodiny: ${state.familyId}',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _inviteStepDescription(FamilyConnectionState state) {
    switch (state.inviteStatus) {
      case FamilyInviteStatus.none:
        return 'Nejdřív je potřeba pozvánku vytvořit.';
      case FamilyInviteStatus.draft:
        return 'Pozvánka je připravená. Teď ji označ jako odeslanou druhému rodiči.';
      case FamilyInviteStatus.waitingForAcceptance:
        return 'Pozvánka už byla odeslaná. Další krok je potvrdit, že ji druhý rodič přijal.';
      case FamilyInviteStatus.accepted:
        return 'Pozvánka už byla přijatá. Poslední krok je aktivovat společnou rodinu.';
      case FamilyInviteStatus.connected:
        return 'Rodina je aktivní.';
    }
  }

  Widget _inviteActionFor(FamilyConnectionState state) {
    switch (state.inviteStatus) {
      case FamilyInviteStatus.none:
        return FilledButton.icon(
          onPressed: () {
            onCreateInvite();
          },
          icon: const Icon(Icons.group_add_outlined),
          label: const Text('Vytvořit pozvánku'),
        );
      case FamilyInviteStatus.draft:
        return FilledButton.icon(
          onPressed: () {
            onMarkInviteShared();
          },
          icon: const Icon(Icons.send_outlined),
          label: const Text('Označit jako odeslanou'),
        );
      case FamilyInviteStatus.waitingForAcceptance:
        return FilledButton.icon(
          onPressed: () {
            onMarkInviteAccepted();
          },
          icon: const Icon(Icons.mark_email_read_outlined),
          label: const Text('Potvrdit přijetí pozvánky'),
        );
      case FamilyInviteStatus.accepted:
        return FilledButton.icon(
          onPressed: () {
            onMarkConnected();
          },
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text('Aktivovat společnou rodinu'),
        );
      case FamilyInviteStatus.connected:
        return FilledButton.icon(
          onPressed: () {
            onOpenSetup();
          },
          icon: const Icon(Icons.verified_user_outlined),
          label: const Text('Rodina je aktivní'),
        );
    }
  }
}

class _SyncRealityCard extends StatelessWidget {
  const _SyncRealityCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.secondaryContainer.withValues(alpha: 0.42),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Co funguje právě teď',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Zatím jde o lokální přípravu rodiny v tomto zařízení. Můžeš si nachystat pečující osoby a otestovat celý pozvánkový lifecycle, ale data dítěte se zatím mezi dvěma telefony ještě nesynchronizují.',
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteLifecycleCard extends StatelessWidget {
  const _InviteLifecycleCard();

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('1', 'Návrh pozvánky', 'Vznikne rodina a kód pro druhého rodiče.'),
      ('2', 'Odeslaná', 'Kód byl sdílený a čeká se na reakci druhého rodiče.'),
      ('3', 'Přijatá', 'Druhý rodič pozvánku potvrdil.'),
      ('4', 'Aktivní rodina', 'Společný rodinný prostor je připravený.'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Životní cyklus pozvánky',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            ...steps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 14, child: Text(step.$1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.$2,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(step.$3),
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

class _WorkspacePreviewCard extends StatelessWidget {
  const _WorkspacePreviewCard({
    required this.workspace,
    required this.onAssignChild,
    required this.onRemoveChild,
  });

  final FamilyWorkspaceSnapshot workspace;
  final Future<void> Function(String childId) onAssignChild;
  final Future<void> Function(String childId) onRemoveChild;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Co se bude synchronizovat',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              workspace.hasFamily
                  ? 'Tohle je lokální náhled budoucího cloudového payloadu pro rodinu, členy a děti.'
                  : 'Jakmile vznikne rodina, objeví se tady cloud-ready přehled toho, co se bude mezi rodiči sdílet.',
            ),
            const SizedBox(height: 14),
            if (workspace.hasFamily) ...[
              InfoLabel(label: 'Rodina ${workspace.familyId}'),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Stav pozvánky ${_statusLabel(workspace.inviteStatus)}',
              ),
              const SizedBox(height: 14),
            ],
            Text(
              'Členové rodiny',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (workspace.members.isEmpty)
              const Text('Zatím není připravený žádný člen rodiny.')
            else
              ...workspace.members.map(
                (member) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${member.name} • ${member.roleLabel}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (member.isOwner) const InfoLabel(label: 'Vlastník'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Text(
              'Děti v rodině',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (workspace.children.isEmpty)
              const Text('Zatím není připravený žádný profil dítěte.')
            else
              ...workspace.children.map(
                (child) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              child.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          InfoLabel(
                            label: child.isLinkedToCurrentFamily
                                ? 'Ve sdílené rodině'
                                : 'Mimo aktuální rodinu',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (workspace.hasFamily &&
                              !child.isLinkedToCurrentFamily)
                            OutlinedButton.icon(
                              onPressed: () {
                                onAssignChild(child.id);
                              },
                              icon: const Icon(Icons.family_restroom_outlined),
                              label: const Text('Přidat do rodiny'),
                            ),
                          if (child.isLinkedToCurrentFamily)
                            OutlinedButton.icon(
                              onPressed: () {
                                onRemoveChild(child.id);
                              },
                              icon: const Icon(Icons.link_off_rounded),
                              label: const Text('Odebrat z rodiny'),
                            ),
                        ],
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

  String _statusLabel(FamilyInviteStatus status) {
    switch (status) {
      case FamilyInviteStatus.none:
        return 'bez pozvánky';
      case FamilyInviteStatus.draft:
        return 'návrh';
      case FamilyInviteStatus.waitingForAcceptance:
        return 'čeká na přijetí';
      case FamilyInviteStatus.accepted:
        return 'přijatá';
      case FamilyInviteStatus.connected:
        return 'aktivní';
    }
  }
}

class _CloudSyncPreviewCard extends StatelessWidget {
  const _CloudSyncPreviewCard({required this.payload});

  final FamilyCloudSyncPayload payload;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: payload.canSync
          ? colorScheme.primaryContainer.withValues(alpha: 0.24)
          : colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Cloud sync preview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                InfoLabel(
                  label: payload.canSync ? 'Payload připraven' : 'Ještě ne',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              payload.canSync
                  ? 'Lokální data už mají tvar, který půjde bezpečně převést do Firestore.'
                  : 'Payload už známe, ale před ostrým syncem ještě chybí několik podmínek.',
            ),
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
            Text(
              'Rodinný dokument',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _PreviewLine(
              label: 'familyId',
              value: '${payload.familyDocument['familyId']}',
            ),
            _PreviewLine(
              label: 'name',
              value: '${payload.familyDocument['name']}',
            ),
            _PreviewLine(
              label: 'inviteStatus',
              value: '${payload.familyDocument['inviteStatus']}',
            ),
            _PreviewLine(
              label: 'memberCount',
              value: '${payload.familyDocument['memberCount']}',
            ),
            _PreviewLine(
              label: 'childCount',
              value: '${payload.familyDocument['childCount']}',
            ),
            const SizedBox(height: 14),
            Text(
              'Členství',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...payload.memberships.map(
              (membership) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${membership.userId} • ${membership.role.name} • ${membership.status.name}',
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Děti',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (payload.children.isEmpty)
              const Text('Zatím není připravené žádné dítě pro sync.')
            else
              ...payload.children.map(
                (child) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('${child['name']} • ${child['childId']}'),
                ),
              ),
            const SizedBox(height: 14),
            Text(
              'Pozvánka',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (payload.invitation == null)
              const Text('Pozvánka zatím není součástí payloadu.')
            else ...[
              _PreviewLine(label: 'code', value: payload.invitation!.code),
              _PreviewLine(
                label: 'createdBy',
                value: payload.invitation!.createdBy,
              ),
              _PreviewLine(
                label: 'expiresAt',
                value: payload.invitation!.expiresAt.toIso8601String(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SyncPlanPreviewCard extends StatelessWidget {
  const _SyncPlanPreviewCard({required this.plan});

  final FamilySyncPlanPreview plan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: plan.isReady
          ? colorScheme.secondaryContainer.withValues(alpha: 0.24)
          : colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Náhled backend orchestrace',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                InfoLabel(
                  label: plan.isReady ? 'Sekvence připravena' : 'Ještě ne',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(plan.summary),
            const SizedBox(height: 14),
            ...plan.operations.map(
              (operation) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: colorScheme.surface,
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              operation.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(operation.description),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      InfoLabel(
                        label: operation.isReady ? 'Připraveno' : 'Blokováno',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestSyncCard extends StatelessWidget {
  const _TestSyncCard({
    required this.report,
    required this.isRunning,
    required this.onRun,
    required this.backendReport,
    required this.isRunningBackend,
    required this.onRunBackend,
  });

  final FamilyTestSyncReport? report;
  final bool isRunning;
  final Future<void> Function() onRun;
  final FamilyRemoteSyncExecutionReport? backendReport;
  final bool isRunningBackend;
  final Future<void> Function() onRunBackend;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Test syncu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (report != null)
                  InfoLabel(
                    label: report!.isReady ? 'Prošlo' : 'Našlo blokery',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Spustí sjednocený kontrolní průchod přes rodinu, timeline i backend připravenost. Neodešle žádná data do cloudu.',
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: isRunning
                      ? null
                      : () {
                          onRun();
                        },
                  icon: isRunning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_circle_outline_rounded),
                  label: Text(
                    isRunning ? 'Spouštím test syncu...' : 'Spustit test syncu',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: isRunningBackend
                      ? null
                      : () {
                          onRunBackend();
                        },
                  icon: isRunningBackend
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    isRunningBackend
                        ? 'Spouštím backend test...'
                        : 'Spustit backend test',
                  ),
                ),
              ],
            ),
            if (report != null) ...[
              const SizedBox(height: 16),
              _ReportBlock(
                title: 'Kontrolní validace',
                summary: report!.summary,
                steps: report!.steps,
              ),
            ],
            if (backendReport != null) ...[
              const SizedBox(height: 16),
              _ReportBlock(
                title: backendReport!.wasExecuted
                    ? 'Výsledek backend testu'
                    : 'Backend test zůstal v kontrolním režimu',
                summary: backendReport!.summary,
                steps: backendReport!.steps,
                statusLabel: backendReport!.isSuccessful
                    ? 'Úspěch'
                    : backendReport!.wasExecuted
                    ? 'Chyba'
                    : 'Kontrola',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReportBlock extends StatelessWidget {
  const _ReportBlock({
    required this.title,
    required this.summary,
    required this.steps,
    this.statusLabel,
  });

  final String title;
  final String summary;
  final List<TestSyncStepResult> steps;
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            if (statusLabel != null) InfoLabel(label: statusLabel!),
          ],
        ),
        const SizedBox(height: 8),
        Text(summary),
        const SizedBox(height: 12),
        ...steps.map(
          (step) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(step.detail),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                InfoLabel(label: _statusLabel(step.status)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _statusLabel(TestSyncStepStatus status) {
    switch (status) {
      case TestSyncStepStatus.ready:
        return 'Připraveno';
      case TestSyncStepStatus.blocked:
        return 'Blokováno';
      case TestSyncStepStatus.info:
        return 'Info';
    }
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({required this.label, required this.value});

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

class _AccountReadinessCard extends StatelessWidget {
  const _AccountReadinessCard({
    required this.session,
    required this.onOpenSetup,
  });

  final AppAccountSession session;
  final Future<void> Function() onOpenSetup;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = AppServices.appAccountController;

    return ValueListenableBuilder<String?>(
      valueListenable: controller.error,
      builder: (context, error, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Účet a cloudová připravenost',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    InfoLabel(
                      label: session.isConfigured
                          ? 'Firebase připraven'
                          : session.isPreviewMode
                          ? 'Lokální preview'
                          : 'Čeká na Firebase',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  session.isConfigured
                      ? 'Projekt už má připravený základ pro cloudové přihlášení. Další krok je dopojit skutečné Firebase options a ostrý login flow.'
                      : session.isSignedIn
                      ? 'Účet je zatím přihlášený jen lokálně pro preview. UX už ale může kopírovat finální chování aplikace.'
                      : 'Aplikace už má připravenou architekturu pro účty rodičů, ale zatím chybí napojení na skutečný Firebase projekt.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () {
                        onOpenSetup();
                      },
                      icon: const Icon(Icons.manage_accounts_outlined),
                      label: const Text('Otevřít účet a synchronizaci'),
                    ),
                    ...session.supportedProviders.map(
                      (provider) => OutlinedButton(
                        onPressed: () {
                          controller.signInPreview(provider);
                        },
                        child: Text(provider.label),
                      ),
                    ),
                    if (session.isSignedIn)
                      OutlinedButton.icon(
                        onPressed: controller.signOutPreview,
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Odhlásit preview účet'),
                      ),
                  ],
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(error, style: TextStyle(color: colorScheme.error)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SyncRoadmapCard extends StatelessWidget {
  const _SyncRoadmapCard();

  @override
  Widget build(BuildContext context) {
    final items = AppServices.familySyncStrategy.getCapabilities();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kam rodinné sdílení míří',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bebia nebude stát na sdíleném jednom účtu. Cíl je vlastní účet každého rodiče a skutečný sdílený rodinný prostor.',
            ),
            const SizedBox(height: 14),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SyncCapabilityTile(item: item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncCapabilityTile extends StatelessWidget {
  const _SyncCapabilityTile({required this.item});

  final FamilySyncCapability item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stageLabel = switch (item.stage) {
      FamilySyncStage.localOnly => 'Dnes',
      FamilySyncStage.accountReady => 'Další krok',
      FamilySyncStage.cloudSync => 'Po backendu',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              InfoLabel(label: stageLabel),
            ],
          ),
          const SizedBox(height: 6),
          Text(item.description),
        ],
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({
    required this.session,
    required this.state,
    required this.isLoading,
    required this.onCreateInvite,
    required this.onMarkInviteShared,
    required this.onMarkInviteAccepted,
    required this.onCopyInviteCode,
    required this.onCancelInvite,
    required this.onMarkConnected,
    required this.formatDateTime,
  });

  final AppAccountSession session;
  final FamilyConnectionState state;
  final bool isLoading;
  final Future<void> Function() onCreateInvite;
  final Future<void> Function() onMarkInviteShared;
  final Future<void> Function() onMarkInviteAccepted;
  final Future<void> Function(String) onCopyInviteCode;
  final Future<void> Function() onCancelInvite;
  final Future<void> Function() onMarkConnected;
  final String Function(DateTime value) formatDateTime;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canCreateInvite = session.isSignedIn;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pozvánka',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(_inviteDescription(state, session)),
            const SizedBox(height: 14),
            if (state.hasInvite) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: colorScheme.primaryContainer.withValues(alpha: 0.46),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Kód pozvánky',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        InfoLabel(label: _statusLabel(state.inviteStatus)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.inviteCode!,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.6,
                          ),
                    ),
                    if (state.inviteCreatedAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Vytvořeno ${formatDateTime(state.inviteCreatedAt!)}',
                      ),
                    ],
                    if (state.inviteSharedAt != null) ...[
                      const SizedBox(height: 4),
                      Text('Odesláno ${formatDateTime(state.inviteSharedAt!)}'),
                    ],
                    if (state.inviteAcceptedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Přijato ${formatDateTime(state.inviteAcceptedAt!)}',
                      ),
                    ],
                    if (state.connectedAt != null) ...[
                      const SizedBox(height: 4),
                      Text('Aktivováno ${formatDateTime(state.connectedAt!)}'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            onCopyInviteCode(state.inviteCode!);
                          },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Kopírovat kód'),
                  ),
                  if (state.inviteStatus == FamilyInviteStatus.draft)
                    OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              onMarkInviteShared();
                            },
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('Označit jako odeslanou'),
                    ),
                  if (state.inviteStatus ==
                      FamilyInviteStatus.waitingForAcceptance)
                    OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              onMarkInviteAccepted();
                            },
                      icon: const Icon(Icons.mark_email_read_outlined),
                      label: const Text('Potvrdit přijetí'),
                    ),
                  if (state.inviteStatus == FamilyInviteStatus.accepted)
                    OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              onMarkConnected();
                            },
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Aktivovat rodinu'),
                    ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            onCancelInvite();
                          },
                    child: const Text('Zrušit pozvánku'),
                  ),
                ],
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading || !canCreateInvite
                      ? null
                      : () {
                          onCreateInvite();
                        },
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('Vytvořit návrh pozvánky'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _inviteDescription(
    FamilyConnectionState state,
    AppAccountSession session,
  ) {
    if (!session.isSignedIn) {
      return 'Nejdřív přihlas rodiče. Teprve potom má smysl založit rodinu a připravit pozvánku pro druhého rodiče.';
    }

    switch (state.inviteStatus) {
      case FamilyInviteStatus.none:
        return 'Vytvoř lokální návrh pozvánky pro druhého rodiče.';
      case FamilyInviteStatus.draft:
        return 'Pozvánka existuje, ale ještě nebyla označená jako odeslaná.';
      case FamilyInviteStatus.waitingForAcceptance:
        return 'Pozvánka už byla odeslaná a čeká na potvrzení druhého rodiče.';
      case FamilyInviteStatus.accepted:
        return 'Pozvánka byla přijatá. Zbývá aktivovat společnou rodinu.';
      case FamilyInviteStatus.connected:
        return 'Rodina je aktivní a pozvánkový tok je lokálně dokončený.';
    }
  }

  String _statusLabel(FamilyInviteStatus status) {
    switch (status) {
      case FamilyInviteStatus.none:
        return 'Bez pozvánky';
      case FamilyInviteStatus.draft:
        return 'Návrh';
      case FamilyInviteStatus.waitingForAcceptance:
        return 'Čeká na přijetí';
      case FamilyInviteStatus.accepted:
        return 'Přijatá';
      case FamilyInviteStatus.connected:
        return 'Aktivní';
    }
  }
}

class _JoinByInviteCard extends StatelessWidget {
  const _JoinByInviteCard({
    required this.state,
    required this.isLoading,
    required this.codeController,
    required this.nameController,
    required this.roleController,
    required this.onAccept,
  });

  final FamilyConnectionState state;
  final bool isLoading;
  final TextEditingController codeController;
  final TextEditingController nameController;
  final TextEditingController roleController;
  final Future<void> Function() onAccept;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Připojení druhého rodiče',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                InfoLabel(
                  label: state.inviteStatus == FamilyInviteStatus.accepted
                      ? 'Pozvánka přijatá'
                      : 'Čeká na přijetí',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              state.inviteStatus == FamilyInviteStatus.accepted
                  ? 'Druhý rodič už kód potvrdil. Pokud je potřeba, můžeš upravit jméno nebo rovnou dokončit aktivaci rodiny.'
                  : 'Tady nasimuluješ krok na druhém zařízení: vlož pozvánkový kód, zadej jméno rodiče a potvrď přijetí.',
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.32,
                ),
              ),
              child: Text(
                'Aktivní kód rodiny: ${state.inviteCode ?? 'bez kódu'}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Pozvánkový kód',
                hintText: 'Např. ABCD-1234',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Jméno druhého rodiče',
                hintText: 'Např. Tomáš',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(
                labelText: 'Role',
                hintText: 'Rodič',
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                        onAccept();
                      },
                icon: const Icon(Icons.how_to_reg_rounded),
                label: Text(
                  state.inviteStatus == FamilyInviteStatus.accepted
                      ? 'Potvrdit údaje druhého rodiče'
                      : 'Přijmout pozvánku k rodině',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaregiverForm extends StatelessWidget {
  const _CaregiverForm({
    required this.nameController,
    required this.roleController,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController roleController;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pečující osoba',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Jméno',
                hintText: 'Např. táta',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(
                labelText: 'Role',
                hintText: 'Rodič',
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  onSubmit();
                },
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Přidat osobu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaregiverList extends StatelessWidget {
  const _CaregiverList({required this.caregivers, required this.onRemove});

  final List<CaregiverProfile> caregivers;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    if (caregivers.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text('Zatím není přidaná žádná pečující osoba.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pečující osoby',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        ...caregivers.map(
          (caregiver) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(caregiver.name),
                subtitle: Text(caregiver.role),
                trailing: caregiver.isOwner
                    ? const InfoLabel(label: 'Vlastník')
                    : IconButton(
                        onPressed: () => onRemove(caregiver.id),
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
