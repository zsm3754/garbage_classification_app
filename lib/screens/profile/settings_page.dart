import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../main.dart';
import '../auth/login_page.dart';
import '../../providers/auth_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("设置"),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text("更换用户名"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                _showChangeUsernameDialog();
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("上传头像"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                _showUploadAvatarDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeUsernameDialog() {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("更换用户名"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "新用户名",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "密码",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () async {
              if (usernameController.text.trim().isNotEmpty && passwordController.text.isNotEmpty) {
                try {
                  // 获取当前登录用户的ID
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final userId = authProvider.userId ?? 1;
                  
                  final response = await http.post(
                    Uri.parse('http://192.168.43.23:8000/api/user/update/username'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'user_id': userId,
                      'new_username': usernameController.text.trim(),
                      'password': passwordController.text.trim(),
                    }),
                  );

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("用户名修改成功")),
                    );
                    
                    // 刷新用户信息
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    await authProvider.refreshUserInfo();
                    
                    // 刷新页面显示
                    if (mounted) {
                      setState(() {});
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("用户名修改失败")),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("网络错误")),
                  );
                }
              }
              Navigator.pop(context);
            },
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }

  void _showUploadAvatarDialog() {
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("上传头像"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "密码",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text("选择头像来源："),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImageFromCamera(passwordController.text);
                  },
                  child: const Text("拍照"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImageFromGallery(passwordController.text);
                  },
                  child: const Text("相册"),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
        ],
      ),
    );
  }

  void _pickImageFromCamera(String password) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _uploadImage(image, password);
    }
  }

  void _pickImageFromGallery(String password) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _uploadImage(image, password);
    }
  }

  void _uploadImage(XFile image, String password) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.43.23:8000/api/user/upload/avatar'),
      );
      
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        image.path,
      ));
      
      // 获取当前登录用户的ID
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId ?? 1;
      
      request.fields['user_id'] = userId.toString();
      request.fields['password'] = password;
      
      final response = await request.send();
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("头像上传成功")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("头像上传失败")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("上传错误")),
      );
    }
  }
}
