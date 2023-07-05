import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:s2_0705/Screens/NewsInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Favotite.dart';
import 'SqlMethods.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

var isLogin = false.obs;
var name = "".obs;
var articleMap = List.empty();
var commentArray = List.empty(growable: true);
var favoriteArray = List.empty(growable: true).obs;

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> key = GlobalKey(debugLabel: "Scaffold");
  var titleController = TextEditingController();
  var subTypeController = TextEditingController();
  var linkTextController = TextEditingController();
  var linkController = TextEditingController();
  var contextController = TextEditingController();
  var tisArticleMap = List.empty();
  var tag = "a1";
  var newTag = "a1".obs;
  var allTags = List.empty(growable: true);
  var emailController = TextEditingController();
  var pwdController = TextEditingController();
  var nameController = TextEditingController();
  var showPwd = false.obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void init() async {
    name.value = await Sql().getName();
    var sp = await SharedPreferences.getInstance();
    isLogin.value = sp.getBool("isLogin") ?? false;
    var jsonText =
        await DefaultAssetBundle.of(context).loadString("res/Data.json");
    articleMap = jsonDecode(jsonText)["文章"];
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
    for (var i = 0; i < articleMap.length; i++) {
      commentArray.add(List.empty(growable: true));
      favoriteArray
          .add(await ArticleSql().getFavorite(articleMap[i].toString()));
    }
    print(favoriteArray);
    var tisComment = jsonDecode(jsonText)["回應"];
    for (var i in tisComment) {
      commentArray[int.parse(i["文章編號"].toString()) - 1].add(i);
    }
    tag = allTags[0];
    tisArticleMap = articleMap;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Obx(() => Text(name.value)),
              ElevatedButton(
                  onPressed: () {
                    Get.to(const Favorite());
                  },
                  child: Text("我的最愛")),
              Spacer(),
              Obx(() => isLogin.value
                  ? ElevatedButton(
                      onPressed: () async {
                        var sp = await SharedPreferences.getInstance();
                        sp.setBool("isLogin", false);
                        isLogin.value = false;
                        name.value = "";
                      },
                      child: const Text("登出"))
                  : ElevatedButton(
                      onPressed: () async {
                        key.currentState!.closeDrawer();
                        key.currentState!
                            .showBottomSheet((context) => Container(
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                      color: Color(0xff9BC4EAFF),
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "登入",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                        TextField(
                                          controller: emailController,
                                          decoration: InputDecoration(
                                            hintText: "帳號",
                                          ),
                                        ),
                                       Obx(() =>  TextField(
                                         controller: pwdController,
                                         obscureText: !showPwd.value,
                                         decoration: InputDecoration(
                                             hintText: "密碼",
                                             suffix: Obx(() => IconButton(
                                               icon: Icon(showPwd.value
                                                   ? Icons.visibility_off
                                                   : Icons.visibility),
                                               onPressed: () {
                                                 showPwd.value = !showPwd.value;
                                                 setState(() {});
                                               },
                                             ))),
                                       ),),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                                onPressed: () async {
                                                  if (await Sql().login(
                                                      emailController.text,
                                                      pwdController.text)) {
                                                    Get.back();
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content:
                                                                Text("登入成功")));
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content:
                                                                Text("登入失敗")));
                                                  }
                                                },
                                                child: Text("送出")),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    Get.back();
                                                  },
                                                  child: Text("取消")),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    Get.back();
                                                    key.currentState!
                                                        .showBottomSheet(
                                                            (context) =>
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  decoration: const BoxDecoration(
                                                                      color: Color(
                                                                          0xff9BC4EAFF),
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              20),
                                                                          topRight:
                                                                              Radius.circular(20))),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .all(
                                                                        10.0),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        const Text(
                                                                          "註冊",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 20),
                                                                        ),
                                                                        TextField(
                                                                          controller:
                                                                              emailController,
                                                                          decoration:
                                                                              const InputDecoration(hintText: "帳號"),
                                                                        ),
                                                                        Obx(() => TextField(
                                                                          controller:
                                                                          pwdController,
                                                                          obscureText:
                                                                          !showPwd.value,
                                                                          decoration:
                                                                          InputDecoration(
                                                                              hintText:
                                                                              "密碼",
                                                                              suffix:
                                                                              Obx(() => IconButton(
                                                                                icon: Icon(showPwd.value ? Icons.visibility_off : Icons.visibility),
                                                                                onPressed: () {
                                                                                  showPwd.value = !showPwd.value;
                                                                                  setState(() {});
                                                                                },
                                                                              ),)
                                                                          ),
                                                                        ),),
                                                                        TextField(
                                                                          controller:
                                                                              nameController,
                                                                          decoration:
                                                                              const InputDecoration(hintText: "暱稱"),
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            ElevatedButton(
                                                                                onPressed: () async {
                                                                                  if (!GetUtils.isEmail(emailController.text)) {
                                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email格式錯誤")));
                                                                                    return;
                                                                                  }
                                                                                  var pwd = pwdController.text;
                                                                                  if (!((pwd.contains(RegExp("[A-Z]")) && pwd.contains(RegExp("[a-z]")) && pwd.contains(RegExp("[\\W]")) && pwd.contains(RegExp("[0-9]"))) || (pwd.length > 8 && pwd.length < 15))) {
                                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("密碼格式錯誤")));
                                                                                    return;
                                                                                  }
                                                                                  if (await Sql().insert(emailController.text, pwdController.text, nameController.text)) {
                                                                                    Get.back();
                                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("註冊成功")));
                                                                                  } else {
                                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("註冊失敗")));
                                                                                  }
                                                                                },
                                                                                child: Text("送出")),
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                              child: ElevatedButton(
                                                                                  onPressed: () {
                                                                                    Get.back();
                                                                                  },
                                                                                  child: Text("取消")),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ));
                                                  },
                                                  child: Text("註冊")),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ));
                      },
                      child: const Text("登入")))
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  child: Image.asset(
                    "res/drawerIcon.png",
                    width: 50,
                    height: 50,
                  ),
                  onTap: () {
                    key.currentState!.openDrawer();
                  },
                ),
                Spacer(),
                const Text(
                  "第53屆全國技能競賽論壇",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xff1D1Ac7), fontWeight: FontWeight.bold),
                ),
                Spacer(),
              ],
            ),
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [
                  for (var i in allTags)
                    PopupMenuItem(
                      child: Text(i.toString()),
                      value: i.toString(),
                    )
                ];
              },
              onSelected: (value) {
                tag = value!.toString();
                tisArticleMap = articleMap.where((i) {
                  if (tag != "全部") {
                    return i["主分類"] != null && i["主分類"] == tag;
                  } else {
                    return true;
                  }
                }).toList();
                setState(() {});
              },
              offset: Offset(0, 42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 1)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text(tag), Icon(Icons.arrow_drop_down)],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tisArticleMap.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: tisArticleMap[index]["發文日期"] != null
                        ? Card(
                            child: InkWell(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(tisArticleMap[index]["發文日期"]),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Text(tisArticleMap[index]
                                                ["發布者"] ??
                                            "未知"),
                                      ),
                                      Spacer(),
                                      Obx(() => IconButton(
                                          onPressed: () async {
                                            await ArticleSql().setFavorite(
                                                tisArticleMap[index]
                                                    .toString());
                                            favoriteArray[int.parse(
                                                        tisArticleMap[index]
                                                                ["文章編號"]
                                                            .toString()) -
                                                    1] =
                                                await ArticleSql().getFavorite(
                                                    tisArticleMap[index]
                                                        .toString());
                                            setState(() {});
                                          },
                                          icon: favoriteArray[int.parse(
                                                      tisArticleMap[index]
                                                              ["文章編號"]
                                                          .toString()) -
                                                  1]
                                              ? Icon(Icons.favorite)
                                              : Icon(Icons.favorite_border)))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        tisArticleMap[index]["主分類"],
                                        style: TextStyle(
                                            color: Color(0xff1D1Ac7),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Text(
                                            tisArticleMap[index]["子分類"] ?? ""),
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
                                  commentArray: commentArray[int.parse(
                                          tisArticleMap[index]["文章編號"]
                                              .toString()) -
                                      1],
                                ));
                              },
                            ),
                          )
                        : Container(),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {
          if (isLogin.value) {
            if (tag != "全部") {
              newTag.value = tag;
            } else {
              newTag.value = "全國技能競賽";
            }
            key.currentState!.showBottomSheet((context) => Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Color(0xff9BC4EAFF),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: PopupMenuButton(
                                itemBuilder: (BuildContext context) {
                                  return [
                                    for (var i = 1; i < allTags.length; i++)
                                      PopupMenuItem(
                                        child: Text(allTags[i].toString()),
                                        value: allTags[i].toString(),
                                      )
                                  ];
                                },
                                onSelected: (value) {
                                  setState(() {
                                    newTag.value = value!.toString();
                                    print(newTag);
                                  });
                                },
                                offset: Offset(0, 42),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.black, width: 1)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Obx(() => Text(newTag.value)),
                                        Icon(Icons.arrow_drop_down)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: subTypeController,
                                decoration: InputDecoration(hintText: "子分類"),
                              ),
                            ),
                          ],
                        ),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(hintText: "標題"),
                        ),
                        TextField(
                          controller: contextController,
                          decoration: InputDecoration(hintText: "內文"),
                        ),
                        TextField(
                          controller: linkTextController,
                          decoration: InputDecoration(hintText: "連結文字"),
                        ),
                        TextField(
                          controller: linkController,
                          decoration: InputDecoration(hintText: "連結"),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  Get.back();
                                  setState(() async {
                                    var jsonMap = {};
                                    var now = DateTime.now();
                                    jsonMap["發文日期"] =
                                        "${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year.toString()}";
                                    jsonMap["主分類"] = newTag.value;
                                    jsonMap["子分類"] = subTypeController.text;
                                    jsonMap["標題"] = titleController.text;
                                    jsonMap["連結顯示文字"] = linkTextController.text;
                                    jsonMap["連結"] = linkController.text;
                                    jsonMap["文章內容"] = contextController.text;
                                    jsonMap["文章編號"] = articleMap.length + 1;
                                    jsonMap["發布者"] = await Sql().getName();
                                    articleMap.add(jsonMap);
                                    commentArray
                                        .add(List.empty(growable: true));
                                    if (newTag == tag) {
                                      tisArticleMap.add(jsonMap);
                                    }
                                    setState(() {});
                                  });
                                },
                                child: Text("送出")),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text("取消")),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ));
          } else {
            key.currentState!.showBottomSheet((context) => Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Color(0xff9BC4EAFF),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "登入",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(hintText: "帳號"),
                        ),
                        Obx(() => TextField(
                          controller: pwdController,
                          obscureText: !showPwd.value,
                          decoration: InputDecoration(
                              hintText: "密碼",
                              suffix: Obx(() => IconButton(
                                icon: Icon(showPwd.value
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  showPwd.value = !showPwd.value;
                                  setState(() {});
                                },
                              ))),
                        )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  if (await Sql().login(emailController.text,
                                      pwdController.text)) {
                                    Get.back();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("登入成功")));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("登入失敗")));
                                  }
                                },
                                child: Text("送出")),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text("取消")),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                    key.currentState!
                                        .showBottomSheet((context) => Container(
                                              width: double.infinity,
                                              decoration: const BoxDecoration(
                                                  color: Color(0xff9BC4EAFF),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  20),
                                                          topRight:
                                                              Radius.circular(
                                                                  20))),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      "註冊",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20),
                                                    ),
                                                    TextField(
                                                      controller:
                                                          emailController,
                                                      decoration:
                                                          const InputDecoration(
                                                              hintText: "帳號"),
                                                    ),
                                                    Obx(() => TextField(
                                                      controller: pwdController,
                                                      obscureText: !showPwd.value,
                                                      decoration:
                                                      InputDecoration(
                                                          hintText: "密碼",
                                                          suffix: Obx(() => IconButton(
                                                            icon: Icon(showPwd.value
                                                                ? Icons
                                                                .visibility_off
                                                                : Icons
                                                                .visibility),
                                                            onPressed: () {
                                                              showPwd.value = !showPwd.value;
                                                              setState(() {});
                                                            },
                                                          ),)
                                                      ),
                                                    )),
                                                    TextField(
                                                      controller:
                                                          nameController,
                                                      decoration:
                                                          const InputDecoration(
                                                              hintText: "暱稱"),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              if (!GetUtils.isEmail(
                                                                  emailController
                                                                      .text)) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(SnackBar(
                                                                        content:
                                                                            Text("Email格式錯誤")));
                                                                return;
                                                              }
                                                              var pwd =
                                                                  pwdController
                                                                      .text;
                                                              if (!((pwd.contains(RegExp("[A-Z]")) &&
                                                                      pwd.contains(
                                                                          RegExp(
                                                                              "[a-z]")) &&
                                                                      pwd.contains(
                                                                          RegExp(
                                                                              "[\\W]")) &&
                                                                      pwd.contains(
                                                                          RegExp(
                                                                              "[0-9]"))) ||
                                                                  (pwd.length >
                                                                          8 &&
                                                                      pwd.length <
                                                                          15))) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(SnackBar(
                                                                        content:
                                                                            Text("密碼格式錯誤")));
                                                                return;
                                                              }
                                                              if (await Sql().insert(
                                                                  emailController
                                                                      .text,
                                                                  pwdController
                                                                      .text,
                                                                  nameController
                                                                      .text)) {
                                                                Get.back();
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(SnackBar(
                                                                        content:
                                                                            Text("註冊成功")));
                                                              } else {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(SnackBar(
                                                                        content:
                                                                            Text("註冊失敗")));
                                                              }
                                                            },
                                                            child: Text("送出")),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: ElevatedButton(
                                                              onPressed: () {
                                                                Get.back();
                                                              },
                                                              child:
                                                                  Text("取消")),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ));
                                  },
                                  child: Text("註冊")),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ));
          }
        },
      ),
    );
  }
}
