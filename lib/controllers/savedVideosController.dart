import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tiksnap/constants/teststrings.dart';
import 'package:tiksnap/dbhelpers/SavedAudiosDBHelper.dart';
import 'package:tiksnap/models/SavedAudios.dart';
import 'package:tiksnap/models/tiktokResponseModel.dart';


import '../constants/colorconstants.dart';
import '../constants/fontconstants.dart';
import '../constants/imageconstants.dart';
import '../dbhelpers/SavedVideosDBHelper.dart';
import '../models/SavedVideos.dart';
import '../screens/base/secondary/audioPlayPage.dart';
import '../screens/base/secondary/offlinePlayPage.dart';
import '../screens/base/secondary/videoPlayPage.dart';
import '../screens/sharablewidgets/deletevideo.dart';
import 'adController.dart';
import 'baseController.dart';
final BaseController baseController =
Get.put(BaseController());
final AdController adController =
Get.put(AdController());
class SavedVideosController extends GetxController {
  final dbHelper = SavedVideosDatabaseHelper();
  final audiodbHelper = SavedAudiosDatabaseHelper();
  int downloadslength=0;
  int openVideotaps=0;
  int openAudiotaps = 0;
  TikTokResponse sampletikTokResponse=TikTokResponse.fromJson(json.decode(sampleResponsefromTikTok));
  SavedVideos savedvideoModel = SavedVideos(
     // id: 1,
      caption: "Wir sind hier \n WIr haben biuer dabei",
      postType: "Video",
      height: 1920,
      width: 1080,
      mediaType: "Video",
      thumbnail:
          "https://instagram.fuln1-2.fna.fbcdn.net/v/t51.2885-15/362994873_624131689822280_8215974899179446900_n.jpg?stp=dst-jpg_e15&_nc_ht=instagram.fuln1-2.fna.fbcdn.net&_nc_cat=108&_nc_ohc=O3vzyePplhAAX8_DJ6R&edm=APfKNqwBAAAA&ccb=7-5&oh=00_AfBITJo-grKa3G7hEo6Te1uh4LNUnTe1Ad0YZdccOFH5Gg&oe=64DC3169&_nc_sid=721f0c",
      url:
          "https://instagram.fstx1-1.fna.fbcdn.net/v/t66.30100-16/10000000_963912298198741_5067272402829562511_n.mp4?efg=eyJ2ZW5jb2RlX3RhZyI6InZ0c192b2RfdXJsZ2VuLjEwODAuY2xpcHMuYmFzZWxpbmUiLCJxZV9ncm91cHMiOiJbXCJpZ193ZWJfZGVsaXZlcnlfdnRzX290ZlwiXSJ9&_nc_ht=instagram.fstx1-1.fna.fbcdn.net&_nc_cat=101&_nc_ohc=IYcWoqiUOXMAX8EqR7H&edm=APfKNqwBAAAA&vs=245445934991324_3902522883&_nc_vs=HBksFQAYJEdJQ1dtQURWOWlCU3JHd0RBSS1TeXg1bmtWSkdicFIxQUFBRhUAAsgBABUAGCRHSGtBc1FMZ2FPSW44TUVEQUhoWkZxTVZTWlFoYnBSMUFBQUYVAgLIAQAoABgAGwAVAAAmjP2c%2B5rP3z8VAigCQzMsF0A6qn752yLRGBZkYXNoX2Jhc2VsaW5lXzEwODBwX3YxEQB1%2FgcA&_nc_rid=64540c153d&ccb=7-5&oh=00_AfDZD47C1MuR1WNPHXWKn1IJXpr7oz-jyrxVrgVpKkmTAQ&oe=64DA55E6&_nc_sid=721f0c",
      fileLocationPath: "fileLocationPath");

  void setdownloadslength(int count){
    downloadslength=count;
    update();
  }
  void incrementopenVideotaps(){
    openVideotaps++;
    int downtaplimit=adController.downtapfrequency;
    if(openVideotaps % downtaplimit == 0){
      adController.showInterstitialAd();
    }update();
  }
  Widget savedvideoslist(BuildContext context) {
    return FutureBuilder<List<SavedVideos>>(
      future: dbHelper.getAllVideos(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final videos = snapshot.data!;
          setdownloadslength(videos.length);
          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return ListTile(
                title: Text(video.caption!),
                subtitle: Text(video.url!),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.redAccent),
                  backgroundColor: Colors.black12,

              ),
            ],
          );
        }
      },
    );
  }
  void incrementdownloadsfortoday() async {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection('NeuDownloads');
   /* var doc = await collectionRef
        .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
        .get();
    if (doc.exists) {
      await FirebaseFirestore.instance
          .collection("Downloads")
          .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
          .update({"numberofdownloads": FieldValue.increment(1)});
    } else {
      await FirebaseFirestore.instance
          .collection("Downloads")
          .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
          .set({"numberofdownloads": 1});
    }*/
    await collectionRef.doc(DateFormat.yMMMMd('en_US').format(DateTime.now())).
    set({
      "numberofdownloads": FieldValue.increment(1)
    },SetOptions(merge: true));
  }
  void setreceivedlength()async{
    int recordCount = await dbHelper.getRecordCount();
    downloadslength=recordCount;
    update();
  }
  Widget savedVidsTab(BuildContext context){
    double screenwidth = MediaQuery.sizeOf(context).width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: screenwidth*0.06,),
        databasesavedVidGrid(context)
      ],
    );
  }
  Widget savedAudiosTab(BuildContext context){
    double screenwidth = MediaQuery.sizeOf(context).width;
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenwidth*0.06,),
          databasesavedAudioGrid(context),
          SizedBox(height: screenwidth*0.06,),
        ],
      ),
    );
  }
  /*Widget databasesavedAudioGrid(BuildContext context){
    double screenwidth = MediaQuery.sizeOf(context).width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for(int i=0;i<8;i++)
        savedAudioBox(context: context,sav: sampletikTokResponse.data)
      ],
    );
  }
  */
  Widget databasesavedVidGrid(BuildContext context) {
    double screenwidth = MediaQuery.sizeOf(context).width;
    return FutureBuilder<List<SavedVideos>>(
      future: dbHelper.getAllVideos(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final videos = snapshot.data!;
          return videos.isEmpty?
              emptydownloadstate(context):
          Container(
              width: screenwidth,
//              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
//      horizontal: 21
                  horizontal: screenwidth * 0.04109),  child:  GridView.builder(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns in the grid
                  mainAxisSpacing: screenwidth * 0.028, // Spacing between rows
                  mainAxisExtent: screenwidth * 0.619, // Spacing between columns
                ),
                itemCount: videos.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return indivSavedVideo(context, video);
                }));
           /* ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return ListTile(
                title: Text(video.caption!),
                subtitle: Text(video.url!),
              );
            },
          );*/
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.redAccent),
                  backgroundColor: Colors.black12,


              ),
            ],
          );
        }
      },
    );
  }

  Widget databasesavedAudioGrid(BuildContext context) {
    double screenwidth = MediaQuery.sizeOf(context).width;
    return FutureBuilder<List<SavedAudios>>(
      future: audiodbHelper.getAllAudios(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final audios = snapshot.data!;
          return audios.isEmpty?
          emptydownloadstate(context):
          Container(
              width: screenwidth,
//              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
//      horizontal: 21
                  horizontal: screenwidth * 0.04109),
              child:  ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: audios.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final audio = audios[index];
                return savedAudioBox(context: context,savedAudio: audio);
              }));
          /* ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return ListTile(
                title: Text(video.caption!),
                subtitle: Text(video.url!),
              );
            },
          );*/
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.redAccent),
                backgroundColor: Colors.black12,


              ),
            ],
          );
        }
      },
    );
  }

  Widget gridViewSavedVideos(BuildContext context) {
    double screenwidth = MediaQuery.sizeOf(context).width;
    return Container(
        width: screenwidth,
      padding: EdgeInsets.symmetric(
//      horizontal: 21
          horizontal: screenwidth * 0.04109),
     //   alignment: Alignment.center,
        child: GridView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns in the grid
              mainAxisSpacing: screenwidth * 0.028, // Spacing between rows
              mainAxisExtent: screenwidth * 0.619, // Spacing between columns
            ),
            itemCount: 4,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
//              return individualSavedVideo(context, savedvideoModel, index);
              return indivSavedVideo(context, savedvideoModel);
            }),
      );
  }
  Widget indivSavedVideo(BuildContext context, SavedVideos savedVideo){
    double screenwidth = MediaQuery.sizeOf(context).width;
    return Container(
      width: screenwidth * 0.441,
      height: screenwidth * 0.639,
      decoration: BoxDecoration(
        //  color: Color(0xffFAFAFA).withOpacity(0.52),
        borderRadius: BorderRadius.all(Radius.circular(5)),
        //  border: Border.all(color: Color(0xff707070).withOpacity(0.2), width: 1),
      ),
      child: Stack(
        children: [
          Container(
            width: screenwidth * 0.441,
            height: screenwidth * 0.639,
            decoration: BoxDecoration(
              //  color: Color(0xffFAFAFA).withOpacity(0.52),
              borderRadius: BorderRadius.all(Radius.circular(5)),
              //  border: Border.all(color: Color(0xff707070).withOpacity(0.2), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              child:  CachedNetworkImage(
                imageUrl: savedVideo.thumbnail!,
                fit: BoxFit.cover,
                width: screenwidth * 0.441,
                //    height: screenwidth * 0.639,
                progressIndicatorBuilder:
                    (context, url, downloadProgress) =>
                    Container(
                      width: screenwidth * 0.441,
                      height: screenwidth * 0.639,
                      decoration: BoxDecoration(
                          color: Colors.white
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.redAccent),
                              backgroundColor: Colors.black12,
                              value: downloadProgress.progress),
                        ],
                      ),
                    ),

                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          Container(
            width: screenwidth * 0.441,
            height: screenwidth * 0.639,
        //    padding: EdgeInsets.only(top: 6,bottom: 6),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                gradient: LinearGradient(
                  colors: [Colors.black12, Colors.black],
                  stops: [0.1, 1],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(onPressed: (){
                      showDialog(
                          context: context,
                          builder: (_) => SimpleDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(16)),
                              ),
                              children: [
                                DeleteVideo(
                                    newUrl: savedVideo.url
                                ),
                              ]));
                    }, icon: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: lightredthemedColor,
                      size: screenwidth*0.048,
                    ))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          incrementopenVideotaps();
                          incrementplaysfortoday();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      OfflinePlayPage(filepath: savedVideo.fileLocationPath)));
                        },
                        icon: Icon(
                          CupertinoIcons.play_fill,
                          color: Colors.white,
                          size: screenwidth * 0.0769,
                        ),
                      ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        //        left: 12
                        left: screenwidth * 0.0251,
                        right: screenwidth * 0.0251,
                      ),
                      margin: EdgeInsets.only(
                        //        left: 12
                          bottom: screenwidth * 0.0291),
                      child: Text(
                        savedVideo.caption!,
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: alshaussbook,
                            color: Colors.white,
                            //    fontSize: 14.5
                            fontSize: screenwidth * 0.032),
                      ),
                    ),
                    openVideoButton(context, savedVideo.fileLocationPath!)
                  ],
                )
              ],
            ),
          ),

        ],
      ),
    );
  }
  Widget individualSavedVideo(
      BuildContext context, SavedVideos savedVideo, int index) {
    double screenwidth = MediaQuery.sizeOf(context).width;
    double screenheight = MediaQuery.sizeOf(context).height;
    return Container(
        margin: EdgeInsets.only(left: index.isEven ? screenwidth * 0.03720 : 0.028),
        width: screenwidth * 0.441,
        height: screenwidth * 0.639,
        decoration: BoxDecoration(
          //  color: Color(0xffFAFAFA).withOpacity(0.52),
          borderRadius: BorderRadius.all(Radius.circular(5)),
          //  border: Border.all(color: Color(0xff707070).withOpacity(0.2), width: 1),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  child: CachedNetworkImage(
                    imageUrl: savedVideo.thumbnail!,
                    fit: BoxFit.cover,
                    width: screenwidth * 0.441,
                //    height: screenwidth * 0.639,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                        Container(
                          width: screenwidth * 0.441,
                          height: screenwidth * 0.639,
                                decoration: BoxDecoration(
                                  color: Colors.white
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.redAccent),
                                        backgroundColor: Colors.black12,
                                        value: downloadProgress.progress),
                                  ],
                                ),
                              ),

                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )
                  /*Image.network(
                  savedVideo.thumbnail,
                  fit: BoxFit.cover,
                  width: screenwidth * 0.441,
                  height: screenwidth * 0.639,
                ),*/
                  ),
            ),
            Container(
              width: screenwidth * 0.441,
              height: screenwidth * 0.639,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  gradient: LinearGradient(
                    colors: [Colors.black12, Colors.black],
                    stops: [0.1, 1],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )),
            ),
            Container(
              width: screenwidth * 0.441,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 35,
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () {
                        incrementplaysfortoday();
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    VideoPlayPage(url: savedVideo.url)));
                      },
                      icon: Icon(
                        CupertinoIcons.play_fill,
                        color: Colors.white,
                        size: screenwidth * 0.0769,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            //        left: 12
                            left: screenwidth * 0.0251,
                            right: screenwidth * 0.0251,
                          ),
                          margin: EdgeInsets.only(
                              //        left: 12
                              bottom: screenwidth * 0.0291),
                          child: Text(
                            savedVideo.caption!,
                            textAlign: TextAlign.left,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: alshaussbook,
                                color: Colors.white,
                                //    fontSize: 14.5
                                fontSize: screenwidth * 0.032),
                          ),
                        ),
                      ),
                    ],
                  ),
                  openVideoButton(context, savedVideo.url!),
                ],
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(onPressed: (){
                    showDialog(
                        context: context,
                        builder: (_) => SimpleDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(16)),
                            ),
                            children: [
                              DeleteVideo(
                                  newUrl: savedVideo.url
                                ),
                            ]));
                  }, icon: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: Colors.redAccent,
                    size: screenwidth*0.048,
                  ))
                ],
              ),
            )
          ],
        ));
  }
  void incrementplaysfortoday() async {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection('Plays');
    /*var doc = await collectionRef
        .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
        .get();
    if (doc.exists) {
      await FirebaseFirestore.instance
          .collection("Plays")
          .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
          .update({"numberofplays": FieldValue.increment(1)});
    } else {
      await FirebaseFirestore.instance
          .collection("Plays")
          .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
          .set({"numberofplays": 1});
    }*/
    await collectionRef.doc(DateFormat.yMMMMd('en_US').format(DateTime.now())).
    set({
      "numberofplays": FieldValue.increment(1)
    },SetOptions(merge: true));
  }
  void deleteVideo(String url )async{
    await dbHelper.deleteVideo(url);
    update();
  }

  Widget openVideoButton(BuildContext context, String filepath) {
    double screenwidth = MediaQuery.sizeOf(context).width;
    return GestureDetector(
      onTap: () {
        incrementopenVideotaps();
        incrementplaysfortoday();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) =>  OfflinePlayPage(filepath: filepath)));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenwidth * 0.0334),
        width: screenwidth * 0.407,
        height: screenwidth * 0.0895,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FeatherIcons.download,
              //      size: 20,
              size: screenwidth * 0.0326,
              color: Colors.white,
            ),
            Container(
              margin: EdgeInsets.only(
                  //        left: 12
                  left: screenwidth * 0.0291),
              child: Text(
                "Open Video",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: alshaussregular,
                    color: Colors.white,
                    //    fontSize: 14.5
                    fontSize: screenwidth * 0.035),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget emptydownloads(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;
    return Container(
      height: screenheight*0.7,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/images/nodownloads.svg",
              width: screenwidth * 0.669,
            ),
            Container(
              child: Text(
                "No downloads yet",
                style: TextStyle(
                    fontFamily: alshaussregular,
                    color: tiksavermainwhite.withOpacity(0.94),
                    fontSize: screenwidth * 0.05109),
              ),
            ),
            Container(
              child: Text(
                "Copy and paste link to see download options",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: alshaussbook,
                    color: Colors.white54,
                    //      fontSize: 12.5
                    fontSize: screenwidth * 0.03041),
              ),
            ),
            GestureDetector(
                onTap: () {
                  baseController.setindex(0);
                },
                child: Container(
                  margin: EdgeInsets.only(
                    //          top: 21
                      top: screenwidth * 0.05109),
                  padding: EdgeInsets.symmetric(
//           vertical: 6,horizontal: 14
                      vertical: screenwidth * 0.0145,
                      horizontal: screenwidth * 0.03406),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.all(Radius.circular(31)),
                  ),
                  child: Text(
                    "Get Started",
                    style: TextStyle(
                        fontFamily: alshaussregular,
                        color: Colors.white,
                        //        fontSize: 15.5
                        fontSize: screenwidth * 0.0377),
                  ),
                ))
          ]),
    );
  }
  Widget topdownloadAppBar(BuildContext context){
    double screenwidth = MediaQuery.of(context).size.width;
    return AppBar(
      backgroundColor: Colors.transparent,
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
            "$downloadslength files",
            style: TextStyle(
                fontFamily: alshaussbook,
                color: tiksavermainwhite.withOpacity(0.84),
                //   fontSize: 19
                fontSize: screenwidth * 0.0342),
          ),
        ),
      ],
    );
  }
  Widget topdownloadrow(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(
//      top: 22
          bottom: screenwidth * 0.0462),
      padding: EdgeInsets.symmetric(
//      horizontal: 21
          horizontal: screenwidth * 0.05109),
      width: screenwidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            child: Text(
              "All Downloads",
              style: TextStyle(
                  fontFamily: alshaussregular,
                  color: tiksavermainwhite.withOpacity(0.84),
                  //   fontSize: 19
                  fontSize: screenwidth * 0.0462),
            ),
          ),
          Container(
            child: Text(
             "$downloadslength files" ,
              style: TextStyle(
                  fontFamily: alshaussbook,
                  color: tiksavermainwhite,
                  //   fontSize: 14
                  fontSize: screenwidth * 0.0340),
            ),
          ),
        ],
      ),
    );
  }
  Widget emptydownloadstate(BuildContext context){
    double screenwidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Container(
      height: screenheight*0.625,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: screenwidth*0.6792,
            height: screenwidth*0.809,
            decoration: BoxDecoration(
              color: tiksaverlightbg,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenwidth*0.04,),
                Container(
                  child: Image.asset(emptybox,
                    width: screenwidth*0.304,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child:Text("A little empty here!",
                  style: TextStyle(
                    fontFamily: alshaussbook,
                    color: Colors.white,
                    fontSize: screenwidth*0.0503
                  ),),),
                GestureDetector(
                    onTap: () {
                      baseController.setindex(0);
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        //          top: 21
                          top: screenwidth * 0.05109),
                      padding: EdgeInsets.symmetric(
//           vertical: 6,horizontal: 14
                          vertical: screenwidth * 0.0145,
                          horizontal: screenwidth * 0.03406),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.all(Radius.circular(31)),
                      ),
                      child: Text(
                        "Get Started",
                        style: TextStyle(
                            fontFamily: alshaussregular,
                            color: Colors.white,
                            //        fontSize: 15.5
                            fontSize: screenwidth * 0.0377),
                      ),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget savedAudioBox(
      {BuildContext? context, SavedAudios? savedAudio,String? audiotitle, String? audioThumbnail, String? audioauthor,
        String? audioduration
      }){
    double screenwidth = MediaQuery.of(context!).size.width;
    return  Container(
      width: screenwidth * 0.92,
      margin: EdgeInsets.only(bottom: screenwidth*0.026),
      padding: EdgeInsets.symmetric(
          horizontal: screenwidth * 0.0282, vertical: screenwidth * 0.046),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          color: tiksaverdarkgreybg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: screenwidth*0.0435),
                    width: screenwidth*0.176,
                    height: screenwidth*0.176,
                    decoration: BoxDecoration(
                      color: Color(0xff717171),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl:savedAudio!.cover!,
                          width: screenwidth*0.176,
                          height: screenwidth*0.176,
                        errorWidget: (context,error,widget){
                          return SizedBox(height: 0,);
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: screenwidth*0.176,
                    height: screenwidth*0.176,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 4,sigmaY:4
                        ),
                        child: Container(
                          padding: EdgeInsets.only(left: screenwidth*0.01),
                          child: IconButton(
                            onPressed: (){
                              //Open Audio here
                              incrementopenAudiotaps();
                              incrementaudioplaysfortoday();
                              //Push Audio Play Page
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AudioPlayPage(
                                          savedAudios: savedAudio)));
                            //  checkpermissionsandOpenAudio(savedAudio.fileLocationPath!);
                            },
                            icon: Icon(CupertinoIcons.play_fill,
                            color: Colors.white,
                                size: screenwidth*0.064,),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      bottom: screenwidth*0.03
                     ),
                    child: Text(
                      savedAudio!.title!,
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      style: TextStyle(
                          fontFamily: alshaussmedium,
                          color: Colors.white,
                          //    fontSize: 14.5
                          fontSize: screenwidth * 0.038),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                        ),
                        child: Text(
                          savedAudio!.author!,
                        //  audioauthor!,
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          style: TextStyle(
                              fontFamily: alshaussregular,
                              color: Colors.white,
                              //    fontSize: 14.5
                              fontSize: screenwidth * 0.038),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 2
                        ),
                        child: Text(
                          formatDuration(savedAudio!.duration!),
                         // audioduration!,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontFamily: alshaussregular,
                              color: Colors.white,
                              //    fontSize: 14.5
                              fontSize: screenwidth * 0.038),
                        ),
                      ),
                    ],
                  )],)],)
        ],
      ),
    );
  }
  String formatDuration(int seconds) {
    print("Printing seconds here:$seconds");
    int minutes = (seconds / 60).truncate();
    int remainingSeconds = seconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    print('bleh here$minutesStr:$secondsStr');
    String finalstring="$minutesStr : $secondsStr";
    return finalstring;
  }
  void incrementopenAudiotaps() {
    openAudiotaps++;
    int playtaplimit = adController.playtapfrequency;

    if (openAudiotaps % playtaplimit == 0) {
      adController.showInterstitialAd();
    }
    update();
  }
  void incrementaudioplaysfortoday() async {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection('Plays');
    /*var doc = await collectionRef
        .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
        .get();
    if (doc.exists) {
      await FirebaseFirestore.instance
          .collection("Plays")
          .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
          .update({"numberofplays": FieldValue.increment(1)});
    } else {
      await FirebaseFirestore.instance
          .collection("Plays")
          .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
          .set({"numberofplays": 1});
    }*/
    await collectionRef
        .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
        .set({"numberofaudioplays": FieldValue.increment(1)},
        SetOptions(merge: true));
  }

}
