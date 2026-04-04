import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SimpleQuizPage extends StatefulWidget {
  const SimpleQuizPage({super.key});

  @override
  State<SimpleQuizPage> createState() => _SimpleQuizPageState();
}

class _SimpleQuizPageState extends State<SimpleQuizPage> {
  Map<String, dynamic>? _todayQuiz;
  Map<String, dynamic>? _submitResult;
  String? _selectedAnswer;
  bool _isLoading = false;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _loadTodayQuiz();
  }

  Future<void> _loadTodayQuiz() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final result = await apiService.getTodayQuiz();

      // 添加调试信息
      print('=== 获取题目调试信息 ===');
      print('API返回结果: $result');
      print('result类型: ${result.runtimeType}');
      if (result['success'] && result['data'] != null) {
        final data = result['data'];
        print('data类型: ${data.runtimeType}');
        print('data内容: $data');
        print('题目ID: ${data['quiz_id']} (类型: ${data['quiz_id']?.runtimeType})');
        print('题目内容: ${data['question']}');
        print('所有字段: ${data.keys}');
      } else {
        print('获取失败: ${result['error']}');
      }
      print('========================');

      if (result['success']) {
        final data = result['data'];
        
        // 检查data是否是数组（List）
        if (data is List && data.isNotEmpty) {
          // 如果是数组，取第一个题目
          print('后端返回数组，取第一个题目: ${data[0]}');
          _todayQuiz = Map<String, dynamic>.from(data[0]);
        } else if (data is Map) {
          // 如果是对象，直接使用，需要类型转换
          print('后端返回对象，直接使用: $data');
          _todayQuiz = Map<String, dynamic>.from(data);
        } else {
          print('数据格式不正确: $data');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("题目数据格式错误")),
            );
          }
          return;
        }
        
        setState(() {
          _submitResult = null;
          _selectedAnswer = null;
          _isAnswered = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? '获取题目失败')),
          );
        }
      }
    } catch (e) {
      print('获取题目异常: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("加载失败: $e")),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAnswer() async {
    if (_todayQuiz == null || _selectedAnswer == null) return;

    setState(() => _isLoading = true);

    try {
      // 添加调试信息
      print('=== 答题提交调试信息 ===');
      print('题目数据: $_todayQuiz');
      
      // 安全地获取题目ID
      final quizIdValue = _todayQuiz!['quiz_id']; // 使用quiz_id字段
      print('题目ID原始值: $quizIdValue (类型: ${quizIdValue.runtimeType})');
      
      final quizId = quizIdValue != null ? int.tryParse(quizIdValue.toString()) ?? 0 : 0;
      
      print('题目ID转换后: $quizId');
      print('选择的答案: $_selectedAnswer');
      print('========================');

      if (quizId == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("题目ID无效，请重新获取题目")),
          );
        }
        return;
      }

      final apiService = ApiService();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userIdValue = authProvider.userId;
      
      // 添加详细的调试信息
      print('=== 登录状态调试 ===');
      print('isAuthenticated: ${authProvider.isAuthenticated}');
      print('userId: $userIdValue');
      print('username: ${authProvider.username}');
      print('userInfo: ${authProvider.userInfo}');
      print('token: ${authProvider.token}');
      print('==================');
      
      // 检查用户是否已登录 - 临时允许未登录用户测试
      if (userIdValue == null) {
        print('用户未登录，但允许临时测试答题');
        // 临时注释登录检查
        /*
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("请先登录后再答题")),
          );
        }
        setState(() => _isLoading = false);
        return;
        */
      }
      
      // 临时测试：直接模拟成功提交
      print('=== 临时测试模式 ===');
      print('题目ID: $quizId');
      print('选择答案: $_selectedAnswer');
      print('用户ID: $userIdValue');
      print('==================');
      
      // 模拟正确答案检查
      final correctAnswer = _todayQuiz!['correct_answer'] ?? '';
      final isCorrect = _selectedAnswer == correctAnswer;
      
      setState(() {
        _submitResult = {
          'correct': isCorrect,
          'points_earned': isCorrect ? 10 : 0,
          'correct_answer': correctAnswer,
          'explanation': _todayQuiz!['explanation'] ?? '暂无解释'
        };
        _isAnswered = true;
      });
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCorrect ? "回答正确！获得10分" : "回答错误，正确答案是：$correctAnswer"),
            backgroundColor: isCorrect ? Colors.green : Colors.orange,
          ),
        );
      }
      
      return; // 临时跳过API调用
      
      // 原来的API调用（暂时注释）
      /*
      final result = await apiService.submitQuizAnswer(
        quizId,
        _selectedAnswer!,
        userId: userIdValue.toString(),
      );

      print('提交结果: $result');

      if (result['success']) {
        setState(() {
          _submitResult = result['data'];
          _isAnswered = true;
        });
      } else {
        if (mounted) {
          // 显示详细的错误信息
          final errorMessage = result['error'] ?? '提交失败';
          print('提交失败原因: $errorMessage');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("提交失败: $errorMessage")),
          );
        }
      }
      */
    } catch (e) {
      print('提交异常: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("提交失败: $e")),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('每日小答题'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.95),
        foregroundColor: Colors.black87,
      ),
      body: _isLoading && _todayQuiz == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : _todayQuiz == null
              ? _buildEmptyState()
              : _buildQuizContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz_outlined, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            '暂无答题',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('今日答题已加载完成，请稍后再试'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadTodayQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('刷新', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    final quiz = _todayQuiz!;
    
    // 安全地获取题目ID
    final quizIdValue = quiz['quiz_id']; // 使用quiz_id字段
    final quizId = quizIdValue != null ? int.tryParse(quizIdValue.toString()) ?? 0 : 0;
    
    final question = quiz['question'] ?? '未知问题';
    final options = [
      quiz['option_a'] ?? 'A',
      quiz['option_b'] ?? 'B',
      quiz['option_c'] ?? 'C',
      quiz['option_d'] ?? 'D',
    ];
    final answerLabels = ['A', 'B', 'C', 'D'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '今日答题 · ${quiz['date'] ?? ''}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),

          // 问题卡片
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 选项
                  Column(
                    children: List.generate(
                      options.length,
                      (index) => _buildOptionButton(
                        answerLabels[index],
                        options[index],
                        index,
                        answerLabels,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 提交按钮
          if (!_isAnswered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedAnswer == null || _isLoading
                    ? null
                    : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        '提交答案',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            )
          else
            _buildResultSection(),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String label, String text, int index, List<String> labels) {
    final isSelected = _selectedAnswer == label;
    final isCorrect = label == (_todayQuiz!['correct_answer'] ?? '');
    final shouldShowCorrect = _isAnswered && isCorrect;
    final shouldShowIncorrect = _isAnswered && isSelected && !isCorrect;

    Color backgroundColor = Colors.grey[100]!;
    Color borderColor = Colors.grey[300]!;
    Color textColor = Colors.black87;

    if (shouldShowCorrect) {
      backgroundColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.green;
      textColor = Colors.green;
    } else if (shouldShowIncorrect) {
      backgroundColor = Colors.red.withOpacity(0.1);
      borderColor = Colors.red;
      textColor = Colors.red;
    } else if (isSelected && !_isAnswered) {
      backgroundColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.green;
      textColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isAnswered ? null : () {
            setState(() {
              _selectedAnswer = label;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                color: borderColor,
                width: isSelected || shouldShowCorrect || shouldShowIncorrect ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: borderColor, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (shouldShowCorrect)
                  const Icon(Icons.check, color: Colors.green, size: 24)
                else if (shouldShowIncorrect)
                  const Icon(Icons.close, color: Colors.red, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    if (_submitResult == null) return const SizedBox.shrink();

    final isCorrect = _submitResult!['correct'] ?? false;
    final points = _submitResult!['points_earned'] ?? 0;
    final correctAnswer = _submitResult!['correct_answer'] ?? '';
    final explanation = _submitResult!['explanation'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // 结果卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCorrect ? Colors.green : Colors.red,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isCorrect ? '回答正确！' : '回答错误',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                    if (points > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+$points积分',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '正确答案：$correctAnswer',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (explanation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '解释：$explanation',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 每日答题完成后不显示按钮，因为每天只做一题
          // const SizedBox(height: 16),
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton(
          //     onPressed: _loadTodayQuiz,
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.green,
          //       padding: const EdgeInsets.symmetric(vertical: 14),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //     ),
          //     child: const Text(
          //       '下一题',
          //       style: TextStyle(
          //         fontSize: 16,
          //         fontWeight: FontWeight.bold,
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
