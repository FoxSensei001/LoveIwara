import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/services/app_service.dart';

/// 读取当前全局站点模式；在 `AppService` 未注册时（例如极早期启动阶段、测试）
/// 回退到 [IwaraSite.main]。
IwaraSite currentIwaraSiteOrMain() {
  if (Get.isRegistered<AppService>()) {
    return Get.find<AppService>().currentSiteMode;
  }
  return IwaraSite.main;
}

/// 给任意 iwara Dio 实例挂上的 request 拦截器：每次发请求时，按当前
/// [AppService.currentSiteMode] 写入 `x-site` / `Referer` / `Origin`。
///
/// 好处：不需要在 Dio 构造时把 header baked 进 BaseOptions，也不用在切站时手动
/// 更新每个 Dio —— 避免"构造早于 site 同步"的时序陷阱。
InterceptorsWrapper buildIwaraSiteHeaderInterceptor() {
  return InterceptorsWrapper(
    onRequest: (options, handler) {
      options.headers.addAll(currentIwaraSiteOrMain().requestHeaders);
      handler.next(options);
    },
  );
}
