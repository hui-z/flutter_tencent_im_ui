import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class KeyBoradModel with ChangeNotifier, DiagnosticableTreeMixin {
  bool _show = true;
  get show => _show;

  setStatus(bool status) {
    _show = status;
    notifyListeners();
  }

  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('show', show));
  }
}
