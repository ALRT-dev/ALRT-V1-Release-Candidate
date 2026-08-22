import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The big in-app banner for an SOS or a check-in request arriving while the
/// phone is already unlocked and in the app.
///
/// A push notification does the work when the screen is off. When it is on,
/// the person is looking at something else in ALRT, and a small toast in the
/// corner is the wrong size for "your daughter has triggered an SOS". This
/// takes the top of the screen, holds a bright pulsing outline so it is
/// impossible to scroll past, and opens the SOS when tapped.
///
/// It never blocks the screen: there is a dismiss, and it times out on its
/// own, because an alert you cannot get rid of is an alert people learn to
/// resent.
class IncomingFamilyAlert {
  const IncomingFamilyAlert._();

  static OverlayEntry? _current;

  /// Shows the banner. A second alert replaces the first rather than
  /// stacking, so the newest emergency is the one on screen.
  static void show({
    required final BuildContext context,
    required final String title,
    required final String body,
    required final bool isSos,
    final VoidCallback? onTap,
    final Duration timeout = const Duration(seconds: 12),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    dismiss();
    _buzz(isSos: isSos);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _Banner(
        title: title,
        body: body,
        isSos: isSos,
        onTap: () {
          dismiss();
          onTap?.call();
        },
        onDismiss: dismiss,
      ),
    );
    _current = entry;
    overlay.insert(entry);

    Future<void>.delayed(timeout, () {
      if (_current == entry) dismiss();
    });
  }

  /// The banner must be felt, not just seen: three pulses for an SOS, one
  /// for a check-in request. HapticFeedback needs no vibrate permission
  /// and quietly does nothing on devices without a motor.
  static Future<void> _buzz({required final bool isSos}) async {
    for (var i = 0; i < (isSos ? 3 : 1); i++) {
      if (i > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
      }
      await HapticFeedback.vibrate();
    }
  }

  static void dismiss() {
    final entry = _current;
    _current = null;
    if (entry == null) return;
    try {
      entry.remove();
    } catch (_) {
      // The overlay can be torn down under us by a navigation, and
      // removing an already-removed entry throws. An SOS banner must
      // never be the thing that crashes the app on its way out.
    }
  }
}

class _Banner extends StatefulWidget {
  const _Banner({
    required this.title,
    required this.body,
    required this.isSos,
    required this.onTap,
    required this.onDismiss,
  });

  final String title;
  final String body;
  final bool isSos;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  State<_Banner> createState() => _BannerState();
}

class _BannerState extends State<_Banner> with TickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();

  @override
  void dispose() {
    _glow.dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // SOS is red; a check-in request is the family indigo. Both bright.
    final accent =
        widget.isSos ? const Color(0xFFE4002B) : const Color(0xFF3D3DDF);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8.spMin,
      left: 12.spMin,
      right: 12.spMin,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic),
        ),
        child: Material(
          color: Colors.transparent,
          child: AnimatedBuilder(
            animation: _glow,
            builder: (context, child) {
              final t = _glow.value;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.spMin),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.65 + 0.35 * t),
                    width: (2.0 + 1.2 * t).spMin,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35 + 0.35 * t),
                      blurRadius: 22.0 + 18.0 * t,
                      spreadRadius: 1.0 + 3.0 * t,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF15161A),
                borderRadius: BorderRadius.circular(20.spMin),
              ),
              padding: EdgeInsets.fromLTRB(
                14.spMin,
                13.spMin,
                12.spMin,
                14.spMin,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42.spMin,
                    height: 42.spMin,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(13.spMin),
                    ),
                    child: Icon(
                      widget.isSos
                          ? LucideIcons.triangleAlert
                          : LucideIcons.handHeart,
                      color: Colors.white,
                      size: 22.spMin,
                    ),
                  ),
                  SizedBox(width: 12.spMin),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 17.spMin,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 3.spMin),
                        Text(
                          widget.body,
                          style: TextStyle(
                            fontSize: 13.spMin,
                            height: 1.35,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        SizedBox(height: 10.spMin),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.spMin,
                                vertical: 8.spMin,
                              ),
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(11.spMin),
                              ),
                              child: Text(
                                widget.isSos ? 'Open SOS' : 'Respond',
                                style: TextStyle(
                                  fontSize: 13.spMin,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ).onTapped(widget.onTap),
                            SizedBox(width: 8.spMin),
                            GestureDetector(
                              onTap: widget.onDismiss,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.spMin,
                                  vertical: 8.spMin,
                                ),
                                child: Text(
                                  'Later',
                                  style: TextStyle(
                                    fontSize: 13.spMin,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension _TapExtension on Widget {
  Widget onTapped(final VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: this,
      );
}
