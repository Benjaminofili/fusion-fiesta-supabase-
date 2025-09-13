class AppError {
  final String message;
  final String? code;
  final bool isNetworkError;

  AppError({
    required this.message,
    this.code,
    this.isNetworkError = false,
  });

  static AppError fromException(dynamic e) {
    if (e.toString().contains('network') || e.toString().contains('connection')) {
      return AppError(
        message: 'Network error. Data saved locally and will sync when online.',
        isNetworkError: true,
      );
    }

    return AppError(message: e.toString());
  }
}