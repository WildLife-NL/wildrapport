class BrownButtonModel {
  // Default values
  static const double DEFAULT_BUTTON_HEIGHT = 48.0;
  static const double DEFAULT_ARROW_ICON_SIZE = 24.0;
  static const double DEFAULT_REGULAR_ICON_SIZE = 38.0;
  static const double DEFAULT_LEFT_ICON_PADDING = 0.0;

  String? _text;
  String? _rightIconPath;
  String? _leftIconPath;
  double? _rightIconSize;
  double? _leftIconSize;
  double? _height;
  double? _width;
  double? _fontSize;
  double? _leftIconPadding;

  // Constructor
  BrownButtonModel({
    String? text,
    String? rightIconPath,
    String? leftIconPath,
    double? rightIconSize,
    double? leftIconSize,
    double? height,
    double? width,
    double? fontSize,
    double? leftIconPadding,
  })  : _text = text,
        _rightIconPath = rightIconPath,
        _leftIconPath = leftIconPath,
        _rightIconSize = rightIconSize ?? (rightIconPath?.contains('arrow') == true ? DEFAULT_ARROW_ICON_SIZE : DEFAULT_REGULAR_ICON_SIZE),
        _leftIconSize = leftIconSize ?? DEFAULT_REGULAR_ICON_SIZE,
        _height = height ?? DEFAULT_BUTTON_HEIGHT,
        _width = width,
        _fontSize = fontSize,
        _leftIconPadding = leftIconPadding ?? DEFAULT_LEFT_ICON_PADDING;

  // Getters
  String? get text => _text;
  String? get rightIconPath => _rightIconPath;
  String? get leftIconPath => _leftIconPath;
  double? get rightIconSize => _rightIconSize;
  double? get leftIconSize => _leftIconSize;
  double? get height => _height;
  double? get width => _width;
  double? get fontSize => _fontSize;
  double? get leftIconPadding => _leftIconPadding;

  // Setters
  set text(String? value) => _text = value;
  set rightIconPath(String? value) => _rightIconPath = value;
  set leftIconPath(String? value) => _leftIconPath = value;
  set rightIconSize(double? value) => _rightIconSize = value;
  set leftIconSize(double? value) => _leftIconSize = value;
  set height(double? value) => _height = value;
  set width(double? value) => _width = value;
  set fontSize(double? value) => _fontSize = value;
  set leftIconPadding(double? value) => _leftIconPadding = value;

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
      'leftIconPadding': _leftIconPadding,
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
      leftIconPadding: map['leftIconPadding'],
    );
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'DropdownModel(text: $_text, rightIconPath: $_rightIconPath, leftIconPath: $_leftIconPath)';
  }
}



