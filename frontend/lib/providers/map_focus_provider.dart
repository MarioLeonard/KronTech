import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapFocusProvider extends ChangeNotifier {
  LatLng? _focus;

  LatLng? get focus => _focus;

  void setFocus(LatLng point) {
    _focus = point;
    notifyListeners();
  }

  void clear() {
    if (_focus == null) {
      return;
    }
    _focus = null;
    notifyListeners();
  }
}
