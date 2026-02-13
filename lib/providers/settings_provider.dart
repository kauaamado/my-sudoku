import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _errorLimitEnabled = true;
  bool _visualAidEnabled = true;

  // Stats per difficulty: { 'easy': { 'won': 0, 'played': 0, 'bestTime': null } }
  Map<String, Map<String, dynamic>> _stats = {
    'easy': {'won': 0, 'played': 0, 'bestTime': null},
    'normal': {'won': 0, 'played': 0, 'bestTime': null},
    'hard': {'won': 0, 'played': 0, 'bestTime': null},
  };

  bool get isDarkMode => _isDarkMode;
  bool get errorLimitEnabled => _errorLimitEnabled;
  bool get visualAidEnabled => _visualAidEnabled;
  Map<String, Map<String, dynamic>> get stats => _stats;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _errorLimitEnabled = prefs.getBool('errorLimitEnabled') ?? true;
    _visualAidEnabled = prefs.getBool('visualAidEnabled') ?? true;

    final statsJson = prefs.getString('stats');
    if (statsJson != null) {
      final decoded = jsonDecode(statsJson) as Map<String, dynamic>;
      _stats = decoded.map(
        (key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)),
      );
    }
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> toggleErrorLimit() async {
    _errorLimitEnabled = !_errorLimitEnabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('errorLimitEnabled', _errorLimitEnabled);
  }

  Future<void> toggleVisualAid() async {
    _visualAidEnabled = !_visualAidEnabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('visualAidEnabled', _visualAidEnabled);
  }

  Future<void> recordGame({
    required String difficulty,
    required bool won,
    required int timeSeconds,
  }) async {
    final diff = _stats[difficulty]!;
    diff['played'] = (diff['played'] as int) + 1;
    if (won) {
      diff['won'] = (diff['won'] as int) + 1;
      final best = diff['bestTime'] as int?;
      if (best == null || timeSeconds < best) {
        diff['bestTime'] = timeSeconds;
      }
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stats', jsonEncode(_stats));
  }

  String formatTime(int? seconds) {
    if (seconds == null) return '--:--';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double winRate(String difficulty) {
    final played = _stats[difficulty]!['played'] as int;
    if (played == 0) return 0;
    return (_stats[difficulty]!['won'] as int) / played;
  }
}
