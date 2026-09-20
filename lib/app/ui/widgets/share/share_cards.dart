import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// 分享卡片里的一个统计项（观看数、评论数、粉丝数……）。
class ShareCardStat {
  final String label;
  final String value;

  const ShareCardStat(this.label, this.value);
}

/// 分享卡片右上/右下的二维码块。
///
/// 白底 + 轻投影，保证暗色卡片上也能扫；二维码四周留足 quiet zone。
class ShareCardQrBox extends StatelessWidget {
  final String url;

  const ShareCardQrBox({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: QrImageView(data: url, version: QrVersions.auto, size: 84),
    );
  }
}

/// 媒体（视频 / 图库）分享卡：封面大图 + 标题 + 作者 + 二维码。
///
/// 供 [ShareImageBottomSheet] 截图成 PNG 分享，卡片自带白底，
/// 不依赖外部背景。
class MediaShareCard extends StatelessWidget {
  final String coverUrl;
  final String title;
  final String authorName;
  final String url;

  const MediaShareCard({
    super.key,
    required this.coverUrl,
    required this.title,
    required this.authorName,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: coverUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 标题、作者和二维码区域
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '@$authorName',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ShareCardQrBox(url: url),
            ],
          ),
        ],
      ),
    );
  }
}

/// 文本内容（帖子 / 论坛主题）分享卡：头像 + 统计面板 + 标题 + 作者行 + 二维码。
///
/// [authorLine] 由调用方提供（帖子用富用户名组件、论坛用普通文本），
/// 卡片本身不耦合用户模型。
class TextContentShareCard extends StatelessWidget {
  final String? avatarUrl;
  final String title;
  final Widget authorLine;
  final List<ShareCardStat> stats;
  final String url;

  const TextContentShareCard({
    super.key,
    required this.avatarUrl,
    required this.title,
    required this.authorLine,
    required this.stats,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部信息
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AvatarWidget(avatarUrl: avatarUrl, size: 56),
              const SizedBox(width: 16),
              // 统计信息
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < stats.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        Text(
                          stats[i].label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stats[i].value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ShareCardQrBox(url: url),
            ],
          ),
          const SizedBox(height: 16),
          // 标题和作者
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              authorLine,
            ],
          ),
        ],
      ),
    );
  }
}

/// 用户主页分享卡：头像 + 昵称/@handle + 三项统计 + 二维码。
class ProfileShareCard extends StatelessWidget {
  final String? avatarUrl;
  final String displayName;
  final String handle;
  final List<ShareCardStat> stats;
  final String url;

  const ProfileShareCard({
    super.key,
    required this.avatarUrl,
    required this.displayName,
    required this.handle,
    required this.stats,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部信息
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AvatarWidget(avatarUrl: avatarUrl, size: 56),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@$handle',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ShareCardQrBox(url: url),
            ],
          ),
          const SizedBox(height: 16),
          // 统计信息
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final stat in stats)
                  _buildStatItem(stat.value, stat.label),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}
