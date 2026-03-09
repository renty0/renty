import 'package:flutter/material.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/constant/imgaeasset.dart';

class Logo extends StatelessWidget{
  const Logo({super.key});

  @override
  Widget build(BuildContext context){
    return Center(
      child: Container(
        child: Image.asset(
          AppImageAsset.logInImage,
          height: MediaQuery.of(context).size.width / 3.3,
          fit: BoxFit.fill,
        )

        ),
      );
  }
}