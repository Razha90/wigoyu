import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wigoyu/help/notification.dart';
import 'package:wigoyu/help/register.dart';
import 'package:wigoyu/model/item_product.dart';
import 'package:wigoyu/model/user_notification.dart';
import 'package:wigoyu/model/user_voucher.dart';

class User extends ChangeNotifier {
  String? _name;
  String? _userId;
  String? _saldo;
  List<String>? _history;
  String? _photo;
  String? _email;
  String? _pin;
  List<UserNotification>? _notification;
  List<int>? _voucher;
  List<int>? _historyVoucher;

  String? get name => _name;
  String? get userId => _userId;
  String? get saldo => _saldo;
  List<String>? get history => _history;
  String? get photo => _photo;
  String? get email => _email;
  String? get pin => _pin;
  List<UserNotification>? get notification => _notification;
  List<int>? get voucher => _voucher;
  List<int>? get historyVoucher => _historyVoucher;

  Future<void> login(
      String name, String userId, List<String> history, String email) async {
    _name = name;
    _userId = userId;
    _history = history;
    _email = email;
    String mySaldo = await _addSaldo(userId);
    String myPhoto = await _addImage(userId);
    String? myPin = await _addPin(userId);
    List<UserNotification>? myNotification = await _addNotidication(userId);
    List<int>? myVoucher = await _addVoucher(userId);
    List<int>? myHistoryVoucher = await _addHistoryVoucher(userId);

    saveUserToLocal(name, userId, mySaldo, history, myPhoto, email, myPin,
        myNotification, myVoucher, myHistoryVoucher);
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
    _pin = null;
    _notification = null;
    _voucher = null;
    _historyVoucher = null;
    notifyListeners();
  }

  User() {
    _loadUserFromLocal();
  }

  bool get isLoggedIn => _userId != null;

  // Menyimpan data pengguna ke SharedPreferences
  Future<void> saveUserToLocal(
      String name,
      String userId,
      String saldo,
      List<String> history,
      String photo,
      String email,
      String? pin,
      List<UserNotification>? notifications,
      List<int>? voucher,
      List<int>? historyVoucher) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('userId', userId);
    await prefs.setString('saldo', saldo);
    await prefs.setString('photo', photo);
    await prefs.setString('email', email);
    await prefs.setStringList('history', history);
    if (pin != null) {
      await prefs.setString('pin', pin);
    }
    if (notifications != null) {
      List<String> jsonNotifications =
          notifications.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList('notifications', jsonNotifications);
    }
    if (voucher != null) {
      List<String> voucherStrings = voucher.map((e) => e.toString()).toList();
      await prefs.setStringList('voucher', voucherStrings);
    }
    if (historyVoucher != null) {
      List<String> historyVoucherStrings =
          historyVoucher.map((e) => e.toString()).toList();
      await prefs.setStringList('historyVoucher', historyVoucherStrings);
    }
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
    await prefs.remove('pin');
    await prefs.remove('notifications');
    await prefs.remove('voucher');
    await prefs.remove('historyVoucher');
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
      _pin = prefs.getString('pin');

      if (prefs.containsKey('notifications')) {
        List<String>? jsonNotifications = prefs.getStringList('notifications');
        if (jsonNotifications != null) {
          _notification ??= [];
          _notification = jsonNotifications
              .map((e) => UserNotification.fromJson(jsonDecode(e)))
              .toList();
        }
      } else {
        print('No notifications found in SharedPreferences');
      }

      List<String>? jsonVouchers = prefs.getStringList('voucher');
      if (jsonVouchers != null) {
        _voucher = jsonVouchers.map((e) => int.parse(e)).toList();
      }

      List<String>? jsonHistoryVouchers = prefs.getStringList('historyVoucher');
      if (jsonHistoryVouchers != null) {
        _historyVoucher = jsonHistoryVouchers.map((e) => int.parse(e)).toList();
      }

      print(
          "Loaded user: $_name, $_userId, $_saldo, $_history, $_photo, $_email, $_pin, $_notification, $_voucher, $_historyVoucher");
      notifyListeners();
    } catch (e) {
      print("Loading user: $e");
    }
  }

  Future<String> _addSaldo(String userId) async {
    List<Users> users = await UserPreferences.getAllUsers();
    Users? user = users.firstWhere((user) => user.id == userId);
    _saldo = user.saldo;
    return _saldo!;
  }

  Future<String?> _addPin(String userId) async {
    List<Users> users = await UserPreferences.getAllUsers();
    Users? user = users.firstWhere((user) => user.id == userId);
    _pin = user.pin;
    return _pin ?? "";
  }

  Future<List<UserNotification>?> _addNotidication(String userId) async {
    List<Users> users = await UserPreferences.getAllUsers();
    Users? user = users.firstWhere((user) => user.id == userId);
    _notification = user.notifications;
    return _notification;
  }

  Future<List<int>?> _addVoucher(String userId) async {
    List<Users> users = await UserPreferences.getAllUsers();
    Users? user = users.firstWhere((user) => user.id == userId);
    List<int>? voucherIds = user.vouchers;
    _voucher = List.from(voucherIds!);
    return voucherIds;
  }

  Future<List<int>?> _addHistoryVoucher(String userId) async {
    List<Users> users = await UserPreferences.getAllUsers();
    Users? user = users.firstWhere((user) => user.id == userId);
    List<int>? voucherIds = user.historyVoucher;
    _historyVoucher = List.from(voucherIds!);
    return voucherIds;
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

  Future<void> updateNotification(
      String userId, UserNotification newNotification) async {
    final notification = NotificationService();
    try {
      List<Users> users = await UserPreferences.getAllUsers();
      Users? user = users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception("User with ID $userId not found"),
      );

      user.notifications ??= [];
      int index = user.notifications!
          .indexWhere((notif) => notif.id == newNotification.id);

      if (index != -1) {
        user.notifications![index] = newNotification;
      } else {
        user.notifications!.add(newNotification);
      }

      await UserPreferences.saveAllUsers(users);

      final prefs = await SharedPreferences.getInstance();
      List<String> jsonNotifications =
          user.notifications!.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList('notifications', jsonNotifications);

      _notification ??= [];
      _notification!.add(newNotification);

      notifyListeners();
      await notification.showNotification(
          id: int.parse(newNotification.id!),
          title: newNotification.name!,
          body: newNotification.text!);
    } catch (e) {
      print("Error updating notification: $e");
    }
  }

  Future<void> updateVoucher(String userId, int newVoucher) async {
    try {
      List<Users> users = await UserPreferences.getAllUsers();
      Users? user = users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception("User with ID $userId not found"),
      );

      user.vouchers ??= [];
      user.vouchers!.add(newVoucher);
      _voucher = List.from(user.vouchers!);

      await UserPreferences.saveAllUsers(users);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          'voucher', user.vouchers!.map((e) => e.toString()).toList());
      notifyListeners();
    } catch (e) {
      print("Error updating voucher: $e");
    }
  }

  Future<void> updateHistoryVoucher(String userId, int newVoucher) async {
    try {
      List<Users> users = await UserPreferences.getAllUsers();
      Users? user = users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception("User with ID $userId not found"),
      );
      user.historyVoucher ??= [];
      user.historyVoucher!.add(newVoucher);
      _historyVoucher = List.from(user.historyVoucher!);

      await UserPreferences.saveAllUsers(users);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'historyVoucher',
        user.historyVoucher!.map((e) => e.toString()).toList(),
      );
      notifyListeners();
    } catch (e) {
      print("Error updating history voucher: $e");
    }
  }

  // Future<void> updateHistoryVoucher(String userId, int newVoucher) async {
  //   try {
  //     List<Users> users = await UserPreferences.getAllUsers();
  //     Users? user = users.firstWhere(
  //       (user) => user.id == userId,
  //       orElse: () => throw Exception("User with ID $userId not found"),
  //     );

  //     user.historyVoucher ??= [];
  //     user.historyVoucher!.add(newVoucher);
  //     await UserPreferences.saveAllUsers(users);
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setStringList('historyVoucher',
  //         user.historyVoucher!.map((e) => e.toString()).toList());
  //     _historyVoucher = List.from(user.historyVoucher!);
  //     notifyListeners();
  //   } catch (e) {
  //     print("Error updating history voucher: $e");
  //   }
  // }

  Future<void> deleteVoucher(String userId, int voucherToDelete) async {
    try {
      List<Users> users = await UserPreferences.getAllUsers();
      Users? user = users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception("User with ID $userId not found"),
      );
      if (!user.vouchers!.contains(voucherToDelete)) {
        return;
      }
      user.vouchers!.remove(voucherToDelete);
      await UserPreferences.saveAllUsers(users);
      _voucher!.remove(voucherToDelete);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          'voucher', _voucher!.map((e) => e.toString()).toList());
      notifyListeners();
      print("Voucher item deleted successfully for user ID: $userId");
    } catch (e) {
      print("Error deleting voucher: $e");
      rethrow;
    }
  }

  Future<void> updatePin(String userId, String pin) async {
    try {
      List<Users> users = await UserPreferences.getAllUsers();
      Users? user = users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception("User with ID $userId not found"),
      );
      user.pin = pin;
      await UserPreferences.saveAllUsers(users);
      _pin = pin;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pin', pin);
      notifyListeners();
    } catch (e) {
      // rethrow;
      throw Exception("Error updating pin: $e");
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
      print("Error updating image: $e");
    }
  }

  Future<void> updateSaldo(String userId, String saldo) async {
    try {
      print("Updating saldo for user ID: $userId");
      List<Users> users = await UserPreferences.getAllUsers();
      Users? user = users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception("User with ID $userId not found"),
      );
      user.saldo = saldo;
      await UserPreferences.saveAllUsers(users);
      _saldo = saldo;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saldo', saldo);
      notifyListeners();
    } catch (e) {
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

  Future<void> openNotification(String userId, String notificationId) async {
    try {
      List<Users> users = await UserPreferences.getAllUsers();
      Users? user = users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception("User with ID $userId not found"),
      );
      int index =
          user.notifications!.indexWhere((notif) => notif.id == notificationId);
      print("index: $index");
      if (index == -1) {
        return;
      }
      user.notifications![index].open = true;
      await UserPreferences.saveAllUsers(users);
      _notification!.firstWhere((notif) => notif.id == notificationId).open =
          true;
      final prefs = await SharedPreferences.getInstance();
      List<String> jsonNotifications =
          user.notifications!.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList('notifications', jsonNotifications);
      notifyListeners();
    } catch (e) {
      print("Error opening notification: $e");
      rethrow;
    }
  }

  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      List<Users> users = await UserPreferences.getAllUsers();
      Users? user = users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception("User with ID $userId not found"),
      );

      int index =
          user.notifications!.indexWhere((notif) => notif.id == notificationId);
      if (index == -1) {
        return;
      }
      user.notifications!.removeAt(index);
      await UserPreferences.saveAllUsers(users);

      _notification!.removeWhere((notif) => notif.id == notificationId);
      final prefs = await SharedPreferences.getInstance();
      List<String> jsonNotifications =
          user.notifications!.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList('notifications', jsonNotifications);
      notifyListeners();
    } catch (e) {
      print("Error deleting notification: $e");
      rethrow;
    }
  }

  Future<void> deleteAllNotifications(String userId) async {
    try {
      List<Users> users = await UserPreferences.getAllUsers();
      Users? user = users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception("User with ID $userId not found"),
      );
      user.notifications!.clear();
      await UserPreferences.saveAllUsers(users);
      _notification!.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notifications');
      notifyListeners();
    } catch (e) {
      print("Error deleting all notifications: $e");
      rethrow;
    }
  }
}
