import 'dart:convert';

import 'package:flutter/material.dart';

class Favorite extends StatefulWidget {
  const Favorite({Key? key}) : super(key: key);

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  var allTags = List.empty(growable: true);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTags();
  }

  void getTags()async{
    var jsonText =
    await DefaultAssetBundle.of(context).loadString("res/Data.json");
    var tisTags = jsonDecode(jsonText)["分類"];
    allTags.add("全部");
    for (var i in tisTags) {
      var has = false;
      for (var j in allTags) {
        if (j == i["主分類"]) {
          has = true;
        }
      }
      if (!has) {
        allTags.add(i["主分類"]);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: allTags.length,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 150,
                  color: Color(0xff4D4BC2),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children:  [
                    const Align(
                      alignment: Alignment.center,
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text(
                            "我的最愛",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: TabBar(
                        isScrollable: true,
                        tabs: [
                          for(var i in allTags) Tab(text:i)
                        ],
                        indicatorColor: Colors.white,
                        indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    )
                  ],
                ),
              ],
            ), 
            Expanded(
              child: TabBarView(children: [
                for(var i in allTags) Text(i)
              ]),
            )
          ],
        ),
      ),
    );
  }
}
