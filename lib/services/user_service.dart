import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  String? _currentUserId;
  final Map<String, UserData> _users = {};

  bool get isLoggedIn => _currentUserId != null;

  // Initialize session from storage
  Future<void> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');
  }

  // Save session
  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    _currentUserId = userId;
  }

  // Clear session
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    _currentUserId = null;
  }

  Future<bool> login(String email, String password) async {
    if (_users.containsKey(email) && _users[email]!.password == password) {
      await _saveSession(email);
      return true;
    }
    return false;
  }

  Future<void> registerUser(
    String email,
    String password, {
    String? name,
  }) async {
    _users[email] = UserData(email: email, password: password, name: name);
    await _saveSession(email);
  }

  String? get currentUserId => _currentUserId;
}

class UserData {
  final String email;
  final String password;
  final String? name;

  UserData({required this.email, required this.password, this.name});
}
