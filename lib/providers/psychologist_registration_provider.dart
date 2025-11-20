import 'package:flutter/material.dart';
import 'dart:io';

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
  String? _verificationCode;
  bool _emailVerified = false;

  // Шаг 3: Профессиональная информация
  String? _specialization;
  int? _experienceYears;
  String? _education;
  String? _bio;
  List<String> _approaches = [];

  // Шаг 4: Документы и сертификаты
  List<File> _certificates = [];
  String? _certificateUrl; // URL после загрузки

  // Шаг 5: Стоимость услуг
  double? _sessionPrice;

  // Статус заявки
  String _applicationStatus = 'draft'; // draft, pending, approved, rejected

  // Getters - Личные данные
  String? get fullName => _fullName;
  DateTime? get dateOfBirth => _dateOfBirth;
  int? get age => _age;
  String? get gender => _gender;
  String? get phone => _phone;

  // Getters - Email и пароль
  String? get email => _email;
  String? get password => _password;
  String? get verificationCode => _verificationCode;
  bool get emailVerified => _emailVerified;

  // Getters - Профессиональные данные
  String? get specialization => _specialization;
  int? get experienceYears => _experienceYears;
  String? get education => _education;
  String? get bio => _bio;
  List<String> get approaches => _approaches;

  // Getters - Документы
  List<File> get certificates => _certificates;
  String? get certificateUrl => _certificateUrl;

  // Getters - Стоимость
  double? get sessionPrice => _sessionPrice;

  // Getters - Статус
  String get applicationStatus => _applicationStatus;

  // Setters - Шаг 1: Личные данные
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

  // Setters - Шаг 2: Email и пароль
  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setVerificationCode(String code) {
    _verificationCode = code;
    notifyListeners();
  }

  void setEmailVerified(bool verified) {
    _emailVerified = verified;
    notifyListeners();
  }

  // Setters - Шаг 3: Профессиональная информация
  void setProfessionalInfo({
    required String specialization,
    required int experienceYears,
    required String education,
    required String bio,
    required List<String> approaches,
  }) {
    _specialization = specialization;
    _experienceYears = experienceYears;
    _education = education;
    _bio = bio;
    _approaches = approaches;
    notifyListeners();
  }

  // Setters - Шаг 4: Документы
  void addCertificate(File certificate) {
    _certificates.add(certificate);
    notifyListeners();
  }

  void removeCertificate(int index) {
    if (index >= 0 && index < _certificates.length) {
      _certificates.removeAt(index);
      notifyListeners();
    }
  }

  void setCertificateUrl(String url) {
    _certificateUrl = url;
    notifyListeners();
  }

  // Setters - Шаг 5: Стоимость
  void setSessionPrice(double price) {
    _sessionPrice = price;
    notifyListeners();
  }

  // Статус заявки
  void setApplicationStatus(String status) {
    _applicationStatus = status;
    notifyListeners();
  }

  // Проверка готовности каждого шага
  bool get isStep1Complete {
    return _fullName != null &&
        _fullName!.isNotEmpty &&
        _dateOfBirth != null &&
        _age != null &&
        _age! >= 21;
  }

  bool get isStep2Complete {
    return _email != null &&
        _email!.isNotEmpty &&
        _password != null &&
        _password!.length >= 8 &&
        _emailVerified;
  }

  bool get isStep3Complete {
    return _specialization != null &&
        _specialization!.isNotEmpty &&
        _experienceYears != null &&
        _experienceYears! >= 0 &&
        _education != null &&
        _education!.length >= 20 &&
        _bio != null &&
        _bio!.length >= 100 &&
        _approaches.isNotEmpty;
  }

  bool get isStep4Complete {
    return _certificates.isNotEmpty || _certificateUrl != null;
  }

  bool get isStep5Complete {
    return _sessionPrice != null && _sessionPrice! > 0;
  }

  // Проверка готовности к регистрации
  bool get canRegister {
    return isStep1Complete &&
        isStep2Complete &&
        isStep3Complete &&
        isStep4Complete &&
        isStep5Complete;
  }

  // Получить данные для отправки на backend
  Map<String, dynamic> getRegistrationData() {
    return {
      'email': _email,
      'password': _password,
      'fullName': _fullName,
      'dateOfBirth': _dateOfBirth?.toIso8601String().split('T')[0],
      'gender': _gender,
      'phone': _phone,
      'role': 'PSYCHOLOGIST',
      'specialization': _specialization,
      'experienceYears': _experienceYears,
      'education': _education,
      'bio': _bio,
      'approaches': _approaches,
      'sessionPrice': _sessionPrice,
      'certificateUrl': _certificateUrl,
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
    _verificationCode = null;
    _emailVerified = false;
    _specialization = null;
    _experienceYears = null;
    _education = null;
    _bio = null;
    _approaches = [];
    _certificates = [];
    _certificateUrl = null;
    _sessionPrice = null;
    _applicationStatus = 'draft';
    notifyListeners();
  }
}
