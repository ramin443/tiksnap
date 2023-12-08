import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/adconstants.dart';

class AdController extends GetxController{
  BannerAd? bannerAd;
  BannerAd? downloadsbannerAd;
  InterstitialAd? interstitialAd;
  RewardedAd? rewardedAd;
  int rewardedScore=0;
  DatabaseReference interstitialref = FirebaseDatabase.instance.ref().child("interstitialads");
  DatabaseReference bannerref = FirebaseDatabase.instance.ref().child("bannerads");
  DatabaseReference downtapfreqref = FirebaseDatabase.instance.ref().child("downloadtapfrequency");
  DatabaseReference playtapfreqref = FirebaseDatabase.instance.ref().child("playtapfrequency");
  late StreamSubscription<DatabaseEvent> showinterstitialsubscription;
  late StreamSubscription<DatabaseEvent> showbannersubscription;
  late StreamSubscription<DatabaseEvent> downtapfreqsubcription;
  late StreamSubscription<DatabaseEvent> playtapsubscription;
  bool showinterstitialads=false;
  bool showbannerads=false;
  int downtapfrequency=3;
  int playtapfrequency=10;
  late Stream<DatabaseEvent> enet;
  void initializestreams()async{

    showinterstitialsubscription=interstitialref.onValue.listen((event) {
      showinterstitialads=event.snapshot.value as bool;
    });

    showbannersubscription=bannerref.onValue.listen((event) {
      showbannerads=event.snapshot.value as bool;
    });
    downtapfreqsubcription=downtapfreqref.onValue.listen((event) {
      downtapfrequency=event.snapshot.value as int;
    });
    playtapsubscription=playtapfreqref.onValue.listen((event) {
      playtapfrequency=event.snapshot.value as int;
    });
   // update();
    print("Setting showbanner ads as $showbannerads");
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad){
      print("Ad Loaded");
    },
    onAdFailedToLoad: (ad,error){
      print("Failed to load because $error");
    },
    onAdOpened: (ad){
      print("Ad opened");
    },
    onAdClosed: (ad){
      print("Ad opened");
    }
  );

  void initializebannerAd()async{
    bannerAd=BannerAd(size: AdSize.fullBanner, adUnitId: banneradunitid,
        listener: bannerAdListener, request: const AdRequest())..load();
    downloadsbannerAd=BannerAd(size: AdSize.fullBanner, adUnitId: banneradunitid,
        listener: bannerAdListener, request: const AdRequest())..load();
  }

  void initializeInterstitialAd()async{
   InterstitialAd.load(adUnitId: interstitialadunitid,
       request: const AdRequest(), adLoadCallback: InterstitialAdLoadCallback(
           onAdLoaded: (ad){
             interstitialAd=ad;
             update();
           }, onAdFailedToLoad: (LoadAdError error){
             interstitialAd=null;
       }));
  }

  void showInterstitialAd(){
    if(showinterstitialads){
      if(interstitialAd !=null){
        interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad){
              ad.dispose();
              initializeInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad,error){
              ad.dispose();
              initializeInterstitialAd();
            }
        );
        interstitialAd!.show();
        interstitialAd=null;
        update();
      }else{
        print("Is not initialized");
      }
    }

  }

  Widget displayBannerWidget(BuildContext context){
    double screenwidth=MediaQuery.sizeOf(context).width;
    return
      showbannerads?
      bannerAd==null?

      SizedBox(
      height: 0,
    ):
    FloatingActionButton.extended(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.transparent,
      onPressed: (){},
      label: StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: screenwidth*0.148,
            width: screenwidth,
            margin: EdgeInsets.all(0), // No margin
            child: AdWidget(
              ad: bannerAd!,
            ),
          );
        }
      ),
    ):SizedBox(
        height: 0,
      );
  }
  Widget displayDownloadsBannerWidget(BuildContext context){
    double screenwidth=MediaQuery.sizeOf(context).width;
    return
      showbannerads?
      downloadsbannerAd==null?

      SizedBox(
        height: 0,
      ):
      FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.transparent,
        onPressed: (){},
        label: Container(
          height: screenwidth*0.148,
          width: screenwidth,
          margin: EdgeInsets.all(0), // No margin
          child: AdWidget(
            ad: downloadsbannerAd!,
          ),
        ),
      ):SizedBox(
        height: 0,
      );
  }
  void fetchbanneradsVal() {
    bannerref.once().then((value) {
      print(value.snapshot.value);
    });
  }
}