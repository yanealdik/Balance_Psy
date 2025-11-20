import 'package:flutter/material.dart';

/// Провайдер для хранения данных регистрации психолога
class PsychologistRegistrationProvider with ChangeNotifier {
  // Шаг 1: Личные данные
  String? _fullName;
  DateTime? _dateOfBirth;
  int? _age;
  String? _gender;
  String? _phone;

  // Шаг 2: Email и пароль
  String? _email;
  String? _password;
  bool _emailVerified = false;

  // Шаг 3: Профессиональная информация
  String? _specialization;
  int? _experienceYears;
  String? _education;
  String? _bio;

  // Шаг 4: Подходы и стоимость
  List<String> _approaches = [];
  double? _hourlyRate;

  // Getters - Личные данные
  String? get fullName => _fullName;
  DateTime? get dateOfBirth => _dateOfBirth;
  int? get age => _age;
  String? get gender => _gender;
  String? get phone => _phone;

  // Getters - Email и пароль
  String? get email => _email;
  String? get password => _password;
  bool get emailVerified => _emailVerified;

  // Getters - Профессиональные данные
  String? get specialization => _specialization;
  int? get experienceYears => _experienceYears;
  String? get education => _education;
  String? get bio => _bio;

  // Getters - Подходы и стоимость
  List<String> get approaches => _approaches;
  double? get hourlyRate => _hourlyRate;

  // Setters - Шаг 1
  void setPersonalInfo({
    required String fullName,
    required DateTime dateOfBirth,
    required int age,
    String? gender,
    String? phone,
  }) {
    _fullName = fullName;
    _dateOfBirth = dateOfBirth;
    _age = age;
    _gender = gender;
    _phone = phone;
    notifyListeners();
  }

  // Setters - Шаг 2
  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setEmailVerified(bool verified) {
    _emailVerified = verified;
    notifyListeners();
  }

  // Setters - Шаг 3
  void setProfessionalInfo({
    required String specialization,
    required int experienceYears,
    required String education,
    required String bio,
  }) {
    _specialization = specialization;
    _experienceYears = experienceYears;
    _education = education;
    _bio = bio;
    notifyListeners();
  }

  // Setters - Шаг 4
  void setApproachesAndRate({
    required List<String> approaches,
    required double hourlyRate,
  }) {
    _approaches = approaches;
    _hourlyRate = hourlyRate;
    notifyListeners();
  }

  // Проверка готовности к регистрации
  bool get canRegister {
    return _fullName != null &&
        _fullName!.isNotEmpty &&
        _dateOfBirth != null &&
        _age != null &&
        _age! >= 21 &&
        _email != null &&
        _emailVerified &&
        _password != null &&
        _password!.length >= 6 &&
        _specialization != null &&
        _specialization!.isNotEmpty &&
        _experienceYears != null &&
        _experienceYears! >= 0 &&
        _education != null &&
        _education!.length >= 10 &&
        _bio != null &&
        _bio!.length >= 50 &&
        _approaches.isNotEmpty &&
        _hourlyRate != null &&
        _hourlyRate! > 0;
  }

  // Получить данные для отправки на backend
  Map<String, dynamic> getRegistrationData() {
    return {
      'email': _email,
      'password': _password,
      'passwordRepeat': _password,
      'fullName': _fullName,
      'dateOfBirth': _dateOfBirth?.toIso8601String().split('T')[0],
      'gender': _gender,
      'phone': _phone,
      'specialization': _specialization,
      'experienceYears': _experienceYears,
      'education': _education,
      'bio': _bio,
      'approaches': _approaches,
      'hourlyRate': _hourlyRate,
    };
  }

  // Очистить все данные
  void clear() {
    _fullName = null;
    _dateOfBirth = null;
    _age = null;
    _gender = null;
    _phone = null;
    _email = null;
    _password = null;
    _emailVerified = false;
    _specialization = null;
    _experienceYears = null;
    _education = null;
    _bio = null;
    _approaches = [];
    _hourlyRate = null;
    notifyListeners();
  }
}
