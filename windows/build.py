import os
import subprocess
import sys

def get_version():
    """从 pubspec.yaml 读取版本号"""
    with open('pubspec.yaml', 'r', encoding='utf-8') as f:
        content = f.read()

    # 提取 version: x.x.x+x 格式中的版本号部分
    for line in content.split('\n'):
        if line.startswith('version:'):
            version_line = line.split('version:')[1].strip()
            version = version_line.split('+')[0].strip()
            return version

    raise Exception("无法从 pubspec.yaml 中找到版本号")

def main():
    print("开始构建 Windows 应用...")

    # 1. 运行 Flutter 构建
    print("\n步骤 1/5: 执行 Flutter 构建...")
    result = subprocess.run(["flutter", "build", "windows", "--release"], shell=True)
    if result.returncode != 0:
        print("Flutter 构建失败!")
        sys.exit(1)

    # 2. 获取版本号
    print("\n步骤 2/5: 获取版本号...")
    version = get_version()
    print(f"当前版本: {version}")

    # 3. 创建带版本号的 ZIP
    print("\n步骤 3/5: 创建 ZIP 压缩包...")
    os.makedirs("build/windows", exist_ok=True)

    # 删除旧的 zip 文件
    zip_filename = f"i_iwara-{version}-windows.zip"
    zip_path = f"build/windows/{zip_filename}"
    if os.path.exists(zip_path):
        os.remove(zip_path)

    # 创建新的 zip（使用 tar 命令，Windows 自带）
    result = subprocess.run([
        "tar", "-a", "-c", "-f",
        zip_path,
        "-C", "build/windows/x64/runner/Release",
        "*"
    ], shell=True)

    if result.returncode != 0:
        print("创建 ZIP 失败!")
        sys.exit(1)
    print(f"ZIP 创建成功: {zip_path}")

    # 4. 处理 Inno Setup 脚本
    print("\n步骤 4/5: 准备 Inno Setup 配置...")

    # 检查并下载中文翻译文件
    chinese_isl_path = "windows/ChineseSimplified.isl"
    if not os.path.exists(chinese_isl_path):
        print("下载中文翻译文件...")
        try:
            import httpx
            url = "https://cdn.jsdelivr.net/gh/kira-96/Inno-Setup-Chinese-Simplified-Translation@latest/ChineseSimplified.isl"
            response = httpx.get(url)
            response.raise_for_status()
            with open(chinese_isl_path, 'wb') as f:
                f.write(response.content)
            print("中文翻译文件下载成功")
        except Exception as e:
            print(f"警告: 下载中文翻译文件失败: {e}")
            print("将继续使用英文界面")

    # 读取原始 build.iss
    iss_path = "windows/build.iss"
    with open(iss_path, 'r', encoding='utf-8') as f:
        iss_content = f.read()

    # 替换占位符
    root_path = os.getcwd().replace('\\', '/')
    new_iss_content = iss_content.replace('{{version}}', version).replace('{{root_path}}', root_path)

    # 写入临时修改
    with open(iss_path, 'w', encoding='utf-8') as f:
        f.write(new_iss_content)

    # 5. 运行 Inno Setup 编译
    print("\n步骤 5/5: 生成安装程序...")
    try:
        result = subprocess.run(["iscc", iss_path], shell=True)
        if result.returncode != 0:
            print("Inno Setup 编译失败!")
            # 还原 build.iss
            with open(iss_path, 'w', encoding='utf-8') as f:
                f.write(iss_content)
            sys.exit(1)
    finally:
        # 还原 build.iss
        with open(iss_path, 'w', encoding='utf-8') as f:
            f.write(iss_content)

    print("\n构建完成!")
    print(f"ZIP 文件: {zip_path}")
    installer_path = f"build/windows/i_iwara-{version}-windows-setup.exe"
    print(f"安装程序: {installer_path}")

if __name__ == '__main__':
    main()
