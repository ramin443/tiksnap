import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../constants/fontconstants.dart';
import '../../../controllers/homeController.dart';
class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return GetBuilder<HomeController>(
        initState: (v){

        },

        init: HomeController(),
        builder: (homecontroller){
      return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          width: screenwidth,
          padding: EdgeInsets.only(bottom:  screenwidth*0.148),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             homecontroller.linktextfield(context),
              homecontroller.linkpasterow(context),
         /*     AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                actions: [
                  IconButton(onPressed: (){
                    homecontroller.parseResponsetoOutput(sampleResponsefromreels);
                  }, icon:
                  Icon(CupertinoIcons.plus_circle_fill,
                  size: 24,
                  color: Colors.black54,))
                ],
              ),
              */
          //    homecontroller.downloadProgressBar(context),
              homecontroller.homeMainColumn(context),

            ],
          ),
        ),
      );
    });
  }
}
