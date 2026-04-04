import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userInfo;
  Map<String, dynamic>? _userProfile;
  String _token = "";
  bool _isLoading = false;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userInfo => _userInfo;
  Map<String, dynamic>? get userProfile => _userProfile;
  String get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _loadAuthState();
  }

  // 从本地存储加载认证状态
  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token') ?? "";
      
      if (_token.isNotEmpty) {
        ApiService.setAuthToken(_token);
        await _fetchUserInfo();
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('加载认证状态失败: $e');
    }
  }

  // 保存认证状态到本地存储
  Future<void> _saveAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token.isNotEmpty) {
        await prefs.setString('auth_token', _token);
      } else {
        await prefs.remove('auth_token');
      }
      
      // 保存或清除用户ID
      if (_userInfo != null) {
        final userId = _getUserIdFromUserInfo();
        if (userId != null) {
          await prefs.setString('user_id', userId.toString());
        } else {
          await prefs.remove('user_id');
        }
      } else {
        await prefs.remove('user_id');
      }
    } catch (e) {
      if (kDebugMode) print('保存认证状态失败: $e');
    }
  }
  
  // 从用户信息中获取ID
  int? _getUserIdFromUserInfo() {
    if (_userInfo == null) return null;
    
    // 尝试多种可能的字段名
    final id = _userInfo!['user_id'] ?? 
              _userInfo!['id'] ?? 
              _userInfo!['userId'];
    
    return int.tryParse(id.toString());
  }

  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 设置错误信息
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // 获取用户信息
  Future<void> _fetchUserInfo() async {
    try {
      final response = await _apiService.getCurrentUser();
      if (response['success']) {
        _userInfo = response['data'];
        await _fetchUserProfile();
      }
    } catch (e) {
      if (kDebugMode) print('获取用户信息失败: $e');
    }
  }

  // 获取用户档案
  Future<void> _fetchUserProfile() async {
    try {
      final response = await _apiService.getUserProfile();
      if (response['success']) {
        _userProfile = response['data'];
      }
    } catch (e) {
      if (kDebugMode) print('获取用户档案失败: $e');
    }
  }

  // 用户登录
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.loginUser(username, password);
      
      if (response['success']) {
        final data = response['data'];
        
        // 简化：假设后端直接返回token在data中
        _token = data['access_token'] ?? data['token'] ?? "";
        _userInfo = data['user'] ?? data;
        _isAuthenticated = true;
        
        if (_token.isNotEmpty) {
          ApiService.setAuthToken(_token);
        }
        await _saveAuthState();
        await _fetchUserProfile();
        
        _setLoading(false);
        return true;
      } else {
        _setError(response['error']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('登录失败，请检查网络连接');
      _setLoading(false);
      return false;
    }
  }

  // 用户注册
  Future<bool> register(String username, String password, {String? email}) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.registerUser(username, password, email: email);
      
      if (response['success']) {
        _setLoading(false);
        return true;
      } else {
        _setError(response['error']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('注册失败，请检查网络连接');
      _setLoading(false);
      return false;
    }
  }

  // 用户登出
  Future<void> logout() async {
    _isAuthenticated = false;
    _userInfo = null;
    _userProfile = null;
    _token = "";
    _errorMessage = null;
    
    ApiService.clearAuthToken();
    await _saveAuthState(); // 这会清除本地存储的用户ID
    notifyListeners();
  }

  // 刷新用户信息
  Future<void> refreshUserInfo() async {
    if (_isAuthenticated) {
      try {
        final response = await _apiService.getCurrentUser();
        if (response['success']) {
          _userInfo = response['data'];
          await _fetchUserProfile();
        }
      } catch (e) {
        if (kDebugMode) print('刷新用户信息失败: $e');
      }
      notifyListeners();
    }
  }

  // 刷新用户档案
  Future<void> refreshUserProfile() async {
    if (_isAuthenticated) {
      try {
        final response = await _apiService.getUserProfile();
        if (response['success']) {
          _userProfile = response['data'];
        }
      } catch (e) {
        if (kDebugMode) print('刷新用户档案失败: $e');
      }
      notifyListeners();
    }
  }

  // 检查token是否有效
  Future<bool> checkAuthStatus() async {
    if (_token == null) return false;

    try {
      final response = await _apiService.getCurrentUser();
      if (response['success']) {
        _userInfo = response['data'];
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    }
  }

  // 获取用户ID
  int? get userId {
    if (_userInfo != null && _userInfo!['user_id'] != null) {
      return int.tryParse(_userInfo!['user_id'].toString());
    }
    return null;
  }

  // 获取用户名
  String get username {
    if (_userInfo != null && _userInfo!['username'] != null) {
      return _userInfo!['username'].toString();
    }
    return '用户';
  }

  // 获取用户积分
  int get userPoints {
    if (_userProfile != null && _userProfile!['total_points'] != null) {
      return int.tryParse(_userProfile!['total_points'].toString()) ?? 0;
    }
    return 0;
  }

  // 获取用户等级
  int get userLevel {
    if (_userProfile != null && _userProfile!['level'] != null) {
      return int.tryParse(_userProfile!['level'].toString()) ?? 1;
    }
    return 1;
  }

  // 获取排名分数
  int get rankScore {
    if (_userProfile != null && _userProfile!['rank_score'] != null) {
      return int.tryParse(_userProfile!['rank_score'].toString()) ?? 0;
    }
    return 0;
  }

  // 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
