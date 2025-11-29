import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/back_button.dart';

class IntroMeditationScreen extends StatefulWidget {
  final String title;
  final String description;
  final String audioUrl; // Не используется, берем локальный файл
  final int durationSeconds;

  const IntroMeditationScreen({
    super.key,
    required this.title,
    required this.description,
    required this.audioUrl,
    this.durationSeconds = 300,
  });

  @override
  State<IntroMeditationScreen> createState() => _IntroMeditationScreenState();
}

class _IntroMeditationScreenState extends State<IntroMeditationScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  bool _isCompleted = false;
  bool _isLoading = false;

  int _remainingSeconds = 300;
  Timer? _timer;
  late AnimationController _pulseController;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  final List<Map<String, String>> _steps = [
    {
      'time': '0:00',
      'title': 'Подготовка',
      'description':
          'Найди удобное место, где тебя никто не побеспокоит. Сядь или ляг в комфортную позу.',
    },
    {
      'time': '1:00',
      'title': 'Дыхание',
      'description':
          'Закрой глаза и сосредоточься на своем дыхании. Дыши естественно, не пытаясь контролировать.',
    },
    {
      'time': '2:00',
      'title': 'Осознанность',
      'description':
          'Почувствуй, как воздух входит и выходит из твоих легких. Наблюдай за этим процессом.',
    },
    {
      'time': '3:00',
      'title': 'Концентрация',
      'description':
          'Если мысли отвлекают - это нормально. Просто верни внимание к дыханию.',
    },
    {
      'time': '4:00',
      'title': 'Расслабление',
      'description':
          'Почувствуй, как твое тело расслабляется с каждым выдохом. Отпусти напряжение.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    // Слушаем позицию воспроизведения
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _remainingSeconds = (_totalDuration.inSeconds - position.inSeconds)
              .clamp(0, widget.durationSeconds);
        });
      }
    });

    // Слушаем длительность
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    // Слушаем завершение
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isCompleted = true;
        });
      }
    });

    // Слушаем состояние
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_isCompleted) {
        // Если медитация завершена, начинаем сначала
        await _audioPlayer.seek(Duration.zero);
        setState(() {
          _isCompleted = false;
        });
      }

      // ✅ Используем локальный файл из assets/video/
      // AssetSource автоматически добавляет префикс 'assets/', поэтому пишем без него
      const String audioAssetPath = 'video/intro_meditation.mp3';

      setState(() => _isLoading = true);

      try {
        await _audioPlayer.play(AssetSource(audioAssetPath));
      } catch (e) {
        print('❌ Error playing audio: $e');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не удалось воспроизвести медитацию'),
              backgroundColor: Colors.red,
            ),
          );
        }

        // Запускаем таймер без аудио
        _startTimerOnly();
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startTimerOnly() {
    setState(() {
      _isPlaying = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isPlaying = false;
          _isCompleted = true;
        }
      });
    });
  }

  Future<void> _stopMeditation() async {
    await _audioPlayer.stop();
    _timer?.cancel();

    setState(() {
      _isPlaying = false;
      _remainingSeconds = widget.durationSeconds;
      _currentPosition = Duration.zero;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  String _getCurrentStep() {
    final elapsed = widget.durationSeconds - _remainingSeconds;
    for (var i = _steps.length - 1; i >= 0; i--) {
      final stepTime = int.parse(_steps[i]['time']!.split(':')[0]) * 60;
      if (elapsed >= stepTime) {
        return _steps[i]['description']!;
      }
    }
    return _steps[0]['description']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    onPressed: () async {
                      await _audioPlayer.stop();
                      if (mounted) {
                        Navigator.pop(context, _isCompleted);
                      }
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
                  children: [
                    const SizedBox(height: 20),

                    // Заголовок
                    Text(
                      widget.title.isNotEmpty
                          ? widget.title
                          : 'Медитация осознанности',
                      style: AppTextStyles.h2.copyWith(fontSize: 26),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.description.isNotEmpty
                          ? widget.description
                          : 'Практика для начинающих',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Анимированный круг с таймером
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.3),
                                AppColors.primary.withOpacity(0.1),
                                Colors.transparent,
                              ],
                              stops: [
                                0.0,
                                0.6 + (_pulseController.value * 0.2),
                                1.0,
                              ],
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius:
                                      20 + (_pulseController.value * 10),
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _formatTime(_remainingSeconds),
                                          style: AppTextStyles.h1.copyWith(
                                            color: Colors.white,
                                            fontSize: 48,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'осталось',
                                          style: AppTextStyles.body3.copyWith(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Текущий шаг медитации
                    if (_isPlaying && !_isCompleted)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.self_improvement,
                              size: 40,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _getCurrentStep(),
                              style: AppTextStyles.body2.copyWith(
                                fontSize: 15,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                    // Сообщение о завершении
                    if (_isCompleted)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Поздравляем!',
                              style: AppTextStyles.h3.copyWith(
                                color: Colors.green,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ты завершил свою первую медитацию! Регулярная практика поможет тебе достичь внутренней гармонии.',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                    // Инструкция перед началом
                    if (!_isPlaying && !_isCompleted) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Инструкция:',
                              style: AppTextStyles.h3.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 12),
                            ..._steps.map(
                              (step) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 50,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        step['time']!,
                                        style: AppTextStyles.body3.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            step['title']!,
                                            style: AppTextStyles.body1.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            step['description']!,
                                            style: AppTextStyles.body3.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Кнопки управления
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (!_isCompleted) ...[
                    CustomButton(
                      text: _isPlaying ? 'Пауза' : 'Начать медитацию',
                      icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                      onPressed: _isLoading ? null : _togglePlayPause,
                      isFullWidth: true,
                    ),

                    if (_isPlaying) ...[
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Остановить',
                        icon: Icons.stop,
                        isPrimary: false,
                        onPressed: _stopMeditation,
                        isFullWidth: true,
                      ),
                    ],
                  ] else
                    CustomButton(
                      text: 'Продолжить',
                      showArrow: true,
                      onPressed: () async {
                        await _audioPlayer.stop();
                        if (mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                      isFullWidth: true,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
