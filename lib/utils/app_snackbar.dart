import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppSnackbar {
  /// Shows an iOS-style popup snackbar
  static void show({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color? iconColor,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onPressed,
    String? actionText,
  }) {
    // Dismiss any existing snackbar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Show iOS-style popup using CupertinoModalPopup
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor ?? AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        actions: onPressed != null && actionText != null
            ? <CupertinoActionSheetAction>[
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    onPressed();
                  },
                  child: Text(actionText),
                ),
              ]
            : null,
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Dismiss'),
        ),
      ),
    );
  }

  /// Shows a success message with a checkmark icon
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onPressed,
    String? actionText,
  }) {
    show(
      context: context,
      message: message,
      icon: FontAwesomeIcons.circleCheck,
      iconColor: Colors.green,
      onPressed: onPressed,
      actionText: actionText,
      duration: duration,
    );
  }

  /// Shows an error message with an error icon
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onPressed,
    String? actionText,
  }) {
    show(
      context: context,
      message: message,
      icon: FontAwesomeIcons.circleExclamation,
      iconColor: Colors.red,
      onPressed: onPressed,
      actionText: actionText,
      duration: duration,
    );
  }

  /// Shows an info message with an info icon
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onPressed,
    String? actionText,
  }) {
    show(
      context: context,
      message: message,
      icon: FontAwesomeIcons.circleInfo,
      iconColor: AppTheme.primaryColor,
      onPressed: onPressed,
      actionText: actionText,
      duration: duration,
    );
  }

  /// Shows a warning message with a warning icon
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onPressed,
    String? actionText,
  }) {
    show(
      context: context,
      message: message,
      icon: FontAwesomeIcons.triangleExclamation,
      iconColor: Colors.orange,
      onPressed: onPressed,
      actionText: actionText,
      duration: duration,
    );
  }
} 