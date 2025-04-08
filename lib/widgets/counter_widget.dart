import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';

class AnimalCounter extends StatefulWidget {
  final String name;
  final Function(String name, int count)? onCountChanged;

  const AnimalCounter({
    Key? key,
    required this.name,
    this.onCountChanged,
  }) : super(key: key);

  @override
  _AnimalCounterState createState() => _AnimalCounterState();
}

class _AnimalCounterState extends State<AnimalCounter> {
  int _count = 0;
  final TextEditingController _controller = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller.text = _count.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _count++;
      _controller.text = _count.toString();
    });
    widget.onCountChanged?.call(widget.name, _count);
  }

  void _decrement() {
    setState(() {
      if (_count > 0) {
        _count--;
        _controller.text = _count.toString();
      }
    });
    widget.onCountChanged?.call(widget.name, _count);
  }

  void _handleTextSubmitted(String value) {
    final newCount = int.tryParse(value) ?? 0;
    setState(() {
      _count = newCount < 0 ? 0 : newCount;
      _controller.text = _count.toString();
      _isEditing = false;
    });
    widget.onCountChanged?.call(widget.name, _count);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 146,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildButton("−", _decrement),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: _isEditing
                      ? TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20, // Increased from 16
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.25),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: _handleTextSubmitted,
                          autofocus: true,
                        )
                      : Text(
                          '$_count',
                          style: TextStyle(
                            fontSize: 20, // Increased from 16
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.25),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
          _buildButton("+", _increment),
        ],
      ),
    );
  }

  Widget _buildButton(String symbol, VoidCallback onPressed) {
    final bool isMinus = symbol == "−";
    return SizedBox(
      width: 44,  // Same width for both buttons
      height: 36,
      child: Material(
        color: AppColors.brown,
        borderRadius: BorderRadius.circular(15),
        elevation: 4, // Added elevation for shadow
        shadowColor: Colors.black.withOpacity(0.25), // Matching shadow color
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          splashColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Center(
            child: Text(
              symbol,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: isMinus ? 2.0 : 0,  // Add letter spacing only for minus sign
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}









