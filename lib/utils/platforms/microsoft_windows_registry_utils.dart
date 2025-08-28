// ignore_for_file: constant_identifier_names

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';


const internetSettingsKey = r'Software\Microsoft\Windows\CurrentVersion\Internet Settings';
const MAX_ITEMLENGTH = 1024;

/// 注册表操作工具类
class RegistryUtil {

  /// 打开指定的注册表键
  ///
  /// [hive] 注册表根键，如 HKEY_CURRENT_USER
  /// [keyPath] 子键路径
  /// 返回打开的注册表键句柄
  static int openKey(int hive, String keyPath) {
    final phKey = calloc<HANDLE>();
    final lpKeyPath = keyPath.toNativeUtf16();
    try {
      final result = RegOpenKeyEx(
          hive, lpKeyPath, 0, KEY_READ, phKey);
      if (result != ERROR_SUCCESS) {
        throw Exception("无法打开注册表键: $keyPath");
      }
      return phKey.value;
    } finally {
      free(phKey);
      free(lpKeyPath);
    }
  }

  /// 查询指定注册表键的值
  ///
  /// [hKey] 注册表键句柄
  /// [valueName] 值的名称
  /// 返回值的内容，类型可以是 int 或 String，若查询失败则返回 null
  static dynamic queryValue(int hKey, String valueName) {
    final lpValueName = valueName.toNativeUtf16();
    final lpType = calloc<DWORD>();
    final lpData = calloc<BYTE>(MAX_ITEMLENGTH);
    final lpcbData = calloc<DWORD>()..value = MAX_ITEMLENGTH;

    try {
      final status = RegQueryValueEx(
          hKey, lpValueName, nullptr, lpType, lpData, lpcbData);

      if (status != ERROR_SUCCESS) {
        return null;
      }

      switch (lpType.value) {
        case REG_DWORD:
          return lpData.cast<DWORD>().value;
        case REG_SZ:
          return lpData.cast<Utf16>().toDartString();
        default:
          return null;
      }
    } finally {
      free(lpValueName);
      free(lpType);
      free(lpData);
      free(lpcbData);
    }
  }

  /// 关闭注册表键
  ///
  /// [hKey] 注册表键句柄
  static void closeKey(int hKey) {
    RegCloseKey(hKey);
  }
}