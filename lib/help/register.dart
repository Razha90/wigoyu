import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:wigoyu/model/user_notification.dart';
import 'package:wigoyu/model/user_voucher.dart';

class UserPreferences {
  static const String _userKey = 'users';

  // Generate ID unik
  static Future<String> generateUniqueId() async {
    // final prefs = await SharedPreferences.getInstance();
    List<Users> users = await getAllUsers();

    String newId;
    do {
      newId = Random()
          .nextInt(100000)
          .toString()
          .padLeft(5, '0'); // Random ID 5 digit
    } while (users.any((user) => user.id == newId));

    return newId;
  }

  // Generate token random
  static Future<String> generateUniqueToken() async {
    // final prefs = await SharedPreferences.getInstance();
    List<Users> users = await getAllUsers();

    String newToken;
    do {
      newToken = Random()
          .nextInt(90000)
          .toString()
          .padLeft(5, '0'); // Random token 5 digit
    } while (users.any((user) => user.token == newToken));

    return newToken;
  }

  // Simpan data pengguna baru
  static Future<void> registerUser(Users user) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> userList = prefs.getStringList(_userKey) ?? [];

    userList.add(jsonEncode(user.toMap()));

    await prefs.setStringList(_userKey, userList);
  }

  static Future<List<Users>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> userList = prefs.getStringList(_userKey) ?? [];

    return userList
        .map((userString) {
          try {
            return Users.fromMap(jsonDecode(userString));
          } catch (e) {
            print('Error decoding user: $e');
            return null; // Jika decoding gagal, kembalikan null
          }
        })
        .whereType<Users>()
        .toList(); // Hapus nilai null dari daftar
  }

  static Future<void> saveAllUsers(List<Users> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> userList =
          users.map((user) => jsonEncode(user.toMap())).toList();
      await prefs.setStringList(_userKey, userList);
    } catch (e) {
      throw Exception('Error saving users: $e');
    }
  }

  static Future<void> deleteAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(
        _userKey); // Menghapus semua data yang tersimpan dengan kunci '_userKey'
  }
}

class Users {
  String id;
  String? name;
  String? email;
  String? phone;
  String? password;
  String? referral;
  String token;
  String? verified;
  String? saldo;
  List<String>? history;
  String? photo;
  String? pin;
  List<UserNotification>? notifications;
  List<int>? vouchers;

  Users({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.password,
    required this.token,
    this.verified,
    this.saldo,
    this.referral,
    this.history,
    this.photo,
    this.pin,
    this.notifications,
    this.vouchers,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'token': token,
      'verified': verified,
      'saldo': saldo,
      'referral': referral,
      'history': history != null ? jsonEncode(history) : null,
      'photo': photo,
      'pin': pin,
      'notifications': notifications != null
          ? jsonEncode(notifications!.map((n) => n.toJson()).toList())
          : null,
      'vouchers': vouchers != null ? jsonEncode(vouchers) : null,
    };
  }

  // Membuat User dari Map (saat diambil dari SharedPreferences)
  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      password: map['password'],
      token: map['token'],
      verified: map['verified'],
      saldo: map['saldo'],
      referral: map['referral'],
      history: map['history'] != null
          ? List<String>.from(jsonDecode(map['history']))
          : null,
      photo: map['photo'],
      pin: map['pin'],
      notifications: map['notifications'] != null
          ? List<UserNotification>.from(jsonDecode(map['notifications'])
              .map((n) => UserNotification.fromJson(n)))
          : null,
      vouchers: map['vouchers'] != null
          ? List<int>.from(jsonDecode(map['vouchers']))
          : null,
    );
  }
}
