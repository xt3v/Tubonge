import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:tubonge/auth.dart';
import 'package:tubonge/home_page.dart';
import 'dart:convert';

class SplashScreen extends StatefulWidget{

  @override
  SplashState createState() => SplashState();

}


class SplashState extends State<SplashScreen>{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //check if there are user details
    SharedPreferences.getInstance().then((pref){
        if(pref.getString("user") != null){
           if(pref.getString("chats") == null){
             List<Map<String,String>> chats = List();
             var o = {
               "name": "Tom",
               "avatar" : "http://www.beautifulhameshablog.com/wp-content/uploads/2017/09/Beautiful-girls-in-India-Alia-Bhatt-beautiful-indian-girl-image-beautiful-girl-image-indian-girls-photos-indian-girls-images.jpg",
               "id" : "12",
               "last" : "The test"
             };
             chats.add(o);
             var p = {
               "name": "Jane",
               "avatar" : "http://www.beautifulhameshablog.com/wp-content/uploads/2017/09/Beautiful-girls-in-India-Alia-Bhatt-beautiful-indian-girl-image-beautiful-girl-image-indian-girls-photos-indian-girls-images.jpg",
               "id" : "11",
               "last" : "The test two"
             };
             chats.add(p);

             pref.setString("chats", json.encode(chats));
           }


           print("logged in nigg!!");
           var user = pref.getString("user");
           var pass = pref.getString("password");
            
           print("User name = $user .. password = $pass");
           
           Auth().signIn(user, pass).then( (user){
               if(user != null){
                 Timer(Duration(milliseconds: 200),()=> Navigator.pushAndRemoveUntil(
                   context,
                   MaterialPageRoute(
                     builder: (context) => HomePage(user: user),
                   ),
                     (Route<dynamic> r) => false
                 ));
               }
           }).catchError((error){
             Fluttertoast.showToast(
               msg: error.toString(),
               toastLength: Toast.LENGTH_SHORT,
               gravity: ToastGravity.BOTTOM,
               timeInSecForIos: 1,
               backgroundColor: Colors.white,
               textColor: Colors.black,
             );
           });
           
        }else{
           Timer(
             Duration(seconds: 2), 
             () => Navigator.of(context).pushNamedAndRemoveUntil("/Login", (Route<dynamic> route)=>false)
            );
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor:  Theme.of(context).primaryColor,
      body: Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[
             Icon(Icons.chat_bubble,size: 60,color: Colors.greenAccent,),
             Text("Tubonge",style: TextStyle(fontStyle: FontStyle.italic,fontSize: 20,fontWeight: FontWeight.bold,color: Theme.of(context).secondaryHeaderColor)),
             Padding(
               padding: EdgeInsets.only(top: 100),
             ),
             CircularProgressIndicator()
           ],
         ),
      ),
    );
  }
}