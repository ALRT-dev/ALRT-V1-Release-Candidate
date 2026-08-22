import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Controller for managing the state of an AlrtDropdown widget.
class AlrtDropdownController {
  _AlrtDropdownState? _state;

  /// Whether the dropdown is currently open.
  bool get isOpen => _state?._entry != null;

  /// Opens the dropdown.
  void open() {
    _state?._showDropdown();
  }

  /// Closes the dropdown.
  void close() {
    _state?._closeDropdown();
  }

  /// Toggles the dropdown state.
  void toggle() {
    if (isOpen) {
      close();
    } else {
      open();
    }
  }

  /// Internal method to attach the state - not for external use.
  void _attach(_AlrtDropdownState state) {
    _state = state;
  }

  /// Internal method to detach the state - not for external use.
  void _detach() {
    _state = null;
  }
}

class AlrtDropdown extends ConsumerStatefulWidget {
  const AlrtDropdown({
    super.key,
    required this.button,
    required this.menuContent,
    this.controller,
    this.dropdownHeight = 300,
    this.dropdownWidth,
    this.buttonAlignment = Alignment.topLeft,
    this.dropdownAlignment = Alignment.topLeft,
  });

  /// The button widget that triggers the dropdown.
  final Widget Function(BuildContext, bool) button;

  /// The content of the dropdown menu.
  final Widget Function(BuildContext, Function()) menuContent;

  /// The controller to manage the dropdown state.
  final AlrtDropdownController? controller;

  /// The height of the dropdown menu.
  final double dropdownHeight;

  /// The width of the dropdown menu. If not provided, it defaults to the button's width.
  final double? dropdownWidth;

  /// The alignment of the button relative to the dropdown menu.
  final Alignment buttonAlignment;

  /// The alignment of the dropdown menu relative to the button.
  final Alignment dropdownAlignment;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AlrtDropdownState();
}

class _AlrtDropdownState extends ConsumerState<AlrtDropdown> {
  OverlayEntry? _entry;
  final _layerLink = LayerLink();

  final _buttonKey = GlobalKey();
  var _isOpen = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(covariant AlrtDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle controller changes
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null) {
      return GestureDetector(
        onTap: _toggleDropdown,
        child: CompositedTransformTarget(
          link: _layerLink,
          key: _buttonKey,
          child: widget.button.call(context, _isOpen),
        ),
      );
    }
    return CompositedTransformTarget(
      link: _layerLink,
      key: _buttonKey,
      child: widget.button.call(context, _isOpen),
    );
  }

  void _toggleDropdown() {
    if (_entry == null) {
      _showDropdown();
    } else {
      _closeDropdown();
    }
  }

  void _showDropdown() {
    if (_entry != null) return;

    final renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    final buttonSize = renderBox?.size ?? Size.zero;

    _entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            IgnorePointer(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),
            Positioned(
              child: CompositedTransformFollower(
                link: _layerLink,
                offset: Offset(0, 57.spMin),
                targetAnchor: widget.buttonAlignment,
                followerAnchor: widget.dropdownAlignment,
                child: TapRegion(
                  onTapOutside: (event) {
                    // check if the tap made on the button itself
                    final renderBox =
                        _buttonKey.currentContext?.findRenderObject()
                            as RenderBox?;
                    final buttonPosition =
                        renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
                    final buttonSize = renderBox?.size ?? Size.zero;
                    final tapPosition = event.position;
                    final isOnButton =
                        (tapPosition.dx >= buttonPosition.dx &&
                        tapPosition.dx <=
                            buttonPosition.dx + buttonSize.width &&
                        tapPosition.dy >= buttonPosition.dy &&
                        tapPosition.dy <=
                            buttonPosition.dy + buttonSize.height);
                    if (isOnButton) {
                      return; // do nothing if tapped on button
                    }

                    // if no controller is provided, close the dropdown on outside tap
                    // otherwise, let the controller manage it
                    if (widget.controller == null) _closeDropdown();
                  },
                  child: Material(
                    color: AppColors.transparent,
                    child: Container(
                      width: widget.dropdownWidth ?? buttonSize.width,
                      height: widget.dropdownHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.spMin),
                        border: Border.all(
                          color: AppColors.lightGrey,
                        ),
                      ),
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        removeBottom: true,
                        child: widget.menuContent(context, _closeDropdown),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_entry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _entry?.remove();
    _entry = null;
    setState(() {
      _isOpen = false;
    });
  }
}
