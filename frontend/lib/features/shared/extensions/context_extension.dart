import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

extension ContextExt on BuildContext {
  /// Returns the theme of the current context.
  ThemeData get theme => Theme.of(this);

  /// Returns true if the current theme is dark mode.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Returns the screen size of the current context.
  Size get screenSize => MediaQuery.of(this).size;

  /// Get the platform of the current context.
  ///
  /// Eg. Android, iOS, macOS, etc.
  TargetPlatform get platform => theme.platform;

  /// Removes the focus from any currently focused input widgets.
  void unfocusInputs() {
    FocusScope.of(this).requestFocus(FocusNode());
  }

  /// Requests focus for the given [FocusNode] or the current focus scope if no [FocusNode] is given.
  void requestFocusOnInputs({
    final FocusNode? focusNode,
  }) {
    if (mounted) FocusScope.of(this).requestFocus(focusNode);
  }

  /// Displays a error toast message.
  ///
  /// The [message] parameter is required and should be a string.
  void showErrorToast({
    required final String message,
    final Duration autoCloseDuration = const Duration(seconds: 4),
  }) {
    Toastification().show(
      context: this,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text(message),
      autoCloseDuration: autoCloseDuration,
    );
  }

  /// Displays a success toast message.
  ///
  /// The [message] parameter is required and should be a string.
  void showSuccessToast({
    required final String message,
    final Duration autoCloseDuration = const Duration(seconds: 3),
  }) {
    Toastification().show(
      context: this,
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: Text(message),
      autoCloseDuration: autoCloseDuration,
    );
  }

  /// Displays a warning toast message.
  ///
  /// The [message] parameter is required and should be a string.
  void showWarningToast({
    required final String message,
    final Duration autoCloseDuration = const Duration(seconds: 2),
  }) {
    Toastification().show(
      context: this,
      type: ToastificationType.warning,
      style: ToastificationStyle.fillColored,
      title: Text(message),
      autoCloseDuration: autoCloseDuration,
    );
  }
}
