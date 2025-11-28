import 'package:flutter/material.dart';
import 'dart:io';

class PsychologistRegistrationProvider with ChangeNotifier {
  String? _fullName;
  DateTime? _dateOfBirth;
  int? _age;
  String? _gender;
  String? _phone;
  String? _email;
  String? _password;
  String? _verificationCode;
  bool _emailVerified = false;
  String? _specialization;
  int? _experienceYears;
  String? _education;
  String? _bio;
  List<String> _approaches = [];
  List<File> _certificates = [];
  String? _certificateUrl;
  double? _sessionPrice;
  String _applicationStatus = 'draft';

  bool _agreementAccepted = false;
  String _agreementVersion = '1.0';

  // Getters
  String? get fullName => _fullName;
  DateTime? get dateOfBirth => _dateOfBirth;
  int? get age => _age;
  String? get gender => _gender;
  String? get phone => _phone;
  String? get email => _email;
  String? get password => _password;
  String? get verificationCode => _verificationCode;
  bool get emailVerified => _emailVerified;
  String? get specialization => _specialization;
  int? get experienceYears => _experienceYears;
  String? get education => _education;
  String? get bio => _bio;
  List<String> get approaches => _approaches;
  List<File> get certificates => _certificates;
  String? get certificateUrl => _certificateUrl;
  double? get sessionPrice => _sessionPrice;
  String get applicationStatus => _applicationStatus;

  bool get agreementAccepted => _agreementAccepted;
  String get agreementVersion => _agreementVersion;

  // Setters
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

  void setSessionPrice(double price) {
    _sessionPrice = price;
    notifyListeners();
  }

  void setApplicationStatus(String status) {
    _applicationStatus = status;
    notifyListeners();
  }

  void setAgreementAccepted(bool accepted) {
    _agreementAccepted = accepted;
    notifyListeners();
  }

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

  bool get canRegister {
    return isStep1Complete &&
        isStep2Complete &&
        isStep3Complete &&
        isStep4Complete &&
        isStep5Complete;
  }

  /// ✅ ИСПРАВЛЕНО: Правильный формат данных
  Map<String, dynamic> getRegistrationData() {
    // Форматируем дату в YYYY-MM-DD
    String formattedDate = '';
    if (_dateOfBirth != null) {
      formattedDate =
          '${_dateOfBirth!.year.toString().padLeft(4, '0')}-'
          '${_dateOfBirth!.month.toString().padLeft(2, '0')}-'
          '${_dateOfBirth!.day.toString().padLeft(2, '0')}';
    }

    print('📋 Provider data:');
    print('  - dateOfBirth: $_dateOfBirth -> $formattedDate');
    print('  - approaches: $_approaches (${_approaches.runtimeType})');
    print('  - sessionPrice: $_sessionPrice (${_sessionPrice.runtimeType})');

    return {
      'email': _email,
      'password': _password,
      'fullName': _fullName,
      'dateOfBirth': formattedDate, // ✅ Формат: "YYYY-MM-DD"
      'phone': _phone ?? '', // ✅ Пустая строка вместо null
      'gender': _gender ?? 'other', // ✅ Значение по умолчанию
      'specialization': _specialization,
      'experienceYears': _experienceYears,
      'education': _education,
      'bio': _bio,
      'approaches': _approaches.toSet(), // ✅ Преобразуем List -> Set
      'sessionPrice': _sessionPrice, // ✅ Будет double
      'agreementAccepted': _agreementAccepted, // ✅ ДОБАВЛЕНО
      'agreementVersion': _agreementVersion,
    };
  }

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

  void reset() {
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
