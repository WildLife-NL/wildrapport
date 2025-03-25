class BrownButtonModel {
  String? _text;
  String? _rightIconPath;
  String? _leftIconPath;
  double? _rightIconSize;
  double? _leftIconSize;
  double? _height;      // Add height property
  double? _width;       // Add width property
  double? _fontSize;    // Add fontSize property

  // Constructor
  BrownButtonModel({
    String? text,
    String? rightIconPath,
    String? leftIconPath,
    double? rightIconSize,
    double? leftIconSize,
    double? height,      // Add to constructor
    double? width,       // Add to constructor
    double? fontSize,    // Add to constructor
  })  : _text = text,
        _rightIconPath = rightIconPath,
        _leftIconPath = leftIconPath,
        _rightIconSize = rightIconSize,
        _leftIconSize = leftIconSize,
        _height = height,
        _width = width,
        _fontSize = fontSize;

  // Getters
  String? get text => _text;
  String? get rightIconPath => _rightIconPath;
  String? get leftIconPath => _leftIconPath;
  double? get rightIconSize => _rightIconSize;
  double? get leftIconSize => _leftIconSize;
  double? get height => _height;
  double? get width => _width;
  double? get fontSize => _fontSize;

  // Setters
  set text(String? value) => _text = value;
  set rightIconPath(String? value) => _rightIconPath = value;
  set leftIconPath(String? value) => _leftIconPath = value;
  set rightIconSize(double? value) => _rightIconSize = value;
  set leftIconSize(double? value) => _leftIconSize = value;
  set height(double? value) => _height = value;
  set width(double? value) => _width = value;
  set fontSize(double? value) => _fontSize = value;

  // Convert model to Map
  Map<String, dynamic> toMap() {
    return {
      'text': _text,
      'rightIconPath': _rightIconPath,
      'leftIconPath': _leftIconPath,
      'rightIconSize': _rightIconSize,
      'leftIconSize': _leftIconSize,
      'height': _height,
      'width': _width,
      'fontSize': _fontSize,
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
      height: map['height'],
      width: map['width'],
      fontSize: map['fontSize'],
    );
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'DropdownModel(text: $_text, rightIconPath: $_rightIconPath, leftIconPath: $_leftIconPath)';
  }
}

