import 'dart:convert';

import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tiksnap/screens/base/pages/downloads.dart';
import 'package:tiksnap/screens/base/pages/home.dart';
import 'package:tiksnap/screens/base/pages/settings.dart';
import '../../constants/colorconstants.dart';
import '../../constants/fontconstants.dart';
import '../../constants/imageconstants.dart';
import '../../constants/teststrings.dart';
import '../../controllers/adController.dart';
import '../../controllers/baseController.dart';
import '../../controllers/homeController.dart';
import '../../models/parseModels.dart';

class Base extends StatelessWidget {
  Base({Key? key}) : super(key: key);
  List pages = [Home(), Downloads(), Settings()];
  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GetBuilder<AdController>(
        initState: (v) {},
        init: AdController(),
        builder: (adcontroller) {
          return GetBuilder<BaseController>(
              initState: (v) {
                adcontroller.initializestreams();
                adcontroller.initializebannerAd();
                adcontroller.initializeInterstitialAd();
              },
              init: BaseController(),
              builder: (basecontroller) {
                return Scaffold(

                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.miniCenterFloat,
                  floatingActionButton: adcontroller.displayBannerWidget(context),
                  appBar:
                  basecontroller.currentindex==1?PreferredSize(
                      child: SizedBox(height: 0,width: 0,),
                      preferredSize: Size(0,0)):
                  AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    centerTitle: false,
                    actions: [
                   /*    IconButton(onPressed: (){
                        homeController.extractShortcode("https://www.instagram.com/p/CvgakunSxqd/?igshid=MzRlODBiNWFlZA==");
                      },
                          icon: Icon(FeatherIcons.cloud,
                            color: Colors.black,
                            size: 20,)),*/
                      /*  IconButton(onPressed: (){
                  homeController.printalltasks();
                },
                    icon: Icon(FeatherIcons.cloud,
                color: Colors.black,
                size: 20,)),
                IconButton(
                    onPressed: () {
//                      homeController.testdownload();



                      //     homeController.parseResponsetoOutput(sampleResponsefromreels);
                     /* Map<String, dynamic> parsedJson = json.decode(sampleResponsefromreels);
                      ApiResponse response = ApiResponse.fromJson(parsedJson);
                      print("Post Type: ${response.postType}");
                      for (var media in response.media) {
                        print("Media Type: ${media.mediaType}");
                        print("Thumbnail: ${media.thumbnail}");
                        print("URL: ${media.url}");
                        print("Dimension - Height: ${media.dimension.height}, Width: ${media.dimension.width}");
                      }*/
                    },
                    icon: Icon(
                      CupertinoIcons.plus_circle_fill,
                      color: Colors.black,
                      size: 24,
                    ))
              */
                    ],

                    title: Container(
                      margin: EdgeInsets.only(
//                left: 8,top: 8
                        top: screenWidth * 0.01946,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            mainlogo,
                            //   height: 42,width: 42,
                            height: screenWidth * 0.1221,
                            width: screenWidth * 0.1221,
                          ),
                          SizedBox(width: screenWidth*0.0,),
                          Text(
                            "TikSnap",
                            style: TextStyle(
                                fontFamily: alshaussmedium,
                                color: Colors.white,
                                //        fontSize: 18
                                fontSize: screenWidth * 0.0483),
                          ),
                        ],
                      ),
                    ),
                  ),
                  backgroundColor: tiksaverdarkpagebg,
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: basecontroller.currentindex,
                    selectedItemColor: Colors.redAccent,
                    unselectedItemColor: Colors.white54,
                    backgroundColor: tiksaverlightbg,
                    onTap: (index) {
                      basecontroller.setindex(index);
                    },
                    selectedLabelStyle: TextStyle(
                        fontFamily: alshaussregular,
                        fontSize: screenWidth * 0.03441
                        //    fontSize: 12.5
                        ),
                    unselectedLabelStyle: TextStyle(
                        fontFamily: alshaussregular,
                        fontSize: screenWidth * 0.03441
                        //    fontSize: 12.5
                        ),
                    items: [
                      BottomNavigationBarItem(
                          icon: Icon(
                            FeatherIcons.home,
                            //   size: 24,
                            size: screenWidth * 0.0603,
                          ),
                          label: "Home"),
                      BottomNavigationBarItem(
                        icon: Icon(
                          FeatherIcons.download,
                          //    size: 24,
                          size: screenWidth * 0.0603,
                        ),
                        label: "Downloads",
                      ),
                      BottomNavigationBarItem(
                          icon: Icon(
                            FeatherIcons.settings,
                            //   size: 24,
                            size: screenWidth * 0.0603,
                          ),
                          label: "Settings"),
                    ],
                  ),
                  body: pages[basecontroller.currentindex],
                );
              });
        });
  }
}
