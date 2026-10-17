import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/app_logger.dart';
import 'features/documents/services/document_service.dart';
import 'features/documents/services/docx_converter.dart';
import 'features/home/print_flow.dart';
import 'features/printing/services/pass_pdf_builder.dart';
import 'features/printing/services/print_dispatcher.dart';
import 'features/settings/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = SettingsController();
  await settings.load();

  final tempRoot = await getTemporaryDirectory();
  final sessionDir = Directory(
    '${tempRoot.path}/nkd_smart_printer',
  );
  await sessionDir.create(recursive: true);

  final logger = AppLogger(enabled: settings.loggingEnabled);
  await logger.init(sessionDir);

  final documents = DocumentService(
    converter: DocxConverter(),
    tempDir: sessionDir,
  );
  final dispatcher = PrintDispatcher();
  final flow = PrintFlow(
    dispatcher: dispatcher,
    pdfBuilder: PassPdfBuilder(),
  );

  runApp(
    App(
      settings: settings,
      services: AppServices(
        documents: documents,
        dispatcher: dispatcher,
        flow: flow,
        logger: logger,
      ),
    ),
  );
}
