import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'HomeScreen.dart';
import 'NewsInfo.dart';
import 'SqlMethods.dart';

class Favorite extends StatefulWidget {
  const Favorite({Key? key}) : super(key: key);

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> with TickerProviderStateMixin {
  var allTags = List.empty(growable: true);
  var tisArticleMap = List.empty(growable: true);
  TabController? controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTags();
  }

  void getTags() async {
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
    controller = TabController(length: allTags.length, vsync: this);
    tisArticleMap = articleMap;
    controller!.addListener(() {
      var tag = allTags[controller!.index];
      tisArticleMap = tag == "全部"
          ? articleMap
          : articleMap.where((element) {
              return element["主分類"] == tag;
            }).toList(growable: false);
      setState(() {});
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 160,
                color: Color(0xff4D4BC2),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Get.back();
                            },
                            icon: const Icon(
                              Icons.arrow_back_sharp,
                              weight: 10,
                            )),
                        const Spacer(),
                        const Text(
                          "我的最愛",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const Spacer(),
                        Container(
                          width: 50,
                        )
                      ],
                    ),
                  ),
                  if (controller != null)
                    Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: TabBar(
                        controller: controller,
                        isScrollable: true,
                        tabs: [for (var i in allTags) Tab(text: i)],
                        indicatorColor: Colors.white,
                        indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    )
                ],
              ),
            ],
          ),
          if (controller != null)
            Expanded(
              child: TabBarView(controller: controller, children: [
                for (var i in allTags)
                  ListView.builder(
                    itemCount: tisArticleMap.length,
                    itemBuilder: (BuildContext context, int index) {
                      return favoriteArray[int.parse(
                                  tisArticleMap[index]["文章編號"].toString()) -
                              1]
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: tisArticleMap[index]["發文日期"] != null
                                  ? Card(
                                      child: InkWell(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(tisArticleMap[index]
                                                    ["發文日期"]),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0),
                                                  child: Text(
                                                      tisArticleMap[index]
                                                              ["發布者"] ??
                                                          "未知"),
                                                ),
                                                Spacer(),
                                                IconButton(
                                                    onPressed: () async {
                                                      await ArticleSql()
                                                          .setFavorite(
                                                              tisArticleMap[
                                                                      index]
                                                                  .toString());
                                                      favoriteArray[
                                                          int.parse(tisArticleMap[
                                                                          index]
                                                                      ["文章編號"]
                                                                  .toString()) -
                                                              1] = await ArticleSql()
                                                          .getFavorite(
                                                              tisArticleMap[
                                                                      index]
                                                                  .toString());
                                                      setState(() {});
                                                    },
                                                    icon: favoriteArray[int.parse(
                                                                tisArticleMap[
                                                                            index]
                                                                        ["文章編號"]
                                                                    .toString()) -
                                                            1]
                                                        ? Icon(Icons.favorite)
                                                        : Icon(Icons
                                                            .favorite_border))
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  tisArticleMap[index]["主分類"],
                                                  style: TextStyle(
                                                      color: Color(0xff1D1Ac7),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0),
                                                  child: Text(
                                                      tisArticleMap[index]
                                                              ["子分類"] ??
                                                          ""),
                                                )
                                              ],
                                            ),
                                            Text(
                                              tisArticleMap[index]["標題"],
                                              maxLines: 2,
                                            )
                                          ],
                                        ),
                                        onTap: () {
                                          Get.to(NewsInfo(
                                            jsonText: tisArticleMap[index],
                                            commentArray: commentArray[
                                                int.parse(tisArticleMap[index]
                                                            ["文章編號"]
                                                        .toString()) -
                                                    1],
                                          ));
                                        },
                                      ),
                                    )
                                  : Container(),
                            )
                          : Container();
                    },
                  )
              ]),
            )
        ],
      ),
    );
  }
}
