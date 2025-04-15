import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/widgets/possesion/damage_type_dropdown.dart';

class GewasschadeDetails extends StatefulWidget{
  const GewasschadeDetails({super.key});

  @override
  State<GewasschadeDetails> createState() => _gewasschadeDetailsState();
}

// ignore: camel_case_types reason: gewasschade is one word, not two
class _gewasschadeDetailsState extends State<GewasschadeDetails>{
  final TextEditingController _responseController = TextEditingController();

  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Getroffen Gebied'
            ),
            DamageTypeDropdown(),
          ],
        ),
        TextField(
          controller: _responseController,
          decoration: InputDecoration(
            hintText: 'hoe groot',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          style: const TextStyle(fontSize: 18, color: AppColors.brown),
        ),
      ],
    );
  }
}