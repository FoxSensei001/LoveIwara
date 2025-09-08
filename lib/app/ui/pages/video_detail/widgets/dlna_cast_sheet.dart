import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../i18n/strings.g.dart';
import '../controllers/dlna_cast_service.dart';

class DlnaCastSheet extends StatefulWidget {
  final String videoUrl;
  final DlnaCastService dlnaController;

  const DlnaCastSheet({
    super.key,
    required this.videoUrl,
    required this.dlnaController,
  });

  @override
  State<DlnaCastSheet> createState() => _DlnaCastSheetState();
}

class _DlnaCastSheetState extends State<DlnaCastSheet> {
  @override
  void initState() {
    super.initState();
    // 弹出时自动开始搜索
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.dlnaController.startSearch();
    });
  }

  @override
  void dispose() {
    // 关闭时自动停止搜索
    widget.dlnaController.stopSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isNarrowScreen = screenSize.width < 600;
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: isNarrowScreen ? screenSize.height * 0.8 : 600,
        maxWidth: isNarrowScreen ? screenSize.width : 400,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isNarrowScreen ? const Radius.circular(16) : Radius.zero,
          bottomRight: isNarrowScreen ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Container(
            padding: EdgeInsets.all(isNarrowScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cast,
                  color: Theme.of(context).primaryColor,
                  size: isNarrowScreen ? 20 : 24,
                ),
                SizedBox(width: isNarrowScreen ? 6 : 8),
                Expanded(
                  child: Text(
                    t.videoDetail.cast.dlnaCastSheet.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: isNarrowScreen ? 18 : 20,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                  tooltip: t.videoDetail.cast.dlnaCastSheet.close,
                  iconSize: isNarrowScreen ? 20 : 24,
                ),
              ],
            ),
          ),
          
          // 内容区域
          Flexible(
            child: Padding(
              padding: EdgeInsets.all(isNarrowScreen ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 搜索状态和按钮
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => Text(
                          widget.dlnaController.isSearching.value
                              ? t.videoDetail.cast.dlnaCastSheet.searchingDevices
                              : t.videoDetail.cast.dlnaCastSheet.searchPrompt,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: isNarrowScreen ? 13 : 14,
                          ),
                        )),
                      ),
                      SizedBox(width: isNarrowScreen ? 6 : 8),
                      Obx(() => ElevatedButton.icon(
                        onPressed: widget.dlnaController.isSearching.value
                            ? null
                            : () => widget.dlnaController.startSearch(),
                        icon: widget.dlnaController.isSearching.value
                            ? SizedBox(
                                width: isNarrowScreen ? 14 : 16,
                                height: isNarrowScreen ? 14 : 16,
                                child: const CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                Icons.search,
                                size: isNarrowScreen ? 16 : 18,
                              ),
                        label: Text(
                          widget.dlnaController.isSearching.value ? t.videoDetail.cast.dlnaCastSheet.searching : t.videoDetail.cast.dlnaCastSheet.searchAgain,
                          style: TextStyle(
                            fontSize: isNarrowScreen ? 12 : 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isNarrowScreen ? 8 : 12,
                            vertical: isNarrowScreen ? 6 : 8,
                          ),
                        ),
                      )),
                    ],
                  ),
                  
                  SizedBox(height: isNarrowScreen ? 12 : 16),
                  
                  // 设备列表
                  Expanded(
                    child: Obx(() {
                      if (widget.dlnaController.devices.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.devices_other,
                                size: isNarrowScreen ? 48 : 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: isNarrowScreen ? 12 : 16),
                              Text(
                                widget.dlnaController.isSearching.value
                                    ? t.videoDetail.cast.dlnaCastSheet.searchingDevicesPrompt
                                    : t.videoDetail.cast.dlnaCastSheet.noDevicesFound,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isNarrowScreen ? 12 : 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: widget.dlnaController.devices.length,
                        itemBuilder: (context, index) {
                          final device = widget.dlnaController.devices[index];
                          final deviceType = device.info.deviceType.split(':')[3];
                          
                          return Card(
                            margin: EdgeInsets.only(bottom: isNarrowScreen ? 6 : 8),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: isNarrowScreen ? 8 : 16,
                                vertical: isNarrowScreen ? 4 : 8,
                              ),
                              leading: widget.dlnaController.getDeviceIcon(deviceType),
                              title: Text(
                                device.info.friendlyName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: isNarrowScreen ? 14 : 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                widget.dlnaController.getDeviceTypeName(deviceType),
                                style: TextStyle(
                                  fontSize: isNarrowScreen ? 12 : 14,
                                ),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  widget.dlnaController.castToDevice(device, widget.videoUrl);
                                  Get.back(); // 投屏后关闭对话框
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isNarrowScreen ? 8 : 12,
                                    vertical: isNarrowScreen ? 4 : 6,
                                  ),
                                ),
                                child: Text(
                                  t.videoDetail.cast.dlnaCastSheet.cast,
                                  style: TextStyle(
                                    fontSize: isNarrowScreen ? 12 : 14,
                                  ),
                                ),
                              ),
                              onTap: () {
                                widget.dlnaController.castToDevice(device, widget.videoUrl);
                                Get.back(); // 投屏后关闭对话框
                              },
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          
          // 底部按钮
          Container(
            padding: EdgeInsets.only(
              left: isNarrowScreen ? 12 : 16,
              right: isNarrowScreen ? 12 : 16,
              top: isNarrowScreen ? 12 : 16,
              bottom: isNarrowScreen ? 12 + MediaQuery.of(context).padding.bottom : 16 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 连接状态
                Obx(() => widget.dlnaController.isConnected.value
                    ? Text(
                        t.videoDetail.cast.dlnaCastSheet.connectedTo(deviceName: widget.dlnaController.connectedDeviceName.value),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: isNarrowScreen ? 12 : 14,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        t.videoDetail.cast.dlnaCastSheet.notConnected,
                        style: TextStyle(
                          fontSize: isNarrowScreen ? 12 : 14,
                        ),
                        textAlign: TextAlign.center,
                      )),
                SizedBox(height: isNarrowScreen ? 8 : 12),
                // 按钮行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (widget.dlnaController.isConnected.value)
                      Expanded(
                        child: TextButton(
                          onPressed: () => widget.dlnaController.stopCast(),
                          child: Text(
                            t.videoDetail.cast.dlnaCastSheet.stopCasting,
                            style: TextStyle(
                              fontSize: isNarrowScreen ? 12 : 14,
                            ),
                          ),
                        ),
                      ),
                    if (widget.dlnaController.isConnected.value)
                      SizedBox(width: isNarrowScreen ? 8 : 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          t.videoDetail.cast.dlnaCastSheet.close,
                          style: TextStyle(
                            fontSize: isNarrowScreen ? 12 : 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
