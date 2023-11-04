import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:background_downloader/background_downloader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:sqflite/sqflite.dart';
import 'package:tiksnap/dbhelpers/SavedAudiosDBHelper.dart';
import 'package:tiksnap/models/SavedAudios.dart';
import '../constants/colorconstants.dart';
import '../constants/fontconstants.dart';
import '../constants/teststrings.dart';
import '../dbhelpers/DownloadedVidDBHelper.dart';
import '../dbhelpers/SavedVideosDBHelper.dart';
import '../models/Downloaded_Video_Model.dart';
import '../models/SavedVideos.dart';
import '../models/parseModels.dart';
import '../models/tiktokResponseModel.dart';
import '../screens/base/secondary/videoPlayPage.dart';
import '../screens/downloadwidgets/error_box.dart';
import '../screens/downloadwidgets/fetchingdownloadinfo.dart';
import '../screens/sharablewidgets/downloadinstruction1.dart';
import '../screens/sharablewidgets/rateus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'adController.dart';

final AdController adController = Get.put(AdController());

class HomeController extends GetxController {
  final dbHelper = SavedVideosDatabaseHelper();
  final audiodbHelper = SavedAudiosDatabaseHelper();
  TextEditingController linkfieldcontroller = TextEditingController();
  int showdownload = 0;
  List<DownloadedVideo> tasklist = [];
  int count = 0;
  String clipboarddata = '';
  String? extractedlink = '';
  DownloadedVidDatabaseHelper downloadedVidDatabaseHelper =
      DownloadedVidDatabaseHelper();
  String lastsavedaudiofileLocation="";
  TikTokResponse? receivedtiktokResponse;
  bool isLoading = false;
  String lastdownloadedurl = "";
  int downloadtaps = 0;
  int audiodownloadtaps = 0;
  int openVideotaps = 0;
  int openAudiotaps = 0;

  //the following are parsing controls
  bool isLinkValid = false;
  bool errorThrown = false;
  int downloadProgress = 0;
  int audiodownloadProgress = 0;
  late TargetPlatform? platform;
  String? localPath = '';

  void updatelastsavedAudiofile(String audiofile){
    lastsavedaudiofileLocation=audiofile;
    update();
  }
  void incrementDownloadtaps() {
    downloadtaps++;
    int downtaplimit = adController.downtapfrequency;
    if (downloadtaps % downtaplimit == 0) {
      adController.showInterstitialAd();
    }
    update();
  }

  void incrementAudioDownloadtaps() {
    audiodownloadtaps++;
    int downtaplimit = adController.downtapfrequency;
    if (audiodownloadtaps % downtaplimit == 0) {
      adController.showInterstitialAd();
    }
    update();
  }

  void incrementopenVideotaps() {
    openVideotaps++;
    int playtaplimit = adController.playtapfrequency;

    if (openVideotaps % playtaplimit == 0) {
      adController.showInterstitialAd();
    }
    update();
  }

  void incrementopenAudiotaps() {
    openAudiotaps++;
    int playtaplimit = adController.playtapfrequency;

    if (openAudiotaps % playtaplimit == 0) {
      adController.showInterstitialAd();
    }
    update();
  }

  void saveVideo(SavedVideos savedVideo) async {
    await dbHelper.insertVideo(savedVideo);
    update();
  }

  void saveAudio(SavedAudios savedAudio) async {
    await audiodbHelper.insertAudio(savedAudio);
    update();
  }

  void deleteVideo(String url) async {
    await dbHelper.deleteVideo(url);
    update();
  }

  void setlastdownload(String url) {
    lastdownloadedurl = url;
    update();
  }

  //the following includes the functional code for parsing control
  void setdownloadProgress(int progress) {
    print("Setting progress $progress");
    downloadProgress = progress;
    update();
  }

  void resetDownloadingProgress() {
    downloadProgress = 0;
    update();
  }

  void resetAudioDownloadingProgress() {
    audiodownloadProgress = 0;
    update();
  }

  void setaudiodownloadProgress(int progress) {
    print("Setting audio progress $progress");
    audiodownloadProgress = progress;
    update();
  }

  void setlinkvalidastrue() {
    isLinkValid = true;
    update();
  }

  void setloadingtrue() {
    isLoading = true;
    update();
  }

  void setloadingfalse() {
    isLoading = false;
    update();
  }

  void seterrorthrowntrue() {
    errorThrown = true;
    update();
  }

  void seterrorthrownfalse() {
    errorThrown = false;
    update();
  }

  void setlinkvalidasfalse() {
    isLinkValid = false;
    update();
  }

  /*void parseResponsetoOutput(String responsebody) {
    // String finalpurestring = sampleResponsefromreels.replaceAll(RegExp(r'[^\x00-\x7F]+'), '');
    String finalpurestring =
        responsebody.replaceAll(RegExp(r'[\x00-\x1F]'), '');
    Map<String, dynamic> parsedJson = json.decode(finalpurestring);
    ApiResponse response = ApiResponse.fromJson(parsedJson);
    print("Post Type: ${response.postType}");
    receivedResponse = response;
    for (var media in response.media) {
      receivedMedia = media;
      setloadingfalse();
      print("Media Type: ${media.mediaType}");
      print("Thumbnail: ${media.thumbnail}");
      print("URL: ${media.url}");
      print(
          "Dimension - Height: ${media.dimension.height}, Width: ${media.dimension.width}");
    }
    update();
  }*/

  //download functions
  void testdownload(String downloadurl) async {
    String forcedurl =
        "https://instagram.fppg1-1.fna.fbcdn.net/v/t66.30100-16/53905490_847286777011273_1522532917070693776_n.mp4?_nc_ht=instagram.fppg1-1.fna.fbcdn.net&_nc_cat=101&_nc_ohc=baAHlPPFljkAX8dpuz_&edm=APfKNqwBAAAA&ccb=7-5&oh=00_AfBBlvtum7R88yAwNvCC-qjocoa-0x0jRoBO4QCRDOlrHg&oe=64D38788&_nc_sid=721f0c";
    bool permissionReady = await _checkPermission();
    if (permissionReady) {
      await _prepareSaveDir();
      //  await _prepareSaveDir();
      print("Downloading");

      try {
        /*FileDownloader.downloadFile(
            //url: receivedMedia!.url.trim(),
            url: forcedurl,
            name: "Neu file test",
            onProgress: ( fileName, progress) {
              print('FILE $fileName HAS PROGRESS $progress');
            },
            onDownloadCompleted: (String path) {
              print('FILE DOWNLOADED TO PATH: $path');
            },
            onDownloadError: (String error) {
              print('DOWNLOAD ERROR: $error');
            });
        FileDownloader.setLogEnabled(true);*/
        downloadtestvideo(downloadurl);

        //     print("Download Completed.");
      } catch (e) {
        print("Download Failed.\n\n" + e.toString());
      }
    }
  }

  void testAudiodownload(String downloadurl) async {
    String forcedurl =
        "https://instagram.fppg1-1.fna.fbcdn.net/v/t66.30100-16/53905490_847286777011273_1522532917070693776_n.mp4?_nc_ht=instagram.fppg1-1.fna.fbcdn.net&_nc_cat=101&_nc_ohc=baAHlPPFljkAX8dpuz_&edm=APfKNqwBAAAA&ccb=7-5&oh=00_AfBBlvtum7R88yAwNvCC-qjocoa-0x0jRoBO4QCRDOlrHg&oe=64D38788&_nc_sid=721f0c";
    bool permissionReady = await _checkPermission();
    if (permissionReady) {
      await _prepareSaveDir();
      //  await _prepareSaveDir();
      print("Downloading");

      try {
        /*FileDownloader.downloadFile(
            //url: receivedMedia!.url.trim(),
            url: forcedurl,
            name: "Neu file test",
            onProgress: ( fileName, progress) {
              print('FILE $fileName HAS PROGRESS $progress');
            },
            onDownloadCompleted: (String path) {
              print('FILE DOWNLOADED TO PATH: $path');
            },
            onDownloadError: (String error) {
              print('DOWNLOAD ERROR: $error');
            });
        FileDownloader.setLogEnabled(true);*/
        downloadtestaudio(downloadurl);

        //     print("Download Completed.");
      } catch (e) {
        print("Download Failed.\n\n" + e.toString());
      }
    }
  }

  Future<void> downloadVideo(String videoUrl) async {
    Dio dio = Dio();

    try {
      // Define the download path
      String savePath = (await getExternalStorageDirectory())!.path;
      String videoName = videoUrl.split('/').last;
      String filePath = '$savePath/$videoName';

      // Download the video
      await dio.download(videoUrl, filePath);
      print('Video downloaded to: $filePath');
    } catch (error) {
      print('Error downloading video: $error');
    }
  }

  Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      platform = TargetPlatform.android;
    } else {
      platform = TargetPlatform.iOS;
    }
    if (platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Widget videopage(BuildContext context) {
    double screenwidth = MediaQuery.sizeOf(context).width;
    return Container(
        margin: EdgeInsets.only(
            top: screenwidth * 0.05720, bottom: screenwidth * 0.0709),
        width: screenwidth * 0.837,
        height: screenwidth * 0.841,
        decoration: BoxDecoration(
          //  color: Color(0xffFAFAFA).withOpacity(0.52),
          borderRadius: BorderRadius.all(Radius.circular(11)),
          //  border: Border.all(color: Color(0xff707070).withOpacity(0.2), width: 1),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(11)),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(11)),
                  child: CachedNetworkImage(
                    imageUrl: receivedtiktokResponse!.data.cover,
                    fit: BoxFit.cover,
                    width: screenwidth * 0.837,
                    height: screenwidth * 0.841,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Container(
                      width: screenwidth * 0.441,
                      height: screenwidth * 0.639,
                      decoration: BoxDecoration(color: tiksaverlightbg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.redAccent),
                              backgroundColor: Colors.white12,
                              value: downloadProgress.progress),
                        ],
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )
                  /*Image.network(
                  receivedMedia!.thumbnail,
                  fit: BoxFit.cover,
                  width: screenwidth * 0.837,
                  height: screenwidth * 0.841,
                ),*/
                  ),
            ),
            Container(
              width: screenwidth * 0.837,
              height: screenwidth * 0.841,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(11)),
                  gradient: LinearGradient(
                    colors: [Colors.black12, Colors.black],
                    stops: [0.1, 1],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )),
            ),
            Container(
              width: screenwidth * 0.837,
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
                                builder: (context) => VideoPlayPage(
                                    url: receivedtiktokResponse!.data.play)));
                      },
                      icon: Icon(
                        CupertinoIcons.play_fill,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      //        left: 12
                      left: screenwidth * 0.0351,
                      right: screenwidth * 0.0351,
                    ),
                    margin: EdgeInsets.only(
                        //        left: 12
                        bottom: screenwidth * 0.0291),
                    child: Text(
                      receivedtiktokResponse!.data.title!,
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      style: TextStyle(
                          fontFamily: alshaussbook,
                          color: Colors.white,
                          //    fontSize: 14.5
                          fontSize: screenwidth * 0.03),
                    ),
                  ),
                  //  receivedMedia!.url != lastdownloadedurl ? downloadbutton(context) :
                  downloadProgress > 0 && downloadProgress < 100
                      ? downloadVideoAudioButtons(context)
                      : downloadProgress == 0
                          ? downloadVideoAudioButtons(context)
                          : downloadProgress == 100
                              ? downloadVideoAudioButtons(context)
                              : downloadVideoAudioButtons(context)
                  //    : downloadbutton(context),
                ],
              ),
            ),
          ],
        ));
  }

  Widget downloadProgressBar(BuildContext context) {
    double screenwidth = MediaQuery.sizeOf(context).width;
    return Container(
      // height: 6,
      width: screenwidth * 0.715,
      margin: EdgeInsets.only(bottom: screenwidth * 0.0634),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(
                    //        left: 12
                    left: screenwidth * 0.0291),
                child: Text(
                  "Downloading....",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: proximanovaregular,
                      color: Colors.white,
                      //    fontSize: 14.5
                      fontSize: screenwidth * 0.034),
                ),
              ),
              Container(
                child: Text(
                  "$downloadProgress%",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: proximanovaregular,
                      color: Colors.white,
                      //    fontSize: 14.5
                      fontSize: screenwidth * 0.034),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: LinearProgressIndicator(
              semanticsLabel: downloadProgress.toString(),
              value: downloadProgress / 100,
              // Convert the progress to a value between 0 and 1
              backgroundColor: Colors.white54,
              valueColor: AlwaysStoppedAnimation<Color>(
                  royalbluethemedcolor), // Change this color as needed
            ),
          )
        ],
      ),
    );
  }

  Widget openVideoButton(BuildContext context) {
    double screenwidth = MediaQuery.sizeOf(context).width;
    return GestureDetector(
      onTap: () {
        incrementopenVideotaps();
        incrementplaysfortoday();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    VideoPlayPage(url: receivedtiktokResponse!.data.play)));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenwidth * 0.0634),
        width: screenwidth * 0.715,
        height: screenwidth * 0.107,
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
              size: screenwidth * 0.0426,
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
                    fontSize: screenwidth * 0.041),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget videoDownloadButton({BuildContext? context}) {
    double screenwidth = MediaQuery.sizeOf(context!).width;
    return downloadProgress > 0 && downloadProgress < 100
        ? Stack(
            children: [
              Container(
                width: screenwidth * 0.33,
                height: screenwidth * 0.107,
                decoration: BoxDecoration(
                  color: tiksaverdarkgreybg,
                  borderRadius: BorderRadius.all(Radius.circular(26)),
                ),
              ),
              Container(
                width: screenwidth * 0.33,
                height: screenwidth * 0.107,
                decoration: BoxDecoration(
                  color: tiksaverdarkgreybg,
                  borderRadius: BorderRadius.all(Radius.circular(26)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      topRight: downloadProgress == 100
                          ? Radius.circular(20)
                          : Radius.circular(0),
                      bottomRight: downloadProgress == 100
                          ? Radius.circular(20)
                          : Radius.circular(0)),
                  child: LinearProgressIndicator(
                    semanticsLabel: "$downloadProgress%",
                    value: downloadProgress / 100,
                    // Convert the progress to a value between 0 and 1
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.redAccent), // Change this color as needed
                  ),
                ),
              ),
              Container(
                width: screenwidth * 0.33,
                height: screenwidth * 0.107,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(26)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FeatherIcons.download,
                      //      size: 20,
                      size: screenwidth * 0.0446,
                      color: Colors.white,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          //        left: 12
                          top: screenwidth * 0.007,
                          left: screenwidth * 0.0241),
                      child: Text(
                        "$downloadProgress%",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: alshaussregular,
                            color: Colors.white,
                            //    fontSize: 14.5
                            fontSize: screenwidth * 0.041),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : downloadProgress == 100
            ? GestureDetector(
                onTap: () {
                  incrementopenVideotaps();
                  incrementplaysfortoday();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VideoPlayPage(
                              url: receivedtiktokResponse!.data.play)));
                },
                child: Container(
                  width: screenwidth * 0.33,
                  height: screenwidth * 0.107,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.all(Radius.circular(26)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FeatherIcons.video,
                        //      size: 20,
                        size: screenwidth * 0.0446,
                        color: Colors.white,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            //        left: 12
                            top: screenwidth * 0.007,
                            left: screenwidth * 0.0241),
                        child: Text(
                          "Open",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: alshaussregular,
                              color: Colors.white,
                              //    fontSize: 14.5
                              fontSize: screenwidth * 0.041),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : GestureDetector(
                onTap: () {
                  checkpermissionsandDownloadVideo();
                },
                child: Container(
                  width: screenwidth * 0.33,
                  height: screenwidth * 0.107,
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
                        size: screenwidth * 0.0446,
                        color: Colors.white,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            //        left: 12
                            top: screenwidth * 0.007,
                            left: screenwidth * 0.0241),
                        child: Text(
                          "Video",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: alshaussregular,
                              color: Colors.white,
                              //    fontSize: 14.5
                              fontSize: screenwidth * 0.041),
                        ),
                      ),
                    ],
                  ),
                ),
              );
  }

  Widget audioDownloadButton({BuildContext? context}) {
    double screenwidth = MediaQuery.sizeOf(context!).width;
    return audiodownloadProgress > 0 && audiodownloadProgress < 100
        ? Stack(
            children: [
              Container(
                width: screenwidth * 0.33,
                height: screenwidth * 0.107,
                decoration: BoxDecoration(
                  color: tiksaverdarkgreybg,
                  borderRadius: BorderRadius.all(Radius.circular(26)),
                ),
              ),
              Container(
                width: screenwidth * 0.33,
                height: screenwidth * 0.107,
                decoration: BoxDecoration(
                  color: tiksaverdarkgreybg,
                  borderRadius: BorderRadius.all(Radius.circular(26)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      topRight: audiodownloadProgress == 100
                          ? Radius.circular(20)
                          : Radius.circular(0),
                      bottomRight: audiodownloadProgress == 100
                          ? Radius.circular(20)
                          : Radius.circular(0)),
                  child: LinearProgressIndicator(
                    semanticsLabel: "$audiodownloadProgress%",
                    value: audiodownloadProgress / 100,
                    // Convert the progress to a value between 0 and 1
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.redAccent), // Change this color as needed
                  ),
                ),
              ),
              Container(
                width: screenwidth * 0.33,
                height: screenwidth * 0.107,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(26)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FeatherIcons.downloadCloud,
                      //      size: 20,
                      size: screenwidth * 0.0446,
                      color: Colors.white,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          //        left: 12
                          top: screenwidth * 0.007,
                          left: screenwidth * 0.0241),
                      child: Text(
                        "$audiodownloadProgress%",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: alshaussregular,
                            color: Colors.white,
                            //    fontSize: 14.5
                            fontSize: screenwidth * 0.041),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : audiodownloadProgress == 100
            ? GestureDetector(
                onTap: () async{
                  //Open Audio here
                  incrementopenAudiotaps();
                  incrementaudioplaysfortoday();
                  //Push Audio Play Page
                  /*Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VideoPlayPage(
                              url: receivedtiktokResponse!.data.play)));
                  */
                  checkpermissionsandOpenAudio(lastsavedaudiofileLocation);
                },
                child: Container(
                  width: screenwidth * 0.33,
                  height: screenwidth * 0.107,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.all(Radius.circular(26)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FeatherIcons.headphones,
                        //      size: 20,
                        size: screenwidth * 0.0446,
                        color: Colors.white,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            //        left: 12
                            top: screenwidth * 0.007,
                            left: screenwidth * 0.0241),
                        child: Text(
                          "Open",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: alshaussregular,
                              color: Colors.white,
                              //    fontSize: 14.5
                              fontSize: screenwidth * 0.041),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : GestureDetector(
                onTap: () {
                  checkpermissionsandDownloadAudio();
                },
                child: Container(
                  width: screenwidth * 0.33,
                  height: screenwidth * 0.107,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.all(Radius.circular(26)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FeatherIcons.downloadCloud,
                        //      size: 20,
                        size: screenwidth * 0.0446,
                        color: Colors.white,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            //        left: 12
                            top: screenwidth * 0.007,
                            left: screenwidth * 0.0241),
                        child: Text(
                          "Audio",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: alshaussregular,
                              color: Colors.white,
                              //    fontSize: 14.5
                              fontSize: screenwidth * 0.041),
                        ),
                      ),
                    ],
                  ),
                ),
              );
  }

  Widget downloadVideoAudioButtons(BuildContext context) {
    double screenwidth = MediaQuery.sizeOf(context).width;
    return Container(
      margin: EdgeInsets.only(bottom: screenwidth * 0.0634),
      width: screenwidth * 0.715,
      height: screenwidth * 0.107,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          videoDownloadButton(
            context: context,
          ),
          audioDownloadButton(
            context: context,
          ),
        ],
      ),
    );
  }

  void checkpermissionsandDownloadVideo() async {
    var manageExternalStoragestatus =
        await Permission.manageExternalStorage.status;

    if (manageExternalStoragestatus.isDenied) {
      await Permission.manageExternalStorage.request();
    }
    incrementDownloadtaps();
    testdownload(receivedtiktokResponse!.data.play);
    setdownloadProgress(1);
    incrementdownloadsfortoday();
  }

  void checkpermissionsandDownloadAudio() async {
    var manageExternalStoragestatus =
        await Permission.manageExternalStorage.status;

    if (manageExternalStoragestatus.isDenied) {
      await Permission.manageExternalStorage.request();
    }
    incrementAudioDownloadtaps();
    testAudiodownload(receivedtiktokResponse!.data.musicInfo.play);
    setaudiodownloadProgress(1);
    incrementaudiodownloadsfortoday();
  }
  void checkpermissionsandOpenAudio(String filelocationPath) async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    openAudioFile(filelocationPath);
  }
  Widget downloadbutton(BuildContext context) {
    double screenwidth = MediaQuery.sizeOf(context).width;
    return GestureDetector(
      onTap: () {
        checkpermissionsandDownloadVideo();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenwidth * 0.0634),
        width: screenwidth * 0.715,
        height: screenwidth * 0.107,
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
              size: screenwidth * 0.0426,
              color: Colors.white,
            ),
            Container(
              margin: EdgeInsets.only(
                  //        left: 12
                  left: screenwidth * 0.0291),
              child: Text(
                "Download",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: alshaussregular,
                    color: Colors.white,
                    //    fontSize: 14.5
                    fontSize: screenwidth * 0.041),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void neuParsePastedLink({String? urli}) async {
    String shortCode = extractShortcode(urli!);
    final encodedParams = Uri(queryParameters: {'shortcode': shortCode}).query;

    final Uri url = Uri.parse(
        'https://instagram-saver-download-anything-on-instagram.p.rapidapi.com/post_data');

    final Map<String, String> headers = {
      'content-type': 'application/x-www-form-urlencoded',
      'X-RapidAPI-Key': '1b6b87d966msh79911a19efb2892p1e4e0fjsn0e980c80dc71',
      'X-RapidAPI-Host':
          'instagram-saver-download-anything-on-instagram.p.rapidapi.com',
    };

    final response =
        await http.post(url, headers: headers, body: encodedParams);

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  void parsePastedLink({String? urli}) async {
    setdownloadProgress(0);
    resetAudioDownloadingProgress();
    final url =
        'https://instagram-saver-download-anything-on-instagram.p.rapidapi.com/igsanitized';
    final headers = {
      'content-type': 'application/x-www-form-urlencoded',
      'X-RapidAPI-Key': '1b6b87d966msh79911a19efb2892p1e4e0fjsn0e980c80dc71',
      'X-RapidAPI-Host':
          'instagram-saver-download-anything-on-instagram.p.rapidapi.com',
    };
    final encodedParams = {'url': urli};
    try {
      print("IN Here");
      final response = await http.post(Uri.parse(url),
          headers: headers, body: encodedParams);
      print(response.body);
      //  parseResponsetoOutput(response.body);
    } catch (error) {
      print('Error from pasted link');
      runnewMainDownload(urli!);
      runBackupdownload(urli!);
//      seterrorthrowntrue();
      print('Error occurred with first option: $error');
    }
  }

  void updatedParsePastedLink({String? urli}) async {
    setdownloadProgress(0);
    resetAudioDownloadingProgress();
    try {
      tikTokAPIResponse(urli!);
      //  runnewMainDownload(urli!);
      //   runBackupdownload(urli!);
    } catch (error) {
      //erro thrown here
      print("IN Here");
    }
  }

  //the following is the rest of the functional code for parsing control

  emptytextfield(BuildContext context) {
    linkfieldcontroller.clear();
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    showdownload = 0;
    update();
  }

  void confirmLinkValidation() {
    if (linkfieldcontroller.text.contains("tiktok")) {
      setlinkvalidastrue();
      showdownload = 2;
    } else {
      seterrorthrownfalse();
      setlinkvalidasfalse();
      showdownload = 0;
    }
    update();
  }

  void deletefromdb(int id) async {
    int result = await downloadedVidDatabaseHelper.deleteDownload(id);
    if (result != 0) {
      print("Deleted succesfully");
    } else {
      print("Delete unsuccesful");
    }
  }

  emptyeverything(BuildContext context) {
    extractedlink = "";
    showdownload = 0;
    clipboarddata = '';
    linkfieldcontroller.clear();
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    update();
  }

  pastetoclipboard() {
    FlutterClipboard.paste().then((value) {
      // Do what ever you want with the value.
      seterrorthrownfalse();
      linkfieldcontroller.text = value;
      clipboarddata = value;
      String url = value;
//      parsePastedLink(urli: url);
      updatedParsePastedLink(urli: url);
      setloadingtrue();
      confirmLinkValidation();
      update();
    });
    //  testigpostdetails();
  }

  Widget homeMainColumn(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        currentActiveSection(context),
        DownloadInstructionOne(),
        RateUs()
      ],
    );
  }

  Widget currentActiveSection(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      /* showdownload == 3?
              ErrorBox():
              showdownload == 1
                  ? FetchingDownloadsInfo()
                  : showdownload ==
                  2
                  ? homepagedownloadvideo(context)

                  :
              */
      /*  receivedMedia != null
          ? videopage(context)
          : SizedBox(
              height: 0,
            ),*/
      errorThrown
          ? ErrorBox()
          : isLinkValid
              ? receivedtiktokResponse != null && isLoading == false
                  ? videopage(context)
                  : FetchingDownloadsInfo()
              : nolinkpasted(context),
    ]);
  }

  Widget linkpasterow(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
            onTap: () {
              emptyeverything(context);
              FlutterClipboard.paste().then((value) {
                pastetoclipboard();
              });
            },
            child: Container(
              //  width: 119,
              width: screenwidth * 0.3895,
              padding: EdgeInsets.symmetric(
                  //           vertical: 9),
                  vertical: screenwidth * 0.0318),
              decoration: BoxDecoration(
                  color: tiksavermainaccent,
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.13),
                        offset: Offset(0, 3),
                        blurRadius: 10)
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.doc_on_clipboard,
                    color: Colors.white,
                    size: screenwidth * 0.0583,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: screenwidth * 0.034),
                    child: Text("Paste Link",
                        style: TextStyle(
                            //        fontSize: 16,
                            fontSize: screenwidth * 0.0439,
                            color: Colors.white,
                            fontFamily: alshaussregular)),
                  ),
                ],
              ),
            )),
        GestureDetector(
            onTap: () {},
            child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                //      width: 111,
                width: screenwidth * 0.3895,
                margin: EdgeInsets.only(
                    //        left: 60
                    left: screenwidth * 0.0459),
                padding: EdgeInsets.symmetric(
                    //           vertical: 9),
                    vertical: screenwidth * 0.0318),
                decoration: BoxDecoration(
                    color:
                        /*  clipboardcontroller.taskss.length==0?
                    royalbluethemedcolor
                        .withOpacity(0.41):
                    clipboardcontroller.taskss[clipboardcontroller.taskss.length-1].name
                        ==clipboardcontroller.currentvideotitle &&
                        clipboardcontroller.taskss[clipboardcontroller.taskss.length-1].status==
                            DownloadTaskStatus.complete?
                    royalbluethemedcolor
                        .withOpacity(0.41):
                    clipboardcontroller.taskss[clipboardcontroller.taskss.length-1].name
                        ==clipboardcontroller.currentvideotitle &&
                        clipboardcontroller.taskss[clipboardcontroller.taskss.length-1].status==
                            DownloadTaskStatus.running?
                    royalbluethemedcolor
                        .withOpacity(0.41):
                        showdownload ==
                        2
                        ? royalbluethemedcolor
                        : */
                        tiksavermainaccent.withOpacity(0.41),
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.13),
                          offset: Offset(0, 3),
                          blurRadius: 10)
                    ]),
                child: Center(
                    child: Text(
                  "Download",
                  style: TextStyle(
                      //      fontSize: 16,
                      fontSize: screenwidth * 0.0439,
                      color: Colors.white,
                      fontFamily: alshaussregular),
                )))),
      ],
    );
  }

  Widget linktextfield(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(
          //          top: 29,bottom: 18
          top: screenwidth * 0.07055,
          bottom: screenwidth * 0.0437),
      padding: EdgeInsets.only(
          //        left: 15
          top: 2.5,
          left: screenwidth * 0.0364963),
      //    height: 41,
      height: screenwidth * 0.12975,
      width: screenwidth * 0.906,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          border:
              Border.all(color: Color(0xff707070).withOpacity(0.2), width: 1),
          color: tiksaverdarkgreybg,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: Offset(0, 3))
          ]),
      child: TextFormField(
        onChanged: (v) {
          confirmLinkValidation();
        },
        controller: linkfieldcontroller,
        cursorColor: Colors.white.withOpacity(0.9),
        style: TextStyle(
            color: Colors.white,
            //      fontSize: 15,
            fontSize: screenwidth * 0.042,
            fontFamily: proximanovaregular),
        decoration: InputDecoration(
            suffixIcon: GestureDetector(
              onTap: () {
                emptytextfield(context);
                setlinkvalidasfalse();
              },
              child: Icon(
                CupertinoIcons.xmark,
                color: Colors.white70,
                //      size: 17,
                size: screenwidth * 0.042,
              ),
            ),
            border: InputBorder.none,
            hintText: "Paste TikTok video video link here",
            hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.43),
                //   fontSize: 15,
                fontSize: screenwidth * 0.042,
                fontFamily: alshaussregular)),
      ),
    );
  }

  Widget nolinkpasted(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Container(
      //    margin: EdgeInsets.only(top: 25,bottom: 31),
      margin: EdgeInsets.only(
          top: screenwidth * 0.05720, bottom: screenwidth * 0.0709),
      width: screenwidth * 0.837,
      decoration: BoxDecoration(
        color: tiksaverlightbg,
        borderRadius: BorderRadius.all(Radius.circular(11)),
        border: Border.all(color: Color(0xff707070).withOpacity(0.2), width: 1),
      ),
      padding: EdgeInsets.all(
//          14
          screenwidth * 0.0460),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Text(
              "Copy link from a TikTok Video\n& start downloading",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: alshaussregular,
                  color: Colors.white,
                  //    fontSize: 16
                  fontSize: screenwidth * 0.0426),
            ),
          ),
          Container(
            child: Image.asset(
              "assets/images/Saly-1@3x.png",
              width: screenwidth * 0.49427,
            ),
          ),
        ],
      ),
    );
  }

  void checkPermissionandDownload() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      print("Permissionn is denied");
    } else {
      await Permission.storage.request();
    }
  }

  Future<void> _prepareSaveDir() async {
    localPath = (await _findLocalPath());

    final savedDir = Directory(localPath!);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }

  void downloadtestvideo(String url) async {
    String videoUrl = url;
    String forcedurl =
        "https://z-p4-instagram.fsgn5-12.fna.fbcdn.net/v/t66.30100-16/318229749_938006627283968_4480891006851727740_n.mp4?_nc_ht=z-p4-instagram.fsgn5-12.fna.fbcdn.net&_nc_cat=108&_nc_ohc=MngP_LvlbmwAX85qlPG&edm=APfKNqwBAAAA&ccb=7-5&oh=00_AfDuGAHuKPPribFmiOU-tyjutyHtOsZ1XDA-Aip3Vk7lNQ&oe=64D8FEDE&_nc_sid=721f0c";
    String caption =
        "Save THIS\u2705\ud83d\udccc\n\nThese are my all time favorite cookies. \n\nNot only do they taste amazing, one cookie packs a punch filling you up nicely.\n\nI must warn you it tastes bland first time around given that there\u2019s no sugar added (except honey). \n\nYou\u2019re more than welcome to play with honey serving, as well as other natural sweeteners like Stevia. \n\nFull instructions & recipe below:\n\n-You will need: \n\n8 eggs\n1 cup of oats\n7 heaping tablespoons of peanut butter\nTeaspoon of honey\nTeaspoon of vanilla extract\n5 scoops of protein of your choice (I use Isopure vanilla flavored)\n1 banana\n2 scoops of Casein Protein of your choice (I use Optimum Nutrition)\n\n-Preheat oven to 425 degrees Fahrenheit. \n\nWhen placing cookies on baking tray:\nOne tablespoon = 1 cookie.\n\nPlace cookies into the baking tray. Make sure to spray the baking sheet with non-stick cooking oil spray!\n\nSet timer for 9 minutes. \n\nAnd voila! \n\nTotal cookies: 22\n\nOverall Macros:\nFat: 159g\nCarbs: 98g\nProtein: 257g\n\nMacros per cookie: \nProtein: 12g\nFat: 7g\nCarbs: 4g\n\n*I recommend storing them in a fridge.\n\nFollow @rishandfit for more fitness content\ud83e\uddbe\n\n\u2022\n\u2022\n\u2022\n\n#fyp #fyp\u30b7 #foru #explore #fitness #gym #gymaddict #healthylifestyle #proteinrecipes #healthyliving #bodypositivity #fit #fitfam #fitnessaddict #fitnessjourney #fitnessmotivation #reels #explorepage";
    String finalpurestring = caption.replaceAll(RegExp(r'[\x00-\x1F]'), '');

    if (finalpurestring.length > 14) {
      finalpurestring = finalpurestring.substring(0, 14);
    } else {
      finalpurestring = finalpurestring;
    }
    update();

    final Directory? externalDir = await getExternalStorageDirectory();
    String externalStoragePath = externalDir!.path + '/' + finalpurestring;
    String randomUniqueString = generateRandomString(4);
    String filename = randomUniqueString;
    String reccaption = receivedtiktokResponse!.data.title;
    if (reccaption.length > 25) {
      filename = "${reccaption.substring(0, 24)}$randomUniqueString.mp4";
    } else {
      filename = "$reccaption$randomUniqueString.mp4";
    }

    final task = DownloadTask(
        url: videoUrl,
        // urlQueryParameters: {'q': 'pizza'},
//        filename: "finalpurestring.mp4",
        filename: filename,
        headers: {"auth": "test_for_sql_encoding"},
        directory: "DownloadedVideos",
        baseDirectory: BaseDirectory.applicationDocuments,
        updates: Updates.statusAndProgress,
        // request status and progress updates
        requiresWiFi: true,
        retries: 5,
        allowPause: true,
        metaData: 'data for me');

// Start download, and wait for result. Show progress and status changes
// while downloading
    final result = await FileDownloader().download(task,
        onProgress: (progress) {
          /* print("COnverted int progress is $intprogress");
          print('Progress: ${progress * 100}%');*/
          int intprogress = (progress * 100).toInt();
          if (intprogress > 0) {
            setdownloadProgress(intprogress);
          }
        },
        onStatus: (status) => print('Status: $status'));
// Act on the result
    switch (result) {
      case TaskStatus.complete:
        print('Success!');

      case TaskStatus.canceled:
        print('Download was canceled');

      case TaskStatus.paused:
        print('Download was paused');

      default:
        print("URL received here is: $videoUrl");
        print("URL set on top is: ${receivedtiktokResponse!.data.play}");
        setlastdownload(videoUrl);
        final newFilepath = await FileDownloader()
            .moveToSharedStorage(task, SharedStorage.files);
        // await FileDownloader().moveToSharedStorage(task, SharedStorage.video);
        final externalFilePath = await FileDownloader()
            .moveToSharedStorage(task, SharedStorage.external);
        final videoFilePath = await FileDownloader()
            .moveToSharedStorage(task, SharedStorage.external);
        if (newFilepath == null) {
          // handle error
          print("Error with new file path");
        } else {
          SavedVideos savedVidmodel = SavedVideos(
              caption: receivedtiktokResponse!.data.title,
              postType: "Video",
              height: 300,
              width: 100,
              mediaType: "Video",
              thumbnail: receivedtiktokResponse!.data.cover,
              url: receivedtiktokResponse!.data.play,
              fileLocationPath: newFilepath);
          saveVideo(savedVidmodel);
          moveFileToGallery(newFilepath);
          print("Files file path found and it is $newFilepath");
          print("External file path found and it is $externalFilePath");
          print("Video file path found and it is $videoFilePath");

          // do something with the newFilePath
        }
        // final downloadedTasks= await FileDownloader().openFile(task: task);
        print('Download not successful');
    }
  }

  void downloadtestaudio(String url) async {
    String videoUrl = url;
    String forcedurl =
        "https://z-p4-instagram.fsgn5-12.fna.fbcdn.net/v/t66.30100-16/318229749_938006627283968_4480891006851727740_n.mp4?_nc_ht=z-p4-instagram.fsgn5-12.fna.fbcdn.net&_nc_cat=108&_nc_ohc=MngP_LvlbmwAX85qlPG&edm=APfKNqwBAAAA&ccb=7-5&oh=00_AfDuGAHuKPPribFmiOU-tyjutyHtOsZ1XDA-Aip3Vk7lNQ&oe=64D8FEDE&_nc_sid=721f0c";
    String caption =
        "Save THIS\u2705\ud83d\udccc\n\nThese are my all time favorite cookies. \n\nNot only do they taste amazing, one cookie packs a punch filling you up nicely.\n\nI must warn you it tastes bland first time around given that there\u2019s no sugar added (except honey). \n\nYou\u2019re more than welcome to play with honey serving, as well as other natural sweeteners like Stevia. \n\nFull instructions & recipe below:\n\n-You will need: \n\n8 eggs\n1 cup of oats\n7 heaping tablespoons of peanut butter\nTeaspoon of honey\nTeaspoon of vanilla extract\n5 scoops of protein of your choice (I use Isopure vanilla flavored)\n1 banana\n2 scoops of Casein Protein of your choice (I use Optimum Nutrition)\n\n-Preheat oven to 425 degrees Fahrenheit. \n\nWhen placing cookies on baking tray:\nOne tablespoon = 1 cookie.\n\nPlace cookies into the baking tray. Make sure to spray the baking sheet with non-stick cooking oil spray!\n\nSet timer for 9 minutes. \n\nAnd voila! \n\nTotal cookies: 22\n\nOverall Macros:\nFat: 159g\nCarbs: 98g\nProtein: 257g\n\nMacros per cookie: \nProtein: 12g\nFat: 7g\nCarbs: 4g\n\n*I recommend storing them in a fridge.\n\nFollow @rishandfit for more fitness content\ud83e\uddbe\n\n\u2022\n\u2022\n\u2022\n\n#fyp #fyp\u30b7 #foru #explore #fitness #gym #gymaddict #healthylifestyle #proteinrecipes #healthyliving #bodypositivity #fit #fitfam #fitnessaddict #fitnessjourney #fitnessmotivation #reels #explorepage";
    String finalpurestring = caption.replaceAll(RegExp(r'[\x00-\x1F]'), '');

    if (finalpurestring.length > 14) {
      finalpurestring = finalpurestring.substring(0, 14);
    } else {
      finalpurestring = finalpurestring;
    }
    update();

    final Directory? externalDir = await getExternalStorageDirectory();
    String externalStoragePath = externalDir!.path + '/' + finalpurestring;
    String randomUniqueString = generateRandomString(4);
    String filename = randomUniqueString;
    String reccaption = receivedtiktokResponse!.data.title;
    if (reccaption.length > 25) {
      filename = "${reccaption.substring(0, 24)}$randomUniqueString.mp3";
    } else {
      filename = "$reccaption$randomUniqueString.mp3";
    }

    final task = DownloadTask(
        url: videoUrl,
        // urlQueryParameters: {'q': 'pizza'},
//        filename: "finalpurestring.mp4",
        filename: filename,
        headers: {"auth": "test_for_sql_encoding"},
        directory: "DownloadedVideos",
        baseDirectory: BaseDirectory.applicationDocuments,
        updates: Updates.statusAndProgress,
        // request status and progress updates
        requiresWiFi: true,
        retries: 5,
        allowPause: true,
        metaData: 'data for me');

// Start download, and wait for result. Show progress and status changes
// while downloading
    final result = await FileDownloader().download(task,
        onProgress: (progress) {
          /* print("COnverted int progress is $intprogress");
          print('Progress: ${progress * 100}%');*/
          int intprogress = (progress * 100).toInt();
          if (intprogress > 0) {
            setaudiodownloadProgress(intprogress);
          }
        },
        onStatus: (status) => print('Status: $status'));
// Act on the result
    switch (result) {
      case TaskStatus.complete:
        print('Success!');

      case TaskStatus.canceled:
        print('Download was canceled');

      case TaskStatus.paused:
        print('Download was paused');

      default:
        print("URL received here is: $videoUrl");
        print("URL set on top is: ${receivedtiktokResponse!.data.play}");
        setlastdownload(videoUrl);
        final newFilepath = await FileDownloader()
            .moveToSharedStorage(task, SharedStorage.files);
        // await FileDownloader().moveToSharedStorage(task, SharedStorage.video);
        final externalFilePath = await FileDownloader()
            .moveToSharedStorage(task, SharedStorage.external);
        final videoFilePath = await FileDownloader()
            .moveToSharedStorage(task, SharedStorage.external);
        if (newFilepath == null) {
          // handle error
          print("Error with new file path");
        } else {
          // add audio model database here
          /*SavedAudios savedAudiomodel = SavedAudios(
              caption: receivedtiktokResponse!.data.title,
              postType: "Video",
              height: 300,
              width: 100,
              mediaType: "Video",
              thumbnail: receivedtiktokResponse!.data.cover,
              url: receivedtiktokResponse!.data.play,
              fileLocationPath: newFilepath);*/
          SavedAudios savedAudiomodel = SavedAudios(
              title: receivedtiktokResponse!.data.musicInfo.title == null
                  ? ""
                  : receivedtiktokResponse!.data.musicInfo.title,
              play: receivedtiktokResponse!.data.musicInfo.play == null
                  ? ""
                  : receivedtiktokResponse!.data.musicInfo.play,
              cover: receivedtiktokResponse!.data.musicInfo.cover == null
                  ? ""
                  : receivedtiktokResponse!.data.musicInfo.cover,
              author: receivedtiktokResponse!.data.musicInfo.author == null
                  ? ""
                  : receivedtiktokResponse!.data.musicInfo.author,
              duration: receivedtiktokResponse!.data.musicInfo.duration == null
                  ? 10
                  : receivedtiktokResponse!.data.musicInfo.duration,
              album: receivedtiktokResponse!.data.musicInfo.album == null
                  ? ""
                  : receivedtiktokResponse!.data.musicInfo.album,
              fileLocationPath: newFilepath);
          updatelastsavedAudiofile(newFilepath);
          saveAudio(savedAudiomodel);
          print("Files file path found and it is $newFilepath");
          print("External file path found and it is $externalFilePath");
          print("Video file path found and it is $videoFilePath");

          // do something with the newFilePath
        }
        // final downloadedTasks= await FileDownloader().openFile(task: task);
        print('Download not successful');
    }
  }

  void incrementdownloadsfortoday() async {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection('NeuDownloads');
    /*var doc = await collectionRef
        .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
        .get();

    if (doc.exists) {
      await FirebaseFirestore.instance
          .collection("NeuDownloads")
          .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
          .update({"numberofdownloads": FieldValue.increment(1)});
    } else {
      await FirebaseFirestore.instance
          .collection("NeuDownloads")
          .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
          .set({"numberofdownloads": 1});
    }*/
    await collectionRef
        .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
        .set({"numberofdownloads": FieldValue.increment(1)},
            SetOptions(merge: true));
  }

  void incrementaudiodownloadsfortoday() async {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection('NeuDownloads');
    /*var doc = await collectionRef
        .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
        .get();

    if (doc.exists) {
      await FirebaseFirestore.instance
          .collection("NeuDownloads")
          .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
          .update({"numberofdownloads": FieldValue.increment(1)});
    } else {
      await FirebaseFirestore.instance
          .collection("NeuDownloads")
          .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
          .set({"numberofdownloads": 1});
    }*/
    await collectionRef
        .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
        .set({"numberofaudiodownloads": FieldValue.increment(1)},
            SetOptions(merge: true));
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
    await collectionRef
        .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
        .set({"numberofplays": FieldValue.increment(1)},
            SetOptions(merge: true));
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

  String generateRandomString(int length) {
    final random = Random();
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String result = '';

    for (int i = 0; i < length; i++) {
      result += chars[random.nextInt(chars.length)];
    }

    return result;
  }

  Future<void> moveFileToGallery(String filepath) async {
    final file = File(filepath); // Replace with your file path
    final galleryDirectory = await getExternalStorageDirectory();
    final newFilePath =
        '${galleryDirectory!.path}/DCIM/${file.path.split('/').last}';
    await file.copy(newFilePath);
  }

  //here is the code for backup fetching function
  void runBackupdownload(String url) {
    String shortCode = extractShortcode(url);
    extractfromBulkScraper(shortCode);
  }

  String extractShortcode(String url) {
    // Splitting the URL by '/' and getting the last part
    List<String> parts = url.split('/');
    String secondlastPart = parts[parts.length - 2];

    // Removing any query parameters or fragments
    if (parts.last.contains('?')) {
      List<String> queryParams = parts.last.split('?');
      print("Query partams is ${queryParams[0]}");
      return secondlastPart;
    }
    return parts.last;
    //  print("Short code is $lastPart");
  }

  void extractfromBulkScraper(String shortcode) async {
    final String url =
        'https://instagram-bulk-scraper-latest.p.rapidapi.com/webmedia_info_from_shortcode/$shortcode';

    final Map<String, String> headers = {
      'X-RapidAPI-Key': '1b6b87d966msh79911a19efb2892p1e4e0fjsn0e980c80dc71',
      'X-RapidAPI-Host': 'instagram-bulk-scraper-latest.p.rapidapi.com',
    };
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        //print(response.body);
        // parseBackUpResponsetoOutput(response.body);
      } else {
        seterrorthrowntrue();
        print('Error from bulk scraper');
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  /*void parseBackUpResponsetoOutput(String responsebody) {
    // String finalpurestring = sampleResponsefromreels.replaceAll(RegExp(r'[^\x00-\x7F]+'), '');
    String finalpurestring =
    responsebody.replaceAll(RegExp(r'[\x00-\x1F]'), '');
    Map<String, dynamic> parsedJson = json.decode(finalpurestring);
    bool isvideo = parsedJson['data']['is_video'];
    String mediaType="Video";
    if(isvideo){
      mediaType="Video";
      print("Post type is video");
      String caption=parsedJson['data']['edge_media_to_caption']['edges'][0]['node']['text'];
      String videoUrl=parsedJson['data']['video_url'];
      String thumbnail=parsedJson['data']['thumbnail_src'];
      int height=parsedJson['data']['dimensions']['height'];
      int width=parsedJson['data']['dimensions']['width'];
      Dimension dimensions=Dimension(height: height, width: width);
      List<Media> medias = [Media(dimension: dimensions, mediaType: mediaType, thumbnail: thumbnail, url: videoUrl)];
      ApiResponse apiResponse =ApiResponse(caption: caption, media: medias, postType: mediaType);
      receivedMedia=medias[0];
      receivedResponse=apiResponse;
      setloadingfalse();
      update();
    }else{
      mediaType="Photo";
      seterrorthrowntrue();
      print("Post type is not video");
    }

/*
    ApiResponse response = ApiResponse.fromJson(parsedJson);
    print("Post Type: ${response.postType}");
    receivedResponse = response;
    for (var media in response.media) {
      receivedMedia = media;
      setloadingfalse();
      print("Media Type: ${media.mediaType}");
      print("Thumbnail: ${media.thumbnail}");
      print("URL: ${media.url}");
      print(
          "Dimension - Height: ${media.dimension.height}, Width: ${media.dimension.width}");
    }*/
    update();
  }*/
  void runnewMainDownload(String url) {
    String shortCode = extractShortcode(url);
    parseFromNewApiStructure(urli: url, shortcode: shortCode);
  }

  void parseFromNewApiStructure(
      {@required String? urli, @required String? shortcode}) async {
    final Uri url = Uri.parse(
        'https://instagram-saver-download-anything-on-instagram.p.rapidapi.com/post_data');
    final Map<String, String> headers = {
      'content-type': 'application/x-www-form-urlencoded',
      'X-RapidAPI-Key': '1b6b87d966msh79911a19efb2892p1e4e0fjsn0e980c80dc71',
      'X-RapidAPI-Host':
          'instagram-saver-download-anything-on-instagram.p.rapidapi.com',
    };

    final Map<String, String> body = {
      //  'shortcode': 'CS8ju3gDkWc',
      'shortcode': '$shortcode',
    };
    final http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      print('Error: ${response.statusCode}');
      runBackupdownload(urli!);
      print(response.body);
    }
  }

  void parseTikTokResponsetoOutput(TikTokResponse tikTokResponse) {
    // String finalpurestring = sampleResponsefromreels.replaceAll(RegExp(r'[^\x00-\x7F]+'), '');
    String responsebody = "";
    String finalpurestring =
        responsebody.replaceAll(RegExp(r'[\x00-\x1F]'), '');
    setloadingfalse();
    update();

/*
    ApiResponse response = ApiResponse.fromJson(parsedJson);
    print("Post Type: ${response.postType}");
    receivedResponse = response;
    for (var media in response.media) {
      receivedMedia = media;
      setloadingfalse();
      print("Media Type: ${media.mediaType}");
      print("Thumbnail: ${media.thumbnail}");
      print("URL: ${media.url}");
      print(
          "Dimension - Height: ${media.dimension.height}, Width: ${media.dimension.width}");
    }*/
    update();
  }

  void tikTokAPIResponse(String tiktokUrl) async {
    final baseUrl = 'tiktok-download-without-watermark.p.rapidapi.com';
    final path = '/analysis';
    final queryParams = {'url': tiktokUrl, 'hd': '0'};
    final headers = {
      'X-RapidAPI-Key': '1b6b87d966msh79911a19efb2892p1e4e0fjsn0e980c80dc71',
      'X-RapidAPI-Host': 'tiktok-download-without-watermark.p.rapidapi.com'
    };

    final uri = Uri.https(baseUrl, path, queryParams);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
//    print(response.body);
      print("We are here succesfully");
      final jsonResponse = json.decode(response.body);
      final tikTokResponse = TikTokResponse.fromJson(jsonResponse);
      receivedtiktokResponse = TikTokResponse.fromJson(jsonResponse);
      parseTikTokResponsetoOutput(receivedtiktokResponse!);
      print("response code and title are:\n");
      // Now you have the TikTokResponse instance.
      print(tikTokResponse.code);
      print("Caption is:\n");
      print(tikTokResponse.data.title);
      print("Thumbnail is:\n");
      print(tikTokResponse.data.cover);
      print("Video Link is:\n");
      print(tikTokResponse.data.play);
      print("Music cover is:\n");
      print(tikTokResponse.data.musicInfo.cover);
    } else {
      seterrorthrowntrue();
      print('Error from bulk scraper');
      print('Request failed with status: ${response.statusCode}');
    }
  }
  Future<void> openAudioFile(String filelocationPath) async {
    String filePath = filelocationPath; // Replace with the actual file path
    try {
      final result = await OpenFile.open(filePath);
      if (result.type == ResultType.done) {
        print('File opened successfully.');
      } else {
        print('Error opening the file: ${result.message}');
      }
    } catch (e) {
      print('Error opening the file: $e');
    }
  }
}
