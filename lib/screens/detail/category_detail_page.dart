import 'package:flutter/material.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryName;

  const CategoryDetailPage({super.key, required this.categoryName});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  bool _isLoading = false;

  // 本地分类数据
  static const Map<String, Map<String, dynamic>> _categoryData = {
    '可回收物': {
      'english_name': 'Recyclable Waste',
      'summary': '可回收物是指适宜回收循环使用和资源利用的废物',
      'description': '可回收物是指适宜回收循环使用和资源利用的废物。主要包括：废纸、塑料、玻璃、金属和布料五大类。这些材料经过回收处理后，可以重新制成新的产品，减少资源浪费和环境污染。',
      'examples': '报纸,纸箱,塑料瓶,玻璃瓶,金属罐,易拉罐,旧衣物,书本,纸盒,塑料袋,铝箔',
      'disposal_method': '1. 清洁干净：确保物品清洁，去除残留物\n2. 分类投放：按材质分类投放\n3. 压缩整理：纸箱、塑料瓶等可压缩以节省空间\n4. 定时投放：按照社区规定时间投放',
      'precautions': '1. 纸类要保持干燥，避免受潮\n2. 塑料瓶要清空并清洗\n3. 玻璃制品要小心轻放，避免破碎\n4. 电池、灯管等有害垃圾不要混入可回收物'
    },
    '有害垃圾': {
      'english_name': 'Hazardous Waste',
      'summary': '有害垃圾是指对人体健康或自然环境造成直接或潜在危害的废弃物',
      'description': '有害垃圾是指含有害物质，需要特殊处理的废弃物。这些垃圾如果处理不当，会对人体健康和环境造成严重危害。必须单独收集和专业处理。',
      'examples': '废电池,废灯管,废药品,废油漆,杀虫剂,消毒剂,温度计,废相纸,化妆品,农药',
      'disposal_method': '1. 单独收集：与其他垃圾分开存放\n2. 密封包装：用原包装或密封袋包装\n3. 专门投放：投放到指定的有害垃圾收集点\n4. 标识清楚：标注清楚是有害垃圾',
      'precautions': '1. 不要随意丢弃，避免污染环境\n2. 不要与其他垃圾混合\n3. 破碎的灯管要小心处理\n4. 过期药品不要随意丢弃，要送到专门收集点'
    },
    '湿垃圾': {
      'english_name': 'Wet Waste',
      'summary': '湿垃圾是指易腐烂的生物质生活废弃物',
      'description': '湿垃圾又称厨余垃圾，是指易腐烂的生物质生活废弃物。主要包括剩菜剩饭、骨头、菜根菜叶、果皮等食品类废物。这些垃圾可以通过生物技术进行处理，转化为有机肥料。',
      'examples': '剩菜剩饭,骨头,菜叶,果皮,茶叶渣,咖啡渣,蛋壳,过期食品,花卉植物,面包,蛋糕',
      'disposal_method': '1. 沥干水分：去除多余水分\n2. 使用专用袋：使用可降解垃圾袋\n3. 及时投放：避免长时间存放\n4. 分类投放：投放到湿垃圾专用容器',
      'precautions': '1. 不要混入塑料袋、包装盒等\n2. 大骨头、硬贝壳等难以降解的要分开\n3. 保持容器清洁，避免产生异味\n4. 定期清理，防止滋生细菌'
    },
    '干垃圾': {
      'english_name': 'Dry Waste',
      'summary': '干垃圾是指除可回收物、有害垃圾、湿垃圾以外的其他生活废弃物',
      'description': '干垃圾又称其他垃圾，是指除可回收物、有害垃圾、湿垃圾以外的其他生活废弃物。这些垃圾通常采用填埋或焚烧方式处理。',
      'examples': '纸巾,烟蒂,尘土,陶瓷碎片,一次性餐具,污染的纸张,破碎的陶瓷,口香糖,头发,宠物粪便',
      'disposal_method': '1. 装袋密封：使用垃圾袋密封\n2. 定时投放：按照规定时间投放\n3. 分类投放：投放到干垃圾容器\n4. 减少产生：尽量减少干垃圾的产生',
      'precautions': '1. 不要混入可回收物和有害垃圾\n2. 污染严重的纸张属于干垃圾\n3. 破碎的玻璃要小心包装\n4. 保持投放点清洁卫生'
    },
    '厨余垃圾': {
      'english_name': 'Kitchen Waste',
      'summary': '厨余垃圾是指居民家庭日常生活及食品加工、餐饮服务等活动中产生的垃圾',
      'description': '厨余垃圾是指居民家庭日常生活及食品加工、餐饮服务等活动中产生的垃圾。主要为有机物，可以通过堆肥、厌氧消化等方式进行资源化利用。',
      'examples': '剩菜剩饭,菜根菜叶,果皮,蛋壳,茶叶渣,咖啡渣,过期食品,面包,蛋糕,米饭,面条',
      'disposal_method': '1. 沥干水分：去除多余液体\n2. 分类投放：与其他垃圾分开\n3. 使用专用容器：投放到厨余垃圾专用桶\n4. 及时处理：避免长时间存放',
      'precautions': '1. 不要混入塑料袋、包装盒\n2. 大骨头要单独处理\n3. 保持容器清洁\n4. 避免产生异味和害虫'
    },
    '其他垃圾': {
      'english_name': 'Other Waste',
      'summary': '其他垃圾是指除可回收物、有害垃圾、湿垃圾以外的其他生活废弃物',
      'description': '其他垃圾是指除可回收物、有害垃圾、湿垃圾以外的其他生活废弃物。这些垃圾通常采用填埋或焚烧方式处理，需要尽量减少产生量。',
      'examples': '纸巾,烟蒂,尘土,陶瓷碎片,一次性餐具,污染的纸张,破碎的陶瓷,口香糖,头发,宠物粪便',
      'disposal_method': '1. 装袋密封：使用垃圾袋密封\n2. 定时投放：按照规定时间投放\n3. 分类投放：投放到其他垃圾容器\n4. 减量产生：从源头减少垃圾产生',
      'precautions': '1. 不要混入可回收物和有害垃圾\n2. 污染严重的纸张属于其他垃圾\n3. 破碎物品要小心包装\n4. 保持投放点清洁'
    }
  };

  Map<String, dynamic>? get _categoryDetail {
    // 尝试多种可能的名称匹配
    final names = [widget.categoryName];
    
    // 添加一些常见的别名
    if (widget.categoryName == '厨余垃圾') {
      names.add('湿垃圾');
    } else if (widget.categoryName == '湿垃圾') {
      names.add('厨余垃圾');
    }
    
    for (String name in names) {
      if (_categoryData.containsKey(name)) {
        return _categoryData[name];
      }
    }
    
    return null;
  }

  @override
  void initState() {
    super.initState();
    // 模拟加载效果
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _isLoading = false);
    });
  }

  Color _getCategoryColor() {
    switch (widget.categoryName) {
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

  IconData _getCategoryIcon() {
    switch (widget.categoryName) {
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

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();
    final categoryIcon = _getCategoryIcon();
    final categoryDetail = _categoryDetail;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 自定义AppBar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: categoryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      categoryColor.withOpacity(0.8),
                      categoryColor.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // 背景装饰
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 30,
                      top: 30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    // 中心图标和标题
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              categoryIcon,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.categoryName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  setState(() => _isLoading = true);
                  Future.delayed(const Duration(milliseconds: 500), () {
                    setState(() => _isLoading = false);
                  });
                },
              ),
            ],
          ),
          // 内容区域
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (categoryDetail == null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '分类信息不存在',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: categoryColor,
                      ),
                      child: const Text('返回'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 分类简介卡片
                  _buildInfoCard(categoryColor, categoryIcon, categoryDetail!),
                  const SizedBox(height: 16),
                  // 详细说明
                  _buildDescriptionCard(categoryColor, categoryDetail!),
                  const SizedBox(height: 16),
                  // 包含物品示例
                  _buildExamplesCard(categoryColor, categoryDetail!),
                  const SizedBox(height: 16),
                  // 处理方法
                  _buildDisposalMethodCard(categoryColor, categoryDetail!),
                  const SizedBox(height: 16),
                  // 注意事项
                  _buildPrecautionsCard(categoryDetail!),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Color categoryColor, IconData categoryIcon, Map<String, dynamic> categoryDetail) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor.withOpacity(0.1),
            categoryColor.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: categoryColor.withOpacity(0.2),
                  ),
                  child: Icon(
                    categoryIcon,
                    color: categoryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.categoryName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                      if (categoryDetail['english_name'] != null)
                        Text(
                          categoryDetail['english_name'],
                          style: TextStyle(
                            fontSize: 16,
                            color: categoryColor.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (categoryDetail['summary'] != null) ...[
              const SizedBox(height: 16),
              Text(
                categoryDetail['summary'],
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(Color categoryColor, Map<String, dynamic> categoryDetail) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: categoryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '详细说明',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (categoryDetail['description'] != null)
              Text(
                categoryDetail['description'],
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamplesCard(Color categoryColor, Map<String, dynamic> categoryDetail) {
    final examples = categoryDetail['examples'];
    List<String> exampleList = [];
    
    if (examples is String) {
      exampleList = examples.split(',').map((e) => e.trim()).toList();
    } else if (examples is List) {
      exampleList = examples.map((e) => e.toString()).toList();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: categoryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '包含物品',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exampleList.map((example) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: categoryColor.withOpacity(0.1),
                    border: Border.all(
                      color: categoryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    example,
                    style: TextStyle(
                      color: categoryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisposalMethodCard(Color categoryColor, Map<String, dynamic> categoryDetail) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  color: categoryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '处理方法',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (categoryDetail['disposal_method'] != null)
              Text(
                categoryDetail['disposal_method'],
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrecautionsCard(Map<String, dynamic> categoryDetail) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.orange.withOpacity(0.1),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '注意事项',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (categoryDetail['precautions'] != null)
              Text(
                categoryDetail['precautions'],
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
