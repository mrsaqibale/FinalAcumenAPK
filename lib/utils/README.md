# AppSnackbar Utility

The `AppSnackbar` utility provides a consistent way to display iOS-style popup notifications throughout the app.

## Features

- iOS-style popup notifications using `CupertinoActionSheet`
- Different message types (info, success, error, warning)
- Customizable icons, colors, and duration
- Support for action buttons

## Usage

### Basic Usage

```dart
// Show an information message
AppSnackbar.showInfo(
  context: context,
  message: 'This is an information message',
);

// Show a success message
AppSnackbar.showSuccess(
  context: context,
  message: 'Operation completed successfully',
);

// Show an error message
AppSnackbar.showError(
  context: context,
  message: 'An error occurred',
);

// Show a warning message
AppSnackbar.showWarning(
  context: context,
  message: 'This action cannot be undone',
);
```

### With Action Button

```dart
AppSnackbar.showInfo(
  context: context,
  message: 'Do you want to proceed?',
  actionText: 'Yes',
  onPressed: () {
    // Action code here
    print('User pressed Yes');
  },
);
```

### Custom Duration

```dart
AppSnackbar.showInfo(
  context: context,
  message: 'This message will stay longer',
  duration: const Duration(seconds: 5),
);
```

### Custom Appearance

```dart
AppSnackbar.show(
  context: context,
  message: 'Custom message',
  icon: Icons.star,
  iconColor: Colors.purple,
);
```

## Implementation Details

The `AppSnackbar` utility uses `CupertinoActionSheet` to provide an iOS-style popup experience, replacing the standard Material Design `SnackBar`. This creates a more consistent look and feel across the app.

Each method (`showInfo`, `showSuccess`, `showError`, `showWarning`) uses appropriate icons and colors to visually indicate the type of message being displayed. 