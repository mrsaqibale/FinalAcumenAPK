// This script provides instructions on how to convert all SnackBar instances to AppSnackbar

/*
MANUAL CONVERSION GUIDE:

1. Find all files with SnackBar usage:
   - Search for "ScaffoldMessenger.of(context).showSnackBar" in the codebase

2. For each file:
   - Add the import: import 'package:acumen/utils/app_snackbar.dart';
   
3. Replace SnackBar instances with appropriate AppSnackbar methods:
   
   BEFORE:
   ```
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text('Your message here')),
   );
   ```
   
   AFTER:
   ```
   AppSnackbar.showInfo(
     context: context,
     message: 'Your message here',
   );
   ```
   
   For error messages:
   ```
   AppSnackbar.showError(
     context: context,
     message: 'Your error message here',
   );
   ```
   
   For success messages:
   ```
   AppSnackbar.showSuccess(
     context: context,
     message: 'Your success message here',
   );
   ```
   
   For warning messages:
   ```
   AppSnackbar.showWarning(
     context: context,
     message: 'Your warning message here',
   );
   ```

4. If the SnackBar has custom duration:
   
   BEFORE:
   ```
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
       content: Text('Your message here'),
       duration: Duration(seconds: 5),
     ),
   );
   ```
   
   AFTER:
   ```
   AppSnackbar.showInfo(
     context: context,
     message: 'Your message here',
     duration: Duration(seconds: 5),
   );
   ```

5. If the SnackBar has an action:
   
   BEFORE:
   ```
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
       content: Text('Your message here'),
       action: SnackBarAction(
         label: 'Action',
         onPressed: () {
           // Action code
         },
       ),
     ),
   );
   ```
   
   AFTER:
   ```
   AppSnackbar.showInfo(
     context: context,
     message: 'Your message here',
     actionText: 'Action',
     onPressed: () {
       // Action code
     },
   );
   ```
*/ 