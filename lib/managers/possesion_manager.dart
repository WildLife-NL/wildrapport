import 'package:wildrapport/interfaces/possesion_interface.dart';
import 'package:wildrapport/widgets/possesion/gewasschade_details.dart';
import 'package:wildrapport/widgets/possesion/suspected_animal.dart';

class PossesionManager implements PossesionInterface{
  @override
  List<dynamic> buildPossesionWidgetList() {
    List<dynamic> possesionWidgetList = [];
    
    possesionWidgetList.add(GewasschadeDetails());
    possesionWidgetList.add(SuspectedAnimal());

    return possesionWidgetList;
  }
}