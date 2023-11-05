import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiksnap/models/SavedAudios.dart';

import '../constants/colorconstants.dart';
import '../constants/fontconstants.dart';
import 'adController.dart';

final AdController adController =
Get.put(AdController());
class AudioPlayController extends GetxController{
  int pausePlaytaps=0;
  bool reachedEnd=false;
  int currentposition=0;
  int maxduration=0;
  final assetsAudioPlayer = AssetsAudioPlayer();
  bool isPlaying=false;

  void currentPositionListener(SavedAudios savedAudio){
    assetsAudioPlayer.currentPosition.listen((event) {
      currentposition=event.inSeconds;
      if(currentposition==savedAudio.duration){
        reachedEnd=true;
        isPlaying=false;
      }else{
        reachedEnd=false;
      }
      update();
    });
  }
  void updateisPlayingState(){
    isPlaying=!isPlaying;
    update();
  }

  void audioListeners(){
    pausePlaytaps=0;
   /* audioPlayer.onDurationChanged.listen((Duration d) { //get the duration of audio
       maxduration = d.inMilliseconds;
       update();
    });
    audioPlayer.onPositionChanged.listen((Duration  p){
      currentposition = p.inMilliseconds; //get the current position of playing audio
      update();
    });*/
    update();
  }
  void incrementpausePlaytaps(){
    pausePlaytaps++;
    int playtaplimit=adController.playtapfrequency;
    if(pausePlaytaps % playtaplimit == 0){
      adController.showInterstitialAd();
    } update();
  }

  void playInitial(SavedAudios savedAudio)async{
    print("Playing intial here");
    try {
      await assetsAudioPlayer.open(
        Audio.network(savedAudio.play!),
      );
    } catch (t) {
      //mp3 unreachable
      print("An error occured");
    }  }

    void stopaudio()async{
      pausePlaytaps=0;
      isPlaying=false;
      await assetsAudioPlayer.stop();
      update();
    }
  Future<bool> onBackPressed() async {
      isPlaying=false;
      await assetsAudioPlayer.stop();
      update();
    /* // Execute your custom function here
    if (vidcontroller.value.isPlaying) {
      vidcontroller.pause();
      update();
    }    // Return true to allow back navigation
    */
    return true;
  }
  Widget videocontrolaction(BuildContext context,SavedAudios savedAudio){
    double screenwidth=MediaQuery.sizeOf(context).width;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Adjust blur intensity
        child: Container(
          width: screenwidth,
          height: screenwidth*0.255,
          decoration: BoxDecoration(
              color: Colors.black12
          ),child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            /*
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                child: LinearProgressIndicator(
                  value: videoProgress,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
              Slider(
                value: sliderValue,
                onChanged: (newValue) {
                    sliderValue = newValue;
                    final newTime = vidcontroller.value.duration * newValue;
                    vidcontroller.seekTo(newTime);
                    update();
                    },
              ),*/
            Container(
              width: screenwidth,
              padding: EdgeInsets.only(left: 12,
                  right: 12,top: 16
              ),
              child: ProgressBar(
                timeLabelTextStyle: TextStyle(
                    fontFamily: proximanovaregular,
                    color: Colors.white,
                    fontSize: 14
                ),
                progress:Duration(seconds: currentposition),
                //Duration(milliseconds: 0),
                total: Duration(seconds: savedAudio.duration!),
                thumbColor: royalbluethemedcolor,
                barHeight: 6.0,
                thumbRadius: 6.0,
                progressBarColor: royalbluethemedcolor,
                baseBarColor: Colors.white.withOpacity(0.24),
                onSeek: (duration) async{
                  await assetsAudioPlayer.seek(duration);


                  //  sliderValue = duration.inMilliseconds.toDouble();
                  // final newTime = vidcontroller.value.duration * duration.inMilliseconds.toDouble();
                //  assetsAudioPlayer.seek(duration);
                //  vidcontroller.seekTo(duration);
                  update();
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(onPressed: (){
                  if(pausePlaytaps==0){
                    playInitial(savedAudio);
                  }else{
                    if (isPlaying) {
                      assetsAudioPlayer.pause();
                      update();
                    } else {
                      // need a slider
                      assetsAudioPlayer.play();
                      update();
                    }
                  }
                  incrementpausePlaytaps();
                  updateisPlayingState();
                }, icon: Icon(
                  reachedEnd?
                  CupertinoIcons.gobackward :
                  isPlaying ?
                  CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                  size: screenwidth*0.08,
                  color: Colors.white,
                )),
                /* GestureDetector(
                  onTap: (){
                    if (vidcontroller.value.isPlaying) {
                      vidcontroller.pause();
                      update();
                    } else {
                      // need a slider

                      vidcontroller.play();
                      update();
                    }
                  },
                  child: Container(
                    child: Icon(
                      reachedEnd?
                      CupertinoIcons.gobackward :
                      vidcontroller.value.isPlaying ?
                    CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                    size: screenwidth*0.08,
                      color: Colors.white,
                    ),
                  ),
                )
                */
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}