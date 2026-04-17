import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';
import '../../services/api_service.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  int _tabIndex = 0;
  List<dynamic> _disposalRecords = [];
  bool _isLoadingRecords = false;

  @override
  void initState() {
    super.initState();
    // 加载真实排名
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.loadRealRanking();
    });
    // 加载投放记录
    _loadDisposalRecords();
  }

  // 加载投放记录
  Future<void> _loadDisposalRecords() async {
    setState(() {
      _isLoadingRecords = true;
    });
    
    try {
      final apiService = ApiService();
      final records = await apiService.getDisposalRecords();
      print('获取到的投放记录数据: $records');
      setState(() {
        _disposalRecords = records;
        _isLoadingRecords = false;
      });
    } catch (e) {
      print('加载投放记录失败: $e');
      setState(() {
        _isLoadingRecords = false;
      });
    }
  }

  // Calculate real category statistics from disposal records
  Map<String, int> _calculateCategoryStatistics() {
    Map<String, int> categoryCounts = {
      '1': 0, // 1: 'can_recycle'
      '2': 0, // 2: 'harmful'
      '3': 0, // 3: 'kitchen'
      '4': 0, // 4: 'other'
    };
    
    for (var record in _disposalRecords) {
      int categoryId = record['category_id'] ?? 1;
      categoryCounts[categoryId.toString()] = (categoryCounts[categoryId.toString()] ?? 0) + 1;
    }
    
    return categoryCounts;
  }

  // Build pie chart sections from real disposal records data
  List<PieChartSectionData> _buildPieChartSections() {
    final categoryStats = _calculateCategoryStatistics();
    final totalCount = categoryStats.values.fold(0, (sum, count) => sum + count);
    
    // If no records, return default data
    if (totalCount == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: '0%',
          radius: 60,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ];
    }
    
    final sections = <PieChartSectionData>[];
    
    // Category mapping: id -> (name, color, display_name)
    final categoryInfo = {
      '1': ('Recyclable', Colors.blue, 'Recyclable'),
      '2': ('Harmful', Colors.red, 'Harmful'),
      '3': ('Kitchen', Colors.green, 'Kitchen'),
      '4': ('Other', Colors.grey, 'Other'),
    };
    
    for (final entry in categoryStats.entries) {
      final count = entry.value;
      if (count > 0) {
        final info = categoryInfo[entry.key]!;
        final percentage = (count / totalCount * 100).round();
        
        sections.add(PieChartSectionData(
          color: info.$2,
          value: count.toDouble(),
          title: '${info.$3}\n${percentage}%',
          radius: 60,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ));
      }
    }
    
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("投放记录"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 标签栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _tabIndex == 0
                                ? Colors.green
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        "统计分析",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _tabIndex == 0 ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _tabIndex == 1
                                ? Colors.green
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        "投放记录",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _tabIndex == 1 ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 内容区域
          Expanded(
            child: _tabIndex == 0 ? _buildStatisticsView(authProvider) : _buildRecordsView(),
          ),
        ],
      ),
      // 添加投放记录的浮动按钮
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDisposalDialog,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.delete_outline, color: Colors.white),
        label: const Text(
          "投放垃圾",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showAddDisposalDialog() {
    showDialog(
      context: context,
      builder: (context) => AddDisposalDialog(
        onDisposalAdded: () async {
          // 投放成功后刷新页面
          setState(() {});
          // 立即刷新投放记录
          await _loadDisposalRecords();
        },
        onRefreshRecords: _loadDisposalRecords, // 传递刷新记录的方法
      ),
    );
  }

  Widget _buildStatisticsView(AuthProvider authProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 总投放数据卡片
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFAED581), Color(0xFF81C784)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "本月投放统计",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem("${authProvider.disposalCount}", "总投放数", Icons.check_circle),
                        _buildStatItem("${authProvider.userPoints}", "获得积分", Icons.star),
                        _buildStatItem("排名", authProvider.rankingText, Icons.trending_up),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 饼图标题
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "分类投放比例",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // Pie chart
          SizedBox(
            height: 280,
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(),
              ),
            ),
          ),
          // Legend
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegendItem("Harmful", Colors.red),
                _buildLegendItem("Recyclable", Colors.blue),
                _buildLegendItem("Kitchen", Colors.green),
                _buildLegendItem("Other", Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsView() {
    return _buildRecordsTab();
  }

  Widget _buildRecordsTab() {
    if (_isLoadingRecords) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_disposalRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无投放记录',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '完成投放后记录将显示在这里',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _disposalRecords.length,
      itemBuilder: (context, index) {
        final record = _disposalRecords[index];
        print('处理投放记录: $record');
        
        // 根据API返回的实际字段名解析数据
        int categoryId = record['category_id'] ?? 1;
        String categoryName = _getCategoryNameById(categoryId);
        String garbageName = record['garbage_name'] ?? '未知垃圾';
        bool isCorrect = true; // API没有返回这个字段，默认为正确
        String timestamp = record['timestamp'] ?? '';
        String createdAt = _formatTimestamp(timestamp);
        
        print('解析后 - 垃圾名: $garbageName, 分类: $categoryName, 正确: $isCorrect, 时间: $createdAt');
        
        // 根据分类设置颜色
        Color categoryColor = _getCategoryColor(categoryName);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? categoryColor : Colors.grey,
                size: 28,
              ),
            ),
            title: Text(
              garbageName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  categoryName,
                  style: TextStyle(
                    color: categoryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  createdAt.isNotEmpty ? _formatDate(createdAt) : '刚刚',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isCorrect ? '正确' : '错误',
                style: TextStyle(
                  color: isCorrect ? Colors.green[700] : Colors.red[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 根据分类名称获取颜色
  Color _getCategoryColor(String categoryName) {
    switch (categoryName) {
      case '可回收物':
        return Colors.blue;
      case '有害垃圾':
        return Colors.red;
      case '厨余垃圾':
        return Colors.green;
      case '其他垃圾':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // 格式化日期
  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.month}-${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  // 根据分类ID获取分类名称
  String _getCategoryNameById(int categoryId) {
    switch (categoryId) {
      case 1:
        return '可回收物';
      case 2:
        return '有害垃圾';
      case 3:
        return '厨余垃圾';
      case 4:
        return '其他垃圾';
      default:
        return '未知分类';
    }
  }

  // 格式化时间戳
  String _formatTimestamp(String timestamp) {
    if (timestamp.isEmpty) return '刚刚';
    
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return '刚刚';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}分钟前';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}小时前';
      } else {
        return '${dateTime.month}-${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return timestamp;
    }
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.white),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class AddDisposalDialog extends StatefulWidget {
  final VoidCallback onDisposalAdded;
  final Future<void> Function()? onRefreshRecords; // 添加刷新记录的回调

  const AddDisposalDialog({super.key, required this.onDisposalAdded, this.onRefreshRecords});

  @override
  State<AddDisposalDialog> createState() => _AddDisposalDialogState();
}

class _AddDisposalDialogState extends State<AddDisposalDialog> {
  final _garbageNameController = TextEditingController();
  int _selectedCategoryId = 1; // 改为category_id
  bool _isCorrect = true;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': '可回收物', 'color': Colors.blue},
    {'id': 2, 'name': '有害垃圾', 'color': Colors.red},
    {'id': 3, 'name': '厨余垃圾', 'color': Colors.green},
    {'id': 4, 'name': '其他垃圾', 'color': Colors.grey},
  ];

  @override
  void dispose() {
    _garbageNameController.dispose();
    super.dispose();
  }

  Future<void> _submitDisposal() async {
    if (_garbageNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入垃圾名称')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.addDisposalRecord(
        _garbageNameController.text.trim(),
        _selectedCategoryId,
        isCorrect: _isCorrect,
      );

      if (result['success']) {
        final point = result['point'] ?? 0;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('投放成功！获得${point}积分'),
            backgroundColor: Colors.green,
          ),
        );

        // 关闭对话框并刷新页面
        Navigator.of(context).pop();
        widget.onDisposalAdded();
        
        // 刷新投放记录列表
        if (widget.onRefreshRecords != null) {
          await widget.onRefreshRecords!();
        }
        
        // 刷新用户数据（积分和投放次数）
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.refreshUserData();
        
        // 刷新UserProvider的统计数据（用于个人资料页面显示）
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.refreshStatistics();
        
        // 强制刷新UI
        if (mounted) {
          setState(() {});
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('投放失败：${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('投放异常: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('投放错误：$e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      insetPadding: EdgeInsets.zero, // 移除默认边距
      child: Container(
        width: screenWidth * 0.95, // 增加到95%宽度
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 简化的标题栏
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    '添加投放记录',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
            
            // 简化的内容区域
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 垃圾名称输入
                  TextField(
                    controller: _garbageNameController,
                    decoration: InputDecoration(
                      labelText: '垃圾名称',
                      hintText: '请输入垃圾名称',
                      prefixIcon: const Icon(Icons.delete_outline, color: Colors.green),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 分类选择 - 简化为单行
                  Row(
                    children: [
                      const Text(
                        '分类：',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _categories.map((category) {
                            final isSelected = _selectedCategoryId == category['id'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategoryId = category['id'];
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? category['color'] : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? category['color'] : Colors.grey[300]!,
                                  ),
                                ),
                                child: Text(
                                  category['name'],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 正确性选择 - 简化为开关
                  Row(
                    children: [
                      const Text(
                        '投放正确：',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Switch(
                        value: _isCorrect,
                        onChanged: (value) {
                          setState(() {
                            _isCorrect = value;
                          });
                        },
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.grey[400],
                        inactiveTrackColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCorrect ? '正确' : '错误',
                        style: TextStyle(
                          color: _isCorrect ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 提交按钮
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitDisposal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('提交中...'),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send, size: 18),
                                SizedBox(width: 8),
                                Text('提交投放记录'),
                              ],
                            ),
                    ),
                  ),
                  
                  // 简化的提示信息
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '投放正确可获得5积分，投放错误不获得积分',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
