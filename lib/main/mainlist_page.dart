import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../sub/question_page.dart';

final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

/*
* 스테이트풀 위젯(Statefull widget)은 동적 데이터를 관리
* 데이터가 변경됨에 따라 UI가 함께 변화
* */
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainPage();
  }
}

class _MainPage extends State<MainPage> {

  String welcomeTitle = '';
  bool bannerUse = false;
  int itemHeight = 50;

  @override
  void initState() {
    super.initState();
    remoteConfigInit();
  }

  void remoteConfigInit() async {
    await remoteConfig.fetchAndActivate();
    welcomeTitle = remoteConfig.getString("welcome");
    bannerUse = remoteConfig.getBool("banner");
    itemHeight = remoteConfig.getInt("item_height");
    print('welcomeTitle : $welcomeTitle');
    print('bannerUse : $bannerUse');
    print('itemHeight : $itemHeight');
  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('res/api/list.json');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: bannerUse
          ? AppBar(
            title: Text(welcomeTitle),
          )
          : null,
      body: FutureBuilder(
        future: loadAsset(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {

            case ConnectionState.none:
              return const Center(
                child: Text('No Data'),
              );
            case ConnectionState.waiting || ConnectionState.active:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasData) {
                Map<String, dynamic> list = jsonDecode(snapshot.data!);
                return ListView.builder(
                  itemBuilder: (context, value) {
                    return InkWell(
                      onTap: () async {
                        await FirebaseAnalytics.instance.logEvent(
                          name: "test_click",
                          parameters: {
                            "test_name" :
                                list['questions'][value]['title'].toString(),
                          },
                        ).then((result) {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                                return QuestionPage(
                                  question: list['questions'][value]['file'].toString(),
                                );
                          }));
                        });
                      },
                      child: SizedBox(
                        height: itemHeight.toDouble(),
                        child: Card(
                          child: Text(list['questions'][value]['title'].toString()),
                        ),
                      ),
                    );
                  },
                  itemCount: list['count'],
                );
              } else {
                return Text('Error: ${snapshot.error}');
              }
          }
        },
      ),
    );
  }
}