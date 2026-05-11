import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/app_config.dart';
import '../core/app_flavor.dart';
import '../core/auth_prefs.dart';
import '../theme/app_color.dart';
import 'authorized_network_image.dart';

/// [CachedNetworkImage] with URL resolution and session headers (parity with [AuthorizedNetworkImage]).
class CachedAuthorizedNetworkImage extends ConsumerWidget {
  const CachedAuthorizedNetworkImage({
    super.key,
    required this.imageUrl,
    required this.fit,
    this.width,
    this.height,
    this.expand = false,
    this.placeholder,
    this.errorFallback,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final bool expand;
  final Widget? placeholder;
  final Widget? errorFallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(appFlavorProvider);
    final base = AppConfig.baseUrl(flavor);
    final resolved = AuthorizedNetworkImage.resolveUrl(imageUrl, base);
    if (resolved.isEmpty) {
      final w = placeholder ?? ColoredBox(color: AppColor.siteListRowGrey);
      return expand ? SizedBox.expand(child: w) : w;
    }

    final token = AuthPrefs.sessionToken;
    final headers = <String, String>{
      'X-Application-Key': AppConfig.xApplicationKey(flavor),
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final image = CachedNetworkImage(
      imageUrl: resolved,
      fit: fit,
      width: expand ? null : width,
      height: expand ? null : height,
      httpHeaders: headers,
      placeholder: (context, url) {
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
      errorWidget: (context, url, _) {
        final w = errorFallback ?? const ColoredBox(color: AppColor.siteListRowGrey);
        return expand ? SizedBox.expand(child: w) : w;
      },
    );

    return expand ? SizedBox.expand(child: image) : image;
  }
}
