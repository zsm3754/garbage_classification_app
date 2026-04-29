import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class LocalDataService {
  static const String _disposalRecordsKey = 'disposal_records';
  static const String _favoritesKey = 'favorites';
  static const String _searchHistoryKey = 'search_history';
  static const String _achievementsKey = 'achievements';

  // 获取所有垃圾分类数据
  static List<GarbageCategory> getAllGarbageCategories() {
    return [
      GarbageCategory(
        id: '1',
        name: '有害垃圾',
        description: '对人体健康或自然环境造成直接或潜在危害的废弃物',
        color: 'FF0000', // 红色
        examples: ['电池', '灯泡', '荧光灯', '药物', '油漆', '杀虫剂'],
        tips: ['请放入有害垃圾专用桶', '不要混合其他垃圾', '大型有害垃圾需单独处理'],
      ),
      GarbageCategory(
        id: '2',
        name: '可回收物',
        description: '适宜回收、可循环利用的废弃物',
        color: '0000FF', // 蓝色
        examples: ['纸张', '纸板', '塑料瓶', '玻璃瓶', '易拉罐', '金属罐'],
        tips: ['请压扁后放入可回收物桶', '玻璃需要单独分类', '保持清洁可提高回收价值'],
      ),
      GarbageCategory(
        id: '3',
        name: '湿垃圾',
        description: '易腐烂的、含有有机物的生活废弃物',
        color: 'FFA500', // 橙色
        examples: ['果皮', '菜叶', '食物残渣', '骨头', '茶叶渣', '花草'],
        tips: ['沥干水分后投放', '不能混入塑料或其他杂物', '夏天容易发酵请及时投放'],
      ),
      GarbageCategory(
        id: '4',
        name: '干垃圾',
        description: '不属于前三类的生活废弃物',
        color: '808080', // 灰色
        examples: ['烟头', '陶瓷碎片', '橡皮擦', '胶带', '一次性餐具', '衣服'],
        tips: ['不知道分类时可投放到干垃圾', '尽量保持干燥', '大型干垃圾需要分解'],
      ),
    ];
  }

  // 保存投放记录
  static Future<void> saveDisposalRecord(DisposalRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = prefs.getStringList(_disposalRecordsKey) ?? [];
    records.add(jsonEncode(record.toJson()));
    await prefs.setStringList(_disposalRecordsKey, records);
  }

  // 获取所有投放记录
  static Future<List<DisposalRecord>> getAllDisposalRecords(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final records = prefs.getStringList(_disposalRecordsKey) ?? [];
    
    return records
        .map((record) => DisposalRecord.fromJson(jsonDecode(record)))
        .where((record) => record.userId == userId)
        .toList();
  }

  // 删除投放记录
  static Future<void> deleteDisposalRecord(String recordId) async {
    final prefs = await SharedPreferences.getInstance();
    final records = prefs.getStringList(_disposalRecordsKey) ?? [];
    
    records.removeWhere((record) {
      final decoded = DisposalRecord.fromJson(jsonDecode(record));
      return decoded.id == recordId;
    });
    
    await prefs.setStringList(_disposalRecordsKey, records);
  }

  // 添加收藏
  static Future<void> addFavorite(Favorite favorite) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    favorites.add(jsonEncode(favorite.toJson()));
    await prefs.setStringList(_favoritesKey, favorites);
  }

  // 获取用户的收藏
  static Future<List<Favorite>> getUserFavorites(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    
    return favorites
        .map((fav) => Favorite.fromJson(jsonDecode(fav)))
        .where((fav) => fav.itemId.startsWith(userId))
        .toList();
  }

  // 删除收藏
  static Future<void> removeFavorite(String favoriteId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    
    favorites.removeWhere((fav) {
      final decoded = Favorite.fromJson(jsonDecode(fav));
      return decoded.id == favoriteId;
    });
    
    await prefs.setStringList(_favoritesKey, favorites);
  }

  // 添加搜索历史
  static Future<void> addSearchHistory(String userId, String query) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_searchHistoryKey}_$userId';
    final histories = prefs.getStringList(key) ?? [];
    
    final history = SearchHistory(
      query: query,
      searchDate: DateTime.now(),
    );
    
    histories.insert(0, jsonEncode(history.toJson()));
    if (histories.length > 20) {
      histories.removeLast();
    }
    
    await prefs.setStringList(key, histories);
  }

  // 获取搜索历史
  static Future<List<String>> getSearchHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_searchHistoryKey}_$userId';
    final histories = prefs.getStringList(key) ?? [];
    
    return histories
        .map((history) => SearchHistory.fromJson(jsonDecode(history)))
        .map((history) => history.query)
        .toList();
  }

  // 清空搜索历史
  static Future<void> clearSearchHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_searchHistoryKey}_$userId';
    await prefs.remove(key);
  }

  // 获取用户成就
  static Future<List<Achievement>> getUserAchievements(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_achievementsKey}_$userId';
    final achievements = prefs.getStringList(key) ?? [];
    
    return achievements
        .map((achievement) {
          final json = jsonDecode(achievement) as Map<String, dynamic>;
          return Achievement(
            id: json['id'] as String,
            name: json['name'] as String,
            description: json['description'] as String,
            icon: json['icon'] as String,
            unlockedDate: DateTime.parse(json['unlockedDate'] as String),
          );
        })
        .toList();
  }


  // 获取统计数据（从数据库获取，不再本地计算）
  static Future<Map<String, dynamic>> getStatistics(String userId) async {
    final records = await getAllDisposalRecords(userId);
    
    final totalDisposals = records.length;
    final totalWeight = records.fold(0.0, (sum, r) => sum + r.weight);

    final categoryStats = <String, int>{};
    for (var record in records) {
      categoryStats[record.categoryName] =
          (categoryStats[record.categoryName] ?? 0) + 1;
    }

    return {
      'totalDisposals': totalDisposals,
      'totalWeight': totalWeight,
      'categoryStats': categoryStats,
    };
  }

}
