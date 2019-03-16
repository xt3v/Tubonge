import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:tubonge/auth.dart';
import 'package:tubonge/home_page.dart';
import 'dart:convert';

import 'package:tubonge/user.dart';

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
           var username = pref.getString("user");
           var pass = pref.getString("password");
           var uuid = pref.getString("uuid");
           print("User name = $username .. password = $pass");

           User user = new User();
           user.username = username;
           user.password = pass;
           user.uuid = uuid;
           Auth.user = user;
           Timer(Duration(milliseconds: 100),()=> Navigator.pushAndRemoveUntil(
               context,
               MaterialPageRoute(
                 builder: (context) => HomePage(user: user),
               ),
                   (Route<dynamic> r) => false
           ));
           
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