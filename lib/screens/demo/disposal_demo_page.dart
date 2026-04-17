import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

class DisposalDemoPage extends StatefulWidget {
  const DisposalDemoPage({super.key});

  @override
  State<DisposalDemoPage> createState() => _DisposalDemoPageState();
}

class _DisposalDemoPageState extends State<DisposalDemoPage> {
  final _garbageNameController = TextEditingController();
  String _selectedCategory = '可回收物';
  bool _isCorrect = true;
  bool _isLoading = false;

  final List<String> _categories = [
    '可回收物',
    '有害垃圾',
    '湿垃圾',
    '干垃圾',
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
      final apiService = ApiService();
      final result = await apiService.addDisposalRecord(
        _garbageNameController.text.trim(),
        _selectedCategory,
        _isCorrect,
      );

      if (result['success']) {
        final point = result['point'] ?? 0;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('投放成功！获得${point}积分'),
            backgroundColor: Colors.green,
          ),
        );

        // 清空输入
        _garbageNameController.clear();
        
        // 更新用户积分（如果有AuthProvider）
        if (mounted && point > 0) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          // 这里可以添加更新积分的逻辑
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('投放记录演示'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 垃圾名称输入
            TextField(
              controller: _garbageNameController,
              decoration: const InputDecoration(
                labelText: '垃圾名称',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.delete),
              ),
            ),
            const SizedBox(height: 16),

            // 分类选择
            const Text(
              '选择分类',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: _getCategoryColor(category),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 是否正确选择
            const Text(
              '投放是否正确',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('正确'),
                    value: true,
                    groupValue: _isCorrect,
                    onChanged: (value) {
                      setState(() {
                        _isCorrect = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('错误'),
                    value: false,
                    groupValue: _isCorrect,
                    onChanged: (value) {
                      setState(() {
                        _isCorrect = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 提交按钮
            ElevatedButton(
              onPressed: _isLoading ? null : _submitDisposal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('提交投放记录'),
            ),
            const SizedBox(height: 16),

            // 说明
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '说明：',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('• 投放正确可获得5积分'),
                  Text('• 投放错误不获得积分'),
                  Text('• 积分会自动累加到用户账户'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '可回收物':
        return Colors.blue;
      case '有害垃圾':
        return Colors.red;
      case '湿垃圾':
        return Colors.green;
      case '干垃圾':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
