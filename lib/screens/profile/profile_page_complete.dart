import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../providers/providers.dart';
import '../auth/login_page.dart';

class ProfilePageComplete extends StatefulWidget {
  const ProfilePageComplete({super.key});

  @override
  State<ProfilePageComplete> createState() => _ProfilePageCompleteState();
}

class _ProfilePageCompleteState extends State<ProfilePageComplete> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("我的"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("设置"),
                  content: const Text("功能开发中..."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("关闭"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 用户信息卡片
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                final stats = userProvider.statistics;
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFAED581), Color(0xFF81C784)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProvider.username ?? '用户',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "等级: ${stats?['level'] ?? '初级环保卫士'}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "积分: ${stats?['totalPoints'] ?? 0}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // 统计卡片
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                final stats = userProvider.statistics;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        "${stats?['totalDisposals'] ?? 0}",
                        "投放次数",
                        Colors.blue,
                      ),
                      _buildStatCard(
                        "${(stats?['totalWeight'] as double?)?.toStringAsFixed(1) ?? '0'}kg",
                        "投放重量",
                        Colors.orange,
                      ),
                      _buildStatCard(
                        "${stats?['totalPoints'] ?? 0}",
                        "总积分",
                        Colors.purple,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 成就系统
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "我的成就",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (userProvider.achievements.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text("完成投放即可解锁成就"),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: userProvider.achievements
                              .map(
                                (achievement) => Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow[50],
                                    border: Border.all(
                                      color: Colors.yellow[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        achievement['icon'] ?? '🏆',
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        achievement['name'] ?? '成就',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 我的收藏
            Consumer<FavoritesProvider>(
              builder: (context, favoritesProvider, _) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "我的收藏",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${favoritesProvider.favorites.length}项",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (favoritesProvider.favorites.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text("暂无收藏"),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: favoritesProvider.favorites.length,
                          itemBuilder: (context, index) {
                            final favorite = favoritesProvider.favorites[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                                title: Text(favorite['name'] ?? favorite['item_name'] ?? '收藏项目'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    favoritesProvider.removeFavorite(favorite['id']);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 功能菜单
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "更多选项",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuTile(
                    "投放地点",
                    Icons.location_on,
                    () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("投放地点"),
                          content: const Text(
                            "推荐投放地点:\n\n"
                            "• 社区垃圾投放点\n"
                            "• 学校垃圾投放点\n"
                            "• 办公楼垃圾投放点\n"
                            "• 商场垃圾投放点",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("关闭"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _buildMenuTile(
                    "关于我们",
                    Icons.info,
                    () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("关于我们"),
                          content: const Text(
                            "绿意分类 v1.0.0\n\n"
                            "一个专业的垃圾分类应用，帮助用户正确分类垃圾，\n"
                            "参与环保行动，为地球做贡献。\n\n"
                            "© 2026 绿意分类",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("关闭"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _buildMenuTile(
                    "用户协议",
                    Icons.description,
                    () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("用户协议"),
                          content: const SingleChildScrollView(
                            child: Text(
                              "用户协议内容...\n\n"
                              "请遵守相关法律法规，\n"
                              "正确使用本应用提供的服务。",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("关闭"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _buildMenuTile(
                    "退出登录",
                    Icons.logout,
                    () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("确认退出"),
                          content: const Text("确定要退出登录吗？"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("取消"),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<AppState>().logout();
                                context.read<UserProvider>().logout();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text("退出"),
                            ),
                          ],
                        ),
                      );
                    },
                    Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String title, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    String title,
    IconData icon,
    VoidCallback onTap, [
    Color? color,
  ]) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.green),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
