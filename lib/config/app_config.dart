/// 应用配置常量
class AppConfig {
  // ====================== 后端API配置 ======================
  // 请根据你的实际情况修改这里

  // 方式1: 使用localhost（如果前后端在同一台电脑）
  static const String apiBaseUrl = "http://192.168.43.23:8000";

  // 方式2: 使用你的电脑IP地址（如果要在其他设备上访问）
  // 获取IP地址: 在Windows上运行 ipconfig
  // 假设你的电脑IP是 192.168.1.100，则改为:
  // static const String apiBaseUrl = "http://192.168.1.100:8000";

  // FastAPI路由
  static const String recognizeEndpoint = "/api/garbage/recognize";
  static const String categoryEndpoint = "/api/category/all";
  static const String quizEndpoint = "/api/quiz/all";
  static const String userEndpoint = "/api/user";

  // 请求超时时间（秒）
  static const int requestTimeout = 30;

  // ====================== 应用配置 ======================
  static const String appName = "绿意分类";
  static const String appVersion = "1.0.0";

  // ====================== 本地存储Key ======================
  static const String keyUserId = "user_id";
  static const String keyUsername = "username";
  static const String keyToken = "token";
  static const String keySearchHistory = "search_history";

  // ====================== 垃圾分类映射 ======================
  static const Map<String, String> garbageCategoryMap = {
    "recyclable": "可回收垃圾",
    "kitchen": "厨余垃圾",
    "harmful": "有害垃圾",
    "other": "其他垃圾",
  };
}
