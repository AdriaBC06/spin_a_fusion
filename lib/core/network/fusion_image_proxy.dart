import 'package:flutter/foundation.dart';

String resolveFusionImageUrl(String sourceUrl) {
  if (!kIsWeb) return sourceUrl;
  if (sourceUrl.isEmpty) return sourceUrl;

  final proxyBase = const String.fromEnvironment(
    'FUSION_PROXY_BASE',
    // Disabled by default because the public function can be unavailable.
    // Set --dart-define=FUSION_PROXY_BASE=... to force proxy usage.
    defaultValue: '',
  );

  if (proxyBase.isEmpty) return sourceUrl;

  final sourceUri = Uri.tryParse(sourceUrl);
  final proxyUri = Uri.tryParse(proxyBase);
  if (sourceUri == null || proxyUri == null) return sourceUrl;

  if (sourceUri.host == proxyUri.host &&
      sourceUri.path == proxyUri.path) {
    return sourceUrl;
  }

  return proxyUri.replace(queryParameters: {'url': sourceUrl}).toString();
}
