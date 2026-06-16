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
    """Read version (x.x.x) and a 4-part VersionInfo (x.x.x.build) from pubspec.yaml.

    pubspec uses the `version: x.y.z+build` convention. The dotted version drives
    the user-facing AppVersion; the 4-part form fills the installer EXE's
    VersionInfoVersion (Windows requires a numeric a.b.c.d there).
    """
    with open('pubspec.yaml', 'r', encoding='utf-8') as f:
        content = f.read()

    for line in content.split('\n'):
        if line.startswith('version:'):
            version_line = line.split('version:')[1].strip()
            version = version_line.split('+')[0].strip()
            build = version_line.split('+')[1].strip() if '+' in version_line else '0'
            # Normalize to exactly four numeric segments.
            parts = (version.split('.') + ['0', '0', '0'])[:3]
            version4 = '.'.join(parts + [build if build.isdigit() else '0'])
            return version, version4

    raise Exception("Cannot find version in pubspec.yaml")


def sign_installer(installer_path: Path) -> None:
    """Authenticode-sign the installer if signing env vars are configured.

    The certificate can be provided either as:
      - WINDOWS_CERT_BASE64  : base64 of a .pfx (the usual GitHub-secret form;
                               decoded to a temp file here), or
      - WINDOWS_CERT_FILE    : a path to an existing .pfx on the runner.
    Both forms require WINDOWS_CERT_PASSWORD. When none is configured (the
    default), signing is skipped and the unsigned installer ships — no failure.

    Args are passed as a list (shell=False) so cert paths / passwords / URLs
    containing shell metacharacters cannot break or be interpreted by a shell.
    """
    import base64
    import tempfile

    cert_password = os.environ.get('WINDOWS_CERT_PASSWORD')
    cert_base64 = os.environ.get('WINDOWS_CERT_BASE64')
    cert_file = os.environ.get('WINDOWS_CERT_FILE')

    has_cert = bool(cert_base64 or cert_file)
    complete = has_cert and bool(cert_password)
    any_present = has_cert or bool(cert_password)

    if not complete:
        # If signing was partially configured (e.g. a typo'd secret name in a
        # release pipeline), fail loudly rather than silently shipping unsigned.
        if any_present and os.environ.get('ALLOW_UNSIGNED_RELEASE') != '1':
            raise RuntimeError(
                "Windows signing is partially configured. Need a cert "
                "(WINDOWS_CERT_BASE64 or WINDOWS_CERT_FILE) AND "
                "WINDOWS_CERT_PASSWORD. To intentionally ship an unsigned "
                "build, set ALLOW_UNSIGNED_RELEASE=1.")
        print("No Windows signing certificate configured; skipping signature.")
        return

    timestamp_url = os.environ.get('WINDOWS_CERT_TIMESTAMP_URL',
                                   'http://timestamp.digicert.com')
    signtool = os.environ.get('SIGNTOOL', 'signtool')

    temp_pfx = None
    try:
        if cert_base64:
            fd, temp_pfx = tempfile.mkstemp(suffix='.pfx')
            with os.fdopen(fd, 'wb') as f:
                f.write(base64.b64decode(cert_base64))
            pfx_path = temp_pfx
        else:
            pfx_path = cert_file

        args = [
            signtool, 'sign',
            '/f', pfx_path,
            '/p', cert_password,
            '/fd', 'SHA256',
            '/tr', timestamp_url,
            '/td', 'SHA256',
            str(installer_path),
        ]
        result = subprocess.run(args, check=False)
        if result.returncode != 0:
            raise RuntimeError(
                f"Installer signing failed with exit code {result.returncode}")
        print(f"Signed installer: {installer_path}")
    finally:
        if temp_pfx and os.path.exists(temp_pfx):
            os.remove(temp_pfx)


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
        print("\nStep 1/5: Building Flutter app...")
        run_command("flutter build windows --release", "Flutter build")
        validate_release_bundle()

        # 2. Get version
        print("\nStep 2/5: Getting version...")
        version, version4 = get_version()
        print(f"Current version: {version} (VersionInfo: {version4})")

        # 3. Process Inno Setup script
        print("\nStep 3/5: Preparing Inno Setup configuration...")

        # The Chinese translation file is vendored in the repo so the build does
        # not depend on a CDN at compile time. Only fall back to a download if it
        # is somehow missing, and degrade gracefully (English-only) if that fails.
        chinese_isl_path = "windows/ChineseSimplified.isl"
        if not os.path.exists(chinese_isl_path):
            print("Chinese translation file missing, attempting download...")
            try:
                import httpx
                url = "https://cdn.jsdelivr.net/gh/kira-96/Inno-Setup-Chinese-Simplified-Translation@latest/ChineseSimplified.isl"
                response = httpx.get(url, timeout=30, follow_redirects=True)
                response.raise_for_status()
                with open(chinese_isl_path, 'wb') as f:
                    f.write(response.content)
                print("Chinese translation file downloaded successfully")
            except Exception as e:
                print(f"Warning: Failed to download Chinese translation file: {e}")
                print("Continuing with English interface only")

        # Read original build.iss
        iss_path = "windows/build.iss"
        with open(iss_path, 'r', encoding='utf-8') as f:
            iss_content = f.read()

        # Replace placeholders
        # Keep Windows path format with backslashes for Inno Setup
        root_path = os.getcwd()
        new_iss_content = (
            iss_content
            .replace('{{version4}}', version4)
            .replace('{{version}}', version)
            .replace('{{root_path}}', root_path)
        )

        # If the Chinese translation file is unavailable, drop the language entry
        # instead of letting Inno Setup fail on a missing include file.
        if not os.path.exists(chinese_isl_path):
            new_iss_content = '\n'.join(
                line for line in new_iss_content.splitlines()
                if 'ChineseSimplified.isl' not in line
            )

        # Write temporary changes
        with open(iss_path, 'w', encoding='utf-8') as f:
            f.write(new_iss_content)

        # 4. Run Inno Setup compilation
        print("\nStep 4/5: Building installer...")
        try:
            run_command(f'iscc "{iss_path}"', "Inno Setup compilation")
        finally:
            # Restore build.iss
            with open(iss_path, 'w', encoding='utf-8') as f:
                f.write(iss_content)

        installer_path = OUTPUT_DIR / f"i_iwara-{version}-windows-setup.exe"

        # 5. Optionally sign the installer (no-op without certificate env vars).
        print("\nStep 5/5: Signing installer (if configured)...")
        sign_installer(installer_path)

        print("\nBuild complete!")
        print(f"Installer: {installer_path}")
    except Exception as error:
        print(f"Build failed: {error}")
        sys.exit(1)

if __name__ == '__main__':
    main()
