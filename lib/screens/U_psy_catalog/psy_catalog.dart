import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/psychologist_service.dart';
import '../../models/psychologist_model.dart';
import 'psychologist_profile_screen.dart';

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

  final List<String> categories = ['Все', 'Детские', 'Семейные', 'Подростковые'];

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
      final psychologists = await _service.getAvailablePsychologists();
      setState(() {
        _psychologists = psychologists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<PsychologistModel> get filteredPsychologists {
    return _psychologists.where((psy) {
      final matchesSearch = psy.fullName.toLowerCase().contains(
        searchQuery.toLowerCase(),
      ) || psy.specialization.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'Каталог психологов',
                style: AppTextStyles.h2.copyWith(fontSize: 28),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearchBar(),
            ),

            const SizedBox(height: 16),

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

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorState()
                      : filteredPsychologists.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadPsychologists,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: filteredPsychologists.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildPsychologistCard(
                                      filteredPsychologists[index],
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
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
          hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () => setState(() => searchQuery = ''),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            builder: (context) => PsychologistProfileScreen(
              psychologist: psychologist,
            ),
          ),
        );
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
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: psychologist.avatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage(psychologist.avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: psychologist.avatarUrl == null
                            ? AppColors.primary.withOpacity(0.2)
                            : null,
                      ),
                      child: psychologist.avatarUrl == null
                          ? const Icon(Icons.person, size: 30, color: AppColors.primary)
                          : null,
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
                            border: Border.all(color: AppColors.cardBackground, width: 2),
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
                      Text(
                        psychologist.fullName,
                        style: AppTextStyles.h3.copyWith(fontSize: 17),
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
                const Icon(Icons.work_outline, size: 16, color: AppColors.textSecondary),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: AppColors.textTertiary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Психологи не найдены', style: AppTextStyles.h3.copyWith(fontSize: 18, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Попробуйте изменить запрос', style: AppTextStyles.body2.copyWith(fontSize: 14, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: AppColors.error.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Ошибка загрузки', style: AppTextStyles.h3.copyWith(fontSize: 18)),
          const SizedBox(height: 8),
          Text(_errorMessage!, style: AppTextStyles.body2),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPsychologists,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}