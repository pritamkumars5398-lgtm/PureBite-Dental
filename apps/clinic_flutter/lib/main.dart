import 'package:flutter/material.dart';

import 'app.dart';
import 'config/app_router.dart';
import 'config/di.dart';
import 'ui/features/shell/view_models/session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDi();
  await getIt<SessionController>().restore();
  runApp(ClinicApp(router: createRouter()));
}
