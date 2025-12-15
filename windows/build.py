import os
import subprocess
import sys

def get_version():
    """Read version from pubspec.yaml"""
    with open('pubspec.yaml', 'r', encoding='utf-8') as f:
        content = f.read()

    # Extract version from version: x.x.x+x format
    for line in content.split('\n'):
        if line.startswith('version:'):
            version_line = line.split('version:')[1].strip()
            version = version_line.split('+')[0].strip()
            return version

    raise Exception("Cannot find version in pubspec.yaml")

def main():
    print("Starting Windows build...")

    # 1. Run Flutter build
    print("\nStep 1/5: Building Flutter app...")
    result = subprocess.run(["flutter", "build", "windows", "--release"], shell=True)
    if result.returncode != 0:
        print("Flutter build failed!")
        sys.exit(1)

    # 2. Get version
    print("\nStep 2/5: Getting version...")
    version = get_version()
    print(f"Current version: {version}")

    # 3. Create ZIP with version
    print("\nStep 3/5: Creating ZIP archive...")
    os.makedirs("build/windows", exist_ok=True)

    # Remove old zip file if exists
    zip_filename = f"i_iwara-{version}-windows.zip"
    zip_path = f"build/windows/{zip_filename}"
    if os.path.exists(zip_path):
        os.remove(zip_path)

    # Create new zip using Windows built-in tar command
    result = subprocess.run([
        "tar", "-a", "-c", "-f",
        zip_path,
        "-C", "build/windows/x64/runner/Release",
        "*"
    ], shell=True)

    if result.returncode != 0:
        print("ZIP creation failed!")
        sys.exit(1)
    print(f"ZIP created successfully: {zip_path}")

    # 4. Process Inno Setup script
    print("\nStep 4/5: Preparing Inno Setup configuration...")

    # Check and download Chinese translation file
    chinese_isl_path = "windows/ChineseSimplified.isl"
    if not os.path.exists(chinese_isl_path):
        print("Downloading Chinese translation file...")
        try:
            import httpx
            url = "https://cdn.jsdelivr.net/gh/kira-96/Inno-Setup-Chinese-Simplified-Translation@latest/ChineseSimplified.isl"
            response = httpx.get(url)
            response.raise_for_status()
            with open(chinese_isl_path, 'wb') as f:
                f.write(response.content)
            print("Chinese translation file downloaded successfully")
        except Exception as e:
            print(f"Warning: Failed to download Chinese translation file: {e}")
            print("Continuing with English interface")

    # Read original build.iss
    iss_path = "windows/build.iss"
    with open(iss_path, 'r', encoding='utf-8') as f:
        iss_content = f.read()

    # Replace placeholders
    # Keep Windows path format with backslashes for Inno Setup
    root_path = os.getcwd()
    new_iss_content = iss_content.replace('{{version}}', version).replace('{{root_path}}', root_path)

    # Write temporary changes
    with open(iss_path, 'w', encoding='utf-8') as f:
        f.write(new_iss_content)

    # 5. Run Inno Setup compilation
    print("\nStep 5/5: Building installer...")
    try:
        result = subprocess.run(["iscc", iss_path], shell=True)
        if result.returncode != 0:
            print("Inno Setup compilation failed!")
            # Restore build.iss
            with open(iss_path, 'w', encoding='utf-8') as f:
                f.write(iss_content)
            sys.exit(1)
    finally:
        # Restore build.iss
        with open(iss_path, 'w', encoding='utf-8') as f:
            f.write(iss_content)

    print("\nBuild complete!")
    print(f"ZIP file: {zip_path}")
    installer_path = f"build/windows/i_iwara-{version}-windows-setup.exe"
    print(f"Installer: {installer_path}")

if __name__ == '__main__':
    main()
