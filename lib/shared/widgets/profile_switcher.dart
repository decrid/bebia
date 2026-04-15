import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../features/profile/child_profile.dart';

class ProfileSwitcher extends StatelessWidget {
  const ProfileSwitcher({
    super.key,
    this.title,
    this.subtitle,
    this.padding = const EdgeInsets.all(14),
    this.margin,
  });

  final String? title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

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
              child: Column(
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
                        for (
                          var index = 0;
                          index < profiles.length;
                          index++
                        ) ...[
                          _ProfileChipButton(
                            profile: profiles[index],
                            isActive: profiles[index].id == activeProfileId,
                            onPressed: () {
                              controller.setActiveProfile(profiles[index].id);
                            },
                          ),
                          if (index < profiles.length - 1)
                            const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
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
    final palette = _profilePalette(profile.sex);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: palette.border.withValues(alpha: 0.12),
                  foregroundColor: palette.foreground,
                  child: Icon(
                    profile.sex == 'boy'
                        ? Icons.male_rounded
                        : profile.sex == 'girl'
                        ? Icons.female_rounded
                        : Icons.child_care_outlined,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  profile.name,
                  style: TextStyle(
                    color: palette.foreground,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

_ProfilePalette _profilePalette(String? sex) {
  switch (sex) {
    case 'boy':
      return const _ProfilePalette(
        background: Color(0xFFDDEEFF),
        border: Color(0xFF4B8DDB),
        foreground: Color(0xFF1B4F8A),
      );
    case 'girl':
      return const _ProfilePalette(
        background: Color(0xFFFFE0EA),
        border: Color(0xFFD36A94),
        foreground: Color(0xFF91355A),
      );
    default:
      return const _ProfilePalette(
        background: Color(0xFFE8F6ED),
        border: Color(0xFF58A176),
        foreground: Color(0xFF29613F),
      );
  }
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
