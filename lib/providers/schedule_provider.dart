import 'package:flutter/material.dart';
import '../models/schedule_slot_model.dart';
import '../services/schedule_service.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleService _service = ScheduleService();

  List<ScheduleSlotModel> _slots = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ScheduleSlotModel> get slots => _slots;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSchedule() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _slots = await _service.getMySchedule();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _slots = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSlot(
    int dayOfWeek,
    String startTime,
    String endTime,
  ) async {
    try {
      final data = {
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
      };

      final slot = await _service.createScheduleSlot(data);
      _slots.add(slot);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSlot(int id) async {
    try {
      await _service.deleteScheduleSlot(id);
      _slots.removeWhere((slot) => slot.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
