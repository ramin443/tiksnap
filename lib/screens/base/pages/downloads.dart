import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colorconstants.dart';
import '../../../constants/fontconstants.dart';
import '../../../controllers/savedVideosController.dart';
import '../../../controllers/videoplayController.dart';
class Downloads extends StatelessWidget {
   Downloads({Key? key}) : super(key: key);
   final VideoPlayController videoPlayController =
   Get.put(VideoPlayController());
   final SavedVideosController savedVideosController =
   Get.put(SavedVideosController());
  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.sizeOf(context).width;
    double screenheight = MediaQuery.sizeOf(context).height; return
      GetBuilder<SavedVideosController>(
        initState: (v){
          savedVideosController.setreceivedlength();
        },
          init: SavedVideosController(),
        builder: (savedvideocontroller){
        return
        Column(
          children: [
            SizedBox(height: screenwidth*0.06,),
            Expanded(
              child: DefaultTabController(length: 2, child:
              Scaffold(
                backgroundColor: tiksaverdarkpagebg,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title:  Container(
                    child: Text(
                      "All Downloads",
                      style: TextStyle(
                          fontFamily: alshaussbold,
                          color: tiksavermainwhite.withOpacity(0.84),
                          //   fontSize: 19
                          fontSize: screenwidth * 0.0462),
                    ),
                  ),
                  leading: IconButton(
                    onPressed: (){},
                    icon: Icon(FeatherIcons.info,
                      color: Colors.white,
                      size: screenwidth*0.064,),
                  ),
                  actions: [
                    Container(
                      margin: EdgeInsets.only(right: screenwidth*0.04),
                      child: Text(
                        "${savedvideocontroller.downloadslength} files",
                        style: TextStyle(
                            fontFamily: alshaussbook,
                            color: tiksavermainwhite.withOpacity(0.84),
                            //   fontSize: 19
                            fontSize: screenwidth * 0.0342),
                      ),
                    ),
                  ],
                  bottom: TabBar(
                    labelColor: tiksavermainwhite,
                    unselectedLabelColor: Color(0xff8E8E93),
                    labelStyle: TextStyle(
                      fontFamily: alshaussmedium,
                      color: tiksavermainwhite,
                      fontSize: screenwidth*0.0373
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                    indicatorPadding: EdgeInsets.symmetric(horizontal: 80),
                    indicatorColor: tiksavermainwhite,
                    unselectedLabelStyle: TextStyle(
                        fontFamily: alshaussmedium,
                        color: Color(0xff8E8E93),
                        fontSize: screenwidth*0.0373
                    ),
                    tabs: <Tab>[
                     Tab(
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(
                             FeatherIcons.video,
                             size: screenwidth*0.0503,
                           ),
                           Container(
                             margin: EdgeInsets.only(left: 12),
                             child: Text("Videos"),
                           )
                         ],
                       ),

                     ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FeatherIcons.headphones,
                              size: screenwidth*0.0503,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 12),
                              child: Text("Audios"),
                            )
                          ],
                        ),

                      ),

                    ],
                  ),
                ),
                body: TabBarView(
                  children: <Widget>[
                    savedvideocontroller.savedVidsTab(context),
                    savedvideocontroller.savedAudiosTab(context),

              //      savedvideocontroller.databasesavedVidGrid(context),
              //      savedvideocontroller.databasesavedVidGrid(context),
                  ],),
              )),
            ),
          ],
        );
          SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            width: screenwidth,

            padding: EdgeInsets.only(
                bottom: screenwidth * 0.2
            ),
           // padding: EdgeInsets.only(left: 14,right: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenwidth*0.0626,),
                savedvideocontroller.topdownloadAppBar(context),
               // savedvideocontroller.topdownloadrow(context),
               // savedvideocontroller.gridViewSavedVideos(context),
                savedvideocontroller.databasesavedVidGrid(context),
              ],
            ),
          ),
        );
      });

  }
}
