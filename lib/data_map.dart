// Exports platform-specific DataMapWidget implementation.
// On web: exports widgets/data_map_web.dart
// On other platforms: exports widgets/data_map_mobile.dart
export 'widgets/data_map_mobile.dart'
    if (dart.library.html) 'widgets/data_map_web.dart';
