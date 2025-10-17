
import 'package:pizza_boys/core/helpers/internet_helper/error_notifier.dart';

class GlobalErrorHandler {
  /// Centralized error logging + UI notification
  static void handleError(Object error, {StackTrace? stackTrace}) {
    // Log to console (can also integrate with Sentry, Firebase Crashlytics, etc.)
    print("⚠️ [GlobalError] $error");
    if (stackTrace != null) {
      print(stackTrace);
    }

    // Show user-friendly server error UI
    ErrorNotifier.showServerError(error.toString());
  }
}
