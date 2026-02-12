import 'package:flutter/foundation.dart';

/// Global guard for web HTML image layering: when a fusion dialog is open,
/// tiles should hide sprite layers so no image can appear above the dialog.
class FusionDialogLayerGuard {
  static final ValueNotifier<bool> isDialogOpen =
      ValueNotifier<bool>(false);
}
