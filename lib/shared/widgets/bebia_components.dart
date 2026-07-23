import 'package:flutter/material.dart';

import '../../core/design/bebia_theme.dart';

class BebiaPage extends StatelessWidget {
  const BebiaPage({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.fromLTRB(
      BebiaSpace.md,
      BebiaSpace.sm,
      BebiaSpace.md,
      BebiaSpace.xxl,
    ),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: BebiaBreakpoints.contentMaxWidth,
              maxHeight: constraints.maxHeight,
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class BebiaScreenHeader extends StatelessWidget {
  const BebiaScreenHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: BebiaSpace.xs),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.bebia.mutedText,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: BebiaSpace.sm),
          trailing!,
        ],
      ],
    );
  }
}

class BebiaCard extends StatelessWidget {
  const BebiaCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(BebiaSpace.md),
    this.color,
    this.borderColor,
    this.semanticsLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(BebiaRadius.large);
    final content = Material(
      color: color ?? scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: borderColor ?? scheme.outlineVariant.withValues(alpha: .55),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(padding: padding, child: child),
      ),
    );
    return Semantics(
      button: onTap != null,
      label: semanticsLabel,
      child: content,
    );
  }
}

class BebiaSectionHeader extends StatelessWidget {
  const BebiaSectionHeader({required this.title, super.key, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BebiaSpace.xxs,
        BebiaSpace.xs,
        BebiaSpace.xxs,
        BebiaSpace.xs,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.bebia.mutedText,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class BebiaSettingsTile extends StatelessWidget {
  const BebiaSettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
    this.onTap,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = destructive ? context.bebia.danger : scheme.primary;
    return BebiaCard(
      onTap: onTap,
      semanticsLabel: '$title. $subtitle',
      child: Row(
        children: <Widget>[
          Container(
            width: BebiaMetrics.minimumTouchTarget,
            height: BebiaMetrics.minimumTouchTarget,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: foreground.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(BebiaRadius.medium),
            ),
            child: Icon(icon, color: foreground),
          ),
          const SizedBox(width: BebiaSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: destructive ? context.bebia.danger : null,
                  ),
                ),
                const SizedBox(height: BebiaSpace.xxs),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.bebia.mutedText,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: BebiaSpace.xs),
            trailing!,
          ] else if (onTap != null)
            Icon(Icons.chevron_right_rounded, color: context.bebia.mutedText),
        ],
      ),
    );
  }
}

class BebiaEventActionTile extends StatelessWidget {
  const BebiaEventActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BebiaCard(
      onTap: onTap,
      semanticsLabel: '$title. $subtitle',
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(BebiaRadius.medium),
            ),
            child: Icon(icon, color: color, size: BebiaIconSize.large),
          ),
          const SizedBox(width: BebiaSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: BebiaSpace.xxs),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.bebia.mutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: BebiaSpace.xs),
          Icon(Icons.arrow_forward_rounded, color: color),
        ],
      ),
    );
  }
}

class BebiaInfoBanner extends StatelessWidget {
  const BebiaInfoBanner({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BebiaCard(
      color: scheme.primaryContainer.withValues(alpha: .55),
      borderColor: scheme.primary.withValues(alpha: .2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: scheme.onPrimaryContainer),
          const SizedBox(width: BebiaSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: BebiaSpace.xxs),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BebiaStatePanel extends StatelessWidget {
  const BebiaStatePanel({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return BebiaCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: BebiaSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: BebiaIconSize.hero,
              color: context.bebia.mutedText,
            ),
            const SizedBox(height: BebiaSpace.sm),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: BebiaSpace.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: context.bebia.mutedText),
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: BebiaSpace.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

Future<bool> showBebiaConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(BebiaSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: BebiaSpace.sm),
              Text(message),
              const SizedBox(height: BebiaSpace.lg),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: BebiaSpace.xs,
                runSpacing: BebiaSpace.xs,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Zrušit'),
                  ),
                  FilledButton(
                    style: destructive
                        ? FilledButton.styleFrom(
                            backgroundColor: context.bebia.danger,
                            foregroundColor: Colors.white,
                          )
                        : null,
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Text(confirmLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}

class BebiaModalSurface extends StatelessWidget {
  const BebiaModalSurface({required this.child, super.key, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: BebiaMotion.resolve(
          BebiaMotion.standard,
          reduceMotion: context.bebia.reduceMotion,
        ),
        curve: BebiaMotion.enter,
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * .88),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(BebiaRadius.hero),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(top: BebiaSpace.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(BebiaRadius.pill),
                  ),
                ),
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      BebiaSpace.lg,
                      BebiaSpace.md,
                      BebiaSpace.lg,
                      BebiaSpace.xs,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title!,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                Flexible(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
