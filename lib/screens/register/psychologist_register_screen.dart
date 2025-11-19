import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/auth_service.dart';
import '../../providers/registration_provider.dart';
import '../login/login_screen.dart';

class PsychologistRegisterScreen extends StatefulWidget {
  const PsychologistRegisterScreen({super.key});

  @override
  State<PsychologistRegisterScreen> createState() =>
      _PsychologistRegisterScreenState();
}

class _PsychologistRegisterScreenState
    extends State<PsychologistRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // Дополнительные поля для психолога
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();

  List<String> _selectedApproaches = [];
  bool _isRegistering = false;

  final List<String> _availableApproaches = [
    'Когнитивно-поведенческая терапия (КПТ)',
    'Психоанализ',
    'Гештальт-терапия',
    'Системная терапия',
    'Гуманистическая терапия',
    'Эксистенциальная терапия',
  ];

  @override
  void dispose() {
    _specializationController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _bioController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedApproaches.isEmpty) {
      _showError('Выберите хотя бы один подход');
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final regProvider = Provider.of<RegistrationProvider>(
        context,
        listen: false,
      );

      // Собираем данные из RegistrationProvider + дополнительные поля
      final data = {
        ...regProvider
            .getRegistrationData(), // email, password, fullName, dateOfBirth, gender
        'specialization': _specializationController.text.trim(),
        'experienceYears': int.parse(_experienceController.text.trim()),
        'education': _educationController.text.trim(),
        'bio': _bioController.text.trim(),
        'approaches': _selectedApproaches,
        'hourlyRate': double.parse(_hourlyRateController.text.trim()),
      };

      await _authService.registerPsychologist(data);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Регистрация успешна! Ожидайте верификации.'),
          backgroundColor: Colors.green,
        ),
      );

      // Переход на логин
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isRegistering = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация психолога')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CustomTextField(
                controller: _specializationController,
                hintText: 'Специализация',
                prefixIcon: Icons.psychology,
                enabled: !_isRegistering,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _experienceController,
                hintText: 'Опыт работы (лет)',
                prefixIcon: Icons.work,
                keyboardType: TextInputType.number,
                enabled: !_isRegistering,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _educationController,
                hintText: 'Образование',
                prefixIcon: Icons.school,
                maxLength: 3,
                enabled: !_isRegistering,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _bioController,
                hintText: 'О себе (мин. 50 символов)',
                prefixIcon: Icons.info,
                maxLength: 5,
                enabled: !_isRegistering,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _hourlyRateController,
                hintText: 'Стоимость часа (₸)',
                prefixIcon: Icons.monetization_on,
                keyboardType: TextInputType.number,
                enabled: !_isRegistering,
              ),
              const SizedBox(height: 16),
              _buildApproachesSelector(),
              const SizedBox(height: 32),
              CustomButton(
                text: _isRegistering ? 'Регистрация...' : 'Зарегистрироваться',
                onPressed: _isRegistering ? null : _register,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApproachesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Подходы:', style: AppTextStyles.body1),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _availableApproaches.map((approach) {
            final isSelected = _selectedApproaches.contains(approach);
            return FilterChip(
              label: Text(approach),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedApproaches.add(approach);
                  } else {
                    _selectedApproaches.remove(approach);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
