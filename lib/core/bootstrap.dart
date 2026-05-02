import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import '../firebase_options.dart';

bool firebaseAppReady = false;

Future<void> bootstrapApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseAppReady = true;
  } catch (_) {
    firebaseAppReady = false;
  }
}
