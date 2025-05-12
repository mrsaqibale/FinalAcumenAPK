import 'package:flutter/material.dart';
import 'package:acumen/utils/app_snackbar.dart';

/// Utility class for showing loading dialogs
class LoadingDialog {
  /// Shows a loading dialog with a circular progress indicator
  /// 
  /// Example:
  /// ```dart
  /// LoadingDialog.show(context);
  /// // Do some async work
  /// LoadingDialog.hide(context);
  /// ```
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Please wait...',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Hides the currently shown loading dialog
  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Shows a loading dialog while performing an async operation
  /// 
  /// Example:
  /// ```dart
  /// await LoadingDialog.showWhile(
  ///   context,
  ///   () async {
  ///     // Do some async work
  ///     await someAsyncOperation();
  ///   },
  /// );
  /// ```
  static Future<T?> showWhile<T>(
    BuildContext context,
    Future<T> Function() operation,
  ) async {
    show(context);
    try {
      final result = await operation();
      if (context.mounted) {
        hide(context);
      }
      return result;
    } catch (e) {
      if (context.mounted) {
        hide(context);
        AppSnackbar.showError(
          context: context,
          message: 'Error: ${e.toString()}',
        );
      }
      return null;
    }
  }
} 