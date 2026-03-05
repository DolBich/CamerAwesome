import 'dart:ui' show Size;

import 'package:camerawesome/pigeon.dart';

extension PreviewSizeExtension on PreviewSize {
  Size toSize() => Size(width, height);

  PreviewSize inverted() => PreviewSize(width: height, height: width);
}