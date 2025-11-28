import 'package:flutter/material.dart';

class RegistrationProvider with ChangeNotifier {
  // Существующие поля
  String _email = '';
  String _password = '';
  String _firstName = '';
  String _lastName = '';
  DateTime? _birthDate;
  int? _age; // ✅ ДОБАВЛЕНО
  String? _gender;
  String? _parentEmail;
  String? _fullName;
  String? _goal; // ✅ ДОБАВЛЕНО
  List<String> _interests = [];
  bool _parentEmailVerified = false; // ✅ ДОБАВЛЕНО

  // Новые поля для соглашения
  bool _agreementAccepted = false;
  String _agreementVersion = '1.0';

  // Геттеры
  String get email => _email;
  String get password => _password;
  String get firstName => _firstName;
  String get lastName => _lastName;
  DateTime? get birthDate => _birthDate;
  int? get age => _age; // ✅ ДОБАВЛЕНО
  String? get gender => _gender;
  String? get parentEmail => _parentEmail;
  bool get parentEmailVerified => _parentEmailVerified; // ✅ ДОБАВЛЕНО
  String? get fullName => _fullName;
  String? get goal => _goal; // ✅ ДОБАВЛЕНО
  List<String> get interests => _interests;

  // Новые геттеры
  bool get agreementAccepted => _agreementAccepted;
  String get agreementVersion => _agreementVersion;

  // Сеттеры
  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setFirstName(String value) {
    _firstName = value;
    notifyListeners();
  }

  void setLastName(String value) {
    _lastName = value;
    notifyListeners();
  }

  // ✅ ИСПРАВЛЕНО: добавлен метод с двумя параметрами
  void setDateOfBirth(DateTime value, int calculatedAge) {
    _birthDate = value;
    _age = calculatedAge;
    notifyListeners();
  }

  void setGender(String? value) {
    _gender = value;
    notifyListeners();
  }

  void setParentEmail(String? value) {
    _parentEmail = value;
    notifyListeners();
  }

  // ✅ ДОБАВЛЕНО
  void setParentEmailVerified(bool verified) {
    _parentEmailVerified = verified;
    notifyListeners();
  }

  // ✅ ДОБАВЛЕНО: метод для сохранения цели
  void setGoal(String value) {
    _goal = value;
    notifyListeners();
  }

  void setPersonalInfo(String fullName, List<String> interests) {
    _fullName = fullName;
    _interests = interests;
    notifyListeners();
  }

  // Новый сеттер
  void setAgreementAccepted(bool accepted) {
    _agreementAccepted = accepted;
    notifyListeners();
  }

  // Получение всех данных для отправки
  Map<String, dynamic> getRegistrationData() {
    // Форматируем дату в yyyy-MM-dd
    String? formattedDate;
    if (_birthDate != null) {
      formattedDate =
          '${_birthDate!.year.toString().padLeft(4, '0')}-'
          '${_birthDate!.month.toString().padLeft(2, '0')}-'
          '${_birthDate!.day.toString().padLeft(2, '0')}';
    }

    return {
      'email': _email,
      'password': _password,
      'passwordRepeat': _password, // ✅ ДОБАВЛЕНО для backend
      'fullName': _fullName ?? '$_firstName $_lastName',
      'dateOfBirth': formattedDate,
      'gender': _gender,
      'phone': '', // пустая строка вместо null
      'parentEmail': _parentEmail,
      'parentEmailVerified': _parentEmailVerified, // ✅ ДОБАВЛЕНО
      'agreementAccepted': _agreementAccepted,
      'agreementVersion': _agreementVersion,
      'interests': _interests,
      'registrationGoal': _goal, // ✅ ИСПРАВЛЕНО
    };
  }

  // Сброс всех данных
  void reset() {
    _email = '';
    _password = '';
    _firstName = '';
    _lastName = '';
    _birthDate = null;
    _age = null;
    _gender = null;
    _parentEmail = null;
    _parentEmailVerified = false;
    _fullName = null;
    _goal = null;
    _interests = [];
    _agreementAccepted = false;
    _agreementVersion = '1.0';
    notifyListeners();
  }

  // Валидация
  bool isValid() {
    return _email.isNotEmpty &&
        _password.isNotEmpty &&
        (_fullName != null && _fullName!.isNotEmpty) &&
        _birthDate != null &&
        _agreementAccepted;
  }
}
