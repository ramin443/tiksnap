import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/colorconstants.dart';
import '../../constants/fontconstants.dart';
import '../../constants/imageconstants.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late Animation<double> upanimation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    upanimation =
        Tween<double>(begin: 50, end: 200).animate(animationController);
    animationController.forward();
    animationController.addListener(() {});
    startTime();
  }

  startTime() async {
    var _duration = new Duration(seconds: 5);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/Base');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(children: [
      Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(color: tiksaverdarkpagebg),
      ),
      Scaffold(
        backgroundColor:tiksaverdarkpagebg,
        body: Container(
          height: screenHeight,
          width: screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                  duration: Duration(milliseconds: 1200),
                  margin: EdgeInsets.only(bottom: upanimation.value),
                  child: Image.asset(
                    mainlogo,
                    width: screenWidth*0.634,
                  )),
              Container(
                  child: Text(
                "TikSnap",
                style: TextStyle(
                    fontFamily: alshaussbold,
                    color: Colors.white,
                    fontSize: screenWidth *0.08
                    //fontSize: 24),
                    ),
              )),
              Container(
                margin: EdgeInsets.only(top: screenWidth*0.016),
                  child: Text(
                    "Downloader for TikTok",
                    style: TextStyle(
                        fontFamily: alshaussbook,
                        color: Colors.white,
                        fontSize: screenWidth * 0.0483
                      //fontSize: 24),
                    ),
                  )),            ],
          ),
        ),
      )
    ]);
  }
}
