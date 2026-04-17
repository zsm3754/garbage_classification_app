import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/providers.dart';
import '../../services/api_service.dart';

class SearchPageComplete extends StatefulWidget {
  const SearchPageComplete({super.key});

  @override
  State<SearchPageComplete> createState() => _SearchPageCompleteState();
}

class _SearchPageCompleteState extends State<SearchPageComplete> {
  final TextEditingController _searchController = TextEditingController();
  bool _showHistory = true;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performRealTimeSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    // Only call search API, don't save history
    await context.read<SearchProvider>().search(query);
    
    setState(() {
      _showHistory = false;
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    
    final userId = context.read<UserProvider>().userId;
    
    // Call search API first
    await context.read<SearchProvider>().search(query);
    
    // Then save history only when user explicitly submits
    await context.read<SearchProvider>().saveSearchHistory(userId, query);
    
    setState(() {
      _showHistory = false;
    });
  }

  /// 从相机拍照
  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        _recognizeGarbageFromImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("拍照失败: $e")),
      );
    }
  }

  /// 从相册选择图片
  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        _recognizeGarbageFromImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("选择图片失败: $e")),
      );
    }
  }

  /// 识别图片中的垃圾 - 调用后端YOLO模型
  Future<void> _recognizeGarbageFromImage() async {
    if (_selectedImage == null) return;

    // 显示识别中的对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("识别中..."),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text("正在连接到后端服务进行分析..."),
          ],
        ),
      ),
    );

    try {
      // 调用后端API进行识别
      final result = await ApiService.recognizeGarbage(_selectedImage!.path);

      if (!mounted) return;
      Navigator.pop(context); // 关闭加载对话框

      if (result['success'] == true) {
        // 显示后端返回的识别结果
        _showRecognitionResults({
          'class_en': result['class_en'],
          'class_cn': result['class_cn'],
          'confidence': result['confidence'],
          'image_name': result['image_name'],
        });
      } else {
        // 识别失败
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("识别失败: ${result['msg']}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("错误: ${e.toString()}")),
      );
    }

    // 清空选择的图片
    setState(() {
      _selectedImage = null;
    });
  }

  /// 显示识别结果 - 支持后端返回的格式和本地识别格式
  void _showRecognitionResults(dynamic items) {
    // 处理后端返回的 Map 格式
    if (items is Map<String, dynamic>) {
      final classCn = items['class_cn'] ?? '未知';
      final classEn = items['class_en'] ?? '';
      final confidence = (items['confidence'] ?? 0) as num;
      
      // 根据垃圾类型选择颜色
      Color categoryColor = Colors.grey;
      IconData categoryIcon = Icons.delete;
      
      if (classCn.contains('有害')) {
        categoryColor = Colors.red;
        categoryIcon = Icons.dangerous;
      } else if (classCn.contains('可回收')) {
        categoryColor = Colors.blue;
        categoryIcon = Icons.recycling;
      } else if (classCn.contains('厨余') || classCn.contains('湿')) {
        categoryColor = Colors.orange;
        categoryIcon = Icons.compost;
      } else if (classCn.contains('干') || classCn.contains('其他')) {
        categoryColor = Colors.grey[600]!;
        categoryIcon = Icons.archive;
      }
      
      // 置信度描述
      String confidenceText = '高度匹配';
      if (confidence < 0.7) {
        confidenceText = '可能匹配';
      } else if (confidence < 0.85) {
        confidenceText = '匹配度好';
      }
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 头部装饰
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    categoryIcon,
                    color: categoryColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                
                // 标题
                Text(
                  '识别成功',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                
                // 分类名称（大、加粗）
                Text(
                  classCn,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // 英文和置信度（水平排列）
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '分类',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            classEn,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '匹配度',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${(confidence * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: categoryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                confidenceText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: categoryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // 进度条（可视化置信度）
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: confidence.toDouble(),
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 按钮
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '关闭',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _searchController.text = classCn;
                          _search(classCn);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: categoryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '了解详情',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    // 处理本地识别的 List 格式（后备方案）
    if (items is List<String>) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("识别结果"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("识别到以下物品："),
              const SizedBox(height: 12),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("取消"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // 使用第一个识别结果进行搜索
                final firstItem = items[0].split(' (')[0];
                _searchController.text = firstItem;
                _search(firstItem);
              },
              child: const Text("搜索"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("搜索垃圾物品"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 搜索栏和拍照按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 搜索输入框
                TextField(
                  controller: _searchController,
                  onSubmitted: _search,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() => _showHistory = true);
                    } else {
                      // Real-time search without saving history
                      _performRealTimeSearch(value);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "搜索垃圾物品（如：电池、塑料瓶）",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _showHistory = true);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),
                // 拍照识别按钮组
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickImageFromCamera,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("拍照识别"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickImageFromGallery,
                        icon: const Icon(Icons.image),
                        label: const Text("相册识别"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 内容区域
          Expanded(
            child: _showHistory
                ? _buildSearchHistory()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        if (searchProvider.searchHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  "暂无搜索历史",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "最近搜索",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final userId = context.read<UserProvider>().userId;
                        await context.read<SearchProvider>().clearHistory(userId);
                      },
                      child: const Text("清空"),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: searchProvider.searchHistory
                    .map(
                      (query) => GestureDetector(
                        onTap: () {
                          _searchController.text = query;
                          _search(query);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(query),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ).paddingAll(16),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        if (searchProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
        }

        if (searchProvider.errorMessage.isNotEmpty && searchProvider.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  "搜索失败",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  searchProvider.errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          );
        }

        if (searchProvider.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  "未找到相关物品",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: searchProvider.searchResults.length,
          itemBuilder: (context, index) {
            final result = searchProvider.searchResults[index];
            
            // 处理后端返回的Map格式（分类或物品）
            if (result is Map<String, dynamic>) {
              // 后端返回的格式: {name, category, tips, example_id}
              final itemName = result['name'] ?? '未知物品';
              final categoryName = result['category'] ?? '未知分类';
              final tips = result['tips'] ?? '';

              // 根据分类名称判断垃圾类型颜色
              Color categoryColor = Colors.grey;
              
              if (categoryName.contains('有害')) {
                categoryColor = Colors.red;
              } else if (categoryName.contains('可回收')) {
                categoryColor = Colors.blue;
              } else if (categoryName.contains('厨余') || categoryName.contains('湿')) {
                categoryColor = Colors.orange;
              } else if (categoryName.contains('干') || categoryName.contains('其他')) {
                categoryColor = Colors.grey;
              }

              return GestureDetector(
                onTap: () {
                  // 显示物品详情 - 高级样式
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 头部 - 物品名称和图标
                                  Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: categoryColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.delete_outline,
                                          color: categoryColor,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              itemName,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '垃圾物品',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // 分类卡片
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: categoryColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: categoryColor.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '垃圾分类',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          categoryName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: categoryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // 处理建议
                                  if (tips.isNotEmpty && tips != "暂无处理建议") ...[
                                    Text(
                                      '处理建议',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey[200]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        tips,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                  ] else
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '暂无处理建议',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 24),
                                  
                                  // 按钮
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => Navigator.pop(context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: categoryColor,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            '知道了',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 关闭按钮
                          Positioned(
                            right: 12,
                            top: 12,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.grey[700],
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.delete_outline, color: categoryColor),
                    ),
                    title: Text(
                      itemName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      categoryName,
                      style: TextStyle(color: categoryColor, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              );
            } else if (result is String) {
              // 处理兼容本地格式的字符串
              final parts = result.split(' (');
              final item = parts[0];
              final category = parts.length > 1 ? parts[1].replaceAll(')', '') : '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(item),
                  subtitle: Text(category),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(item),
                        content: Text('分类: $category'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('关闭'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

extension on Widget {
  Widget paddingAll(double value) {
    return Padding(
      padding: EdgeInsets.all(value),
      child: this,
    );
  }
}
