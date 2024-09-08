import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


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
  Future<String> loadAsset() async {
    return await rootBundle.loadString('res/api/list.json');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      onTap: (){},
                      child: SizedBox(
                        height: 50,
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