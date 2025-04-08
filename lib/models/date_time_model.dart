class DateTimeModel {
  final DateTime? date;
  final DateTime? time;
  final bool isUnknown;

  DateTimeModel({
    this.date,
    this.time,
    this.isUnknown = false,
  });

  Map<String, dynamic> toJson() => {
    'date': date?.toIso8601String(),
    'time': time?.toIso8601String(),
    'isUnknown': isUnknown,
  };

  factory DateTimeModel.fromJson(Map<String, dynamic> json) => DateTimeModel(
    date: json['date'] != null ? DateTime.parse(json['date']) : null,
    time: json['time'] != null ? DateTime.parse(json['time']) : null,
    isUnknown: json['isUnknown'] ?? false,
  );
}