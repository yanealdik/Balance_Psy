import 'package:flutter/material.dart';

class RegistrationProvider with ChangeNotifier {
  // Существующие поля
  String _email = '';
  String _password = '';
  String _firstName = '';
  String _lastName = '';
  DateTime? _birthDate;
  String? _gender;
  String? _parentEmail;
  String? _fullName;
  List<String> _interests = [];

  // ✅ НОВЫЕ ПОЛЯ для соглашения
  bool _agreementAccepted = false;
  String _agreementVersion = '1.0';

  // Геттеры
  String get email => _email;
  String get password => _password;
  String get firstName => _firstName;
  String get lastName => _lastName;
  DateTime? get birthDate => _birthDate;
  String? get gender => _gender;
  String? get parentEmail => _parentEmail;
  String? get fullName => _fullName;
  List<String> get interests => _interests;

  // ✅ НОВЫЕ геттеры
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

  void setBirthDate(DateTime value) {
    _birthDate = value;
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

  void setPersonalInfo(String fullName, List<String> interests) {
    _fullName = fullName;
    _interests = interests;
    notifyListeners();
  }

  // ✅ НОВЫЙ сеттер
  void setAgreementAccepted(bool accepted) {
    _agreementAccepted = accepted;
    notifyListeners();
  }

  // Получение всех данных для отправки
  Map<String, dynamic> getRegistrationData() {
    return {
      'email': _email,
      'password': _password,
      'firstName': _firstName,
      'lastName': _lastName,
      'birthDate': _birthDate?.toIso8601String(),
      'gender': _gender,
      'parentEmail': _parentEmail,
      'agreementAccepted': _agreementAccepted, // ✅ ДОБАВЛЕНО
      'agreementVersion': _agreementVersion, // ✅ ДОБАВЛЕНО
      'fullName': _fullName,
      'interests': _interests,
    };
  }

  // Сброс всех данных
  void reset() {
    _email = '';
    _password = '';
    _firstName = '';
    _lastName = '';
    _birthDate = null;
    _gender = null;
    _parentEmail = null;
    _fullName = null;
    _interests = [];
    _agreementAccepted = false; // ✅ ДОБАВЛЕНО
    _agreementVersion = '1.0'; // ✅ ДОБАВЛЕНО
    notifyListeners();
  }

  // Валидация
  bool isValid() {
    return _email.isNotEmpty &&
        _password.isNotEmpty &&
        _firstName.isNotEmpty &&
        _lastName.isNotEmpty &&
        _birthDate != null &&
        _agreementAccepted; // ✅ ДОБАВЛЕНО
  }
}
