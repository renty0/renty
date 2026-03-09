import 'package:flutter/material.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/functions/alertexitapp.dart';
import 'package:renty/component/internet_checker_widget.dart';
import 'package:renty/pages/MyHomePage.dart' hide Text;

class MainContainer extends StatefulWidget {
  final int initialIndex;

  const MainContainer({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await alertExitApp(context);
      },
      child: InternetCheckerWidget(
        showOnlineMessage: true,
        child: Scaffold(body: MyHomePage()),
      ),
    );
  }
}
