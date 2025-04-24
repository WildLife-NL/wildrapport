import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:flutter/services.dart';

class CustomTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;

  const CustomTimePickerDialog({
    super.key,
    required this.initialTime,
  });

  @override
  State<CustomTimePickerDialog> createState() => _CustomTimePickerDialogState();
}

class _CustomTimePickerDialogState extends State<CustomTimePickerDialog> {
  late int _selectedHour;
  late int _selectedMinute;
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    _updateTimeDisplay();
  }

  void _updateTimeDisplay() {
    _timeController.text = '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kies tijd',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.brown,
              ),
            ),
            const SizedBox(height: 20),
            _buildCurrentTimeDisplay(),
            const SizedBox(height: 20),
            _buildTimeWheels(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTimeDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.brown.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _timeController,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.brown,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
          LengthLimitingTextInputFormatter(5),
        ],
        onTap: () {
          String currentText = _timeController.text;
          _timeController.text = "__:__";
          _timeController.selection = const TextSelection(
            baseOffset: 0,
            extentOffset: 0,
          );
        },
        onChanged: (value) {
          String numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
          String formattedTime = "__:__";
          
          if (numbers.isNotEmpty) {
            List<String> chars = formattedTime.split('');
            for (int i = 0; i < numbers.length && i < 4; i++) {
              if (i < 2) {
                chars[i] = numbers[i];
              } else {
                chars[i + 1] = numbers[i];
              }
            }
            formattedTime = chars.join();
          }
          
          _timeController.value = TextEditingValue(
            text: formattedTime,
            selection: TextSelection.collapsed(offset: numbers.length + (numbers.length > 2 ? 1 : 0)),
          );
          
          // Only update the actual time values when we have a complete input
          if (numbers.length == 4) {
            int hours = int.parse(numbers.substring(0, 2));
            int minutes = int.parse(numbers.substring(2));
            
            if (hours >= 24) hours = 23;
            if (minutes >= 60) minutes = 59;
            
            setState(() {
              _selectedHour = hours;
              _selectedMinute = minutes;
            });
          }
        },
      ),
    );
  }

  Widget _buildTimeWheels() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.brown.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildWheel(
            value: _selectedHour,
            maxValue: 23,
            onChanged: (value) => setState(() => _selectedHour = value),
            label: 'uur',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.brown,
              ),
            ),
          ),
          _buildWheel(
            value: _selectedMinute,
            maxValue: 59,
            onChanged: (value) => setState(() => _selectedMinute = value),
            step: 5,
            label: 'min',
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required int value,
    required int maxValue,
    required Function(int) onChanged,
    int step = 1,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60,
          height: 120,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) => onChanged(index * step),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: (maxValue ~/ step) + 1,
              builder: (context, index) {
                final number = index * step;
                final isSelected = number == value;
                return Center(
                  child: Text(
                    number.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: isSelected ? 20 : 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? AppColors.brown 
                          : AppColors.brown.withOpacity(0.5),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.brown.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Annuleren',
            style: TextStyle(color: AppColors.brown),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(
            TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brown,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Bevestigen',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}








