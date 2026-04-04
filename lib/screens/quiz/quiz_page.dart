import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String? _selectedAnswer;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadTodayQuiz();
    });
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
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.isLoading && quizProvider.todayQuiz.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          }

          if (quizProvider.errorMessage.isNotEmpty && quizProvider.todayQuiz.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    '加载失败',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      quizProvider.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      quizProvider.loadTodayQuiz();
                      _resetAnswers();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('重试', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final quiz = quizProvider.todayQuiz['quiz'] as Map<String, dynamic>?;
          if (quiz == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.help_outline, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    '暂无答题',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('今日答题已加载完成，请稍后再试'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      quizProvider.loadTodayQuiz();
                      _resetAnswers();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('刷新', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final quizId = quiz['quiz_id'] ?? 0;
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
                    '今日答题 · ${quizProvider.todayQuiz['date'] ?? ''}',
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
                              _isAnswered,
                              () {
                                if (!_isAnswered) {
                                  setState(() {
                                    _selectedAnswer = answerLabels[index];
                                  });
                                }
                              },
                              quizProvider,
                              quiz,
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
                      onPressed: _selectedAnswer == null || quizProvider.isLoading
                          ? null
                          : () async {
                              final userProvider =
                                  context.read<UserProvider>();
                              final userId =
                                  int.tryParse(userProvider.userId) ?? 0;

                              if (userId == 0) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('用户ID无效，请重新登录'),
                                    ),
                                  );
                                }
                                return;
                              }

                              final isCorrect = await quizProvider
                                  .submitAnswer(userId, quizId, _selectedAnswer!);

                              if (mounted) {
                                setState(() {
                                  _isAnswered = true;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: quizProvider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        if (quizProvider.lastSubmitResult != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: (quizProvider.lastSubmitResult?['correct'] ?? false)
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: (quizProvider.lastSubmitResult?['correct'] ?? false)
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      (quizProvider.lastSubmitResult?['correct'] ?? false)
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: (quizProvider.lastSubmitResult?['correct'] ?? false)
                                          ? Colors.green
                                          : Colors.red,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      (quizProvider.lastSubmitResult?['correct'] ?? false)
                                          ? '回答正确！'
                                          : '回答错误',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: (quizProvider.lastSubmitResult?['correct'] ?? false)
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '正确答案：${quizProvider.lastSubmitResult?['answer'] ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '解释：${quizProvider.lastSubmitResult?['explanation'] ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                quizProvider.loadTodayQuiz();
                                _resetAnswers();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                '下一题',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionButton(
    String label,
    String text,
    int index,
    List<String> labels,
    bool isAnswered,
    VoidCallback onTap,
    QuizProvider quizProvider,
    Map<String, dynamic> quiz,
  ) {
    final isSelected = _selectedAnswer == label;
    final isCorrect = label == (quiz['correct_answer'] ?? '');
    final shouldShowCorrect = isAnswered && isCorrect;
    final shouldShowIncorrect = isAnswered && isSelected && !isCorrect;

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
    } else if (isSelected && !isAnswered) {
      backgroundColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.green;
      textColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAnswered ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                color: borderColor,
                width: isSelected || shouldShowCorrect || shouldShowIncorrect
                    ? 2
                    : 1,
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
                    border: Border.all(
                      color: borderColor,
                      width: 2,
                    ),
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

  void _resetAnswers() {
    setState(() {
      _selectedAnswer = null;
      _isAnswered = false;
    });
  }
}
