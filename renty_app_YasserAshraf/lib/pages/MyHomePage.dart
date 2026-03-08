import 'package:flutter/material.dart';
import 'package:renty/core/constant/app_colors.dart';
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text("Renty",style: TextStyle(color: AppColor.whiteColor,fontSize: 24,fontWeight: FontWeight.bold),),
        backgroundColor: AppColor.secondColor,
      ),
      backgroundColor: AppColor.backgroundcolor,
      body: Center(
        child: Text(
          "Hello From Renty",
          style: TextStyle(
            color: Color(0xff1a365d), // Primary color
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
