import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../core/constants/app_colors.dart';
import 'cached_image_view.dart';

/// Opens a full-screen video player dialog for a network URL or local file.
/// Call [PortfolioVideoPlayer.show] from any context.
class PortfolioVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? title;

  const PortfolioVideoPlayer({
    super.key,
    required this.videoUrl,
    this.title,
  });

  static Future<void> show(
    BuildContext context, {
    required String videoUrl,
    String? title,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => PortfolioVideoPlayer(videoUrl: videoUrl, title: title),
    );
  }

  @override
  State<PortfolioVideoPlayer> createState() => _PortfolioVideoPlayerState();
}

class _PortfolioVideoPlayerState extends State<PortfolioVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _hasError = false;
  String? _errorMsg;
  String _resolvedUrl = '';

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final raw = widget.videoUrl.trim();
      final resolved = CachedImageView.resolveUrl(raw);
      _resolvedUrl = resolved;

      if (resolved.isEmpty) {
        throw Exception('Video URL is empty');
      }

      final isLocal = (raw.startsWith('/') && !raw.startsWith('/uploads')) ||
          raw.contains(':\\') ||
          raw.startsWith('file://');

      if (isLocal && File(raw).existsSync()) {
        _videoController = VideoPlayerController.file(File(raw));
      } else if (resolved.startsWith('assets/')) {
        _videoController = VideoPlayerController.asset(resolved);
      } else {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(resolved),
        );
      }

      await _videoController!.initialize();
      if (!mounted) return;

      final double ar = _videoController!.value.aspectRatio > 0
          ? _videoController!.value.aspectRatio
          : 16 / 9;

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        aspectRatio: ar,
        autoPlay: true,
        looping: false,
        allowFullScreen: false,
        allowMuting: true,
        showControlsOnInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          bufferedColor: AppColors.primary.withValues(alpha: 0.3),
          backgroundColor: Colors.white24,
        ),
        placeholder: Container(color: Colors.black),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      final str = e.toString().toLowerCase();
      final isChannelError = str.contains('channel-error') ||
          str.contains('unable to establish connection') ||
          str.contains('missingplugin');
      setState(() {
        _hasError = true;
        _errorMsg = isChannelError
            ? 'Native video plugin needs an app rebuild.\nPlease restart "flutter run" in your terminal to enable in-app playback.'
            : 'Could not load video. Tap below to play externally.';
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 48),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: Colors.black,
              child: Row(
                children: [
                  const Icon(Icons.play_circle_fill_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (widget.title?.isNotEmpty == true)
                          ? widget.title!
                          : 'Portfolio Video',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white70, size: 22),
                  ),
                ],
              ),
            ),

            // Player
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _hasError
                  ? _buildError()
                  : _chewieController != null
                      ? Chewie(controller: _chewieController!)
                      : _buildLoader(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoader() => Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 12),
              Text('Loading video...',
                  style: TextStyle(color: Colors.white60, fontSize: 13)),
            ],
          ),
        ),
      );

  Widget _buildError() => Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_rounded,
                  color: Colors.white30, size: 40),
              const SizedBox(height: 10),
              Text(
                _errorMsg ?? 'Failed to load video',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              if (_resolvedUrl.isNotEmpty)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    try {
                      final uri = Uri.parse(_resolvedUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    } catch (_) {}
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Play in External Player',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ),
      );
}

/// Grid tile with play overlay. Tap opens [PortfolioVideoPlayer].
class PortfolioVideoThumbnail extends StatelessWidget {
  final String videoUrl;
  final String? title;
  final String? thumbnailUrl;
  final Widget? thumbnailWidget;

  const PortfolioVideoThumbnail({
    super.key,
    required this.videoUrl,
    this.title,
    this.thumbnailUrl,
    this.thumbnailWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget background;
    if (thumbnailWidget != null) {
      background = thumbnailWidget!;
    } else if (thumbnailUrl != null &&
        thumbnailUrl!.isNotEmpty &&
        !CachedImageView.isVideoUrl(thumbnailUrl)) {
      background = CachedImageView(
        imageUrl: thumbnailUrl!,
        fit: BoxFit.cover,
        fallbackIcon: Icons.videocam_rounded,
        iconColor: AppColors.gold,
        backgroundColor: AppColors.primaryDark,
      );
    } else {
      background = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              const Color(0xFF1B2236),
            ],
          ),
        ),
        child: const Center(
          child: Icon(Icons.movie_creation_outlined,
              color: Colors.white24, size: 44),
        ),
      );
    }

    return GestureDetector(
      onTap: () => PortfolioVideoPlayer.show(context,
          videoUrl: videoUrl, title: title),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background / thumbnail
          background,

          // Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),

          // Play button
          Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white38, width: 1.5),
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 28),
            ),
          ),

          // VIDEO label
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'VIDEO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
