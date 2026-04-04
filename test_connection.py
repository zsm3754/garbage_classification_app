"""
前后端连接测试脚本
用于快速验证API连接和识别功能
"""

import requests
import json
from pathlib import Path
from typing import Dict, Any

# 配置
API_BASE_URL = "http://192.168.43.23:8000"
TIMEOUT = 10


class ApiConnectionTester:
    """API连接测试工具"""
    
    def __init__(self, base_url: str = API_BASE_URL):
        self.base_url = base_url
        self.results = {
            "server_health": False,
            "model_loaded": False,
            "endpoints": {}
        }
    
    def print_header(self, text: str):
        """打印标题"""
        print("\n" + "="*60)
        print(f"  {text}")
        print("="*60)
    
    def print_status(self, status: str, message: str):
        """打印状态"""
        icons = {
            "ok": "✅",
            "error": "❌",
            "warning": "⚠️",
            "info": "ℹ️",
            "loading": "🔄"
        }
        icon = icons.get(status, "•")
        print(f"{icon} {message}")
    
    def test_server_connection(self) -> bool:
        """测试后端服务是否在线"""
        self.print_header("1. 测试后端连接")
        
        try:
            print(f"   地址: {self.base_url}")
            print(f"   超时: {TIMEOUT}秒")
            
            response = requests.get(
                f"{self.base_url}/",
                timeout=TIMEOUT
            )
            
            if response.status_code == 200:
                data = response.json()
                self.print_status("ok", f"后端服务在线！")
                self.print_status("info", f"服务状态: {data.get('status')}")
                self.print_status("info", f"服务名称: {data.get('service')}")
                self.print_status("info", f"版本: {data.get('version')}")
                self.results["server_health"] = True
                return True
            else:
                self.print_status("error", f"服务返回错误状态码: {response.status_code}")
                return False
        
        except requests.exceptions.ConnectionError:
            self.print_status("error", "连接被拒绝 - 后端服务未启动")
            self.print_status("info", "请运行: python main.py")
            return False
        except requests.exceptions.Timeout:
            self.print_status("error", f"连接超时 ({TIMEOUT}秒)")
            self.print_status("info", "检查后端是否响应缓慢")
            return False
        except Exception as e:
            self.print_status("error", f"连接失败: {e}")
            return False
    
    def test_detailed_health(self) -> bool:
        """测试详细健康检查"""
        self.print_header("2. 测试详细健康检查")
        
        try:
            response = requests.get(
                f"{self.base_url}/api/health",
                timeout=TIMEOUT
            )
            
            if response.status_code == 200:
                data = response.json()
                self.print_status("ok", "健康检查通过")
                self.print_status("info", f"数据库: {data.get('database')}")
                
                model_info = data.get('model', {})
                if model_info.get('loaded'):
                    self.print_status("ok", "YOLO模型已加载")
                    self.print_status("info", f"模型路径: {model_info.get('path')}")
                    self.print_status("info", f"支持的类别: {model_info.get('classes')}")
                    self.results["model_loaded"] = True
                else:
                    self.print_status("error", "YOLO模型未加载")
                    return False
                
                return True
            else:
                self.print_status("error", f"健康检查失败: {response.status_code}")
                return False
        
        except Exception as e:
            self.print_status("error", f"测试失败: {e}")
            return False
    
    def test_endpoints(self) -> Dict[str, bool]:
        """测试所有端点"""
        self.print_header("3. 测试API端点")
        
        endpoints = {
            "/api/category/all": "GET",
            "/api/quiz/all": "GET",
            "/api/user/1": "GET",
        }
        
        for endpoint, method in endpoints.items():
            try:
                url = f"{self.base_url}{endpoint}"
                print(f"   测试: {method} {endpoint}")
                
                if method == "GET":
                    response = requests.get(url, timeout=TIMEOUT)
                
                if response.status_code == 200:
                    self.print_status("ok", f"端点可访问")
                    self.results["endpoints"][endpoint] = True
                else:
                    self.print_status("warning", f"状态码: {response.status_code}")
                    self.results["endpoints"][endpoint] = False
            
            except Exception as e:
                self.print_status("error", f"访问失败: {e}")
                self.results["endpoints"][endpoint] = False
        
        return self.results["endpoints"]
    
    def test_recognition_with_image(self, image_path: str) -> bool:
        """测试识别功能（需要真实图片）"""
        self.print_header("4. 测试识别功能")
        
        if not Path(image_path).exists():
            self.print_status("warning", f"图片不存在，跳过此测试: {image_path}")
            return False
        
        try:
            print(f"   图片路径: {image_path}")
            print(f"   上传中...")
            
            with open(image_path, 'rb') as f:
                files = {'file': f}
                response = requests.post(
                    f"{self.base_url}/api/garbage/recognize",
                    files=files,
                    timeout=30  # 识别可能需要更长时间
                )
            
            if response.status_code == 200:
                data = response.json()
                self.print_status("ok", "识别成功")
                
                result = data.get('data', {}).get('recognize_result', {})
                self.print_status("info", f"类别: {result.get('class_cn')}")
                self.print_status("info", f"英文: {result.get('class_en')}")
                self.print_status("info", f"置信度: {result.get('confidence')}")
                
                return True
            else:
                self.print_status("error", f"识别失败: {response.status_code}")
                print(f"   响应: {response.text}")
                return False
        
        except Exception as e:
            self.print_status("error", f"测试失败: {e}")
            return False
    
    def print_summary(self):
        """打印测试总结"""
        self.print_header("测试总结")
        
        if self.results["server_health"]:
            self.print_status("ok", "后端服务: 运行中")
        else:
            self.print_status("error", "后端服务: 离线")
        
        if self.results["model_loaded"]:
            self.print_status("ok", "YOLO模型: 已加载")
        else:
            self.print_status("error", "YOLO模型: 未加载")
        
        working_endpoints = len([e for e in self.results["endpoints"].values() if e])
        total_endpoints = len(self.results["endpoints"])
        self.print_status("info", f"端点: {working_endpoints}/{total_endpoints} 可用")
        
        # 最终状态
        if self.results["server_health"] and self.results["model_loaded"]:
            self.print_status("ok", "✨ 系统准备就绪，可以开始使用！")
            return True
        else:
            self.print_status("error", "❌ 系统存在问题，请检查错误信息")
            return False
    
    def run_all_tests(self, image_path: str = None):
        """运行所有测试"""
        self.print_header("🚀 前后端连接测试")
        print(f"API基址: {self.base_url}")
        
        # 基础测试
        if not self.test_server_connection():
            self.print_status("error", "后端服务未运行，无法继续测试")
            self.print_summary()
            return False
        
        self.test_detailed_health()
        self.test_endpoints()
        
        # 如果提供了图片，进行识别测试
        if image_path:
            self.test_recognition_with_image(image_path)
        
        # 打印总结
        success = self.print_summary()
        
        print("\n")
        return success


def main():
    """主函数"""
    print("\n")
    print("█" * 60)
    print("█  垃圾分类APP - 前后端集成测试")
    print("█" * 60)
    
    tester = ApiConnectionTester()
    
    # 运行所有测试
    # 如果有垃圾图片，可以替换路径进行识别测试
    success = tester.run_all_tests(image_path=None)
    
    print("提示:")
    print("  • 如需测试识别功能，在 run_all_tests() 中提供图片路径")
    print("  • 例: tester.run_all_tests(image_path='test_image.jpg')")
    print("  • 查看详细日志: INTEGRATION_QUICK_START.md")
    print("\n")
    
    return success


if __name__ == "__main__":
    try:
        success = main()
        exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\n用户中止测试")
        exit(1)
    except Exception as e:
        print(f"\n❌ 测试异常: {e}")
        exit(1)
