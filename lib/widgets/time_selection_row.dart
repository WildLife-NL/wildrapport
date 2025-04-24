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
          : '--:--',  // Changed to show dashes when time is null (Onbekend)
      icon: Icons.access_time,
      onTap: enabled ? () => _showTimePicker(context) : null,
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
    final TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) => CustomTimePickerDialog(
        initialTime: _selectedTime != null 
            ? TimeOfDay.fromDateTime(_selectedTime!)
            : TimeOfDay.now(),
        selectedDate: _selectedDate ?? DateTime.now(),  // Add this parameter
      ),
    );
    
    if (picked != null) {
      final DateTime selectedDateTime = DateTime(
        _selectedDate?.year ?? DateTime.now().year,
        _selectedDate?.month ?? DateTime.now().month,
        _selectedDate?.day ?? DateTime.now().day,
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
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,  // Changed from DateTime(2100) to now
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      widget.onDateSelected?.call(picked);
    }
  }

  Widget _buildCheckboxWithLabel(String label) {
    final isSelected = _selectedOption == label;
    
    return Expanded(
      child: GestureDetector(  // Add GestureDetector here
        onTap: () => _handleSelection(label),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: _buildCheckboxDecoration(isSelected),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: Checkbox(
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
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: AppColors.brown,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
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
    required bool enabled,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? placeholder,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: enabled ? AppColors.offWhite : AppColors.offWhite.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: enabled 
                  ? AppColors.brown.withOpacity(0.15)
                  : AppColors.brown.withOpacity(0.05),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: enabled
                    ? Colors.black.withOpacity(0.08)
                    : Colors.black.withOpacity(0.04),
                offset: const Offset(0, 2),
                blurRadius: 6,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: AppColors.brown.withOpacity(0.6),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          color: enabled 
                              ? AppColors.brown 
                              : AppColors.brown.withOpacity(0.7),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  icon,
                  color: enabled
                      ? AppColors.brown.withOpacity(0.7)
                      : AppColors.brown.withOpacity(0.4),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeFieldLabels(String label, String value) {
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
        Text(
          value,
          style: TextStyle(
            color: AppColors.brown,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
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

































