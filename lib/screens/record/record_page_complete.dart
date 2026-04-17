import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';

class RecordPageComplete extends StatefulWidget {
  const RecordPageComplete({super.key});

  @override
  State<RecordPageComplete> createState() => _RecordPageCompleteState();
}

class _RecordPageCompleteState extends State<RecordPageComplete> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("投放记录"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
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
                        "详细记录",
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
          Expanded(
            child: _tabIndex == 0 ? _buildStatisticsTab() : _buildRecordsTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return Consumer2<UserProvider, AuthProvider>(
      builder: (context, userProvider, authProvider, _) {
        final stats = userProvider.statistics;
        
        if (stats == null || stats.isEmpty) {
          return const Center(child: Text("暂无数据"));
        }

        final categoryStats = stats['categoryStats'] as Map<String, int>? ?? {};
        final pieChartData = PieChartData(
          sections: [
            if (categoryStats.containsKey('有害垃圾'))
              PieChartSectionData(
                color: const Color(0xFFFF0000),
                value: categoryStats['有害垃圾']!.toDouble(),
                title: '有害垃圾',
              ),
            if (categoryStats.containsKey('可回收物'))
              PieChartSectionData(
                color: const Color(0xFF0000FF),
                value: categoryStats['可回收物']!.toDouble(),
                title: '可回收物',
              ),
            if (categoryStats.containsKey('湿垃圾'))
              PieChartSectionData(
                color: const Color(0xFFFFA500),
                value: categoryStats['湿垃圾']!.toDouble(),
                title: '湿垃圾',
              ),
            if (categoryStats.containsKey('干垃圾'))
              PieChartSectionData(
                color: const Color(0xFF808080),
                value: categoryStats['干垃圾']!.toDouble(),
                title: '干垃圾',
              ),
          ],
          centerSpaceRadius: 40,
        );

        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildStatItem(
                        "${stats['totalDisposals'] ?? 0}",
                        "总投放次数",
                        Icons.delete,
                      ),
                      const Divider(),
                      _buildStatItem(
                        "${(stats['totalWeight'] as double?)?.toStringAsFixed(1) ?? '0'}kg",
                        "总投放重量",
                        Icons.scale,
                      ),
                      const Divider(),
                      _buildStatItem(
                        "${authProvider.userPoints}",
                        "总积分",
                        Icons.star,
                      ),
                      const Divider(),
                      _buildStatItem(
                        "${stats['level'] ?? '初级'}",
                        "当前等级",
                        Icons.emoji_events,
                      ),
                    ],
                  ),
                ),
              ),
              if (categoryStats.isNotEmpty && categoryStats.values.any((v) => v > 0))
                SizedBox(
                  height: 300,
                  child: PieChart(pieChartData),
                ),
              const SizedBox(height: 16),
              if (categoryStats.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "分类统计",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...categoryStats.entries.map((entry) {
                          final colorMap = {
                            '有害垃圾': Color(0xFFFF0000),
                            '可回收物': Color(0xFF0000FF),
                            '湿垃圾': Color(0xFFFFA500),
                            '干垃圾': Color(0xFF808080),
                          };
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: colorMap[entry.key],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(entry.key),
                                ),
                                Text("${entry.value}次"),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecordsTab() {
    return Consumer<DisposalRecordProvider>(
      builder: (context, recordProvider, _) {
        if (recordProvider.records.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.checklist,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  "暂无投放记录",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: recordProvider.records.length,
          itemBuilder: (context, index) {
            final record = recordProvider.records[index];
            
            final colorMap = {
              '有害垃圾': Color(0xFFFF0000),
              '可回收物': Color(0xFF0000FF),
              '湿垃圾': Color(0xFFFFA500),
              '干垃圾': Color(0xFF808080),
            };

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorMap[record['category_name']] ?? Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                title: Text(record['category_name'] ?? '垃圾'),
                subtitle: Text(
                  "${record['weight']}kg • ${record['location']}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text("删除"),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("确认删除"),
                            content: const Text("确定要删除这条记录吗？"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("取消"),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<DisposalRecordProvider>()
                                      .deleteRecord(record['id']);
                                  Navigator.pop(context);
                                },
                                child: const Text("删除"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
