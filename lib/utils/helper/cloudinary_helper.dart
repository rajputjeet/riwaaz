import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../data/api_provider/api_constant.dart';

// ---------------------------------------------------------------------------
// CloudinaryHelper
// ---------------------------------------------------------------------------
/// Cloudinary Helper for ShaadiHub
///
/// Handles:
/// - Dynamic format negotiation (`f_auto`)
/// - Perceptual quality optimisation (`q_auto`)
/// - Optional responsive scaling (`w_<width>`)
/// - Video poster-frame thumbnail generation (`.jpg`)
/// - Upload & delete via the project's own backend (`/api/upload`)
class CloudinaryHelper {
  // -------------------------------------------------------------------------
  // URL optimisation
  // -------------------------------------------------------------------------

  /// Optimises a Cloudinary image **or** video URL by injecting
  /// `f_auto,q_auto` (and optionally `w_[width]`) into the transformation
  /// segment.  Any pre-existing transformation segment is stripped first to
  /// avoid duplicate-parameter errors from the Cloudinary CDN.
  ///
  /// Non-Cloudinary URLs are returned unchanged.
  static String optimizeUrl(String? url, {int? width}) {
    if (url == null || url.isEmpty) return '';
    if (!url.contains('res.cloudinary.com')) return url;

    const uploadTypes = ['/video/upload/', '/image/upload/'];
    for (final type in uploadTypes) {
      final index = url.indexOf(type);
      if (index == -1) continue;

      final baseUrl = url.substring(0, index + type.length);
      String remaining = url.substring(index + type.length);

      // Strip any existing transformation segment
      final segments = remaining.split('/');
      if (segments.length > 1) {
        final first = segments.first;
        final isVersion = RegExp(r'^v\d+$').hasMatch(first);
        final isTransform = !isVersion &&
            (first.contains(',') ||
                first.contains('_') ||
                first == 'f_auto' ||
                first == 'q_auto');

        if (isTransform) {
          segments.removeAt(0);
          remaining = segments.join('/');
        }
      }

      final transform =
          (width != null && width > 0) ? 'f_auto,q_auto,w_$width' : 'f_auto,q_auto';

      return '$baseUrl$transform/$remaining';
    }

    return url;
  }

  /// Optimises a Cloudinary **image** URL.
  static String optimizeImageUrl(String? url, {int? width}) =>
      optimizeUrl(url, width: width);

  /// Optimises a Cloudinary **video** URL.
  static String optimizeVideoUrl(String? url, {int? width}) =>
      optimizeUrl(url, width: width);

  /// Returns a fully-resolved, optimised URL for any image value.
  ///
  /// Accepts:
  /// - A plain [String] URL
  /// - A [Map] with a `"url"` key (e.g. the API response `data` object)
  ///
  /// Rules applied in order:
  /// 1. `blob:` / `data:` URIs → returned as-is
  /// 2. Cloudinary URLs → optimised with [optimizeImageUrl]
  /// 3. Absolute `http(s)://` URLs → returned as-is
  /// 4. Relative paths → prefixed with [ApiConstants.baseUrl]
  static String getImageUrl(
    dynamic image, {
    int? width,
    String? baseUrl,
  }) {
    if (image == null) return '';

    String url = '';
    if (image is String) {
      url = image;
    } else if (image is Map) {
      url = image['url']?.toString() ?? '';
    }
    if (url.isEmpty) return '';

    // Raw binary / blob data URIs — keep as-is
    if (url.startsWith('blob:') || url.startsWith('data:')) return url;

    // Cloudinary CDN — inject f_auto,q_auto
    if (url.contains('res.cloudinary.com')) {
      return optimizeImageUrl(url, width: width);
    }

    // Already absolute — return as-is
    if (url.startsWith('http://') || url.startsWith('https://')) return url;

    // Relative path — prepend the backend base URL
    final resolvedBase = (baseUrl ?? ApiConstants.baseUrl)
        .replaceAll(RegExp(r'/api/?$'), '')
        .replaceAll(RegExp(r'/$'), '');
    final prefix = url.startsWith('/') ? '' : '/';
    return '$resolvedBase$prefix$url';
  }

  /// Derives a poster-frame thumbnail (.jpg) from a Cloudinary video URL and
  /// applies Cloudinary optimisations.
  static String getVideoThumbnail(String? videoUrl, {int? width}) {
    if (videoUrl == null || videoUrl.isEmpty) return '';
    if (!videoUrl.contains('res.cloudinary.com')) return videoUrl;

    final jpgUrl = videoUrl.replaceAll(
      RegExp(
        r'\.(mp4|webm|mov|mkv|avi|3gp|flv|wmv|m4v)(\?.*)?$',
        caseSensitive: false,
      ),
      '.jpg',
    );
    return optimizeImageUrl(jpgUrl, width: width);
  }

  // -------------------------------------------------------------------------
  // Upload  (uses Dio — already in pubspec.yaml)
  // -------------------------------------------------------------------------

  /// Uploads [file] to the backend `/api/upload` endpoint.
  ///
  /// [context] maps to the backend's folder routing:
  ///   `'portfolio'` | `'banners'` | `'blogs'` | `'users'`
  ///
  /// Returns the `data` map from the response body, which contains:
  /// - `data['url']`       — full Cloudinary secure URL
  /// - `data['public_id']` — Cloudinary public ID (needed for deletion)
  ///
  /// Throws a [DioException] on network errors or a [Exception] on non-200
  /// status codes.
  static Future<Map<String, dynamic>> uploadFile({
    required File file,
    String context = 'portfolio',
    String? authToken,
    Dio? dio,
  }) async {
    final client = dio ?? Dio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'context': context,
    });

    final response = await client.post(
      '${ApiConstants.baseUrl}/api/upload',
      data: formData,
      options: Options(
        headers: {
          if (authToken != null && authToken.isNotEmpty)
            'Authorization': 'Bearer $authToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;
      return body['data'] as Map<String, dynamic>;
    }

    throw Exception('Upload failed [${response.statusCode}]: ${response.data}');
  }

  // -------------------------------------------------------------------------
  // Delete  (uses Dio — already in pubspec.yaml)
  // -------------------------------------------------------------------------

  /// Deletes a Cloudinary asset via the backend `/api/upload/delete` endpoint.
  ///
  /// [publicIdOrUrl] may be either:
  /// - A Cloudinary `public_id`  (e.g. `"portfolio/abc123"`)
  /// - A full Cloudinary URL     (the backend resolves the public_id itself)
  ///
  /// [resourceType] must be `'image'` or `'video'`.
  ///
  /// Returns `true` on success, `false` on any non-200 response.
  static Future<bool> deleteAsset({
    required String publicIdOrUrl,
    String resourceType = 'image',
    String? authToken,
    Dio? dio,
  }) async {
    final client = dio ?? Dio();

    try {
      final response = await client.post(
        '${ApiConstants.baseUrl}/api/upload/delete',
        data: {
          'public_id': publicIdOrUrl,
          'url': publicIdOrUrl,
          'resource_type': resourceType,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            if (authToken != null && authToken.isNotEmpty)
              'Authorization': 'Bearer $authToken',
          },
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Flutter widget helpers
  // -------------------------------------------------------------------------

  /// Renders an optimised Cloudinary image with disk-caching via
  /// `cached_network_image`.
  ///
  /// Automatically applies 2× pixel-density scaling for Retina / HD displays
  /// when [width] is provided.
  static Widget buildOptimizedImage(
    String? imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    final optimized = getImageUrl(
      imageUrl,
      width: width != null ? (width * 2).toInt() : null,
    );

    if (optimized.isEmpty) {
      return errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
    }

    return CachedNetworkImage(
      imageUrl: optimized,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
    );
  }

  /// Renders a video thumbnail derived from a Cloudinary video URL, overlaid
  /// with a circular play-button indicator.
  static Widget buildVideoThumbnail(
    String? videoUrl, {
    double? width,
    double? height,
    int thumbnailWidth = 400,
  }) {
    final thumbUrl = getVideoThumbnail(videoUrl, width: thumbnailWidth);

    return Stack(
      alignment: Alignment.center,
      children: [
        CachedNetworkImage(
          imageUrl: thumbUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (context, url, error) => Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.videocam_off, color: Colors.grey),
          ),
        ),
        const CircleAvatar(
          backgroundColor: Colors.black54,
          child: Icon(Icons.play_arrow, color: Colors.white),
        ),
      ],
    );
  }
}
