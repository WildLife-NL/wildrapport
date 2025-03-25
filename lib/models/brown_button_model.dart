class BrownButtonModel {
  String? _text;
  String? _rightIconPath;
  String? _leftIconPath;
  double? _rightIconSize;
  double? _leftIconSize;

  // Constructor
  BrownButtonModel({
    String? text,
    String? rightIconPath,
    String? leftIconPath,
    double? rightIconSize,
    double? leftIconSize,
  })  : _text = text,
        _rightIconPath = rightIconPath,
        _leftIconPath = leftIconPath,
        _rightIconSize = rightIconSize,
        _leftIconSize = leftIconSize;

  // Getters
  String? get text => _text;
  String? get rightIconPath => _rightIconPath;
  String? get leftIconPath => _leftIconPath;
  double? get rightIconSize => _rightIconSize;
  double? get leftIconSize => _leftIconSize;

  // Setters
  set text(String? value) => _text = value;
  set rightIconPath(String? value) => _rightIconPath = value;
  set leftIconPath(String? value) => _leftIconPath = value;
  set rightIconSize(double? value) => _rightIconSize = value;
  set leftIconSize(double? value) => _leftIconSize = value;

  // Convert model to Map
  Map<String, dynamic> toMap() {
    return {
      'text': _text,
      'rightIconPath': _rightIconPath,
      'leftIconPath': _leftIconPath,
      'rightIconSize': _rightIconSize,
      'leftIconSize': _leftIconSize,
    };
  }

  // Create model from Map
  factory BrownButtonModel.fromMap(Map<String, dynamic> map) {
    return BrownButtonModel(
      text: map['text'],
      rightIconPath: map['rightIconPath'],
      leftIconPath: map['leftIconPath'],
      rightIconSize: map['rightIconSize'],
      leftIconSize: map['leftIconSize'],
    );
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'DropdownModel(text: $_text, rightIconPath: $_rightIconPath, leftIconPath: $_leftIconPath)';
  }
}
