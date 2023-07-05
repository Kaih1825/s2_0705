import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';
import 'SqlMethods.dart';

class NewsInfo extends StatefulWidget {
  final Map jsonText;
  final List commentArray;

  const NewsInfo({Key? key, required this.jsonText, required this.commentArray})
      : super(key: key);

  @override
  State<NewsInfo> createState() => _NewsInfoState();
}

class _NewsInfoState extends State<NewsInfo> {
  GlobalKey<ScaffoldState> key=GlobalKey();
  var commentController=TextEditingController();
  var emailController=TextEditingController();
  var pwdController=TextEditingController();
  var nameController=TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSp();
  }

  void getSp()async{
    var sp=await SharedPreferences.getInstance();
    isLogin.value=sp.getBool("isLogin")??false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {
          if(isLogin.value){
            key.currentState!.showBottomSheet((context) =>Container(
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
                    TextField(controller: commentController,decoration: InputDecoration(
                        hintText: "回應內容"
                    ),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(onPressed: ()async{
                          var jsonMap={};
                          jsonMap["文章編號"]=widget.jsonText["文章編號"];
                          var now=DateTime.now();
                          jsonMap["回應日期"]="${now.month.toString().padLeft(2,'0')}/${now.day.toString().padLeft(2,'0')}/${now.year.toString()}";
                          jsonMap["發布者"]=await Sql().getName();
                          jsonMap["回應內容"]=commentController.text;
                          widget.commentArray.add(jsonMap);
                          Get.back();
                          setState(() {});
                        }, child: Text("送出")),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ElevatedButton(onPressed: (){
                            Get.back();
                          }, child: Text("取消")),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ));
          }else{
            key.currentState!.showBottomSheet((context) =>Container(
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
                    Text("登入",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                    TextField(controller: emailController,decoration: InputDecoration(
                        hintText: "帳號"
                    ),),
                    TextField(controller: pwdController,decoration: InputDecoration(
                        hintText: "密碼"
                    ),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(onPressed: ()async{
                          if(await Sql().login(emailController.text, pwdController.text)){
                            Get.back();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("登入成功")));
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("登入失敗")));
                          }
                        }, child: Text("送出")),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ElevatedButton(onPressed: (){
                            Get.back();
                          }, child: Text("取消")),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ElevatedButton(onPressed: (){
                            Get.back();
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
                                    const Text("註冊",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                    TextField(controller: emailController,decoration:const InputDecoration(
                                        hintText: "帳號"
                                    ),),
                                    TextField(controller: pwdController,decoration:const InputDecoration(
                                        hintText: "密碼"
                                    ),),
                                    TextField(controller: nameController,decoration:const InputDecoration(
                                        hintText: "暱稱"
                                    ),),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(onPressed: ()async{
                                          if(!GetUtils.isEmail(emailController.text)){
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email格式錯誤")));
                                            return;
                                          }
                                          var pwd=pwdController.text;
                                          if(!((pwd.contains(RegExp("[A-Z]")) &&
                                              pwd.contains(RegExp("[a-z]")) &&
                                              pwd.contains(RegExp("[\\W]")) &&
                                              pwd.contains(RegExp("[0-9]"))) ||
                                              (pwd.length > 8 &&
                                                  pwd.length < 15))){
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("密碼格式錯誤")));
                                            return;
                                          }
                                          if(await Sql().insert(emailController.text, pwdController.text, nameController.text)){
                                            Get.back();
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("註冊成功")));
                                          }else{
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("註冊失敗")));
                                          }
                                        }, child: Text("送出")),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: ElevatedButton(onPressed: (){
                                            Get.back();
                                          }, child: Text("取消")),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ));
                          }, child: Text("註冊")),
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
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "發布者:" + (widget.jsonText["發布者"] ?? "未知"),
                          style: TextStyle(fontSize: 18),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            widget.jsonText["發文日期"],
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          widget.jsonText["主分類"],
                          style: TextStyle(
                            color: Color(0xff1D1Ac7),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            widget.jsonText["子分類"] ?? "",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      widget.jsonText["標題"],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.jsonText["文章內容"] ?? "",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        var url = widget.jsonText["連結"];
                        if (url != null) {
                          launchUrl(Uri.parse(url));
                        }
                      },
                      child: Text(widget.jsonText["連結顯示文字"] ?? "",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 15,
                          )),
                    ),
                  ],
                ),
              ),
              for (var i in widget.commentArray)
                Card(
                  color: Colors.blueGrey.shade200,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "回應者:" + (i["發布者"] ?? "未知"),
                              style: TextStyle(fontSize: 18),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                i["回應日期"],
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          i["回應內容"] ?? "",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            var url = i["連結"];
                            if (url != null) {
                              launchUrl(Uri.parse(url));
                            }
                          },
                          child: Text(i["連結顯示文字"] ?? "",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 15,
                              )),
                        )
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      )),
    );
  }
}
