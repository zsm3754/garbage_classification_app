import 'package:flutter/material.dart';
import '../services/api_service.dart';

// UserProvider：管理用户认证状态
class UserProvider extends ChangeNotifier {
  String? _userId;
  String? _username;
  String? _token;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _statistics;
  List<Map<String, dynamic>> _achievements = [];

  String? get userId => _userId;
  String? get username => _username;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get statistics => _statistics;
  List<Map<String, dynamic>> get achievements => _achievements;

  final ApiService _apiService = ApiService();

  Future<bool> register(String username, String password) async {
    try {
      final response = await _apiService.registerUser(username, password);
      if (response['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.loginUser(username, password);
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        // Handle backend response format: data['data'] contains the actual response
        final backendData = data['data'] ?? data;
        _userId = backendData['user_id']?.toString();
        _username = username;
        _token = backendData['user_id']?.toString(); // Using user_id as token for now
        _isLoggedIn = true;
        debugPrint('用户登录成功 - ID: $_userId, 用户名: $_username');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('登录失败: $e');
      return false;
    }
  }

  Future<void> loadStatistics() async {
    try {
      if (_userId != null) {
        final response = await _apiService.getUserProfile();
        if (response['success'] == true) {
          _statistics = response['data'];
          debugPrint('统计数据加载成功: $_statistics');
        } else {
          debugPrint('统计数据加载失败: ${response['error']}');
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load statistics error: $e');
    }
  }

  // 刷新统计数据（用于投放后更新）
  Future<void> refreshStatistics() async {
    debugPrint('=== 刷新统计数据开始 ===');
    await loadStatistics();
    debugPrint('=== 刷新统计数据完成 ===');
    debugPrint('当前统计数据: $_statistics');
  }

  Future<void> loadAchievements() async {
    try {
      if (_userId != null) {
        final response = await _apiService.getUserProfile();
        _achievements = [];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load achievements error: $e');
    }
  }

  void logout() {
    _userId = null;
    _username = null;
    _token = null;
    _isLoggedIn = false;
    _statistics = null;
    _achievements = [];
    notifyListeners();
  }
}

// QuizProvider：管理每日问卷
class QuizProvider extends ChangeNotifier {
  Map<String, dynamic>? _currentQuiz;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get currentQuiz => _currentQuiz;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  Future<void> loadTodayQuiz() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getTodayQuiz();
      _currentQuiz = response;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitAnswer(int quizId, String selectedOption) async {
    try {
      final response = await _apiService.submitQuizAnswer(
        quizId,
        selectedOption,
      );
      return response['success'] == true;
    } catch (e) {
      debugPrint('Submit answer error: $e');
      return false;
    }
  }
}

// SearchProvider：管理搜索功能
class SearchProvider extends ChangeNotifier {
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  List<String> _searchHistory = [];

  List<dynamic> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get searchHistory => _searchHistory;

  final ApiService _apiService = ApiService();

  Future<void> search(String keyword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.searchGarbage(keyword);
      if (response is Map && response['success'] == true) {
        _searchResults = response['data'] ?? [];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _searchResults = [];
    _error = null;
    notifyListeners();
  }

  // Save search history only when user explicitly submits
  Future<void> saveSearchHistory(String userId, String keyword) async {
    try {
      await _apiService.addSearchHistory(keyword, userId: userId);
    } catch (e) {
      print('Failed to save search history: $e');
    }
  }

  // Load search history from backend
  Future<void> loadSearchHistory({String? userId}) async {
    try {
      final history = await _apiService.getSearchHistory(userId: userId);
      _searchHistory = List<String>.from(history.map((item) => item.toString()));
      notifyListeners();
    } catch (e) {
      print('Failed to load search history: $e');
    }
  }

  // Clear search history
  Future<void> clearHistory(String userId) async {
    _searchHistory.clear();
    notifyListeners();
    
    // Also clear from server
    try {
      await ApiService.clearAllSearchHistory(userId: userId);
    } catch (e) {
      print('Failed to clear server search history: $e');
    }
  }
}

// DisposalRecordProvider：管理垃圾处理记录
class DisposalRecordProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> addRecord(Map<String, dynamic> record) async {
    try {
      _records.add(record);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteRecord(dynamic recordId) async {
    try {
      _records.removeWhere((record) => record['id'] == recordId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 从 API 加载记录
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}

// GarbageCategoryProvider：管理垃圾分类
class GarbageCategoryProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _categories = [];
  Map<String, dynamic>? _selectedCategory;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get categories => _categories;
  Map<String, dynamic>? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getAllCategories();
      if (response['success']) {
        _categories = List<Map<String, dynamic>>.from(response['data']);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCategoryByName(String name) async {
    try {
      // 如果分类列表为空，先加载
      if (_categories.isEmpty) {
        await loadCategories();
      }
      
      for (var category in _categories) {
        if (category['name'] == name) {
          _selectedCategory = category;
          notifyListeners();
          return;
        }
      }
      
      // 如果没找到，设置一个默认的分类
      _selectedCategory = {
        'name': name,
        'description': '$name的详细信息',
        'color': _getCategoryColor(name),
        'icon': _getCategoryIcon(name),
      };
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Color _getCategoryColor(String name) {
    switch (name) {
      case '可回收物':
        return Colors.blue;
      case '有害垃圾':
        return Colors.red;
      case '湿垃圾':
      case '厨余垃圾':
        return Colors.orange;
      case '干垃圾':
      case '其他垃圾':
        return Colors.grey;
      default:
        return Colors.green;
    }
  }
  
  IconData _getCategoryIcon(String name) {
    switch (name) {
      case '可回收物':
        return Icons.recycling;
      case '有害垃圾':
        return Icons.warning;
      case '湿垃圾':
      case '厨余垃圾':
        return Icons.compost;
      case '干垃圾':
      case '其他垃圾':
        return Icons.delete;
      default:
        return Icons.info;
    }
  }
}

// FavoritesProvider：管理收藏
class FavoritesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isFavorited(dynamic itemId) {
    return _favorites.any((item) => item['id'] == itemId);
  }

  void addFavorite(Map<String, dynamic> item) {
    if (!_favorites.any((f) => f['id'] == item['id'])) {
      _favorites.add(item);
      notifyListeners();
    }
  }

  void removeFavorite(dynamic id) {
    _favorites.removeWhere((item) => item['id'] == id);
    notifyListeners();
  }

  void clearFavorites() {
    _favorites = [];
    notifyListeners();
  }
}
