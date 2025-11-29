import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/back_button.dart';

/// Экран с видео из assets
class IntroVideoScreen extends StatefulWidget {
  final String title;
  final String description;
  final String
  videoPath; // Путь к видео в assets (не используется, берем дефолтный)

  const IntroVideoScreen({
    super.key,
    required this.title,
    required this.description,
    required this.videoPath,
  });

  @override
  State<IntroVideoScreen> createState() => _IntroVideoScreenState();
}

class _IntroVideoScreenState extends State<IntroVideoScreen> {
  late VideoPlayerController _controller;
  bool _hasWatched = false;
  bool _isPlayerReady = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // ✅ Используем локальный файл из assets/video/
    const String videoAssetPath = 'assets/video/intro_video.mp4';
    _controller = VideoPlayerController.asset(videoAssetPath);

    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isPlayerReady = true;
        });
      }

      _controller.addListener(_videoListener);
    } catch (e) {
      debugPrint('Ошибка инициализации видео: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось загрузить видео'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _videoListener() {
    if (!mounted) return;

    // Отслеживаем состояние воспроизведения
    if (_controller.value.isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
      });
    }

    // Проверяем прогресс просмотра
    if (_isPlayerReady && _controller.value.isPlaying) {
      final position = _controller.value.position.inSeconds;
      final duration = _controller.value.duration.inSeconds;

      // Если досмотрел 80% или дошел до конца
      if (duration > 0 &&
          (position > duration * 0.8 || position >= duration - 2)) {
        if (!_hasWatched && mounted) {
          setState(() {
            _hasWatched = true;
          });
        }
      }
    }

    // Проверяем, закончилось ли видео
    if (_controller.value.position >= _controller.value.duration) {
      if (!_hasWatched && mounted) {
        setState(() {
          _hasWatched = true;
        });
      }
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.pause();
    _controller.dispose();
    // Возвращаем портретную ориентацию
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _controller.pause();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Верхняя часть с кнопкой назад
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CustomBackButton(
                      onPressed: () {
                        _controller.pause();
                        Navigator.pop(context, _hasWatched);
                      },
                    ),
                  ],
                ),
              ),

              // Контент
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок
                      Text(
                        widget.title,
                        style: AppTextStyles.h2.copyWith(fontSize: 24),
                      ),

                      const SizedBox(height: 12),

                      // Описание
                      Text(
                        widget.description,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Видео плеер
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _isPlayerReady
                            ? AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    VideoPlayer(_controller),

                                    // Оверлей с кнопкой play/pause
                                    GestureDetector(
                                      onTap: _togglePlayPause,
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Center(
                                          child: AnimatedOpacity(
                                            opacity: _isPlaying ? 0.0 : 1.0,
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              child: Icon(
                                                _isPlaying
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Прогресс бар внизу
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black54,
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              _formatDuration(
                                                _controller.value.position,
                                              ),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: VideoProgressIndicator(
                                                _controller,
                                                allowScrubbing: true,
                                                colors:
                                                    const VideoProgressColors(
                                                      playedColor:
                                                          AppColors.primary,
                                                      bufferedColor:
                                                          Colors.grey,
                                                      backgroundColor:
                                                          Colors.white24,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatDuration(
                                                _controller.value.duration,
                                              ),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                      ),

                      const SizedBox(height: 24),

                      // Индикатор просмотра
                      if (_hasWatched)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Видео просмотрено! Можешь продолжить',
                                  style: AppTextStyles.body2.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Досмотри видео до конца, чтобы продолжить',
                                  style: AppTextStyles.body3.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Кнопка "Продолжить"
              Padding(
                padding: const EdgeInsets.all(24),
                child: CustomButton(
                  text: 'Продолжить',
                  showArrow: true,
                  onPressed: _hasWatched
                      ? () {
                          _controller.pause();
                          Navigator.pop(context, true);
                        }
                      : null,
                  isFullWidth: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
