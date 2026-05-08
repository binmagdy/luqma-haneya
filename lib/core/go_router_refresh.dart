import 'dart:async';

import 'package:flutter/foundation.dart';

/// Notifies [GoRouter] when auth session changes so redirects re-run.
class GoRouterAuthRefresh extends ChangeNotifier {
  GoRouterAuthRefresh(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}
