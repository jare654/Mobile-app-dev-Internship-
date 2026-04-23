// lib/services/api_exception.dart

/// Thrown by [NewsApiService._checkResponse] whenever the server returns
/// a non-200 HTTP status code.
///
/// Carrying [statusCode] lets the UI display context-aware messages
/// (e.g. "401 — Invalid API Key" vs "503 — Server unavailable").
class ApiException implements Exception {
  /// The HTTP status code returned by the server.
  final int statusCode;

  /// The human-readable message extracted from the API response body,
  /// or a sensible fallback if the body cannot be parsed.
  final String message;

  const ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'ApiException [$statusCode]: $message';

  // ── Convenience factory constructors for known status codes ───────────────

  factory ApiException.unauthorized() => const ApiException(
        statusCode: 401,
        message:
            'Your API key is invalid or has been revoked. '
            'Please check your .env configuration.',
      );

  factory ApiException.rateLimited() => const ApiException(
        statusCode: 429,
        message:
            'Too many requests. The free-tier rate limit has been reached. '
            'Please wait a moment and try again.',
      );

  factory ApiException.serverError(int code, String detail) => ApiException(
        statusCode: code,
        message: 'Server returned an error ($code): $detail',
      );

  // ── User-friendly message for display in [ErrorView] ─────────────────────

  /// Returns a sentence the user can actually understand, without
  /// exposing raw HTTP jargon.
  String get userMessage {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your search and try again.';
      case 401:
        return 'API key invalid. Please reconfigure the app.';
      case 429:
        return 'Rate limit reached. Please wait a moment and retry.';
      case 500:
      case 502:
      case 503:
        return 'The news server is temporarily unavailable ($statusCode). '
            'Please try again later.';
      default:
        return 'Server error ($statusCode): $message';
    }
  }
}
