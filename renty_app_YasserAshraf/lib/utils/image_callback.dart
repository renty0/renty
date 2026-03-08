
typedef ImageUpdateCallback = void Function();

class ImageUpdateNotifier {
  static ImageUpdateCallback? _callback;

  static void setCallback(ImageUpdateCallback callback) {
    _callback = callback;
  }

  static void notifyImageUpdate() {
    if (_callback != null) {
      _callback!();
    }
  }

  static void clearCallback() {
    _callback = null;
  }
}