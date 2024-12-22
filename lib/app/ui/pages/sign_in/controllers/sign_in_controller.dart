import 'package:get/get.dart';
import 'package:i_iwara/app/models/user.model.dart';
import '../../../../../utils/logger_utils.dart';
import '../../../../repositories/sign_in_repository.dart';
import '../../../../services/user_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class SignInController extends GetxController {
  final SignInRepository _signInRepository = SignInRepository.instance;
  final UserService _userService = Get.find<UserService>();

  RxBool isLoading = false.obs;
  RxBool hasSignedInToday = false.obs;
  RxInt totalSignIns = 0.obs;
  RxInt consecutiveSignIns = 0.obs;
  RxMap<DateTime, bool> signInStatus = <DateTime, bool>{}.obs;
  RxString failureReason = ''.obs;
  final RxMap<DateTime, String> signInReasons = <DateTime, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _onUserChanged(_userService.currentUser.value);
    _userService.currentUser.listen((user) => _onUserChanged(user));
  }

  void _onUserChanged(User? user) {
    if (user != null) {
      _checkIfSignedInToday(user.id);
      _fetchSignInHistory(user.id);
    } else {
      hasSignedInToday.value = false;
      totalSignIns.value = 0;
      consecutiveSignIns.value = 0;
      signInStatus.clear();
    }
  }

  // 检查用户今天是否已签到
  Future<void> _checkIfSignedInToday(String userId) async {
    isLoading.value = true;
    try {
      final todayRecord = await _signInRepository.checkIfSignedInToday(userId);
      if (todayRecord != null) {
        hasSignedInToday.value = true;
        failureReason.value = todayRecord['status'] == 1 ? '' : todayRecord['reason'] ?? '';
      } else {
        hasSignedInToday.value = false;
        failureReason.value = '';
      }
    } catch (e) {
      LogUtils.e('检查签到状态时出错', error: e);
      Get.snackbar(slang.t.errors.error, slang.t.errors.errorOccurred);
    } finally {
      isLoading.value = false;
    }
  }

  // 执行签到操作
  Future<void> signIn({required bool isSuccess, String? reason}) async {
    final user = _userService.currentUser.value;
    if (user == null) {
      Get.snackbar(slang.t.errors.error, slang.t.signIn.pleaseLoginFirst);
      return;
    }
    if (hasSignedInToday.value) {
      LogUtils.i('用户已签到，无需重复签到');
      Get.snackbar(slang.t.errors.error, slang.t.signIn.alreadySignedInToday);
      return;
    }
    isLoading.value = true;
    try {
      await _signInRepository.signIn(user.id, isSuccess: isSuccess, reason: reason);
      hasSignedInToday.value = true;
      if (isSuccess) {
        totalSignIns.value += 1;
        Get.snackbar(slang.t.common.success, slang.t.signIn.signInSuccess);
      } else {
        failureReason.value = reason ?? '';
        Get.snackbar(slang.t.errors.error, slang.t.signIn.youDidNotStickToTheSignIn);
      }
      // 更新连续签到天数
      consecutiveSignIns.value = await _signInRepository.getConsecutiveSignIns(user.id);
      // 更新签到状态
      await _fetchSignInHistory(user.id);
    } catch (e) {
      LogUtils.e('签到失败', error: e);
      Get.snackbar(slang.t.errors.error, slang.t.signIn.signInFailed);
    } finally {
      isLoading.value = false;
    }
  }

  // 获取签到历史
  Future<void> _fetchSignInHistory(String userId) async {
    isLoading.value = true;
    try {
      final records = await _signInRepository.getSignInRecords(userId);
      signInStatus.clear();
      signInReasons.clear();
      for (var record in records) {
        DateTime date = DateTime(record['date'].year, record['date'].month, record['date'].day);
        bool isSuccess = (record['status'] as int) == 1;
        signInStatus[date] = isSuccess;
        if (!isSuccess && record['reason'] != null) {
          signInReasons[date] = record['reason'] as String;
        }
      }
      totalSignIns.value = await _signInRepository.getTotalSignIns(userId);
      consecutiveSignIns.value = await _signInRepository.getConsecutiveSignIns(userId);
    } catch (e) {
      LogUtils.e('获取签到历史时出错', error: e);
      Get.snackbar(slang.t.errors.error, slang.t.errors.errorWhileFetchingDatas);
    } finally {
      isLoading.value = false;
    }
  }

  // 选择日期（可选）
  void selectDay(DateTime day) {
    // 根据需求处理日期选择
  }
}
