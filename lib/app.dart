import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_logger.dart';
import 'theme/app_theme.dart';
import 'features/documents/services/document_service.dart';
import 'features/home/home_screen.dart';
import 'features/home/print_flow.dart';
import 'features/printing/services/print_dispatcher.dart';
import 'features/settings/settings_controller.dart';
import 'localization/strings.dart';

/// Các service dùng chung của ứng dụng (khởi tạo trong main()).
class AppServices {
  AppServices({
    required this.documents,
    required this.dispatcher,
    required this.flow,
    required this.logger,
  });

  final DocumentService documents;
  final PrintDispatcher dispatcher;
  final PrintFlow flow;
  final AppLogger logger;
}

class App extends StatelessWidget {
  const App({
    super.key,
    required this.settings,
    required this.services,
  });

  final SettingsController settings;
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final strings = S(settings.locale);
        return MaterialApp(
          title: strings.appTitle,
          debugShowCheckedModeBanner: false,
          locale: settings.locale,
          supportedLocales: const [
            Locale('vi'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.dark,
          home: HomeScreen(
            strings: strings,
            settings: settings,
            documents: services.documents,
            dispatcher: services.dispatcher,
            flow: services.flow,
          ),
        );
      },
    );
  }
}
