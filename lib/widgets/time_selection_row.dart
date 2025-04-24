import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wildrapport/widgets/time_picker_dialog.dart';
import 'package:wildrapport/constants/app_colors.dart';

class TimeSelectionRow extends StatefulWidget {
  final Function(String) onOptionSelected;
  final Function(DateTime)? onDateSelected;
  final Function(DateTime)? onTimeSelected;
  final String? initialSelection;
  final DateTime? initialDate;
  final DateTime? initialTime;

  const TimeSelectionRow({
    super.key,
    required this.onOptionSelected,
    this.onDateSelected,
    this.onTimeSelected,
    this.initialSelection,
    this.initialDate,
    this.initialTime,
  });

  @override
  State<TimeSelectionRow> createState() => _TimeSelectionRowState();
}

class _TimeSelectionRowState extends State<TimeSelectionRow> {
  DateTime? _selectedDate;
  DateTime? _selectedTime;
  String _selectedOption = 'Nu';
  final TextEditingController _timeController = TextEditingController();
  final FocusNode _timeFocusNode = FocusNode();

  // Constants - using shorter terms
  static const _options = ['Nu', 'Onbekend', 'Kiezen'];  // Changed 'Zelf selecteren' to 'Kiezen'

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialSelection ?? 'Nu';
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
    _timeController.text = _formatTime(_selectedTime);
  }

  @override
  void dispose() {
    _timeController.dispose();
    _timeFocusNode.dispose();
    super.dispose();
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _handleSelection(String option) {
    setState(() {
      _selectedOption = option;
      if (option == 'Nu') {
        final now = DateTime.now();
        widget.onDateSelected?.call(now);
        widget.onTimeSelected?.call(now);
      }
    });
    widget.onOptionSelected(option);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSelectionCard(),
        const SizedBox(height: 16),
        _buildDateTimeSelectors(),
      ],
    );
  }

  Widget _buildSelectionCard() {
    return Container(
      decoration: _buildCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4), // Reduced horizontal padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed to spaceBetween
          children: _options.map((option) => _buildCheckboxWithLabel(option)).toList(),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelectors() {
    final DateTime currentTime = DateTime.now();
    final bool isCustomSelection = _selectedOption == 'Kiezen';
    final bool isCurrentTime = _selectedOption == 'Nu';
    final bool isUnknown = _selectedOption == 'Onbekend';
    
    final displayDate = isCurrentTime ? currentTime : _selectedDate;
    final displayTime = isCurrentTime ? currentTime : _selectedTime;

    return Row(
      children: [
        _buildDateSelector(
          isUnknown ? null : (displayDate ?? currentTime), 
          isCustomSelection
        ),
        const SizedBox(width: 16),
        _buildTimeSelector(
          isUnknown ? null : (displayTime ?? currentTime), 
          isCustomSelection
        ),
      ],
    );
  }

  Widget _buildDateSelector(DateTime? date, bool enabled) {
    return _buildDateTimeField(
      label: 'Datum',
      value: date != null 
          ? '${date.day}-${date.month}-${date.year}'
          : '--/--/----',
      icon: Icons.calendar_today,
      onTap: enabled ? () => _selectDate(context) : null,
      enabled: enabled,
    );
  }

  Widget _buildTimeSelector(DateTime? time, bool enabled) {
    return _buildDateTimeField(
      label: 'Tijd',
      value: time != null 
          ? _formatTime(time)
          : '--:--',
      icon: Icons.access_time,
      onTap: enabled ? () => _showTimePicker(context) : null,
      onTextTap: enabled ? () => _enableTimeTextInput() : null,
      enabled: enabled,
      controller: _timeController,
      focusNode: _timeFocusNode,
    );
  }

  void _enableTimeTextInput() {
    _timeFocusNode.requestFocus();
    _timeController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _timeController.text.length,
    );
  }

  void _showTimePicker(BuildContext context) async {
    final TimeOfDay? picked = await showDialog<TimeOfDay>(  // Changed from showTimePicker to showDialog
      context: context,
      builder: (BuildContext context) => CustomTimePickerDialog(  // Renamed to avoid conflict with Flutter's TimePickerDialog
        initialTime: _selectedTime != null 
            ? TimeOfDay.fromDateTime(_selectedTime!)
            : TimeOfDay.now(),
      ),
    );
    
    if (picked != null) {
      final DateTime selectedDateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        picked.hour,
        picked.minute,
      );
      setState(() {
        _selectedTime = selectedDateTime;
        _timeController.text = _formatTime(selectedDateTime);
      });
      widget.onTimeSelected?.call(selectedDateTime);
    }
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: AppColors.offWhite,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      widget.onDateSelected?.call(picked);
    }
  }

  Widget _buildCheckboxWithLabel(String label) {
    final isSelected = _selectedOption == label;
    
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2), // Reduced horizontal margin
        decoration: _buildCheckboxDecoration(isSelected),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: _buildCheckboxContent(label, isSelected),
        ),
      ),
    );
  }

  BoxDecoration _buildCheckboxDecoration(bool isSelected) {
    return BoxDecoration(
      color: isSelected ? AppColors.offWhite : Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      boxShadow: isSelected ? [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ] : [],
    );
  }

  Widget _buildCheckboxContent(String label, bool isSelected) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center, // Center the content
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: _buildCustomCheckbox(isSelected, label),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: _buildCheckboxLabel(label, isSelected),
        ),
      ],
    );
  }

  Widget _buildCustomCheckbox(bool isSelected, String label) {
    return Checkbox(
      value: isSelected,
      onChanged: (_) => _handleSelection(label),
      activeColor: AppColors.brown,
      checkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      side: BorderSide(
        color: AppColors.brown,
        width: 2,
      ),
    );
  }

  Widget _buildCheckboxLabel(String label, bool isSelected) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.brown,
        fontSize: 14,
        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
    VoidCallback? onTextTap,
    required bool enabled,
    TextEditingController? controller,
    FocusNode? focusNode,
  }) {
    return Expanded(
      child: Container(
        height: 70,
        decoration: _buildDateTimeFieldDecoration(enabled),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onTextTap ?? onTap,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: controller != null && enabled
                      ? _buildTimeTextField(label, controller, focusNode!)
                      : _buildDateTimeFieldLabels(label, value),
                ),
              ),
            ),
            GestureDetector(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  icon,
                  color: AppColors.brown.withOpacity(enabled ? 0.8 : 0.4),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTextField(String label, TextEditingController controller, FocusNode focusNode) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.brown.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.datetime,
          style: TextStyle(
            color: AppColors.brown,
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
          onChanged: _handleTimeInput,
        ),
      ],
    );
  }

  void _handleTimeInput(String value) {
    if (value.length == 5) {
      final parts = value.split(':');
      if (parts.length == 2) {
        final hours = int.tryParse(parts[0]);
        final minutes = int.tryParse(parts[1]);
        
        if (hours != null && minutes != null && 
            hours >= 0 && hours < 24 && 
            minutes >= 0 && minutes < 60) {
          final selectedDateTime = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            hours,
            minutes,
          );
          setState(() => _selectedTime = selectedDateTime);
          widget.onTimeSelected?.call(selectedDateTime);
        }
      }
    }
  }

  BoxDecoration _buildDateTimeFieldDecoration(bool enabled) {
    return BoxDecoration(
      color: AppColors.offWhite,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: enabled ? AppColors.brown.withOpacity(0.1) : Colors.transparent,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ],
    );
  }

  Widget _buildDateTimeFieldContent(
    String label,
    String value,
    IconData icon,
    bool enabled,
  ) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: _buildDateTimeFieldLabels(label, value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Icon(
            icon,
            color: AppColors.brown.withOpacity(enabled ? 0.8 : 0.4),
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeFieldLabels(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFittedText(
          label,
          color: AppColors.brown.withOpacity(0.6),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 4),
        _buildFittedText(
          value,
          color: AppColors.brown,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  Widget _buildFittedText(
    String text, {
    required Color color,
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

























