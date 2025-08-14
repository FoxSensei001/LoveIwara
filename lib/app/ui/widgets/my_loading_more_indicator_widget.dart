import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

Widget myLoadingMoreIndicator(
  BuildContext context,
  IndicatorStatus status, {
  bool isSliver = true,
  LoadingMoreBase? loadingMoreBase,
  double paddingTop = 0,
  IconData? emptyIcon,
}) {
  Widget? widget;
  final t = slang.Translations.of(context);

  // 尝试获取具体的错误消息
  String? errorMessage;
  if (loadingMoreBase != null) {
    try {
      final dynamic repository = loadingMoreBase;
      // 检查是否有lastErrorMessage属性
      if (repository.lastErrorMessage != null) {
        errorMessage = repository.lastErrorMessage as String?;
      }
    } catch (_) {
      // 如果获取失败，使用默认错误消息
    }
  }

  // 如果有错误消息且列表为空且状态为empty，强制显示错误状态
  IndicatorStatus actualStatus = status;
  if (errorMessage != null && 
      errorMessage.isNotEmpty && 
      status == IndicatorStatus.empty && 
      (loadingMoreBase?.isEmpty ?? false)) {
    actualStatus = IndicatorStatus.fullScreenError;
  }

  switch (actualStatus) {
    case IndicatorStatus.none:
      widget = Container(height: 0.0);
      break;
    case IndicatorStatus.loadingMoreBusying:
      widget = Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 5.0),
              height: 15.0,
              width: 15.0,
              child: getIndicator(context),
            ),
            Text(t.common.loading)
          ],
        ),
      );
      break;
    case IndicatorStatus.fullScreenBusying:
      widget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 0.0),
            height: 30.0,
            width: 30.0,
            child: getIndicator(context),
          ),
          const SizedBox(height: 10.0),
          Text(t.common.loading)
        ],
      );
      widget = Padding(
        padding: EdgeInsets.only(top: paddingTop),
        child: Center(child: widget),
      );
      widget = isSliver
          ? SliverFillRemaining(hasScrollBody: false, child: widget)
          : CustomScrollView(
              slivers: <Widget>[SliverFillRemaining(hasScrollBody: false, child: widget)],
            );
      break;
    case IndicatorStatus.error:
      widget = Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: GestureDetector(
          onTap: () => loadingMoreBase?.errorRefresh(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.error, color: Colors.red),
                Text(errorMessage?.isNotEmpty == true ? errorMessage! : t.errors.errorOccurred),
              ],
            ),
          ),
        ),
      );
      break;
    case IndicatorStatus.fullScreenError:
      widget = GestureDetector(
        onTap: () => loadingMoreBase?.errorRefresh(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.error, color: Colors.red),
            Text(errorMessage?.isNotEmpty == true ? errorMessage! : t.errors.errorOccurred),
          ],
        ),
      );
      widget = Padding(
        padding: EdgeInsets.only(top: paddingTop),
        child: Center(child: widget),
      );
      widget = isSliver
          ? SliverFillRemaining(hasScrollBody: false, child: widget)
          : CustomScrollView(
              slivers: <Widget>[SliverFillRemaining(hasScrollBody: false, child: widget)],
            );
      break;
    case IndicatorStatus.noMoreLoad:
      widget = Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            t.common.noMoreDatas,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
      break;
    case IndicatorStatus.empty:
      widget = MyEmptyWidget(message: t.common.noMoreDatas);
      widget = Padding(
        padding: EdgeInsets.only(top: paddingTop),
        child: Center(child: widget),
      );
      widget = isSliver
          ? SliverFillRemaining(hasScrollBody: false, child: widget)
          : CustomScrollView(
              slivers: <Widget>[SliverFillRemaining(hasScrollBody: false, child: widget)],
            );
      break;
  }
  return widget;
}

Widget getIndicator(BuildContext context) {
  return CircularProgressIndicator(
    strokeWidth: 2.0,
    valueColor: AlwaysStoppedAnimation<Color>(
      Theme.of(context).colorScheme.primary,
    ),
  );
}
