import 'dart:ui' show Size;

import 'package:camerawesome/pigeon.dart';

extension PreviewSizeExtension on PreviewSize {
  Size toSize() => Size(width, height);

  PreviewSize inverted() => PreviewSize(width: height, height: width);
}

extension ExposureTimeRangeExt on ExposureTimeRange {
  /// Minimum exposure time in seconds (double).
  double get minSeconds => minMicroseconds / 1000000;

  /// Maximum exposure time in seconds (double).
  double get maxSeconds => maxMicroseconds / 1000000;

  /// Minimum exposure time in milliseconds (double).
  double get minMilliseconds => minMicroseconds / 1000;

  /// Maximum exposure time in milliseconds (double).
  double get maxMilliseconds => maxMicroseconds / 1000;

  /// The total range of exposure time in seconds (max - min).
  double get inSeconds => maxSeconds - minSeconds;

  /// The total range of exposure time in milliseconds (max - min).
  double get inMilliseconds => maxMilliseconds - minMilliseconds;
}