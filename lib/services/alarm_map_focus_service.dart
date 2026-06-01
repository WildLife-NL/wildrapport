import 'package:flutter/foundation.dart';
import 'package:wildrapport/models/map_alarm_focus.dart';

/// Coordinates navigation from alarm detail to the map tab with a focused pin.
class AlarmMapFocusService extends ChangeNotifier {
  MapAlarmFocus? _pendingFocus;
  bool _openMapTab = false;

  bool get hasPendingFocus => _pendingFocus != null;
  bool get shouldOpenMapTab => _openMapTab;

  void requestShowOnMap(MapAlarmFocus focus) {
    _pendingFocus = focus;
    _openMapTab = true;
    notifyListeners();
  }

  /// Returns focus for the map screen and clears the pending payload.
  MapAlarmFocus? takePendingFocus() {
    final focus = _pendingFocus;
    _pendingFocus = null;
    return focus;
  }

  /// Main nav calls once after switching to the kaart tab.
  bool consumeOpenMapTabRequest() {
    if (!_openMapTab) return false;
    _openMapTab = false;
    return true;
  }
}
