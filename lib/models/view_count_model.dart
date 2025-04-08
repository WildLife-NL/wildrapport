class ViewCountModel {
  int pasGeborenAmount;
  int onvolwassenAmount;
  int volwassenAmount;
  int unknownAmount;

  ViewCountModel({
    this.pasGeborenAmount = 0,
    this.onvolwassenAmount = 0,
    this.volwassenAmount = 0,
    this.unknownAmount = 0,
  });

  Map<String, dynamic> toJson() => {
    'pasGeborenAmount': pasGeborenAmount,
    'onvolwassenAmount': onvolwassenAmount,
    'volwassenAmount': volwassenAmount,
    'unknownAmount': unknownAmount,
  };

  factory ViewCountModel.fromJson(Map<String, dynamic> json) => ViewCountModel(
    pasGeborenAmount: json['pasGeborenAmount'] ?? 0,
    onvolwassenAmount: json['onvolwassenAmount'] ?? 0,
    volwassenAmount: json['volwassenAmount'] ?? 0,
    unknownAmount: json['unknownAmount'] ?? 0,
  );
}