import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/user.model.dart';

Widget buildUserName(BuildContext context, User? user,
    {double? fontSize, int? overflowLines, bool bold = false, Color? defaultNameColor}) {
  if (user == null) {
    return const SizedBox.shrink();
  }
  // 根据用户角色设置颜色，已更新为与头像的颜色保持同步
  Color? nameColor;
  if (user.role == 'admin' || user.isAdmin) {
    nameColor = Colors.red;
  } else if (user.role == 'officer' || user.role == 'moderator') {
    nameColor = Colors.green.shade400;
  } else if (user.role == 'limited') {
    nameColor = Colors.grey.shade400;
  } else {
    nameColor = defaultNameColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
  }

  // 如果是高级用户,使用渐变效果
  if (user.premium) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          Colors.purple.shade300,
          Colors.blue.shade300,
          Colors.pink.shade300,
        ],
      ).createShader(bounds),
      child: Text(
        user.name,
        maxLines: overflowLines ?? 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize ?? 12,
          color: Colors.white,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // 普通用户名显示
  return Text(
    user.name,
    maxLines: overflowLines ?? 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: fontSize ?? 12,
      color: nameColor,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    ),
  );
}
