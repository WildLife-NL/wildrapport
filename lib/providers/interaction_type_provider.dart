import 'package:flutter/material.dart';
import 'package:wildrapport/models/api_models/interaction_type.dart';

class InteractionTypeProvider extends ChangeNotifier {
  List<InteractionType> _interactionTypes = [];
  bool _isLoading = false;
  String? _error;

  List<InteractionType> get interactionTypes => _interactionTypes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setInteractionTypes(List<InteractionType> types) {
    _interactionTypes = types;
    _error = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  InteractionType? getInteractionTypeByName(String name) {
    try {
      return _interactionTypes.firstWhere(
        (type) => type.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  InteractionType? getInteractionTypeById(int id) {
    try {
      return _interactionTypes.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }
}
