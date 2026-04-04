import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class KnowledgeDetailPage extends StatefulWidget {
  final GarbageCategory category;

  const KnowledgeDetailPage({super.key, required this.category});

  @override
  State<KnowledgeDetailPage> createState() => _KnowledgeDetailPageState();
}

class _KnowledgeDetailPageState extends State<KnowledgeDetailPage> {
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
  }

  void _checkIfFavorited() {
    final favoritesProvider = context.read<FavoritesProvider>();
    _isFavorited = favoritesProvider.isFavorited('garbage_${widget.category.name}');
  }

  Future<void> _toggleFavorite() async {
    final userProvider = context.read<UserProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();

    if (_isFavorited) {
      try {
        final favorite = favoritesProvider.favorites
            .firstWhere((f) => f['name'] == widget.category.name);
        favoritesProvider.removeFavorite(favorite['id']);
      } catch (e) {
        // 忽略未找到的错误
      }
    } else {
      favoritesProvider.addFavorite({
        'user_id': userProvider.userId,
        'item_id': 'garbage_${widget.category.name}',
        'type': 'garbage',
        'name': widget.category.name,
        'id': 'garbage_${widget.category.name}',
      });
    }

    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = Color(int.parse('0xFF${widget.category.color}'));
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.category.name),
        centerTitle: true,
        backgroundColor: categoryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isFavorited ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 华丽头部卡片
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [categoryColor, categoryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 大标题和描述
                  Text(
                    widget.category.name,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.category.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.6,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 统计数据
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('常见物品', '${widget.category.examples.length}种', Colors.white),
                      _buildStatItem('投放贴士', '${widget.category.tips.length}条', Colors.white),
                      _buildStatItem('收藏状态', _isFavorited ? '已收藏' : '未收藏', Colors.white),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 详细介绍
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '分类详解',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getDetailedDescription(widget.category.name),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.8,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 常见物品
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '常见物品',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '共${widget.category.examples.length}种',
                          style: TextStyle(
                            fontSize: 12,
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: widget.category.examples
                          .map(
                            (example) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: categoryColor.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: categoryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    example,
                                    style: TextStyle(
                                      color: categoryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 投放贴士
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '投放贴士',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '🎯 重要',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: widget.category.tips
                        .map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: categoryColor.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [categoryColor, categoryColor.withOpacity(0.7)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.lightbulb,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.6,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 环保小知识
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.withOpacity(0.1), Colors.blue.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '♻️ 环保知识',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getEcoTip(widget.category.name),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.7,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 收藏按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [categoryColor.withOpacity(0.2), categoryColor.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: categoryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleFavorite,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isFavorited ? Icons.favorite : Icons.favorite_border,
                            color: categoryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isFavorited ? '已收藏' : '收藏此分类',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: categoryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  String _getDetailedDescription(String categoryName) {
    switch (categoryName) {
      case '可回收物':
        return '可回收物是指适合回收、可循环利用的材料。这些物品经过处理可以重新加工成新产品，既节省资源又保护环境。合理回收可回收物可以减少对自然资源的开采需求，降低生产能耗，同时创造经济价值。';
      case '有害垃圾':
        return '有害垃圾是指对人体健康或自然环境造成直接或潜在危害的废弃物。这些物品含有毒有害物质，必须单独投放并妥善处理，以防污染土壤和水资源。常见的有害垃圾包括含汞灯泡、电池、过期药品等。';
      case '厨余垃圾':
        return '厨余垃圾是指易腐烂的、含有有机物的生活废弃物。这类垃圾可以进行堆肥处理，制成有机肥料用于农业生产。正确分类厨余垃圾有助于改善环境质量，推进资源循环利用。';
      case '其他垃圾':
        return '其他垃圾是指不属于可回收物、有害垃圾和厨余垃圾的生活废弃物。这类垃圾通常通过焚烧或填埋方式处理。当你不确定某个物品属于哪一类时，可以归类为其他垃圾。';
      default:
        return '了解正确的垃圾分类知识，从小事开始保护地球环境。';
    }
  }

  String _getEcoTip(String categoryName) {
    switch (categoryName) {
      case '可回收物':
        return '💡 回收纸质、塑料和金属制品可以减少垃圾填埋量。将这些物品投放到回收箱时，最好先清洗干净并压扁以节省空间。';
      case '有害垃圾':
        return '💡 有害垃圾必须单独投放，不能混入其他垃圾。这些物品会被专门收运到危险废物处理中心进行安全处理，避免对环境造成污染。';
      case '厨余垃圾':
        return '💡 厨余垃圾沥干后可用作堆肥。堆肥既可以改善土壤质量，又能减少甲烷排放。尽量不在厨余垃圾中混入塑料、金属等物品。';
      case '其他垃圾':
        return '💡 当你不确定某个物品的分类时，投放到其他垃圾中即可。但最好养成思考和学习的习惯，逐渐掌握更多分类知识。';
      default:
        return '💡 垃圾分类是保护地球的第一步，让我们一起为美好家园努力！';
    }
  }
}
