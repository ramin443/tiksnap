import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiksnap/constants/fontconstants.dart';
import 'package:tiksnap/controllers/adController.dart';
import 'package:tiksnap/controllers/audioPlayController.dart';
import 'package:tiksnap/models/SavedAudios.dart';

import '../../../constants/colorconstants.dart';
class AudioPlayPage extends StatelessWidget {
   AudioPlayPage({@required this.savedAudios});
   SavedAudios? savedAudios;

   final AudioPlayController audioPlayController =
  Get.put(AudioPlayController());
  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.sizeOf(context).width;
    double screenheight = MediaQuery.sizeOf(context).height;
    return
      GetBuilder<AdController>(
          init: AdController(),
          initState: (v) {
            //    v.initState();
          },
          builder: (adcontroller) {
          return GetBuilder<AudioPlayController>(
            initState: (v){
              adcontroller.initializebannerAd();
              adcontroller.initializeInterstitialAd();
              audioPlayController.stopaudio();
              audioPlayController.currentPositionListener(savedAudios!);
           //   audioPlayController.initaudioplaycontroller(savedAudios!.play!);
            },
            init: AudioPlayController(),
            builder: (audioplaycontroller){
              return WillPopScope(
                onWillPop: audioplaycontroller.onBackPressed,
                child: Scaffold(
                  backgroundColor: tiksaverdarkpagebg,
                  body: Stack(
                    children: [
                      SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Container(
                          width: screenwidth,
                          height: screenheight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: screenwidth*0.6,
                                height: screenwidth*0.6,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                  child: Image.network(savedAudios!.cover!,
                                    width: screenwidth*0.4,
                                    height: screenwidth*0.4,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: screenwidth*0.04,
                                left: screenwidth*0.04,right: screenwidth*0.04
                                ),
                                child:
                                    Text(savedAudios!.title!,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                      fontFamily: alshaussmedium,
                                      color: Colors.white,
                                      fontSize: screenwidth*0.06
                                    ),),

                              ),
                              Container(
                                margin: EdgeInsets.only(top: screenwidth*0.02,
                                    left: screenwidth*0.04,right: screenwidth*0.04
                                ),
                                child:
                                Text(savedAudios!.author!,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontFamily: alshaussregular,
                                      color: greythemedcolor,
                                      fontSize: screenwidth*0.04
                                  ),),

                              )

                            ],
                          )


                          // Show loading indicator
                        ),
                      ),

                      Container(
                        width: screenwidth,
                        height: screenheight * 0.25,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AppBar(
                              backgroundColor: Colors.black12,
                              elevation: 0,
                              //  centerTitle: true,
                              leading: IconButton(
                                onPressed: () {
                                  audioPlayController.stopaudio();
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  CupertinoIcons.back,
                                  color: Colors.white,
                                  size: screenwidth * 0.06,
                                ),
                              ),
                              //    title: Text('Video Player'),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        width: screenwidth,
                        height: screenheight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            audioplaycontroller
                                .videocontrolaction(context,savedAudios!),
                            SizedBox(
                              width: screenwidth,
                              height: 0,
                            ),
                            adcontroller.displayBannerWidget(context),
                          ],
                        ),
                      )

                    ],
                  ),
                ),
              );
            });
        }
      );
  }
}
