import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator/wb_device_generator.dart';

/// Entry point for build_runner.
Builder wbDeviceBuilder(BuilderOptions options) =>
    LibraryBuilder(WbDeviceGenerator(), generatedExtension: '.wb.g.dart');
