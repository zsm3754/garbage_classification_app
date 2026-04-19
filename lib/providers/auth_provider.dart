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
  String? get avatarUrl => _userProfile?['avatar_url'];

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
        // Only set authenticated if user info was successfully loaded
        if (_userInfo != null) {
          _isAuthenticated = true;
          // 加载实际的投放次数
          await _loadDisposalCount();
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('加载认证状态失败: $e');
    }
  }

  // 加载投放次数
  Future<void> _loadDisposalCount() async {
    try {
      final actualCount = await getActualDisposalCount();
      _cachedDisposalCount = actualCount;
    } catch (e) {
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
        
        // Handle backend response format: data['data'] contains the actual response
        final backendData = data['data'] ?? data;
        
        // Use user_id as token for now (since backend doesn't return a separate token)
        _token = backendData['user_id']?.toString() ?? "";
        _userInfo = backendData;
        // Ensure username is saved in userInfo
        if (_userInfo != null && _userInfo!['username'] == null) {
          _userInfo!['username'] = username;
        }
        _isAuthenticated = true;
        
        
        if (_token.isNotEmpty) {
          ApiService.setAuthToken(_token);
        }
        await _saveAuthState();
        await _fetchUserProfile();
        // 加载实际的投放次数
        await _loadDisposalCount();
        
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

  // 获取投放次数
  int get disposalCount {
    // 由于后端没有disposal_count字段，我们需要缓存实际投放次数
    return _cachedDisposalCount;
  }

  // 缓存的投放次数
  int _cachedDisposalCount = 0;

  // 获取实际投放次数（通过计算投放记录）
  Future<int> getActualDisposalCount() async {
    try {
      final apiService = ApiService();
      final records = await apiService.getDisposalRecords();
      return records.length;
    } catch (e) {
      debugPrint('获取实际投放次数失败: $e');
      return 0;
    }
  }

  // 获取用户等级
  int get userLevel {
    // 根据积分计算等级：每30分升一级
    final points = userPoints;
    return (points ~/ 30) + 1; // 0-29分=1级，30-59分=2级，以此类推
  }

  // 获取排名分数
  int get rankScore {
    if (_userProfile != null && _userProfile!['rank_score'] != null) {
      return int.tryParse(_userProfile!['rank_score'].toString()) ?? 0;
    }
    return 0;
  }

  // 真实排名相关属性
  int _realRanking = 0;
  int _totalUsers = 0;
  bool _isLoadingRanking = false;

  // 获取真实排名
  int get realRanking => _realRanking;
  int get totalUsers => _totalUsers;
  bool get isLoadingRanking => _isLoadingRanking;

  // 获取排名显示文本
  String get rankingText {
    if (_realRanking > 0 && _realRanking != 999) {
      return "第$_realRanking名";
    } else if (_realRanking == 999) {
      return "第999名";
    }
    return "排名计算中...";
  }

  // 加载真实排名
  Future<void> loadRealRanking() async {
    if (_isLoadingRanking) return;
    
    _isLoadingRanking = true;
    notifyListeners();

    try {
      if (userId == null) {
          _realRanking = 999;
        return;
      }
      
      final currentUserId = userId.toString();
      
      final response = await ApiService.getUserRanking(userId: currentUserId);
      
      if (response['success'] == true) {
        final data = response['data'];
        
        // 根据你的接口格式获取排名
        _realRanking = data['rank'] ?? 999;
        
        // 更新用户积分（如果后端返回了积分）
        if (data['total_points'] != null) {
          if (_userProfile == null) _userProfile = {};
          _userProfile!['total_points'] = data['total_points'];
        }
      } else {
        _realRanking = 999; // 设置默认排名
      }
    } catch (e) {
      _realRanking = 999;
    } finally {
      _isLoadingRanking = false;
      notifyListeners();
    }
  }

  // 刷新用户数据（包括积分和投放次数）
  Future<void> refreshUserData() async {
    try {
      // 重新加载用户资料以获取最新的积分
      await refreshUserProfile();
      
      // 获取实际投放次数并缓存
      final actualCount = await getActualDisposalCount();
      _cachedDisposalCount = actualCount;
      
      notifyListeners();
      
      // 同时刷新排名
      await loadRealRanking();
    } catch (e) {
    }
  }

  // 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Update avatar URL directly
  void updateAvatarUrl(String avatarUrl) {
    if (_userProfile == null) {
      _userProfile = {};
    }
    _userProfile!['avatar_url'] = avatarUrl;
    notifyListeners();
  }
}
