import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'HomeScreen.dart';

class Sql {
  Database? database;

  getDB() async {
    database ??= await openDatabase("db.db", version: 1);
    try{
      database!.execute(
          "CREATE TABLE User(account TEXT PRIMARY KEY,pwd TEXT,name TEXT)");
    }catch(ex){}
    return database;
  }

  Future<bool> insert(account,pwd,name)async{
    Database db=await getDB();
    List get=await db.rawQuery("SELECT * FROM User WHERE account='$account'");
    if(get.length!=0){
      return false;
    }
    try{
      db.execute("INSERT INTO User(account,pwd,name) VALUES('$account','$pwd','$name')");
      var sp=await SharedPreferences.getInstance();
      sp.setBool("isLogin", true);
      sp.setString("email", account);
      isLogin.value=true;
      return true;
    }catch(ex){
      return false;
    }
  }

  Future<bool> login(account,pwd)async{
    Database db=await getDB();
    List get=await db.rawQuery("SELECT * FROM User WHERE account='$account'");
    if(get.length==0){
      return false;
    }
    else{
      if(get[0]["pwd"]==pwd){
        isLogin.value=true;
        var sp=await SharedPreferences.getInstance();
        sp.setBool("isLogin", true);
        sp.setString("email", account);
        name.value=await Sql().getName();
        return true;
      }
      return false;
    }
  }

  Future<String> getName()async{
    var sp=await SharedPreferences.getInstance();
    var email=sp.getString("email")??"non";

    Database db=await getDB();
    var get=await db.rawQuery("SELECT * FROM User WHERE account='$email'");
    if(get.isNotEmpty){
      return ((get[0]["name"] ?? "Non").toString());
    }else{
      return "";
    }
  }
}

class ArticleSql{
  Database? database;
  getDB()async{
    database ??= await openDatabase("db.db",version: 1);
    try{
      database!.execute("CREATE TABLE article(json TEXT PRIMARY KEY)");
    }catch(ex){}
    return database!;
  }

  Future<bool> setFavorite(json)async{
    Database db=await getDB();
    var get=await db.rawQuery("SELECT * FROM article WHERE json='${json.toString().replaceAll("'", "''")}'");
    if(get.length==0){
      db.execute("INSERT INTO article(json) VALUES('${json.toString().replaceAll("'", "''")}')");
      return true;
    }else{
      db.execute("DELETE FROM article WHERE json='${json.toString().replaceAll("'", "''")}'");
      return false;
    }
  }

  Future<bool> getFavorite(json)async{
    Database db=await getDB();
    var get=await db.rawQuery("SELECT * FROM article WHERE json='${json.toString().replaceAll("'", "''")}'");
    if(get.length==0){
      return false;
    }else{
      return true;
    }
  }
}
