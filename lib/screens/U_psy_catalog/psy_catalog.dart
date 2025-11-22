import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/psychologist_service.dart';
import '../../models/psychologist_model.dart';
import 'psychologist_profile_screen.dart';
import '../../widgets/psychologist/psychologist_avatar.dart';

class PsychologistsScreen extends StatefulWidget {
  const PsychologistsScreen({super.key});

  @override
  State<PsychologistsScreen> createState() => _PsychologistsScreenState();
}

class _PsychologistsScreenState extends State<PsychologistsScreen> {
  final PsychologistService _service = PsychologistService();

  int selectedCategory = 0;
  String searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  List<PsychologistModel> _psychologists = [];

  final List<String> categories = [
    'Все',
    'Детские',
    'Семейные',
    'Подростковые',
  ];

  @override
  void initState() {
    super.initState();
    _loadPsychologists();
  }

  Future<void> _loadPsychologists() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📞 Loading psychologists from API...');

      final psychologists = await _service.getAvailablePsychologists();

      print('✅ Loaded ${psychologists.length} psychologists');

      if (!mounted) return;

      setState(() {
        _psychologists = psychologists;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading psychologists: $e');

      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<PsychologistModel> get filteredPsychologists {
    var filtered = _psychologists;

    // Фильтр по категории
    if (selectedCategory != 0) {
      final category = categories[selectedCategory].toLowerCase();
      filtered = filtered.where((psy) {
        return psy.specialization.toLowerCase().contains(category);
      }).toList();
    }

    // Фильтр по поиску
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((psy) {
        final query = searchQuery.toLowerCase();
        return psy.fullName.toLowerCase().contains(query) ||
            psy.specialization.toLowerCase().contains(query) ||
            psy.bio.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Каталог психологов',
                    style: AppTextStyles.h2.copyWith(fontSize: 28),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadPsychologists,
                    tooltip: 'Обновить',
                  ),
                ],
              ),
            ),

            // Поиск
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearchBar(),
            ),

            const SizedBox(height: 16),

            // Категории
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildCategoryChip(index),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Список психологов
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загрузка психологов...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_psychologists.isEmpty) {
      return _buildEmptyState(
        'Психологи не зарегистрированы',
        'В базе данных пока нет психологов.\nПопросите психологов зарегистрироваться.',
      );
    }

    final filtered = filteredPsychologists;

    if (filtered.isEmpty) {
      return _buildEmptyState(
        'Психологи не найдены',
        'Попробуйте изменить фильтры или поисковый запрос',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPsychologists,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPsychologistCard(filtered[index]),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Поиск психолога...',
          hintStyle: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () => setState(() => searchQuery = ''),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(int index) {
    final isSelected = selectedCategory == index;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          categories[index],
          style: AppTextStyles.body1.copyWith(
            fontSize: 15,
            color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildPsychologistCard(PsychologistModel psychologist) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PsychologistProfileScreen(psychologist: psychologist),
          ),
        ).then((value) {
          // Обновляем список если была создана запись
          if (value == true) {
            _loadPsychologists();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: buildPsychologistAvatar(
                        psychologist.avatarUrl,
                        psychologist.fullName,
                        radius: 30,
                      ),
                    ),
                    if (psychologist.isAvailable)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.cardBackground,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              psychologist.fullName,
                              style: AppTextStyles.h3.copyWith(fontSize: 17),
                            ),
                          ),
                          if (psychologist.isVerified)
                            const Icon(
                              Icons.verified,
                              size: 18,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        psychologist.specialization,
                        style: AppTextStyles.body2.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, size: 18, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  psychologist.rating.toStringAsFixed(1),
                  style: AppTextStyles.body1.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${psychologist.reviewsCount})',
                  style: AppTextStyles.body3.copyWith(fontSize: 12),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.work_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${psychologist.experienceYears} лет',
                  style: AppTextStyles.body2.copyWith(fontSize: 13),
                ),
                const Spacer(),
                Text(
                  '${psychologist.hourlyRate.toStringAsFixed(0)} ₸',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.body2.copyWith(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPsychologists,
              icon: const Icon(Icons.refresh),
              label: const Text('Обновить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки',
              style: AppTextStyles.h3.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPsychologists,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
