import 'package:flutter/material.dart';

class RegistrationProvider with ChangeNotifier {
  // Шаг 1: Цель
  String? _goal;

  // Шаг 2: Имя и интересы
  String? _fullName;
  List<String> _interests = [];

  // Шаг 3: Пол
  String? _gender;

  // Шаг 4: Дата рождения
  DateTime? _dateOfBirth;
  int? _age;

  // Шаг 5: Email и пароль
  String? _email;
  String? _password;
  bool _emailVerified = false;
  bool _isUnder18 = false;

  // Родительский email (если < 18)
  String? _parentEmail;
  bool _parentEmailVerified = false;

  // Getters
  String? get goal => _goal;
  String? get fullName => _fullName;
  List<String> get interests => _interests;
  String? get gender => _gender;
  DateTime? get dateOfBirth => _dateOfBirth;
  int? get age => _age;
  String? get email => _email;
  String? get password => _password;
  bool get emailVerified => _emailVerified;
  bool get isUnder18 => _isUnder18;
  String? get parentEmail => _parentEmail;
  bool get parentEmailVerified => _parentEmailVerified;

  // Setters
  void setGoal(String goal) {
    _goal = goal;
    notifyListeners();
  }

  void setPersonalInfo(String name, List<String> interests) {
    _fullName = name;
    _interests = interests;
    notifyListeners();
  }

  void setGender(String? gender) {
    _gender = gender;
    notifyListeners();
  }

  void setDateOfBirth(DateTime date, int age) {
    _dateOfBirth = date;
    _age = age;
    _isUnder18 = age < 18;
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

  void setEmailVerified(bool verified) {
    _emailVerified = verified;
    notifyListeners();
  }

  void setParentEmail(String email) {
    _parentEmail = email;
    notifyListeners();
  }

  void setParentEmailVerified(bool verified) {
    _parentEmailVerified = verified;
    notifyListeners();
  }

  // Проверка готовности к регистрации
  bool get canRegister {
    if (_fullName == null || _fullName!.isEmpty) return false;
    if (_interests.isEmpty) return false;
    if (_dateOfBirth == null) return false;
    if (_email == null || !_emailVerified) return false;
    if (_password == null || _password!.length < 6) return false;
    if (_isUnder18 && (!_parentEmailVerified || _parentEmail == null)) {
      return false;
    }
    return true;
  }

  // Получить данные для регистрации
  Map<String, dynamic> getRegistrationData() {
    return {
      'email': _email,
      'password': _password,
      'passwordRepeat': _password,
      'fullName': _fullName,
      'dateOfBirth': _dateOfBirth?.toIso8601String().split('T')[0],
      'gender': _gender,
      'interests': _interests,
      'registrationGoal': _goal,
      'parentEmail': _parentEmail,
    };
  }

  // Очистить данные
  void clear() {
    _goal = null;
    _fullName = null;
    _interests = [];
    _gender = null;
    _dateOfBirth = null;
    _age = null;
    _email = null;
    _password = null;
    _emailVerified = false;
    _isUnder18 = false;
    _parentEmail = null;
    _parentEmailVerified = false;
    notifyListeners();
  }
}
