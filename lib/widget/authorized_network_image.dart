import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/app_config.dart';
import '../core/app_flavor.dart';
import '../core/auth_prefs.dart';
import '../theme/app_color.dart';

/// [Image.network] with session `Authorization` and API-relative URL resolution.
class AuthorizedNetworkImage extends ConsumerWidget {
  const AuthorizedNetworkImage({
    super.key,
    required this.imageUrl,
    required this.fit,
    this.width,
    this.height,
    this.expand = false,
    this.placeholder,
    this.error,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final bool expand;

  /// Shown while loading / on error when non-null.
  final Widget? placeholder;
  final Widget? error;

  static String resolveUrl(String raw, String apiBase) {
    final t = raw.trim();
    if (t.isEmpty) return '';
    final lower = t.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) return t;
    var base = apiBase.trim();
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    final path = t.startsWith('/') ? t : '/$t';
    return '$base$path';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(appFlavorProvider);
    final base = AppConfig.baseUrl(flavor);
    final resolved = resolveUrl(imageUrl, base);
    if (resolved.isEmpty) {
      final w = placeholder ?? ColoredBox(color: AppColor.siteListRowGrey);
      return expand ? SizedBox.expand(child: w) : w;
    }

    final token = AuthPrefs.sessionToken;
    final headers = <String, String>{
      'X-Application-Key': AppConfig.xApplicationKey(flavor),
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final image = Image.network(
      resolved,
      width: expand ? null : width,
      height: expand ? null : height,
      fit: fit,
      headers: headers,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        final w =
            placeholder ??
            ColoredBox(
              color: AppColor.siteListRowGrey,
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: AppColor.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
            );
        return expand ? SizedBox.expand(child: w) : w;
      },
      errorBuilder: (_, _, _) {
        final w = error ?? const ColoredBox(color: AppColor.siteListRowGrey);
        return expand ? SizedBox.expand(child: w) : w;
      },
    );

    return expand ? SizedBox.expand(child: image) : image;
  }
}
