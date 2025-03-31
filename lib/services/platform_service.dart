import 'package:flutter/foundation.dart' show kIsWeb;

// For non-web platforms
import 'dart:io' if (dart.library.js) 'platform_web.dart';

class PlatformService {
  static bool get isWeb => kIsWeb;

  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }
}
