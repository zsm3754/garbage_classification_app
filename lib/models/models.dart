// 垃圾分类模型
class GarbageCategory {
  final String id;
  final String name;
  final String description;
  final String color;
  final List<String> examples;
  final List<String> tips;

  GarbageCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.examples,
    required this.tips,
  });
}

// 投放记录模型
class DisposalRecord {
  final String id;
  final String userId;
  final String categoryId;
  final String categoryName;
  final double weight;
  final DateTime timestamp;
  final String location;

  DisposalRecord({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.weight,
    required this.timestamp,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'weight': weight,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
    };
  }

  factory DisposalRecord.fromJson(Map<String, dynamic> json) {
    return DisposalRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      weight: json['weight'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: json['location'] as String,
    );
  }
}

// 用户成就模型
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final DateTime unlockedDate;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.unlockedDate,
  });
}

// 用户收藏模型
class Favorite {
  final String id;
  final String itemId;
  final String itemType; // 'garbage' 或 'article'
  final String itemName;
  final DateTime createdDate;

  Favorite({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.itemName,
    required this.createdDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'itemType': itemType,
      'itemName': itemName,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      itemType: json['itemType'] as String,
      itemName: json['itemName'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
    );
  }
}

// 搜索历史模型
class SearchHistory {
  final String query;
  final DateTime searchDate;

  SearchHistory({
    required this.query,
    required this.searchDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'searchDate': searchDate.toIso8601String(),
    };
  }

  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    return SearchHistory(
      query: json['query'] as String,
      searchDate: DateTime.parse(json['searchDate'] as String),
    );
  }
}

// 知识文章模型
class KnowledgeArticle {
  final String id;
  final String title;
  final String content;
  final String category;
  final String imageUrl;

  KnowledgeArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.imageUrl,
  });
}
