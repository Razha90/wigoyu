import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wigoyu/help/register.dart';

class User extends ChangeNotifier {
  String? _name;
  String? _userId;
  String? _saldo;
  List<String>? _history;
  String? _photo;
  String? _email;

  String? get name => _name;
  String? get userId => _userId;
  String? get saldo => _saldo;
  List<String>? get history => _history;
  String? get photo => _photo;
  String? get email => _email;

  // Metode untuk login dan menyimpan data pengguna
  void login(
      String name, String userId, List<String> history, String email) async {
    _name = name;
    _userId = userId;
    _history = history;
    _email = email;
    String mySaldo = await _addSaldo(userId);
    String myPhoto = await _addImage(userId);
    saveUserToLocal(name, userId, mySaldo, history, myPhoto, email);

    notifyListeners();
  }

  void logout() {
    _name = null;
    _userId = null;
    clearUserFromLocal();
    _history = null;
    _saldo = null;
    _photo = null;
    _email = null;
    notifyListeners();
  }

  User() {
    _loadUserFromLocal();
  }

  bool get isLoggedIn => _userId != null;

  // Menyimpan data pengguna ke SharedPreferences
  Future<void> saveUserToLocal(String name, String userId, String saldo,
      List<String> history, String photo, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('userId', userId);
    await prefs.setString('saldo', saldo);
    await prefs.setString('photo', photo);
    await prefs.setString('email', email);
    await prefs.setStringList('history', history);
  }

  // Menghapus data pengguna dari SharedPreferences
  Future<void> clearUserFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('name');
    await prefs.remove('userId');
    await prefs.remove('saldo');
    await prefs.remove('history');
    await prefs.remove('photo');
    await prefs.remove('email');
  }

  // Memuat data pengguna dari SharedPreferences
  Future<void> _loadUserFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _name = prefs.getString('name');
      _userId = prefs.getString('userId');
      _saldo = prefs.getString('saldo');
      _photo = prefs.getString('photo');
      _history = prefs.getStringList('history');
      _email = prefs.getString('email');

      print("Loaded user: $_name, $_userId, $_saldo, $_history");
      notifyListeners();
    } catch (e) {
      print("Eoading user: $e");
    }
  }

  Future<String> _addSaldo(String userId) async {
    List<Users> users = await UserPreferences.getAllUsers();
    Users? user = users.firstWhere((user) => user.id == userId);
    _saldo = user.saldo;
    return _saldo!;
  }

  Future<String> _addImage(String userId) async {
    List<Users> users = await UserPreferences.getAllUsers();
    Users? user = users.firstWhere((user) => user.id == userId);
    _photo = user.photo;
    return _photo!;
  }

  Future<void> updateHistory(String userId, String history) async {
    try {
      List<Users> users = await UserPreferences.getAllUsers();
      Users? user = users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception("User with ID $userId not found"),
      );
      if (user.history!.contains(history)) {
        return;
      }
      user.history!.add(history);
      if (user.history!.length > 10) {
        user.history!.removeAt(0);
        _history!.removeAt(0);
      }
      await UserPreferences.saveAllUsers(users);
      _history!.add(history);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('history', _history!);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateImage(String userId, String image) async {
    try {
      List<Users> users = await UserPreferences.getAllUsers();
      Users? user = users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception("User with ID $userId not found"),
      );
      user.photo = image;
      await UserPreferences.saveAllUsers(users);
      _photo = image;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('photo', image);
      notifyListeners();
    } catch (e) {
      // rethrow;
      print("Error updating image: $e");
    }
  }

  Future<void> updateName(String userId, String name) async {
    try {
      List<Users> users = await UserPreferences.getAllUsers();
      Users? user = users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception("User with ID $userId not found"),
      );
      user.name = name;
      await UserPreferences.saveAllUsers(users);
      _name = name;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', name);
      notifyListeners();
    } catch (e) {
      // rethrow;
      print("Error updating image: $e");
    }
  }

  Future<void> deleteHistory(String userId, String historyToDelete) async {
    try {
      List<Users> users = await UserPreferences.getAllUsers();
      Users? user = users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception("User with ID $userId not found"),
      );
      if (!user.history!.contains(historyToDelete)) {
        return; // Jika tidak ada, hentikan eksekusi
      }
      user.history!.remove(historyToDelete);
      await UserPreferences.saveAllUsers(users);
      _history!.remove(historyToDelete);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('history', _history!);
      notifyListeners();
      print("History item deleted successfully for user ID: $userId");
    } catch (e) {
      print("Error deleting history: $e");
      rethrow;
    }
  }
}
