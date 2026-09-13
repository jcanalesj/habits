import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habits/theme/app_theme.dart';

enum AppNoticeType { success, error, info }

/// Aviso flotante de Constanza. Vive en el overlay raíz, por lo que no mueve
/// el contenido ni se solapa con el bottom bar.
abstract final class AppNotice {
  static OverlayEntry? _visibleEntry;

  static void show(
    BuildContext context, {
    required String message,
    AppNoticeType type = AppNoticeType.info,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    final previous = _visibleEntry;
    if (previous?.mounted ?? false) previous!.remove();
    _visibleEntry = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AppNoticeOverlay(
        message: message,
        type: type,
        onDismissed: () {
          if (entry.mounted) entry.remove();
          if (identical(_visibleEntry, entry)) _visibleEntry = null;
        },
      ),
    );
    _visibleEntry = entry;
    overlay.insert(entry);
  }
}

class _AppNoticeOverlay extends StatefulWidget {
  const _AppNoticeOverlay({
    required this.message,
    required this.type,
    required this.onDismissed,
  });

  final String message;
  final AppNoticeType type;
  final VoidCallback onDismissed;

  @override
  State<_AppNoticeOverlay> createState() => _AppNoticeOverlayState();
}

class _AppNoticeOverlayState extends State<_AppNoticeOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _controller.forward();
    _timer = Timer(const Duration(milliseconds: 2800), _dismiss);
  }

  Future<void> _dismiss() async {
    if (_closing || !mounted) return;
    _closing = true;
    _timer?.cancel();
    if (MediaQuery.disableAnimationsOf(context)) {
      widget.onDismissed();
      return;
    }
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = switch (widget.type) {
      AppNoticeType.success => const _NoticeScheme(
        icon: Icons.check_rounded,
        accent: Color(0xFF24B985),
        surface: Color(0xFFF1FCF7),
      ),
      AppNoticeType.error => const _NoticeScheme(
        icon: Icons.error_outline_rounded,
        accent: Color(0xFFE95E70),
        surface: Color(0xFFFFF3F5),
      ),
      AppNoticeType.info => const _NoticeScheme(
        icon: Icons.auto_awesome_rounded,
        accent: AppColors.primary,
        surface: Color(0xFFF7F3FF),
      ),
    };
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return Positioned(
      top: MediaQuery.paddingOf(context).top + 12,
      left: 16,
      right: 16,
      child: SafeArea(
        top: false,
        bottom: false,
        child: FadeTransition(
          opacity: reduceMotion ? const AlwaysStoppedAnimation(1) : animation,
          child: SlideTransition(
            position: reduceMotion
                ? const AlwaysStoppedAnimation(Offset.zero)
                : Tween<Offset>(
                    begin: const Offset(0, -.22),
                    end: Offset.zero,
                  ).animate(animation),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Material(
                  color: Colors.transparent,
                  child: Semantics(
                    liveRegion: true,
                    label: widget.message,
                    child: InkWell(
                      onTap: _dismiss,
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: scheme.accent.withValues(alpha: .16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textPrimary.withValues(
                                alpha: .12,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: scheme.accent.withValues(alpha: .13),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                scheme.icon,
                                color: scheme.accent,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.message,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      height: 1.25,
                                    ),
                              ),
                            ),
                            IconButton(
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).closeButtonTooltip,
                              onPressed: _dismiss,
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textSecondary,
                                size: 19,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoticeScheme {
  const _NoticeScheme({
    required this.icon,
    required this.accent,
    required this.surface,
  });

  final IconData icon;
  final Color accent;
  final Color surface;
}
