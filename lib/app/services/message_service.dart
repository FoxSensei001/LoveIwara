import 'package:get/get.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';

class MessageService extends GetxService {
  final List<_QueuedMessage> _messageQueue = [];
  bool _isReady = false;

  void markReady() {
    _isReady = true;
    _processQueue();
  }

  void showMessage(String message, MDToastType type) {
    if (!_isReady) {
      _messageQueue.add(_QueuedMessage(message, type));
    } else {
      _showToast(message, type);
    }
  }

  void _processQueue() {
    if (!_isReady) return;

    for (var message in _messageQueue) {
      _showToast(message.message, message.type);
    }
    _messageQueue.clear();
  }

  void _showToast(String message, MDToastType type) {
    showToastWidget(
      MDToastWidget(
        message: message,
        type: type,
      ),
    );
  }
}

class _QueuedMessage {
  final String message;
  final MDToastType type;

  _QueuedMessage(this.message, this.type);
} 