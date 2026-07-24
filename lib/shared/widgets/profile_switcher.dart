import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/design/bebia_theme.dart';
import '../../features/profile/child_profile.dart';

class ProfileSwitcher extends StatelessWidget {
  const ProfileSwitcher({
    super.key,
    this.title,
    this.subtitle,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.embedded = false,
  });

  final String? title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final controller = AppServices.childProfileController;

    return ValueListenableBuilder<List<ChildProfile>>(
      valueListenable: controller.profiles,
      builder: (context, profiles, child) {
        if (profiles.isEmpty) {
          return const SizedBox.shrink();
        }

        return ValueListenableBuilder<String?>(
          valueListenable: controller.activeProfileId,
          builder: (context, activeProfileId, child) {
            final colorScheme = Theme.of(context).colorScheme;
            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!),
                  ],
                  const SizedBox(height: 12),
                ],
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var index = 0; index < profiles.length; index++) ...[
                        _ProfileChipButton(
                          profile: profiles[index],
                          isActive: profiles[index].id == activeProfileId,
                          onPressed: () async {
                            try {
                              await controller.setActiveProfile(
                                profiles[index].id,
                              );
                            } catch (_) {
                              if (!context.mounted) return;
                              final message =
                                  controller.error.value ??
                                  'Profil se nepodařilo přepnout.';
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(message)));
                            }
                          },
                        ),
                        if (index < profiles.length - 1)
                          const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ],
            );

            if (embedded) {
              return Padding(padding: padding, child: content);
            }

            return Container(
              margin: margin,
              padding: padding,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: content,
            );
          },
        );
      },
    );
  }
}

class _ProfileChipButton extends StatelessWidget {
  const _ProfileChipButton({
    required this.profile,
    required this.isActive,
    required this.onPressed,
  });

  final ChildProfile profile;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = _profilePalette(context, profile.sex);

    return AnimatedContainer(
      duration: BebiaMotion.resolve(
        const Duration(milliseconds: 180),
        reduceMotion: context.bebia.reduceMotion,
      ),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: isActive
            ? palette.background
            : palette.background.withValues(alpha: 0.36),
        border: Border.all(
          color: isActive
              ? palette.border
              : palette.border.withValues(alpha: 0.45),
          width: isActive ? 1.6 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: palette.border.withValues(alpha: 0.16),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              profile.name,
              style: TextStyle(
                color: palette.foreground,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

_ProfilePalette _profilePalette(BuildContext context, String? sex) {
  final seed = switch (sex) {
    'boy' => BebiaColors.sky,
    'girl' => BebiaColors.rose,
    _ => BebiaColors.sage,
  };
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Theme.of(context).brightness,
  );
  return _ProfilePalette(
    background: scheme.secondaryContainer,
    border: scheme.secondary,
    foreground: scheme.onSecondaryContainer,
  );
}

class _ProfilePalette {
  const _ProfilePalette({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;
}
