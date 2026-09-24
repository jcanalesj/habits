import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habits/components/cat_mascot.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_dimensions.dart';
import 'package:habits/theme/app_theme.dart';

/// Cabecera de la Home: saludo, lema y avatar.
class HomeHeader extends StatefulWidget {
  const HomeHeader({
    super.key,
    required this.greeting,
    required this.onAvatarTap,
    this.messages = const [],
  });

  final String greeting;
  final VoidCallback onAvatarTap;
  final List<String> messages;

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  static const _rotationInterval = Duration(seconds: 12);
  Timer? _rotationTimer;
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _restartRotation();
  }

  @override
  void didUpdateWidget(covariant HomeHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages != widget.messages) {
      _messageIndex = 0;
      _restartRotation();
    }
  }

  void _restartRotation() {
    _rotationTimer?.cancel();
    if (widget.messages.length < 2) return;
    _rotationTimer = Timer.periodic(_rotationInterval, (_) {
      if (!mounted) return;
      setState(() {
        _messageIndex = (_messageIndex + 1) % widget.messages.length;
      });
    });
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final message = widget.messages.isEmpty
        ? context.l10n.tagline
        : widget.messages[_messageIndex % widget.messages.length];

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: AppDimensions.screenTitleFontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                layoutBuilder: (currentChild, previousChildren) =>
                    currentChild ?? const SizedBox.shrink(),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, .22),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  ),
                ),
                child: Text(
                  message,
                  key: ValueKey(message),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: context.l10n.navProfile,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onAvatarTap,
              customBorder: const CircleBorder(),
              child: const UserAvatar(size: 52),
            ),
          ),
        ),
      ],
    );
  }
}
