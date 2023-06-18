import 'package:flutter/cupertino.dart';
import 'package:smart_station/utils/constants/urls.dart';

class PinChatProvider extends ChangeNotifier {
  final socketUrl = AppUrls.appSocketUrl;

  bool _isPressed = false;
  bool _isPinned = false;
  bool _isMuted = false;

  bool get isPressed => _isPressed;
  bool get isPinned => _isPinned;
  bool get isMuted => _isMuted;

  void setValue(value) {
    _isPressed = value;
    notifyListeners();
  }

  void checkPinned(value) {
    print("RRRRRRRRRRRRRRRRRRR");
    print(value);
    print("RRRRRRRRRRRRRRRRRRR");
    _isPinned = value;
    notifyListeners();
  }

  void checkMuted(value) {
    print("RRRRRRRRRRRRRRRRRRR");
    print(value);
    print("RRRRRRRRRRRRRRRRRRR");
    _isMuted = value;
    notifyListeners();
  }

  void clearAll() {
    _isPressed = false;
    _isPinned = false;
    _isMuted = false;
    notifyListeners();
  }
}
