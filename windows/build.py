import os
import subprocess
import sys
from pathlib import Path

OUTPUT_DIR = Path("build/windows")
RELEASE_DIR = Path("build/windows/x64/runner/Release")
APP_EXE_NAME = "i_iwara.exe"

def run_command(command: str, step_name: str) -> None:
    """Run external command and raise with a clear step label on failure."""
    if not command:
        raise ValueError(f"{step_name} failed: empty command")

    result = subprocess.run(command, shell=True, check=False)
    if result.returncode != 0:
        raise RuntimeError(
            f"{step_name} failed with exit code {result.returncode}: {command}"
        )

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


def validate_release_bundle() -> None:
    """Check that release output contains the executable required for installer."""
    if not RELEASE_DIR.exists():
        raise FileNotFoundError(f"Release directory not found: {RELEASE_DIR}")

    app_exe = RELEASE_DIR / APP_EXE_NAME
    if not app_exe.exists():
        raise FileNotFoundError(
            f"Missing required executable in Release bundle: {APP_EXE_NAME}"
        )


def main():
    print("Starting Windows build...")

    try:
        # 1. Run Flutter build
        print("\nStep 1/4: Building Flutter app...")
        run_command("flutter build windows --release", "Flutter build")
        validate_release_bundle()

        # 2. Get version
        print("\nStep 2/4: Getting version...")
        version = get_version()
        print(f"Current version: {version}")

        # 3. Process Inno Setup script
        print("\nStep 3/4: Preparing Inno Setup configuration...")

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

        # 4. Run Inno Setup compilation
        print("\nStep 4/4: Building installer...")
        try:
            run_command(f'iscc "{iss_path}"', "Inno Setup compilation")
        finally:
            # Restore build.iss
            with open(iss_path, 'w', encoding='utf-8') as f:
                f.write(iss_content)

        print("\nBuild complete!")
        installer_path = OUTPUT_DIR / f"i_iwara-{version}-windows-setup.exe"
        print(f"Installer: {installer_path}")
    except Exception as error:
        print(f"Build failed: {error}")
        sys.exit(1)

if __name__ == '__main__':
    main()
